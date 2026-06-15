package com.hust.kawaiienglish.repository;

import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.hust.kawaiienglish.model.AttemptRow;

/**
 * Tầng kết nối DB cho việc nộp bài. Lệnh INSERT vào Student_Submissions sẽ
 * "kích nổ" Trigger BEFORE/AFTER INSERT để tự tạo phiên làm bài, chấm điểm và cộng CLP.
 */
@Repository
public class SubmissionRepository {

    private final JdbcTemplate jdbc;

    public SubmissionRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * Xoá phiên làm bài còn dang dở (IN_PROGRESS) của học sinh cho quiz này, để mỗi lần
     * làm lại là một phiên sạch. Các phiên COMPLETED được giữ lại để tính điểm chênh lệch.
     */
    public void deleteInProgress(int studentId, int quizId) {
        jdbc.update("""
                DELETE FROM Student_Submissions
                WHERE Attempt_ID IN (
                    SELECT Attempt_ID FROM Attempts
                    WHERE Student_ID = ? AND Quiz_ID = ? AND Status = 'IN_PROGRESS'
                )
                """, studentId, quizId);
        jdbc.update("""
                DELETE FROM Attempts
                WHERE Student_ID = ? AND Quiz_ID = ? AND Status = 'IN_PROGRESS'
                """, studentId, quizId);
    }

    /** Nộp 1 câu trả lời. Trigger sẽ tự gán Attempt_ID và Is_Correct. */
    public void insertSubmission(int studentId, int questionId, String answer) {
        jdbc.update(
                "INSERT INTO Student_Submissions (Student_ID, Student_ANS, Question_ID) VALUES (?, ?, ?)",
                studentId, answer, questionId);
    }

    /** Phiên làm bài mới nhất của học sinh cho quiz này (sau khi đã nộp xong). */
    public Optional<AttemptRow> findLatestAttempt(int studentId, int quizId) {
        String sql = """
                SELECT Attempt_ID, Total_Points, Total_Points_Last, Amount_Questions, Possible_Points, Status
                FROM Attempts
                WHERE Student_ID = ? AND Quiz_ID = ?
                ORDER BY Attempt_ID DESC
                LIMIT 1
                """;
        return jdbc.query(sql, (rs, i) -> new AttemptRow(
                rs.getInt("Attempt_ID"),
                rs.getInt("Total_Points"),
                rs.getInt("Total_Points_Last"),
                rs.getInt("Amount_Questions"),
                rs.getInt("Possible_Points"),
                rs.getString("Status")
        ), studentId, quizId).stream().findFirst();
    }
}
