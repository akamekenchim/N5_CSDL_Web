package com.hust.kawaiienglish.dto.request;

/**
 * Một câu trả lời của học sinh cho 1 câu hỏi.
 */
public record AnswerItemReq(
        Integer questionId,
        String answer
) {}
