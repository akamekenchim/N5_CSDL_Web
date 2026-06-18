package com.hust.kawaiienglish.dto.response;

/**
 * Thông tin tóm tắt 1 bài tập (quiz) để hiển thị danh sách.
 *
 * attempted: học sinh hiện tại đã có lượt làm bài này chưa (để đổi màu nền).
 * bestScore: ĐIỂM CAO NHẤT từng đạt của học sinh ở bài tập này (nhãn hiển thị "Kỷ lục điểm").
 *            Đặt tên khác cột DB Total_Points để tránh nhầm lẫn; chỉ có ý nghĩa khi biết studentId.
 */
public record QuizSummaryRes(
        int quizId,
        String lessonTitle,
        int levelRequired,
        int numQuestions,
        int possiblePoints,
        int minimumPassScore,
        boolean attempted,
        int bestScore
) {}
