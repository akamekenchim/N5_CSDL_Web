package com.hust.kawaiienglish.dto.response;

/**
 * Thông tin tóm tắt 1 bài tập (quiz) để hiển thị danh sách.
 */
public record QuizSummaryRes(
        int quizId,
        String lessonTitle,
        int levelRequired,
        int numQuestions,
        int possiblePoints,
        int minimumPassScore
) {}
