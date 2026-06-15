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
            rs.getString("Teacher_Email")
    );

    public List<LessonCatalogRes> findCatalog() {
        return jdbc.query("SELECT * FROM v_lesson_catalog ORDER BY Lesson_ID", CATALOG_MAPPER);
    }

    public Optional<LessonCatalogRes> findCatalogById(int lessonId) {
        return jdbc.query("SELECT * FROM v_lesson_catalog WHERE Lesson_ID = ?",
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
