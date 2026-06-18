package com.hust.kawaiienglish.dto.response;

/**
 * Một dòng trong danh mục bài giảng, đọc từ view v_lesson_catalog.
 *
 * attempted: học sinh hiện tại đã làm bài tập nào thuộc bài giảng này chưa
 *            (dùng để đổi màu nền "đã học"). False khi xem ở chế độ không kèm studentId.
 */
public record LessonCatalogRes(
        int lessonId,
        String lessonTitle,
        int levelRequired,
        String teacherName,
        String teacherEmail,
        boolean attempted
) {}
