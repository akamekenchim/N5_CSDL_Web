package com.hust.kawaiienglish.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.hust.kawaiienglish.dto.response.DashboardRes;
import com.hust.kawaiienglish.dto.response.StudentSummaryRes;

/**
 * Tầng kết nối DB cho bảng Students và view v_student_dashboard.
 */
@Repository
public class StudentRepository {

    private final JdbcTemplate jdbc;

    public StudentRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<StudentSummaryRes> SUMMARY_MAPPER = (rs, i) -> new StudentSummaryRes(
            rs.getInt("Student_ID"),
            rs.getString("Full_Name"),
            rs.getInt("Level"),
            rs.getString("Assessment_CEFR"),
            rs.getString("Class_Name")
    );

    public List<StudentSummaryRes> findAllSummaries() {
        String sql = """
                SELECT s.Student_ID, s.Full_Name, s.Level, s.Assessment_CEFR, c.Class_Name
                FROM Students s
                LEFT JOIN Classes c ON s.Class_ID = c.Class_ID
                ORDER BY s.Student_ID
                """;
        return jdbc.query(sql, SUMMARY_MAPPER);
    }

    public boolean existsById(int studentId) {
        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM Students WHERE Student_ID = ?", Integer.class, studentId);
        return count != null && count > 0;
    }

    /** Đọc thông tin dashboard từ view (rankPosition để null, sẽ được Service bổ sung). */
    public Optional<DashboardRes> findDashboard(int studentId) {
        String sql = "SELECT * FROM v_student_dashboard WHERE Student_ID = ?";
        return jdbc.query(sql, (rs, i) -> new DashboardRes(
                rs.getInt("Student_ID"),
                rs.getString("Student_Name"),
                rs.getString("Student_Email"),
                rs.getInt("Level"),
                rs.getInt("Current_Level_Progress"),
                (Integer) rs.getObject("Next_Level_CLP"),
                rs.getDouble("Accuracy"),
                rs.getInt("Total_Answered"),
                rs.getInt("Total_Correct"),
                rs.getString("Assessment_CEFR"),
                rs.getString("Class_Name"),
                rs.getString("Teacher_Name"),
                null
        ), studentId).stream().findFirst();
    }
}
