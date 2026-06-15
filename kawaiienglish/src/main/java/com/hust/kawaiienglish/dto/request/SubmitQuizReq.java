package com.hust.kawaiienglish.dto.request;

import java.util.List;

/**
 * JSON do frontend (Bình Minh) gửi lên khi nộp bài:
 * { "studentId": 1, "quizId": 1, "answers": [ { "questionId": 1, "answer": "am" }, ... ] }
 */
public record SubmitQuizReq(
        Integer studentId,
        Integer quizId,
        List<AnswerItemReq> answers
) {}
