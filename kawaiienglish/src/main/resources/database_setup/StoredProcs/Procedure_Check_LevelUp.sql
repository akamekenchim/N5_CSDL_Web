drop PROCEDURE if exists sp_check_levelup;
DELIMITER //
create Procedure sp_check_levelup (
    in s_id INT,
    in added_points INT
)
begin
    declare curLevel int;
    declare curLevelRequired int;
    declare afterPlus int;
    
    select level into curLevel from students where students.`Student_ID` = s_id;
    select CLP_Required into curLevelRequired from levels where levels.`Level` = curLevel;
    
    update students
    set `Current_Level_Progress` = `Current_Level_Progress` + added_points
    where `Student_ID` = s_id;
    
    select `Current_Level_Progress` into afterPlus from students where students.`Student_ID` = s_id;

    while (afterPlus >= curLevelRequired and curLevelRequired is not null) do
        
        -- 1. Cập nhật trừ điểm, tăng cấp và đổi CEFR
        update students
        set `Current_Level_Progress` = `Current_Level_Progress` - curLevelRequired,
            `Level` = `Level` + 1,
            `Assessment_CEFR` = (select `Description` from levels where levels.`Level` = curLevel + 1)
        where `Student_ID` = s_id;
        
        -- 2. Cập nhật lại các biến nội bộ để vòng lặp xét tiếp
        set curLevel = curLevel + 1;
        set afterPlus = afterPlus - curLevelRequired;
        
        -- 3. Lấy mốc điểm yêu cầu của level mới
        set curLevelRequired = null;
        select CLP_Required into curLevelRequired from levels where levels.`Level` = curLevel;
        
    end while;
end //
DELIMITER ;