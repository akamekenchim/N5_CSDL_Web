USE n5_kawaii_english;

-- ==============================================================================
-- BUOC 0: DON DEP SACH SE DATABASE (BAO VE RANG BUOC KHOA NGOAI)
-- ==============================================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Student_Submissions;
TRUNCATE TABLE Attempts;
TRUNCATE TABLE Questions;
TRUNCATE TABLE Vocabulary;
TRUNCATE TABLE Grammar_Structures;
TRUNCATE TABLE Quizzes;
TRUNCATE TABLE Lessons;
TRUNCATE TABLE Students;
TRUNCATE TABLE Classes;
TRUNCATE TABLE Levels;
TRUNCATE TABLE Teacher;
SET FOREIGN_KEY_CHECKS = 1;

-- ==============================================================================
-- BUOC 1: NAP DU LIEU TINH (MASTER DATA TIEU CHUAN)
-- ==============================================================================

-- 1. Bang Levels: Nap chuan 6 cap do CEFR 
INSERT INTO Levels (Level, CLP_Required, Description) VALUES
(1, 100, 'A1'),
(2, 250, 'A2'),
(3, 500, 'B1'),
(4, 800, 'B2'),
(5, 1200, 'C1'),
(6, 20000, 'C2');

-- 2. Bang Teacher: Doi ngu giang vien
INSERT INTO Teacher (Full_Name, Email) VALUES
('Tran Binh Minh', 'minh@hust.edu.vn'),
('Nguyen Gia Anh', 'anh@hust.edu.vn'),
('Le Tuan Kiet', 'kiet@hust.edu.vn'),
('Pham Bao Ngoc', 'ngoc@hust.edu.vn');

-- 3. Bang Classes: (KHONG NHAP No_of_Students - Trigger tu dem)
INSERT INTO Classes (Class_Name, No_of_Students, Teacher_ID, CEFR_Level) VALUES
('Lop A1 Co ban - Sang', 0, 1, 'A1'),
('Lop A1 Co ban - Toi', 0, 2, 'A1'), -- Lop A1 thu 2 de test thuat toan can bang si so
('Lop A2 Tien Trung cap - Toi', 0, 2, 'A2'),
('Lop B1 Trung cap - Cuoi tuan', 0, 3, 'B1'),
('Lop B2 Tren Trung cap - Cap toc', 0, 4, 'B2'),
('Lop C1 Cao cap - Chuyen sau', 0, 1, 'C1'),
('Lop C2 Thanh thao - Tinh hoa', 0, 2, 'C2');

-- 4. Bang Lessons: Bai giang theo tung cap do
INSERT INTO Lessons (Level_Required, Title, Teacher_ID) VALUES
(1, 'Bai 1: Dong tu To Be & Dai tu Nhan xung', 1),
(1, 'Bai 2: Thi Hien tai Don', 1),
(2, 'Bai 3: Thi Qua khu Don vs Hien tai Hoan thanh', 2),
(3, 'Bai 4: Cau dieu kien (Loai 1 & 2)', 3),
(1, 'DAC BIET: Bai Kiem tra Nang luc (Toan bo Cap do)', 4); -- Bai test nhay coc

-- 5. Bang Grammar_Structures
INSERT INTO Grammar_Structures (Lesson_ID, Content, Example) VALUES
(1, 'S + am/is/are + Noun/Adjective', 'Co ay la mot hoc sinh.'),
(2, 'S + V(s/es) cho ngoi thu 3 so it', 'Anh ay di hoc moi ngay.'),
(3, 'Hien tai hoan thanh: S + have/has + PII', 'Toi da song o day duoc 5 nam.'),
(4, 'Cau dieu kien Loai 2: If + S + V-ed, S + would + V', 'Neu toi la ban, toi se hoc cham hon.');

-- 6. Bang Vocabulary
INSERT INTO Vocabulary (Content, Meaning, Example, Lesson_ID) VALUES
('Student', 'Hoc sinh, sinh vien', 'Toi la mot sinh vien dai hoc.', 1),
('Always', 'Luon luon', 'Co ay luon thuc day som.', 2),
('Experience', 'Kinh nghiem, trai nghiem', 'Day la mot trai nghiem tuyet voi.', 3),
('Hypothetical', 'Gia dinh, vien canh', 'Hay xem xet mot tinh huong gia dinh.', 4);

-- 7. Bang Quizzes: De thi
INSERT INTO Quizzes (Lesson_ID, Minimum_Pass_Score, Possible_Points) VALUES 
(1, 10, 120),    -- Quiz 1 (Unit 1): 3 cau, Quy 120d
(3, 15, 200),    -- Quiz 2 (Unit 3): 4 cau, Quy 200d
(4, 20, 300),    -- Quiz 3 (Unit 4): 2 cau, Quy 300d
(5, 50, 1000);   -- Quiz 4 (Placement Test): 5 cau, Quy 1000d (Dung de test nhay cap lien hoan)

-- 8. Bang Questions: 
-- Quiz 1 (ID=1) - 3 cau
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES 
(1, 'Dien vao cho trong: I ___ a student.', 'am'),
(1, 'Dien vao cho trong: They ___ happy.', 'are'),
(1, 'Tu trai nghia cua "Big" la gi?', 'small');

-- Quiz 2 (ID=2) - 4 cau
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES 
(2, 'Dien vao cho trong: I have ___ to Paris twice.', 'been'),
(2, 'Qua khu cua "Go" la gi?', 'went'),
(2, 'Tu dong nghia cua "Quick"?', 'fast'),
(2, 'Tu trai nghia cua "Heavy"?', 'light');

