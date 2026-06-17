CREATE INDEX idx_attempt_lookup 
ON Attempts (Student_ID, Quiz_ID, Status);
-- Lưu ý: MySQL tự động tạo Index cho Khóa ngoại. 

-- Tạo lại Index để tối ưu phép đếm COUNT(*)
CREATE INDEX idx_submission_attempt 
ON Student_Submissions (Attempt_ID);

-- index cho bảng classes

CREATE INDEX idx_classes_assignment 
ON Classes (CEFR_Level, No_of_Students);


-- Tạo Index với thứ tự giảm dần (DESC)
CREATE INDEX idx_students_leaderboard 
ON Students (Level DESC, Current_Level_Progress DESC);