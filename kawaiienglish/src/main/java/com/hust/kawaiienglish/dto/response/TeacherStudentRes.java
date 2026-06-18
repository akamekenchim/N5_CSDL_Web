package com.hust.kawaiienglish.dto.response;

/**
 * Một học sinh trong lớp do giáo viên dạy (kết quả JOIN Students + Classes).
 * Hiển thị: thông tin cơ bản, tên lớp, tỷ lệ chính xác (Accuracy) và cấp độ hiện tại.
 */
public record TeacherStudentRes(
        int studentId,
        String fullName,
        String email,
        String className,
        double accuracy,
        int level,
        int currentLevelProgress
) {}
