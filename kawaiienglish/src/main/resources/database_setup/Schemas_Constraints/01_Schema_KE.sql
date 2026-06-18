use kawaiienglishl;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Student_Submissions;
DROP TABLE IF EXISTS Attempts;
DROP TABLE IF EXISTS Questions;
DROP TABLE IF EXISTS Vocabulary;
DROP TABLE IF EXISTS Grammar_Structures;
DROP TABLE IF EXISTS Quizzes;
DROP TABLE IF EXISTS Lessons;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Classes;
DROP TABLE IF EXISTS Levels;
DROP TABLE IF EXISTS Teacher;
SET FOREIGN_KEY_CHECKS = 1;



create table Students(
    Student_ID INT ,
    Full_Name VARCHAR(50),
    Email varchar(30),
    Class_ID INT,
    Level INT,
    Current_Level_Progress INT,
    Accuracy DOUBLE,
    Total_Answered INT,
    Total_Correct INT,
    Assessment_CEFR VARCHAR(4)
);

CREATE TABLE Levels (
    Level INT,
    CLP_Required INT,
    Description VARCHAR(50)
);

CREATE TABLE Teacher (
    Teacher_ID INT ,
    Full_Name VARCHAR(50),
    Email VARCHAR(50)
);

CREATE TABLE Classes (
    Class_ID INT ,
    Class_Name VARCHAR(50),
    No_of_Students INT,
    Teacher_ID INT,
    CEFR_Level VARCHAR(4)
);
CREATE TABLE Lessons (
    Lesson_ID INT ,
    Level_Required INT,
    Title VARCHAR(100),
    Teacher_ID INT
);

CREATE TABLE Grammar_Structures (
    GS_ID INT ,
    Lesson_ID INT,
    Content VARCHAR(200),
    Example VARCHAR(50)
);

CREATE TABLE Vocabulary (
    V_ID INT ,
    Content VARCHAR(100),
    Meaning VARCHAR(50),
    Example VARCHAR(50),
    Lesson_ID INT
);
CREATE TABLE Quizzes (
    Quiz_ID INT ,
    Lesson_ID INT,
    Minimum_Pass_Score INT,
    Possible_Points INT
);

CREATE TABLE Questions (
    Question_ID INT ,
    Quiz_ID INT,
    Content VARCHAR(120),
    Correct_Answer VARCHAR(50)
);

CREATE TABLE Student_Submissions (
    Submission_ID INT ,
    Student_ID INT,
    Student_ANS VARCHAR(50),
    Question_ID INT,
    Attempt_ID INT,
    Is_Correct TINYINT
);

CREATE TABLE Attempts (
    Attempt_ID INT ,
    Total_Points INT,
    Total_Points_Last INT,
    Quiz_ID INT,
    Student_ID INT,
    Amount_Questions INT,
    Possible_Points INT,
    Status VARCHAR(20)
);
DROP TABLE if exists Class;