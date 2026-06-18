-- ==============================================================================
-- BULK DATA GENERATOR cho KawaiiEnglish
-- ------------------------------------------------------------------------------
-- Sinh khoi luong lon du lieu dua tren cau truc cua Test_data.sql, ton trong
-- day du Trigger (auto assign class, cham diem) va Stored Procedure (CLP, level up).
--
-- Cach dung:
--   1) Nap file nay de tao cac procedure sinh du lieu.
--   2) Goi:  CALL sp_generate_bulk(extra_teachers, classes_per_level,
--                                  lessons, students, max_attempts, q_per_quiz);
--      Vi du: CALL sp_generate_bulk(16, 3, 30, 500, 3, 4);
--
-- Du lieu duoc THEM (append) vao du lieu hien co, khong xoa du lieu cu.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Sinh MASTER DATA: teachers, classes, lessons, grammar, vocab, quizzes, questions
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_gen_master;
DELIMITER //
CREATE PROCEDURE sp_gen_master(
    IN p_extra_teachers INT,
    IN p_classes_per_level INT,
    IN p_lessons INT,
    IN p_q_per_quiz INT
)
BEGIN
    DECLARE i INT;
    DECLARE j INT;
    DECLARE lv INT;
    DECLARE v_cefr VARCHAR(4);
    DECLARE v_teacher INT;
    DECLARE v_cnt INT;
    DECLARE v_lesson INT;
    DECLARE v_quiz INT;
    DECLARE v_poss INT;
    DECLARE v_maxt INT;

    -- Teachers
    SET i = 1;
    WHILE i <= p_extra_teachers DO
        INSERT INTO Teacher(Full_Name, Email)
        VALUES (CONCAT('GV ', i, ' ', ELT(1+FLOOR(RAND()*5),'Nguyen','Tran','Le','Pham','Vo')),
                CONCAT('gv', i, '_', FLOOR(RAND()*9999), '@ke.edu.vn'));
        SET i = i + 1;
    END WHILE;

    SELECT MAX(Teacher_ID) INTO v_maxt FROM Teacher;

    -- Classes: bo sung moi cap CEFR cho du p_classes_per_level lop
    SET lv = 1;
    WHILE lv <= 6 DO
        SET v_cefr = ELT(lv,'A1','A2','B1','B2','C1','C2');
        SELECT COUNT(*) INTO v_cnt FROM Classes WHERE CEFR_Level = v_cefr;
        WHILE v_cnt < p_classes_per_level DO
            SET v_teacher = 1 + FLOOR(RAND()*v_maxt);
            INSERT INTO Classes(Class_Name, No_of_Students, Teacher_ID, CEFR_Level)
            VALUES (CONCAT('Lop ', v_cefr, ' #', v_cnt+1), 0, v_teacher, v_cefr);
            SET v_cnt = v_cnt + 1;
        END WHILE;
        SET lv = lv + 1;
    END WHILE;

    -- Lessons + Grammar + Vocabulary + Quiz + Questions
    SET i = 1;
    WHILE i <= p_lessons DO
        SET lv = 1 + ((i-1) % 6);
        SET v_teacher = 1 + FLOOR(RAND()*v_maxt);
        INSERT INTO Lessons(Level_Required, Title, Teacher_ID)
        VALUES (lv, CONCAT('Bai hoc #', i, ' (Level ', lv, ')'), v_teacher);
        SET v_lesson = LAST_INSERT_ID();

        INSERT INTO Grammar_Structures(Lesson_ID, Content, Example)
        VALUES (v_lesson, CONCAT('Cau truc ngu phap cua bai ', i), 'Vi du minh hoa.');

        INSERT INTO Vocabulary(Content, Meaning, Example, Lesson_ID) VALUES
            (CONCAT('word', i, 'a'), 'nghia a', 'vi du a', v_lesson),
            (CONCAT('word', i, 'b'), 'nghia b', 'vi du b', v_lesson);

        SET v_poss = 100 + lv*100;   -- Level1=200 ... Level6=700
        INSERT INTO Quizzes(Lesson_ID, Minimum_Pass_Score, Possible_Points)
        VALUES (v_lesson, GREATEST(1, FLOOR(v_poss*0.4)), v_poss);
        SET v_quiz = LAST_INSERT_ID();

        SET j = 1;
        WHILE j <= p_q_per_quiz DO
            INSERT INTO Questions(Quiz_ID, Content, Correct_Answer)
            VALUES (v_quiz, CONCAT('Quiz ', v_quiz, ' - Cau hoi ', j), CONCAT('ans', v_quiz, '_', j));
            SET j = j + 1;
        END WHILE;

        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- ------------------------------------------------------------------------------
