package com.hust.kawaiienglish.dto.request;

/** Một từ vựng nhập ở Bước 2 của workflow tạo bài giảng. */
public record LessonVocabReq(
        String content,
        String meaning,
        String example
) {}
