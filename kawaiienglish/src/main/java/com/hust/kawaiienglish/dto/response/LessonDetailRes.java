package com.hust.kawaiienglish.dto.response;

import java.util.List;

/**
 * Chi tiết 1 bài giảng: thông tin + danh sách từ vựng + ngữ pháp.
 */
public record LessonDetailRes(
        int lessonId,
        String lessonTitle,
        int levelRequired,
        String teacherName,
        List<VocabularyRes> vocabulary,
        List<GrammarRes> grammar
) {}
