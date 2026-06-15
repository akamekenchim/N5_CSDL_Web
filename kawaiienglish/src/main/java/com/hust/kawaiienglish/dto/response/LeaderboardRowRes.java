package com.hust.kawaiienglish.dto.response;

/**
 * Một dòng trong bảng xếp hạng, đọc từ view v_leaderboard.
 */
public record LeaderboardRowRes(
        int studentId,
        String fullName,
        String className,
        int level,
        int currentLevelProgress,
        double accuracy,
        int rankPosition
) {}
