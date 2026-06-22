select * from students;
insert INTO students(`Full_Name`, `Email`, `Assessment_CEFR`)
values ('Le Sang Hiec', 'faker@hust.edu.vn', 'A1');
select * from classes;
insert into students(`Full_Name`, `Email`, `Assessment_CEFR`)
values ('Viet Anh', 'Vietanh@hust.edu.vn', 'A1');
select students.* from students where students.`Full_Name` like '%Viet Anh%';
call show_lessons(10);
select * from lessons;
select * from v_student_dashboard where v_student_dashboard.`Student_ID` = 10; 
call delete_Student(9); 
call delete_Student(10); 

select * from vocabulary where vocabulary.`Lesson_ID` = 1;
select * from grammar_structures where grammar_structures.`Lesson_ID` = 1;
select * from quizzes where quizzes.`Lesson_ID` = 1;
select * from questions where questions.Quiz_ID = 1;
select * from v_quiz_details_student where quiz_ID = 1;

INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) values
(10, 'water', 1),
(10, 'any', 2);

select * from student_submissions;
select * from attempts;
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) values
(10, 'ko biet', 3);

INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) values
(10, 'water', 1),
(10, 'any', 2);
INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) values
(10, 'full', 3);

call sp_check_levelup(10, -10);


select * from v_class_students where `Class_ID` = 2;
select * from v_leaderboard LIMIT 10;