package com.hust.kawaiienglish.dto.request;

/** Một cấu trúc ngữ pháp nhập ở Bước 2 của workflow tạo bài giảng. */
public record LessonGrammarReq(
        String content,
        String example
) {}
