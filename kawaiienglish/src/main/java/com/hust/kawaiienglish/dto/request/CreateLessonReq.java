package com.hust.kawaiienglish.dto.request;

import java.util.List;

/**
 * Toàn bộ dữ liệu của workflow tạo bài giảng 3 bước. Frontend thu thập qua nhiều bước
 * nhưng gửi 1 lần để backend ghi tất cả trong CÙNG 1 transaction.
 *
 * Bước 1: title, levelRequired           -> bảng Lessons
 * Bước 2: vocabulary[5], grammar[2]       -> bảng Vocabulary, Grammar_Structures
 * Bước 3: minimumPassScore, possiblePoints, questions[3] -> bảng Quizzes, Questions
 */
public record CreateLessonReq(
        String title,
        Integer levelRequired,
        List<LessonVocabReq> vocabulary,
        List<LessonGrammarReq> grammar,
        Integer minimumPassScore,
        Integer possiblePoints,
        List<LessonQuestionReq> questions
) {}
