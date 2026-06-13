drop Procedure if exists getStudents;

DELIMITER $$
CREATE PROCEDURE getStudents()
BEGIN
    SELECT * FROM students;
END $$  
DELIMITER ;

call `getStudents`;