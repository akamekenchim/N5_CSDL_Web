drop trigger if exists trg_after_insert_atm;
delimiter //
create trigger trg_after_insert_atm
after INSERT
on student_submissions
for each ROW
begin
    declare v_submitted_count INT;
    declare v_total_questions INT;
    IF NEW.Is_Correct = 1 THEN
        UPDATE Attempts 
        SET Total_Points = Total_Points + 1 
        WHERE Attempt_ID = NEW.Attempt_ID;
    END IF;
    SELECT COUNT(*) INTO v_submitted_count 
    FROM Student_Submissions 
    WHERE Attempt_ID = NEW.Attempt_ID;

    SELECT Amount_Questions INTO v_total_questions 
    FROM Attempts 
    WHERE Attempt_ID = NEW.Attempt_ID;

    IF v_submitted_count = v_total_questions THEN
        UPDATE Attempts 
        SET Status = 'COMPLETED' 
        WHERE Attempt_ID = NEW.Attempt_ID;

        CALL sp_update_clp(NEW.Student_ID, NEW.Attempt_ID);
    END IF;

END //

DELIMITER ;

         

