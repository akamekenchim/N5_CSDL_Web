-- Dành cho admin: các câu lệnh select * from (table) để kiểm tra dữ liệu
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

-- Dành cho admin: Câu lệnh xóa 1 học sinh được đóng gói trong 1 Stored Procedure: Xóa hết các Attempts và Submission để Giải phóng data.
select * from students where `Full_Name` like '%Tuyen%';
call delete_Student(10);
-- Câu lệnh thêm 1 em học sinh vào lớp:
insert into students(`Full_Name`, `Email`, `Assessment_CEFR`) VALUES
('Ngoc Trinh', 'trinh@gmail.com', 'A2');
-- Class_ID: Được gán bằng Trigger xếp lớp: Tìm lớp có cùng CEFR, có số hs hiện tại ít nhất, gán Class_ID bằng Class_ID của lớp vừa tìm. Lớp đó No_Of_students += 1.
-- Level: Được gán bằng level nhỏ nhất cùng CEFR.
-- Accuracy, Total_Answered, Total_Correct: Được cập nhật liên tục từ Procedure_Check_LevelUp.
-- Current Level Progress được cộng bởi giáo viên hoặc được tích lũy từ việc làm bài hoặc cải thiện bài. Được khởi tạo = 0.

-- Dành cho giáo viên: câu lệnh tìm học sinh của 1 lớp nào đó mình đang dạy (Thầy Khánh)
select * from teacher where `Full_Name` like '%Khanh%'; --lay ID;
select * from classes where `Teacher_ID` = 1;
select * from students where `Class_ID` = 1;
-- Câu lệnh tìm tất cả học sinh mình đang dạy:
select students.*, classes.`Class_Name`
from students
join classes on classes.`Class_ID` = students.`Class_ID`
where `Teacher_ID` = 1
order by students.`Class_ID` ASC;
-- Câu lệnh xem top 10 học sinh:
select * from v_leaderboard limit 10;
-- hoặc:
select * from students
order by level desc, current_level_progress desc limit 10;

-- Câu lệnh cộng điểm hoặc phệt học sinh: Được đóng gói trong hàm Procedure_Check_LevelUp
select * from students where `Full_Name` like '%Viet Anh%';
call sp_check_levelup(1, 100);
call sp_check_levelup(1, -100);

-- Các câu lệnh tạo bài giảng, tạo câu hỏi, ngữ pháp/từ vựng tuân theo cấu trúc câu lệnh INSERT INTO chuẩn.





