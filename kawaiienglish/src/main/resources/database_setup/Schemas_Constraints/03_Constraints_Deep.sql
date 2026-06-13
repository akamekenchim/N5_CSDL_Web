------------------------------------------
-- CEFR DOMAIN CONSTRAINTS ---------------
------------------------------------------

-- Giới hạn 6 giá trị CEFR cho bảng Students
ALTER TABLE Students
ADD CONSTRAINT chk_students_cefr 
CHECK (Assessment_CEFR IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

-- Giới hạn 6 giá trị CEFR cho bảng Classes
ALTER TABLE Classes
ADD CONSTRAINT chk_classes_cefr 
CHECK (CEFR_Level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

-- Giới hạn 6 giá trị CEFR cho cột Description của bảng Levels
ALTER TABLE Levels
ADD CONSTRAINT chk_levels_cefr 
CHECK (Description IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

ALTER TABLE Students
MODIFY COLUMN Current_Level_Progress INT NOT NULL DEFAULT 0,
MODIFY COLUMN Accuracy DOUBLE NOT NULL DEFAULT 0,
MODIFY COLUMN Total_Answered INT NOT NULL DEFAULT 0,
MODIFY COLUMN Total_Correct INT NOT NULL DEFAULT 0,
MODIFY COLUMN Level INT NOT NULL DEFAULT 1; -- Riêng Level khởi điểm thì nên để mặc định là 1 thay vì 0

-- 2. Bảng Classes (Bảo vệ thuật toán cân bằng tải lớp học)
-- Lớp mới tạo ra mặc định có 0 học sinh
ALTER TABLE Classes
MODIFY COLUMN No_of_Students INT NOT NULL DEFAULT 0;

-- 3. Bảng Attempts (Bảo vệ Trigger chấm điểm)
-- Điểm của một phiên làm bài bắt đầu từ 0
ALTER TABLE Attempts
MODIFY COLUMN Total_Points INT NOT NULL DEFAULT 0,
MODIFY COLUMN Total_Points_Last INT NOT NULL DEFAULT 0;

-- 4. Bảng Student_Submissions (Bảo vệ cờ đúng/sai)
-- Mặc định câu trả lời chưa chấm hoặc sai là 0, chỉ lên 1 khi khớp đáp án
ALTER TABLE Student_Submissions
MODIFY COLUMN Is_Correct TINYINT NOT NULL DEFAULT 0;

-- 5. Bảng Quizzes (Bảo vệ công thức chia lấy tỷ lệ)
-- Tránh việc giáo viên quên nhập điểm làm lỗi công thức tính CLP_gain
ALTER TABLE Quizzes
MODIFY COLUMN Minimum_Pass_Score INT NOT NULL DEFAULT 0,
MODIFY COLUMN Possible_Points INT NOT NULL DEFAULT 0;