package com.hust.kawaiienglish.dto.response;

/**
 * Kết quả chấm của từng câu hỏi sau khi nộp bài (có hiện đáp án đúng để học sinh xem lại).
 */
public record QuestionResultRes(
        int questionId,
        String content,
        String yourAnswer,
        String correctAnswer,
        boolean correct
) {}
