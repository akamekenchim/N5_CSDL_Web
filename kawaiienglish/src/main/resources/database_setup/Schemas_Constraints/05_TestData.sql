SET FOREIGN_KEY_CHECKS = 0;
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
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- 1. NẠP DANH MỤC CƠ BẢN
-- ==========================================
INSERT INTO Levels (Level, CLP_Required, Description) VALUES
(1, 100, 'A1'), (2, 150, 'A1'), 
(3, 200, 'A2'), (4, 250, 'A2'), 
(5, 300, 'B1'), (6, 400, 'B2');

INSERT INTO Teacher (Full_Name, Email) VALUES 
('Nguyễn Phúc Bình Minh', 'minh.np@hust.edu.vn'),
('Trần Thị Oanh', 'oanh.tt@hust.edu.vn'),
('Lê Văn Hùng', 'hung.lv@hust.edu.vn');

-- KHỞI TẠO LỚP HỌC (SĨ SỐ = 0, để Trigger tự cộng)
INSERT INTO Classes (Class_Name, No_of_Students, Teacher_ID, CEFR_Level) VALUES 
('Lớp A1 - Sáng', 0, 1, 'A1'),
('Lớp A1 - Chiều', 0, 2, 'A1'),
('Lớp A2 - Tối', 0, 3, 'A2');

-- ==========================================
-- 2. NẠP HỌC SINH (CHỈ TRUYỀN THÔNG TIN CƠ BẢN - ĐỂ TRIGGER TỰ XẾP LỚP)
-- ==========================================
-- Trigger sẽ tự chia 2 bạn A1 này vào 2 lớp Sáng và Chiều để cân bằng tải
INSERT INTO Students (Full_Name, Email, Assessment_CEFR) VALUES ('Nguyễn Văn Cũ', 'cu.nv@gmail.com', 'A1');
INSERT INTO Students (Full_Name, Email, Assessment_CEFR) VALUES ('Trần Thị Cũ', 'cu.tt@gmail.com', 'A1');

-- Bạn A2 này sẽ tự chui vào lớp Tối, tự gán Level 3 (Sàn của A2), các điểm số tự gán = 0
INSERT INTO Students (Full_Name, Email, Assessment_CEFR) VALUES ('Lê Văn Luyện', 'luyen.lv@gmail.com', 'A2');

-- [BƯỚC CHUẨN BỊ MÔI TRƯỜNG MÔ PHỎNG]
-- Để test tính năng "Nhảy cấp" ở Kịch bản 4, ta cần giả lập bạn Luyện đã học một thời gian và có sẵn 190 điểm.
-- Ta dùng lệnh UPDATE (bỏ qua Trigger INSERT) để setup trạng thái này:
UPDATE Students 
SET Current_Level_Progress = 190, Total_Answered = 30, Total_Correct = 15, Accuracy = 0.5 
WHERE Full_Name = 'Lê Văn Luyện';

-- ==========================================
-- 3. NẠP HỌC LIỆU VÀ BÀI TEST
-- ==========================================
INSERT INTO Lessons (Level_Required, Title, Teacher_ID) VALUES 
(1, 'Unit 1: Introduction to Embedded Systems', 1),
(3, 'Unit 2: IoT Architecture', 3);

-- Quiz 1 (A1): 2 câu, Tổng 100 điểm
INSERT INTO Quizzes (Lesson_ID, Minimum_Pass_Score, Possible_Points) VALUES (1, 50, 100);
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES
(1, 'Which board has built-in WiFi? \nA. Arduino Uno \nB. ESP32', 'B'),
(1, 'What does ADC stand for? \nA. Analog-to-Digital \nB. Auto-Data-Control', 'A');

-- Quiz 2 (A2): 3 câu, Tổng 150 điểm
INSERT INTO Quizzes (Lesson_ID, Minimum_Pass_Score, Possible_Points) VALUES (2, 50, 150);
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES
(2, 'What protocol operates on port 80? \nA. HTTP \nB. MQTT', 'A'),
(2, 'A sensor sends continuous voltage. Type? \nA. Digital \nB. Analog', 'B'),
(2, 'Which topology connects all nodes to a hub? \nA. Star \nB. Mesh', 'A');


INSERT INTO Students (Full_Name, Email, Assessment_CEFR) 
VALUES ('Nguyễn Phúc Gia Anh', 'giaanh.np@hust.edu.vn', 'A1');

INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES (4, 'B', 1);
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES (4, 'A', 2);

INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES 
(3, 'A', 3), 
(3, 'B', 4), 
(3, 'A', 5);