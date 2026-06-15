package com.hust.kawaiienglish.dto.response;

/**
 * Thông tin rút gọn của học sinh - dùng cho màn hình chọn/đăng nhập.
 */
public record StudentSummaryRes(
        int studentId,
        String fullName,
        int level,
        String assessmentCefr,
        String className
) {}
