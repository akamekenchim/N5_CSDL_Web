package com.hust.kawaiienglish.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.hust.kawaiienglish.dto.response.GrammarRes;
import com.hust.kawaiienglish.dto.response.LessonCatalogRes;
import com.hust.kawaiienglish.dto.response.VocabularyRes;

/**
 * Tầng kết nối DB cho bài giảng: view v_lesson_catalog + bảng Vocabulary, Grammar_Structures.
 */
@Repository
public class LessonRepository {

    private final JdbcTemplate jdbc;

    public LessonRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<LessonCatalogRes> CATALOG_MAPPER = (rs, i) -> new LessonCatalogRes(
            rs.getInt("Lesson_ID"),
            rs.getString("Lesson_Title"),
            rs.getInt("Level_Required"),
            rs.getString("Teacher_Name"),
            rs.getString("Teacher_Email"),
            rs.getInt("Attempted") != 0
    );

    public List<LessonCatalogRes> findCatalog() {
        return jdbc.query("SELECT v.*, 0 AS Attempted FROM v_lesson_catalog v ORDER BY v.Lesson_ID",
                CATALOG_MAPPER);
    }

    /**
     * Bài giảng học sinh đủ cấp độ học (Level_Required <= level), kèm cờ "đã học" =
     * học sinh đã làm bài tập nào thuộc bài giảng này chưa (để đổi màu nền).
     */
    public List<LessonCatalogRes> findCatalogForLevel(int studentId, int studentLevel) {
        String sql = """
                SELECT v.*,
                       EXISTS(SELECT 1 FROM Quizzes qz
                              JOIN Attempts a ON a.Quiz_ID = qz.Quiz_ID
                              WHERE qz.Lesson_ID = v.Lesson_ID AND a.Student_ID = ?) AS Attempted
                FROM v_lesson_catalog v
                WHERE v.Level_Required <= ?
                ORDER BY v.Lesson_ID
                """;
        return jdbc.query(sql, CATALOG_MAPPER, studentId, studentLevel);
    }

    public Optional<LessonCatalogRes> findCatalogById(int lessonId) {
        return jdbc.query("SELECT v.*, 0 AS Attempted FROM v_lesson_catalog v WHERE v.Lesson_ID = ?",
                CATALOG_MAPPER, lessonId).stream().findFirst();
    }

    public List<VocabularyRes> findVocabulary(int lessonId) {
        return jdbc.query(
                "SELECT V_ID, Content, Meaning, Example FROM Vocabulary WHERE Lesson_ID = ? ORDER BY V_ID",
                (rs, i) -> new VocabularyRes(rs.getInt("V_ID"), rs.getString("Content"),
                        rs.getString("Meaning"), rs.getString("Example")),
                lessonId);
    }

    public List<GrammarRes> findGrammar(int lessonId) {
        return jdbc.query(
                "SELECT GS_ID, Content, Example FROM Grammar_Structures WHERE Lesson_ID = ? ORDER BY GS_ID",
                (rs, i) -> new GrammarRes(rs.getInt("GS_ID"), rs.getString("Content"), rs.getString("Example")),
                lessonId);
    }
}
