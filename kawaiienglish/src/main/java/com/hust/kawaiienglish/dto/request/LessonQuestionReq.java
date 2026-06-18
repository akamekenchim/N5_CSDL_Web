package com.hust.kawaiienglish.dto.request;

/** Một câu hỏi của bài tập, nhập ở Bước 3 của workflow tạo bài giảng. */
public record LessonQuestionReq(
        String content,
        String correctAnswer
) {}
