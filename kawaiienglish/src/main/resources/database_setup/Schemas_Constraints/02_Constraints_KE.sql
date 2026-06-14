--PK For students table
alter table students
add constraint pk_student_id PRIMARY KEY (Student_ID);
alter table students
modify column Student_ID INT AUTO_INCREMENT;
--PK for levels table
alter table levels
add constraint pk_level PRIMARY KEY(Level);
--PK for Class table
alter table classes
add constraint pk_class_id PRIMARY KEY (Class_id);
alter table classes
modify column Class_ID INT AUTO_INCREMENT;

-- PK for Teacher table
ALTER TABLE Teacher 
ADD CONSTRAINT pk_teacher_id PRIMARY KEY (Teacher_ID);
ALTER TABLE Teacher 
MODIFY COLUMN Teacher_ID INT AUTO_INCREMENT;

-- PK for Lessons table
ALTER TABLE Lessons 
ADD CONSTRAINT pk_lesson_id PRIMARY KEY (Lesson_ID);
ALTER TABLE Lessons 
MODIFY COLUMN Lesson_ID INT AUTO_INCREMENT;

-- PK for Grammar_Structures table
ALTER TABLE Grammar_Structures 
ADD CONSTRAINT pk_gs_id PRIMARY KEY (GS_ID);
ALTER TABLE Grammar_Structures 
MODIFY COLUMN GS_ID INT AUTO_INCREMENT;

-- PK for Vocabulary table
ALTER TABLE Vocabulary 
ADD CONSTRAINT pk_v_id PRIMARY KEY (V_ID);
ALTER TABLE Vocabulary 
MODIFY COLUMN V_ID INT AUTO_INCREMENT;

-- PK for Quizzes table
ALTER TABLE Quizzes 
ADD CONSTRAINT pk_quiz_id PRIMARY KEY (Quiz_ID);
ALTER TABLE Quizzes 
MODIFY COLUMN Quiz_ID INT AUTO_INCREMENT;
-- PK for Questions table
ALTER TABLE Questions 
ADD CONSTRAINT pk_question_id PRIMARY KEY (Question_ID);
ALTER TABLE Questions 
MODIFY COLUMN Question_ID INT AUTO_INCREMENT;

-- PK for Attempts table
ALTER TABLE Attempts 
ADD CONSTRAINT pk_attempt_id PRIMARY KEY (Attempt_ID);
ALTER TABLE Attempts 
MODIFY COLUMN Attempt_ID INT AUTO_INCREMENT;

-- PK for Student_Submissions table
ALTER TABLE Student_Submissions 
ADD CONSTRAINT pk_submission_id PRIMARY KEY (Submission_ID);
ALTER TABLE Student_Submissions 
MODIFY COLUMN Submission_ID INT AUTO_INCREMENT;

------------------------------------------
-- FOREIGN KEYS --------------------------
alter table students
add constraint fk_class_id_students FOREIGN KEY (class_id) REFERENCES classes(class_id);

alter table students 
add constraint fk_level_students FOREIGN KEY (level) REFERENCES levels(level);

alter table classes
add constraint fk_teacher_id_class FOREIGN KEY (teacher_id) references teacher(teacher_id);
ALTER TABLE Lessons 
ADD CONSTRAINT fk_teacher_id_lessons FOREIGN KEY (Teacher_ID) REFERENCES Teacher(Teacher_ID);
-- Kết nối Ngữ pháp
ALTER TABLE Grammar_Structures 
ADD CONSTRAINT fk_lesson_id_grammar FOREIGN KEY (Lesson_ID) REFERENCES Lessons(Lesson_ID);

-- Kết nối Từ vựng
ALTER TABLE Vocabulary 
ADD CONSTRAINT fk_lesson_id_vocabulary FOREIGN KEY (Lesson_ID) REFERENCES Lessons(Lesson_ID);

-- Kết nối Bài tập vào Bài giảng
ALTER TABLE Quizzes 
ADD CONSTRAINT fk_lesson_id_quizzes FOREIGN KEY (Lesson_ID) REFERENCES Lessons(Lesson_ID);

-- Kết nối Câu hỏi vào Bài tập
ALTER TABLE Questions 
ADD CONSTRAINT fk_quiz_id_questions FOREIGN KEY (Quiz_ID) REFERENCES Quizzes(Quiz_ID);

-- Kết nối với Bài tập
ALTER TABLE Attempts 
ADD CONSTRAINT fk_quiz_id_attempts FOREIGN KEY (Quiz_ID) REFERENCES Quizzes(Quiz_ID);

-- Kết nối với Học sinh
ALTER TABLE Attempts
ADD CONSTRAINT fk_student_id_attempts FOREIGN KEY (Student_ID) REFERENCES Students(Student_ID); 

-- Kết nối với Học sinh
ALTER TABLE Student_Submissions 
ADD CONSTRAINT fk_student_id_submissions FOREIGN KEY (Student_ID) REFERENCES Students(Student_ID);

-- Kết nối với Câu hỏi
ALTER TABLE Student_Submissions 
ADD CONSTRAINT fk_question_id_submissions FOREIGN KEY (Question_ID) REFERENCES Questions(Question_ID);

-- Kết nối với Lượt làm bài (Phiên làm bài)
ALTER TABLE Student_Submissions 
ADD CONSTRAINT fk_attempt_id_submissions FOREIGN KEY (Attempt_ID) REFERENCES Attempts(Attempt_ID);



