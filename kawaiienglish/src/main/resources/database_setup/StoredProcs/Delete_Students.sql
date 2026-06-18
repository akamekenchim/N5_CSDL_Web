drop PROCEDURE if exists delete_Student;
DELIMITER //
create Procedure delete_Student (
    in s_id INT
)
BEGIN
    DELETE FROM Student_Submissions WHERE Student_ID = s_id;
    DELETE FROM Attempts WHERE Student_ID = s_id;
    DELETE FROM Students WHERE Student_ID = s_id;

    ALTER TABLE Students AUTO_INCREMENT = 1;

end //

DELIMITER ;
