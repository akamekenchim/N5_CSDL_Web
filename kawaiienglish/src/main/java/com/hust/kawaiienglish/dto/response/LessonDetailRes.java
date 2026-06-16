package com.hust.kawaiienglish.dto.response;

import java.util.List;

/**
 * Chi tiết 1 bài giảng: thông tin + từ vựng + ngữ pháp + các bài tập (quiz) đính kèm.
 */
public record LessonDetailRes(
        int lessonId,
        String lessonTitle,
        int levelRequired,
        String teacherName,
        List<VocabularyRes> vocabulary,
        List<GrammarRes> grammar,
        List<QuizSummaryRes> quizzes
) {}