-- Quiz 3 (ID=3) - 2 cau
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES 
(3, 'If it rains, I ___ stay at home.', 'will'),
(3, 'If I had a million dollars, I ___ buy a car.', 'would');

-- Quiz 4 (ID=4) - PLACEMENT TEST - 5 cau
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES 
(4, 'Co ban (A1): She ___ a doctor.', 'is'),
(4, 'Tien Trung cap (A2): I ___ my homework yesterday.', 'did'),
(4, 'Trung cap (B1): I have ___ reading this book for 2 hours.', 'been'),
(4, 'Tren Trung cap (B2): Hardly ___ I reached the station when the train left.', 'had'),
(4, 'Cao cap (C1): It is imperative that he ___ here tomorrow.', 'be');


-- ==============================================================================
-- BUOC 2: TAO HOC SINH (KICH HOAT TRIGGER trg_auto_assign_class)
-- ==============================================================================
-- KHONG NHAP Class_ID, Level, Current_Level_Progress, Accuracy.
INSERT INTO Students (Full_Name, Email, Assessment_CEFR) VALUES
('Gia Anh', 'giaanh@hust.edu.vn', 'A1'),         -- Vao lop A1 thu nhat
('Binh Minh', 'binhminh@hust.edu.vn', 'A1'),       -- Vao lop A1 thu hai
('Tuan Kiet', 'kiet@hust.edu.vn', 'A1'),           -- Vao lop A1 thu nhat
('Hoang Nam', 'nam@hust.edu.vn', 'A2'),
('Mai Phuong', 'phuong@hust.edu.vn', 'A2'),
('Thanh Tung', 'tung@hust.edu.vn', 'B1'),
('Bao Ngoc', 'ngoc@hust.edu.vn', 'B2');


-- ==============================================================================
-- BUOC 3: KICH BAN THI & CHAM DIEM (DOMINO TRIGGER & STORED PROCEDURE)
-- ==============================================================================

-- ---------------------------------------------------------
-- KICH BAN A: Gia Anh (ID=1) lam bai binh thuong.
-- Lam Quiz 1 (3 cau). Quy diem: 120. Dung 3/3 = 120d.
-- Moc A1 can 100d -> Du 20d, len Level 2 (A2).
-- ---------------------------------------------------------
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES 
(1, 'am', 1), 
(1, 'are', 2), 
(1, 'small', 3);

-- ---------------------------------------------------------
-- KICH BAN B: Binh Minh (ID=2) lam sai, rot dai.
-- Lam Quiz 1. Dung 1/3 cau. Nhieu nhat nhan duoc 40d.
-- Khong du 100d -> Van o Level 1, thong ke Accuracy se tinh dung ty le.
-- ---------------------------------------------------------
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES 
(2, 'am', 1),   -- Dung
(2, 'are', 2),   -- Sai
(2, 'tiny', 3);  -- Sai

-- ---------------------------------------------------------
-- KICH BAN C: Hoang Nam (ID=4) dang thi do dang.
-- Lam Quiz 2 (4 cau). Moi lam 2 cau.
-- Trigger sinh Attempt voi Status 'IN_PROGRESS', diem chua duoc cong.
-- ---------------------------------------------------------
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES 
(4, 'been', 4), 
(4, 'went', 5);

-- ---------------------------------------------------------
-- KICH BAN D (DINH CAO): Tuan Kiet (ID=3) thi Placement Test.
-- Tuan Kiet dang o Level 1 (A1).
-- Lam Quiz 4 (5 cau). Quy diem 1000. Lam dung 5/5 -> Nhan 1000 diem.
-- Vong lap WHILE hoat dong:
--   + Nhan 1000d. Dang Lvl 1 (Can 100d). Tru 100 -> Du 900 -> Lvl 2.
--   + Dang Lvl 2 (Can 250d). Tru 250 -> Du 650 -> Lvl 3.
--   + Dang Lvl 3 (Can 500d). Tru 500 -> Du 150 -> Lvl 4.
--   + Dang Lvl 4 (Can 800d). 150 < 800 -> Dung lap.
-- Ket qua cuoi cung: Tuan Kiet nhay tu Level 1 len Level 4, du 150 diem, CEFR tu doi thanh 'B2'.
-- ---------------------------------------------------------
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES 
(3, 'is', 10), 
(3, 'did', 11), 
(3, 'been', 12), 
(3, 'had', 13), 
(3, 'be', 14);


select * from v_leaderboard;
SELECT * FROM v_lesson_catalog;
-- Xem toan bo cau hoi cua bai thi so 1 (Bai thi To Be)
SELECT * FROM v_quiz_details WHERE Quiz_ID = 1;

-- Xem toan bo cau hoi cua bai thi so 4 (Bai thi Placement Test)
SELECT * FROM v_quiz_details WHERE Quiz_ID = 4;

-- Kiem tra thong tin cua Gia Anh (Hoc sinh da thang cap)
SELECT * FROM v_student_dashboard WHERE Student_ID = 1;

-- Kiem tra thong tin cua Binh Minh (Hoc sinh lam sai nhieu)
SELECT * FROM v_student_dashboard WHERE Student_ID = 2;

-- Kiem tra thong tin cua Hoang Nam (Hoc sinh dang lam do dang)
SELECT * FROM v_student_dashboard WHERE Student_ID = 4;
