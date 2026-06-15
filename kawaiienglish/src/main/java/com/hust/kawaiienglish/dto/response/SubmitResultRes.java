package com.hust.kawaiienglish.dto.response;

import java.util.List;

/**
 * Kết quả tổng hợp sau khi nộp bài. Các giá trị điểm/level được lấy lại từ DB
 * (sau khi Trigger và Stored Procedure đã tự động chấm và cộng CLP).
 */
public record SubmitResultRes(
        int attemptId,
        int correctCount,
        int totalQuestions,
        int possiblePoints,
        int pointsEarned,
        int clpGain,
        boolean leveledUp,
        int oldLevel,
        int newLevel,
        int currentLevelProgress,
        Integer nextLevelClp,
        double accuracy,
        int minimumPassScore,
        boolean passed,
        String status,
        List<QuestionResultRes> questions
) {}
