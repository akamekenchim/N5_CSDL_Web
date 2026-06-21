ALTER TABLE Attempts ALTER INDEX idx_attempt_lookup INVISIBLE;
ALTER TABLE Classes ALTER INDEX idx_classes_assignment INVISIBLE;
ALTER TABLE Students ALTER INDEX idx_students_leaderboard INVISIBLE;
ALTER TABLE Student_Submissions ALTER INDEX idx_submission_attempt INVISIBLE;
alter table lessons alter index idx_lessons_level_req invisible;
alter table levels alter index idx_levels_cefr invisible;

-- ======================================================================
-- BƯỚC 2: MỞ KHÓA B-TREE (Demo Index Lookup -> Chạy SIÊU TỐC)
-- ======================================================================
ALTER TABLE Attempts ALTER INDEX idx_attempt_lookup VISIBLE;
ALTER TABLE Classes ALTER INDEX idx_classes_assignment VISIBLE;
ALTER TABLE Students ALTER INDEX idx_students_leaderboard VISIBLE;
ALTER TABLE Student_Submissions ALTER INDEX idx_submission_attempt VISIBLE;

alter table lessons alter index idx_lessons_level_req visible;
alter table levels alter index idx_levels_cefr visible;

show index from Attempts;
show index from Classes;
show index from Students;
show index from Student_Submissions;

-- ======================================================================
-- PHẦN INDEX leaderboard và assign class --
-- ======================================================================

-- Câu lệnh được chạy để tìm lớp có trình độ A1 - số học sinh ít nhất - được chạy trong Trigger chức năng tự xếp lớp
SELECT * FROM Classes 
WHERE CEFR_Level = 'A1' 
ORDER BY No_of_Students ASC 
LIMIT 1;

-- Câu lệnh được chạy để tìm 10 học sinh có trình độ cao nhất - chính là chức năng bảng xếp hạng
SELECT * FROM Students 
ORDER BY Level DESC, Current_Level_Progress DESC 
LIMIT 10;

explain
SELECT * FROM Classes 
WHERE CEFR_Level = 'A1' 
ORDER BY No_of_Students ASC 
LIMIT 1;

explain
SELECT * FROM Students 
ORDER BY Level DESC, Current_Level_Progress DESC 
LIMIT 10;
-- ======================================================================
-- Phần INDEX attempts và student_submissions --
-- ======================================================================
-- Câu lệnh được chạy để tìm điểm số cao nhất của học sinh trong một quiz - chính là Total_Points_Last được gán bằng Trigger
select COALESCE(max(attempts.`Total_Points`),0) as TTPL from attempts
where `Student_ID` = 3647 and `Quiz_ID` = 2052 and `Status` = 'COMPLETED';

-- Câu lệnh kiểm tra xem có bài quiz nào đang làm dở không
SELECT Attempt_ID FROM Attempts 
WHERE Student_ID = 18889 AND Quiz_ID = 1567 AND Status = 'IN_PROGRESS';

-- Câu lệnh đếm số câu đã làm (Trigger after insert vào Student_Submissions sẽ cập nhật)
SELECT COUNT(*) FROM Student_Submissions 
WHERE Attempt_ID = 1;  

explain
SELECT Attempt_ID FROM Attempts 
WHERE Student_ID = 18889 AND Quiz_ID = 1567 AND Status = 'IN_PROGRESS';

EXPLAIN
select COALESCE(max(attempts.`Total_Points`),0) as TTPL from attempts
where `Student_ID` = 3647 and `Quiz_ID` = 2052 and `Status` = 'COMPLETED';

EXPLAIN
SELECT COUNT(*) FROM Student_Submissions 
WHERE Attempt_ID = 1;  
select * from lessons where `Level_Required` <= 2;
explain
select * from lessons where `Level_Required` <= 2;
