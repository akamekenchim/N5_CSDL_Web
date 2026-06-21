CREATE OR REPLACE VIEW v_leaderboard AS
SELECT 
    s.Student_ID,
    s.Full_Name,
    c.Class_Name,
    s.Level,
    s.Current_Level_Progress,
    s.Accuracy,
    -- Phân hạng: Ưu tiên Level trước, Current_Level_Progress sau
    DENSE_RANK() OVER (ORDER BY s.Level DESC, s.Current_Level_Progress DESC) AS Rank_Position
FROM 
    Students s
LEFT JOIN 
    Classes c ON s.Class_ID = c.Class_ID;

CREATE OR REPLACE VIEW v_quiz_details AS
SELECT 
    qz.Quiz_ID,
    l.Lesson_ID,
    l.Title AS Lesson_Title,
    qz.Minimum_Pass_Score,
    qz.Possible_Points,
    q.Question_ID,
    q.Content AS Question_Content,
    q.Correct_Answer
FROM 
    Quizzes qz
JOIN 
    Lessons l ON qz.Lesson_ID = l.Lesson_ID
JOIN 
    Questions q ON qz.Quiz_ID = q.Quiz_ID;


CREATE OR REPLACE VIEW v_student_dashboard AS
SELECT 
    s.Student_ID,
    s.Full_Name AS Student_Name,
    s.Email AS Student_Email,
    s.Level,
    s.Current_Level_Progress,
    lv.CLP_Required AS Next_Level_CLP, -- Lấy mốc điểm cần để lên cấp tiếp theo
    s.Accuracy,
    s.Total_Answered,
    s.Total_Correct,
    s.Assessment_CEFR,
    c.Class_Name,
    t.Full_Name AS Teacher_Name
FROM 
    Students s
LEFT JOIN 
    Levels lv ON s.Level = lv.Level
LEFT JOIN 
    Classes c ON s.Class_ID = c.Class_ID
LEFT JOIN 
    Teacher t ON c.Teacher_ID = t.Teacher_ID;

CREATE OR REPLACE VIEW v_lesson_catalog AS
SELECT 
    l.Lesson_ID,
    l.Title AS Lesson_Title,
    l.Level_Required,
    t.Teacher_ID,
    t.Full_Name AS Teacher_Name,
    t.Email AS Teacher_Email
FROM 
    Lessons l
JOIN 
    Teacher t ON l.Teacher_ID = t.Teacher_ID;


create or replace view v_class_students as
select students.`Full_Name`, classes.`Class_Name`, students.`Email`, students.`Current_Level_Progress`, students.`Level`, students.`Accuracy`, students.`Class_ID`
from students
    join classes on classes.`Class_ID` = students.`Class_ID`;

select * from v_class_students where `Class_ID` = 3;

CREATE OR REPLACE VIEW v_quiz_details_student AS
SELECT 
    qz.Quiz_ID,
    l.Lesson_ID,
    l.Title AS Lesson_Title,
    qz.Minimum_Pass_Score,
    qz.Possible_Points,
    q.Question_ID,
    q.Content AS Question_Content
FROM 
    Quizzes qz
JOIN 
    Lessons l ON qz.Lesson_ID = l.Lesson_ID
JOIN 
    Questions q ON qz.Quiz_ID = q.Quiz_ID;