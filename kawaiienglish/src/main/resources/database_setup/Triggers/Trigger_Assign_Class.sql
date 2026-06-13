DROP TRIGGER IF EXISTS trg_auto_assign_class;

DELIMITER //

CREATE TRIGGER trg_auto_assign_class
BEFORE INSERT ON Students
FOR EACH ROW
BEGIN 
    declare newLevel INT;
    declare newClass INT;
    select levels.`Level` into newLevel from levels
    where levels.`Description` = NEW.Assessment_CEFR
    order by levels.`Level` ASC limit 1;

    set NEW.Level = newLevel;

    select classes.`Class_ID` into newClass from classes
    where classes.`CEFR_Level` = NEW.Assessment_CEFR order by classes.`No_of_Students` ASC limit 1;

    set NEW.Class_ID = newClass;
    set NEW.Current_Level_Progress = 0;

    update classes
    set classes.`No_of_Students` = classes.`No_of_Students` + 1
    where classes.`Class_ID` = newClass;

END //

DELIMITER ;