package com.hust.kawaiienglish.dto.request;

/**
 * Yêu cầu tăng/giảm điểm cho 1 học sinh. points có thể ÂM hoặc DƯƠNG.
 * Service sẽ gọi Stored Procedure: CALL sp_check_levelup(studentId, points).
 */
public record AdjustPointsReq(
        Integer points
) {}
