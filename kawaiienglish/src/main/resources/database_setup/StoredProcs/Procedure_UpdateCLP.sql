drop Procedure if exists sp_update_clp;
delimiter //
create procedure sp_update_clp(
in stu_id int, att_id int
)
begin
    declare totalPointsLast INT;
    declare totalPoints INT;
    declare amountQuestions INT;
    declare possiblePoints INT;
    declare clp_gain INT;

    select `Total_Points_Last`, `Total_Points`, `Amount_Questions`, `Possible_Points` into totalPointsLast, totalPoints, amountQuestions, possiblePoints
    from attempts
    where attempts.`Attempt_ID` = att_id;

    set clp_gain = GREATEST(0, possiblePoints*(totalPoints/amountQuestions) - possiblePoints*(totalPointsLast/amountQuestions));
    update students
    set students.`Total_Answered` = `Total_Answered` + amountQuestions
    where students.`Student_ID` = stu_id;

    update students
    set students.`Total_Correct` = `Total_Correct` + totalPoints
    where students.`Student_ID` = stu_id;

    update students
    set students.`Accuracy` =
    CASE 
        WHEN `Total_Answered` != 0 THEN students.`Total_Correct` / students.`Total_Answered`
        ELSE 0
    END 
    where students.`Student_ID` = stu_id;

    call sp_check_levelup(stu_id, clp_gain);
end //
delimiter ;