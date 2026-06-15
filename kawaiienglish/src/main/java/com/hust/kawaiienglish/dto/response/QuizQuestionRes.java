package com.hust.kawaiienglish.dto.response;

/**
 * Câu hỏi trả về cho học sinh khi làm bài.
 * CỐ TÌNH ẨN trường Correct_Answer để chống gian lận.
 */
public record QuizQuestionRes(
        int questionId,
        String content
) {}
