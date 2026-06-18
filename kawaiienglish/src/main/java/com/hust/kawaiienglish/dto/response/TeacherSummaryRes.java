package com.hust.kawaiienglish.dto.response;

/**
 * Thông tin rút gọn của giáo viên - dùng cho màn hình chọn vai trò (Profile Switcher).
 */
public record TeacherSummaryRes(
        int teacherId,
        String fullName,
        String email,
        int classCount
) {}
