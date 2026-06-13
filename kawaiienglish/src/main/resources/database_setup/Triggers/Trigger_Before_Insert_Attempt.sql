drop trigger if exists trg_before_insert_atm;

DELIMITER //
create trigger trg_before_insert_atm
before insert 
on student_submissions
for each row
begin 
    declare this_quiz_id INT;
    declare this_attempt_id INT;
    declare highest_last_attempt INT;
    declare this_possible_points INT;
    declare this_amount_questions INT;
    DECLARE v_correct_ans VARCHAR(50);
    select quiz_id into this_quiz_id from questions where questions.`Question_ID` = NEW.`Question_ID`;
    select attempt_id into this_attempt_id from attempts where attempts.`Student_ID` = NEW.`Student_ID`
        and attempts.`Quiz_ID` = this_quiz_id and attempts.`Status` = 'IN_PROGRESS';
    
    if this_attempt_id is null THEN
        select coalesce(max(`Total_Points`), 0) into highest_last_attempt
        from attempts
        where attempts.`Student_ID` = NEW.`Student_ID`
            and attempts.`Quiz_ID` = this_quiz_id and attempts.`Status` = 'COMPLETED';
        select quizzes.`Possible_Points`, count(questions.`Question_ID`) into this_possible_points, this_amount_questions
        from quizzes
        join questions on quizzes.`Quiz_ID` = questions.`Quiz_ID`
        where quizzes.`Quiz_ID` = this_quiz_id
        group by quizzes.`Possible_Points`;

        insert into attempts(`Total_Points`, `Total_Points_Last`, `Quiz_ID`, `Student_ID`, `Amount_Questions`, `Possible_Points`, `Status`)
        values(0, highest_last_attempt, this_quiz_id, NEW.`Student_ID`, this_amount_questions, this_possible_points, 'IN_PROGRESS');

        select LAST_INSERT_ID() into this_attempt_id;
        

    end if;
    set NEW.`Attempt_ID` = this_attempt_id;
    SELECT Correct_Answer INTO v_correct_ans 
    FROM Questions 
    WHERE Question_ID = NEW.Question_ID;

    IF NEW.Student_ANS = v_correct_ans THEN
        SET NEW.Is_Correct = 1;
    ELSE
        SET NEW.Is_Correct = 0;
    END IF;
end //
DELIMITER ;

