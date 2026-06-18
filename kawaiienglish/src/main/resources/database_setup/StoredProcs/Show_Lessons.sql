drop PROCEDURE if exists show_lessons;
DELIMITER //
create Procedure show_lessons (
    in s_id INT
)
BEGIN
    select * from v_lesson_catalog 
    where `Level_Required` <= (select `Level` from students where students.`Student_ID` = s_id);

end //

DELIMITER;

call show_lessons(1);