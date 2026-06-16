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
            rs.getInt("Minimum_Pass_Score")
    );

    /** SQL nền: mỗi quiz kèm thông tin bài giảng (Lesson) + đếm số câu hỏi. */
    private static final String SUMMARY_SELECT = """
            SELECT qz.Quiz_ID, l.Title, l.Level_Required,
                   qz.Possible_Points, qz.Minimum_Pass_Score,
                   COUNT(q.Question_ID) AS Num_Questions
            FROM Quizzes qz
            JOIN Lessons l   ON qz.Lesson_ID = l.Lesson_ID
            JOIN Questions q ON q.Quiz_ID = qz.Quiz_ID
            """;
    private static final String SUMMARY_GROUP =
            " GROUP BY qz.Quiz_ID, l.Title, l.Level_Required, qz.Possible_Points, qz.Minimum_Pass_Score"
            + " ORDER BY qz.Quiz_ID";

    public List<QuizSummaryRes> findAllSummaries() {
        return jdbc.query(SUMMARY_SELECT + SUMMARY_GROUP, SUMMARY_MAPPER);
    }

    /** Chỉ các bài tập mà học sinh đủ cấp độ làm (theo Level_Required của bài giảng). */
    public List<QuizSummaryRes> findSummariesForLevel(int studentLevel) {
        return jdbc.query(SUMMARY_SELECT + " WHERE l.Level_Required <= ?" + SUMMARY_GROUP,
                SUMMARY_MAPPER, studentLevel);
    }

    /** Các bài tập thuộc về 1 bài giảng cụ thể (đính kèm qua Lesson_ID trong bảng Quizzes). */
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
