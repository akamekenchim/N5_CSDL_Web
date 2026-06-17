-- các câu lệnh select để kiểm tra dữ liệu trong các bảng
select * from attempts;
select * from classes;
select * from grammar_structures;
select * from lessons;
select * from questions;
select * from students;
select * from teacher;
select * from vocabulary;
select * from quizzes;
select * from levels;
select * from student_submissions;


-- các câu lệnh xem views
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

call sp_check_levelup(2, -320);