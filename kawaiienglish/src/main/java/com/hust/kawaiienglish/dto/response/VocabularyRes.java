package com.hust.kawaiienglish.dto.response;

/**
 * Một từ vựng trong bài giảng.
 */
public record VocabularyRes(
        int vId,
        String content,
        String meaning,
        String example
) {}
