package com.hust.kawaiienglish.model;

/**
 * Ánh xạ 1 bản ghi phiên làm bài (Attempts) đọc từ DB sau khi Trigger đã xử lý.
 */
public record AttemptRow(
        int attemptId,
        int totalPoints,
        int totalPointsLast,
        int amountQuestions,
        int possiblePoints,
        String status
) {}
