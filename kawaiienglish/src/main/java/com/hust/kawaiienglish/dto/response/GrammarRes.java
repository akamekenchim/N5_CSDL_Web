package com.hust.kawaiienglish.dto.response;

/**
 * Một cấu trúc ngữ pháp trong bài giảng.
 */
public record GrammarRes(
        int gsId,
        String content,
        String example
) {}
