package com.hust.kawaiienglish.dto.response;

/**
 * Đóng gói thông tin trang cá nhân (Level, CLP, Rank...) lấy từ view v_student_dashboard
 * và bổ sung thứ hạng từ v_leaderboard.
 */
public record DashboardRes(
        int studentId,
        String studentName,
        String studentEmail,
        int level,
        int currentLevelProgress,
        Integer nextLevelClp,
        double accuracy,
        int totalAnswered,
        int totalCorrect,
        String assessmentCefr,
        String className,
        String teacherName,
        Integer rankPosition
) {}
