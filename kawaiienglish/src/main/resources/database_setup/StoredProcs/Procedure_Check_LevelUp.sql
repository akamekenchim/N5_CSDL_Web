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
    declare trinhDo varchar(4);
    declare minLevel INT;

    select level into curLevel from students where students.`Student_ID` = s_id;
    select CLP_Required into curLevelRequired from levels where levels.`Level` = curLevel;
    
    select students.`Assessment_CEFR` into trinhDo from students where students.`Student_ID` = s_id;

    select levels.`Level` into minLevel from levels where levels.`Description` = trinhDo order by levels.`Level` asc limit 1;

    update students
    set `Current_Level_Progress` = `Current_Level_Progress` + added_points
    where `Student_ID` = s_id;
    
    select `Current_Level_Progress` into afterPlus from students where students.`Student_ID` = s_id;

    while (afterPlus >= curLevelRequired and curLevelRequired is not null) do
        
        -- 2. Cập nhật lại các biến nội bộ để vòng lặp xét tiếp
        set curLevel = curLevel + 1;
        set afterPlus = afterPlus - curLevelRequired;
        
        -- 3. Lấy mốc điểm yêu cầu của level mới
        set curLevelRequired = null;
        select CLP_Required into curLevelRequired from levels where levels.`Level` = curLevel;
        
    end while;

    WHILE (afterPlus < 0 AND curLevel > minLevel) DO
        -- 1. Giảm cấp độ nội bộ xuống 1
        SET curLevel = curLevel - 1;
        
        -- 2. Lấy mức điểm yêu cầu của level TRƯỚC ĐÓ (level mới vừa bị giáng xuống)
        SET curLevelRequired = NULL;
        SELECT CLP_Required INTO curLevelRequired FROM levels WHERE Level = curLevel;
        
        -- 3. Bù trừ điểm âm vào mức yêu cầu của level mới
        -- Vì afterPlus đang mang dấu âm, phép cộng này tương đương với phép trừ
        SET afterPlus = curLevelRequired + afterPlus;
        
        
        
    END WHILE;
    UPDATE students
    SET Level = curLevel,
        Current_Level_Progress = afterPlus,
        Assessment_CEFR = (SELECT Description FROM levels WHERE Level = curLevel)
    WHERE Student_ID = s_id;
    -- ==========================================
    -- CHẶN ĐÁY (Floor Capping)
    -- ==========================================
    -- Nếu đã rớt xuống tận minLevel nhưng số điểm bù trừ vẫn bị âm
    IF (afterPlus < 0) THEN
        UPDATE students
        SET Current_Level_Progress = 0
        WHERE Student_ID = s_id;
    END IF;
    
end //
DELIMITER ;