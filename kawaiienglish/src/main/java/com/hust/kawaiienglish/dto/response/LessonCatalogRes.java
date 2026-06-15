package com.hust.kawaiienglish.dto.response;

/**
 * Một dòng trong danh mục bài giảng, đọc từ view v_lesson_catalog.
 */
public record LessonCatalogRes(
        int lessonId,
        String lessonTitle,
        int levelRequired,
        String teacherName,
        String teacherEmail
) {}