-- 2. Sinh HOC SINH (kich hoat trigger trg_auto_assign_class)
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_gen_students;
DELIMITER //
CREATE PROCEDURE sp_gen_students(IN p_n INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_cefr VARCHAR(4);
    WHILE i <= p_n DO
        -- Lech ve cac cap thap cho giong thuc te (A1/A2 nhieu hon)
        SET v_cefr = ELT(1+FLOOR(RAND()*RAND()*6),'A1','A2','B1','B2','C1','C2');
        INSERT INTO Students(Full_Name, Email, Assessment_CEFR)
        VALUES (CONCAT(ELT(1+FLOOR(RAND()*5),'Nguyen','Tran','Le','Pham','Vo'), ' HS', i),
                CONCAT('stu', i, '_', FLOOR(RAND()*9999), '@ke.vn'),
                v_cefr);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- ------------------------------------------------------------------------------
-- 3. Lam 1 LUOT THI hoan chinh cho 1 hoc sinh tren 1 quiz
--    (submit DU het cau hoi -> attempt COMPLETED -> cham diem + xet level up)
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_do_attempt;
DELIMITER //
CREATE PROCEDURE sp_do_attempt(IN p_stu INT, IN p_quiz INT, IN p_acc DOUBLE)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_qid INT;
    DECLARE v_correct VARCHAR(50);
    DECLARE cur CURSOR FOR
        SELECT Question_ID, Correct_Answer FROM Questions
        WHERE Quiz_ID = p_quiz ORDER BY Question_ID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_qid, v_correct;
        IF done THEN LEAVE read_loop; END IF;
        IF RAND() < p_acc THEN
            INSERT INTO Student_Submissions(Student_ID, Student_ANS, Question_ID)
            VALUES (p_stu, v_correct, v_qid);                 -- tra loi DUNG
        ELSE
            INSERT INTO Student_Submissions(Student_ID, Student_ANS, Question_ID)
            VALUES (p_stu, CONCAT(v_correct, '_x'), v_qid);   -- tra loi SAI
        END IF;
    END LOOP;
    CLOSE cur;
END //
DELIMITER ;

-- ------------------------------------------------------------------------------
-- 4. Sinh nhieu LUOT THI cho cac hoc sinh moi (Student_ID >= p_from)
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_gen_attempts;
DELIMITER //
CREATE PROCEDURE sp_gen_attempts(IN p_max_attempts INT, IN p_from INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_stu INT;
    DECLARE n INT;
    DECLARE a INT;
    DECLARE v_quiz INT;
    DECLARE v_acc DOUBLE;
    DECLARE cur CURSOR FOR SELECT Student_ID FROM Students WHERE Student_ID >= p_from;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    sloop: LOOP
        FETCH cur INTO v_stu;
        IF done THEN LEAVE sloop; END IF;

        SET n   = 1 + FLOOR(RAND() * p_max_attempts);  -- 1..p_max_attempts luot
        SET v_acc = 0.35 + RAND() * 0.65;              -- nang luc moi hoc sinh khac nhau
        SET a = 0;
        WHILE a < n DO
            SELECT Quiz_ID INTO v_quiz FROM Quizzes ORDER BY RAND() LIMIT 1;
            CALL sp_do_attempt(v_stu, v_quiz, LEAST(1.0, v_acc + a*0.1)); -- thi lai tot dan
            SET a = a + 1;
        END WHILE;
    END LOOP;
    CLOSE cur;
END //
DELIMITER ;

-- ------------------------------------------------------------------------------
-- 5. ORCHESTRATOR: goi 1 lenh sinh tat ca
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_generate_bulk;
DELIMITER //
CREATE PROCEDURE sp_generate_bulk(
    IN p_extra_teachers INT,
    IN p_classes_per_level INT,
    IN p_lessons INT,
    IN p_students INT,
    IN p_max_attempts INT,
    IN p_q_per_quiz INT
)
BEGIN
    DECLARE start_stu INT;
    CALL sp_gen_master(p_extra_teachers, p_classes_per_level, p_lessons, p_q_per_quiz);
    SELECT COALESCE(MAX(Student_ID), 0) + 1 INTO start_stu FROM Students;
    CALL sp_gen_students(p_students);
    CALL sp_gen_attempts(p_max_attempts, start_stu);
END //
DELIMITER ;
