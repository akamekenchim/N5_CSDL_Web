-- =========================================================
-- 1. TẮT KIỂM TRA KHÓA NGOẠI ĐỂ DỌN DẸP DỮ LIỆU
-- =========================================================
SET FOREIGN_KEY_CHECKS = 0;

-- Làm sạch toàn bộ các bảng (Reset luôn cả AUTO_INCREMENT về 1)
TRUNCATE TABLE Student_Submissions;
TRUNCATE TABLE Attempts;
TRUNCATE TABLE Questions;
TRUNCATE TABLE Quizzes;
TRUNCATE TABLE Vocabulary;
TRUNCATE TABLE Grammar_Structures;
TRUNCATE TABLE Lessons;
TRUNCATE TABLE Students;
TRUNCATE TABLE Classes;
TRUNCATE TABLE Teacher;
TRUNCATE TABLE Levels;

-- =========================================================
-- 2. BẬT LẠI KIỂM TRA KHÓA NGOẠI ĐỂ THÊM DỮ LIỆU CHUẨN
-- =========================================================
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Nạp ngưỡng Level (Dữ liệu tĩnh)
INSERT INTO Levels (Level, CLP_Required, Description) VALUES
(1, 100, 'Beginner'), 
(2, 150, 'Elementary'), 
(3, 200, 'Pre-Intermediate');

-- 2. Nạp Giáo viên và Lớp học
INSERT INTO Teacher (Full_Name, Email) VALUES ('Nguyen Van A', 'teacher@hust.edu.vn');
INSERT INTO Classes (Class_Name, No_of_Students, Teacher_ID, CEFR_Level) VALUES ('IT1_VNJP', 1, 1, 'A1');

-- 3. Nạp Học sinh (Setup ở trạng thái chuẩn bị thăng cấp)
-- Cố tình để Current_Level_Progress = 80 (chỉ cần thêm 20 điểm nữa là lên Level 2)
INSERT INTO Students (Full_Name, Email, Class_ID, Level, Current_Level_Progress, Accuracy, Total_Answered, Total_Correct, Assessment_CEFR)
VALUES ('Gia Anh', 'anh.np@student.hust.edu.vn', 1, 1, 80, 0, 0, 0, 'A1'); 

-- 4. Nạp Bài giảng và Bài Quiz (Điểm tối đa: 60 điểm)
INSERT INTO Lessons (Level_Required, Title, Teacher_ID) VALUES (1, 'Unit 1: Embedded Systems', 1);
INSERT INTO Quizzes (Lesson_ID, Minimum_Pass_Score, Possible_Points) VALUES (1, 1, 60);

-- 5. Nạp Câu hỏi (Gồm 2 câu)
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES
(1, 'What does MCU stand for?', 'Microcontroller Unit'),
(1, 'Which component provides clock signals?', 'Oscillator');

INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) 
VALUES (1, 'Microcontroller Unit', 1);
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) 
VALUES (1, 'Oscillator', 2);
-- Nộp câu 1 (Đúng)
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES (1, 'Microcontroller Unit', 1);
-- Nộp câu 2 (Sai)
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES (1, 'Wrong Answer', 2);