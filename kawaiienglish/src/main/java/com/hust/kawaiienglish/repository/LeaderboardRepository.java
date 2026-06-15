package com.hust.kawaiienglish.repository;

import java.util.List;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.hust.kawaiienglish.dto.response.LeaderboardRowRes;

/**
 * Đọc bảng xếp hạng trực tiếp từ view v_leaderboard.
 */
@Repository
public class LeaderboardRepository {

    private final JdbcTemplate jdbc;

    public LeaderboardRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<LeaderboardRowRes> MAPPER = (rs, i) -> new LeaderboardRowRes(
            rs.getInt("Student_ID"),
            rs.getString("Full_Name"),
            rs.getString("Class_Name"),
            rs.getInt("Level"),
            rs.getInt("Current_Level_Progress"),
            rs.getDouble("Accuracy"),
            rs.getInt("Rank_Position")
    );

    public List<LeaderboardRowRes> findAll() {
        String sql = """
                SELECT Student_ID, Full_Name, Class_Name, Level, Current_Level_Progress, Accuracy, Rank_Position
                FROM v_leaderboard
                ORDER BY Rank_Position ASC, Level DESC, Current_Level_Progress DESC
                """;
        return jdbc.query(sql, MAPPER);
    }

    /** Thứ hạng của 1 học sinh (null nếu không có). */
    public Integer findRank(int studentId) {
        try {
            return jdbc.queryForObject(
                    "SELECT Rank_Position FROM v_leaderboard WHERE Student_ID = ?",
                    Integer.class, studentId);
        } catch (EmptyResultDataAccessException ex) {
            return null;
        }
    }
}
