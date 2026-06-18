package com.hust.kawaiienglish.dto.response;

/**
 * Kết quả tạo bài giảng theo workflow 3 bước (chạy trong 1 transaction):
 * trả về các khoá tự sinh và số bản ghi con đã tạo.
 */
public record CreateLessonRes(
        int lessonId,
        int quizId,
        int vocabularyCount,
        int grammarCount,
        int questionCount
) {}
