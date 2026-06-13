DROP PROCEDURE IF EXISTS sp_check_levelup;
DELIMITER //

CREATE Procedure sp_check_levelup (
    IN s_id INT,
    IN added_points INT
)
BEGIN
    DECLARE curLevel INT;
    DECLARE curLevelRequired INT;
    DECLARE afterPlus INT;

    -- 1. Lấy trạng thái hiện tại của học sinh và cộng điểm trên RAM
    SELECT `Level`, `Current_Level_Progress` + added_points 
    INTO curLevel, afterPlus 
    FROM Students 
    WHERE `Student_ID` = s_id;

    -- 2. Lấy ngưỡng điểm yêu cầu của Level hiện tại
    SELECT `CLP_Required` INTO curLevelRequired 
    FROM Levels 
    WHERE Levels.`Level` = curLevel;

    -- 3. Vòng lặp WHILE chuẩn cú pháp (Sử dụng DO ... END WHILE)
    -- Vòng lặp sẽ chạy liên tục cho đến khi số điểm sau cộng không đủ để lên cấp tiếp theo
    WHILE (afterPlus >= curLevelRequired AND curLevelRequired IS NOT NULL) DO
        -- Trừ điểm progress trên RAM
        SET afterPlus = afterPlus - curLevelRequired;
        -- Tăng cấp độ trên RAM
        SET curLevel = curLevel + 1;
        
        -- Cập nhật lại ngưỡng điểm yêu cầu của Level mới để phục vụ vòng lặp tiếp theo
        SET curLevelRequired = (SELECT `CLP_Required` FROM Levels WHERE Levels.`Level` = curLevel);
    END WHILE;

    -- 4. Ghi trạng thái cuối cùng xuống đĩa vật lý (Chỉ tốn duy nhất 1 lần UPDATE)
    UPDATE Students
    SET `Current_Level_Progress` = afterPlus,
        `Level` = curLevel
    WHERE `Student_ID` = s_id;

END //

DELIMITER ;