package com.hust.kawaiienglish.repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.hust.kawaiienglish.dto.response.QuizQuestionRes;
import com.hust.kawaiienglish.dto.response.QuizSummaryRes;

/**
 * Tầng kết nối DB cho Quizzes / Questions.
 */
@Repository
public class QuizRepository {

    private final JdbcTemplate jdbc;

    public QuizRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<QuizSummaryRes> SUMMARY_MAPPER = (rs, i) -> new QuizSummaryRes(
            rs.getInt("Quiz_ID"),
            rs.getString("Title"),
            rs.getInt("Level_Required"),
            rs.getInt("Num_Questions"),
            rs.getInt("Possible_Points"),
            rs.getInt("Minimum_Pass_Score"),
            rs.getInt("Attempted") != 0,
            rs.getInt("Best_Score")
    );

    private static final String FROM_QUIZ = """
            FROM Quizzes qz
            JOIN Lessons l   ON qz.Lesson_ID = l.Lesson_ID
            JOIN Questions q ON q.Quiz_ID = qz.Quiz_ID
            """;
    private static final String SUMMARY_GROUP =
            " GROUP BY qz.Quiz_ID, l.Title, l.Level_Required, qz.Possible_Points, qz.Minimum_Pass_Score"
            + " ORDER BY qz.Quiz_ID";

    /** SQL nền không gắn học sinh: attempted/bestScore để mặc định 0. */
    private static final String SUMMARY_SELECT =
            "SELECT qz.Quiz_ID, l.Title, l.Level_Required, qz.Possible_Points, qz.Minimum_Pass_Score, "
            + "COUNT(q.Question_ID) AS Num_Questions, 0 AS Attempted, 0 AS Best_Score "
            + FROM_QUIZ;

    /**
     * SQL gắn học sinh: thêm hai cột phụ thuộc Student_ID (tham số ? đầu tiên & thứ hai):
     *  - Best_Score = điểm cao nhất từng đạt: SELECT COALESCE(MAX(total_points),0) ... status='COMPLETED'
     *  - Attempted  = đã có lượt làm bài này chưa
     */
    private static final String SUMMARY_SELECT_STUDENT =
            "SELECT qz.Quiz_ID, l.Title, l.Level_Required, qz.Possible_Points, qz.Minimum_Pass_Score, "
            + "COUNT(q.Question_ID) AS Num_Questions, "
            + "EXISTS(SELECT 1 FROM Attempts a2 WHERE a2.Student_ID = ? AND a2.Quiz_ID = qz.Quiz_ID) AS Attempted, "
            + "(SELECT COALESCE(MAX(at.Total_Points), 0) FROM Attempts at "
            + " WHERE at.Student_ID = ? AND at.Quiz_ID = qz.Quiz_ID AND at.Status = 'COMPLETED') AS Best_Score "
            + FROM_QUIZ;

    public List<QuizSummaryRes> findAllSummaries() {
        return jdbc.query(SUMMARY_SELECT + SUMMARY_GROUP, SUMMARY_MAPPER);
    }

    /**
     * Bài tập học sinh đủ cấp độ làm (Level_Required <= level), kèm cờ đã-làm và điểm cao nhất.
     * Thứ tự tham số: studentId (Attempted), studentId (Best_Score), studentLevel (WHERE).
     */
    public List<QuizSummaryRes> findSummariesForLevel(int studentId, int studentLevel) {
        return jdbc.query(SUMMARY_SELECT_STUDENT + " WHERE l.Level_Required <= ?" + SUMMARY_GROUP,
                SUMMARY_MAPPER, studentId, studentId, studentLevel);
    }

    /** Các bài tập của 1 bài giảng, kèm cờ đã-làm + điểm cao nhất của học sinh. */
    public List<QuizSummaryRes> findByLessonId(int studentId, int lessonId) {
        return jdbc.query(SUMMARY_SELECT_STUDENT + " WHERE qz.Lesson_ID = ?" + SUMMARY_GROUP,
                SUMMARY_MAPPER, studentId, studentId, lessonId);
    }

    /** Các bài tập của 1 bài giảng (không gắn học sinh - dùng cho ngữ cảnh quản trị). */
    public List<QuizSummaryRes> findByLessonId(int lessonId) {
        return jdbc.query(SUMMARY_SELECT + " WHERE qz.Lesson_ID = ?" + SUMMARY_GROUP,
                SUMMARY_MAPPER, lessonId);
    }

    public boolean existsById(int quizId) {
        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM Quizzes WHERE Quiz_ID = ?", Integer.class, quizId);
        return count != null && count > 0;
    }

    /** Danh sách câu hỏi (đã ẩn đáp án) để học sinh làm bài. */
    public List<QuizQuestionRes> findQuestions(int quizId) {
        String sql = "SELECT Question_ID, Content FROM Questions WHERE Quiz_ID = ? ORDER BY Question_ID";
        return jdbc.query(sql, (rs, i) -> new QuizQuestionRes(
                rs.getInt("Question_ID"), rs.getString("Content")), quizId);
    }

    /** Map Question_ID -> { content, correctAnswer } để chấm và hiển thị lại. */
    public Map<Integer, String[]> findQuestionDetails(int quizId) {
        String sql = "SELECT Question_ID, Content, Correct_Answer FROM Questions WHERE Quiz_ID = ?";
        return jdbc.query(sql, rs -> {
            Map<Integer, String[]> map = new HashMap<>();
            while (rs.next()) {
                map.put(rs.getInt("Question_ID"),
                        new String[]{rs.getString("Content"), rs.getString("Correct_Answer")});
            }
            return map;
        }, quizId);
    }

    public int findMinimumPassScore(int quizId) {
        try {
            Integer v = jdbc.queryForObject(
                    "SELECT Minimum_Pass_Score FROM Quizzes WHERE Quiz_ID = ?", Integer.class, quizId);
            return v == null ? 0 : v;
        } catch (EmptyResultDataAccessException ex) {
            return 0;
        }
    }
}
