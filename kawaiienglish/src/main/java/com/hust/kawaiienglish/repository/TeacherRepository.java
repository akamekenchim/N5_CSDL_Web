package com.hust.kawaiienglish.repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import com.hust.kawaiienglish.dto.response.TeacherClassRes;
import com.hust.kawaiienglish.dto.response.TeacherStudentRes;
import com.hust.kawaiienglish.dto.response.TeacherSummaryRes;

/**
 * Tầng kết nối DB cho vai trò Giáo viên: danh sách giáo viên (phân trang), các lớp dạy,
 * học sinh trong lớp, điều chỉnh điểm (gọi Stored Procedure) và tạo bài giảng (INSERT nhiều bảng).
 */
@Repository
public class TeacherRepository {

    private final JdbcTemplate jdbc;

    public TeacherRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /* =========================================================================
     * 1) PROFILE SWITCHER - danh sách giáo viên có phân trang (3 giáo viên / trang)
     * ========================================================================= */

    private static final RowMapper<TeacherSummaryRes> TEACHER_MAPPER = (rs, i) -> new TeacherSummaryRes(
            rs.getInt("Teacher_ID"),
            rs.getString("Full_Name"),
            rs.getString("Email"),
            rs.getInt("Class_Count")
    );

    public long countTeachers() {
        Long n = jdbc.queryForObject("SELECT COUNT(*) FROM Teacher", Long.class);
        return n == null ? 0 : n;
    }

    /** 1 trang giáo viên (LIMIT/OFFSET) kèm số lớp đang dạy. */
    public List<TeacherSummaryRes> findTeacherPage(int limit, int offset) {
        String sql = """
                SELECT t.Teacher_ID, t.Full_Name, t.Email,
                       (SELECT COUNT(*) FROM Classes c WHERE c.Teacher_ID = t.Teacher_ID) AS Class_Count
                FROM Teacher t
                ORDER BY t.Teacher_ID
                LIMIT ? OFFSET ?
                """;
        return jdbc.query(sql, TEACHER_MAPPER, limit, offset);
    }

    public Optional<TeacherSummaryRes> findTeacherById(int teacherId) {
        String sql = """
                SELECT t.Teacher_ID, t.Full_Name, t.Email,
                       (SELECT COUNT(*) FROM Classes c WHERE c.Teacher_ID = t.Teacher_ID) AS Class_Count
                FROM Teacher t
                WHERE t.Teacher_ID = ?
                """;
        return jdbc.query(sql, TEACHER_MAPPER, teacherId).stream().findFirst();
    }

    /* =========================================================================
     * 2) Các lớp do giáo viên dạy + học sinh trong từng lớp
     * ========================================================================= */

    /**
     * Các lớp do giáo viên hiện tại dạy.
     * Lệnh lõi theo yêu cầu: SELECT class_id FROM classes WHERE teacher_id = ?
     * (bổ sung tên lớp / cấp độ / sĩ số để hiển thị tab).
     */
    public List<TeacherClassRes> findClassesByTeacher(int teacherId) {
        String sql = """
                SELECT Class_ID, Class_Name, CEFR_Level, No_of_Students
                FROM Classes
                WHERE Teacher_ID = ?
                ORDER BY Class_ID
                """;
        return jdbc.query(sql, (rs, i) -> new TeacherClassRes(
                rs.getInt("Class_ID"),
                rs.getString("Class_Name"),
                rs.getString("CEFR_Level"),
                rs.getInt("No_of_Students")
        ), teacherId);
    }

    /** Lớp này có đúng do giáo viên đó dạy không (chặn xem lớp của người khác). */
    public boolean classBelongsToTeacher(int classId, int teacherId) {
        Integer n = jdbc.queryForObject(
                "SELECT COUNT(*) FROM Classes WHERE Class_ID = ? AND Teacher_ID = ?",
                Integer.class, classId, teacherId);
        return n != null && n > 0;
    }

    public long countStudentsInClass(int classId) {
        Long n = jdbc.queryForObject(
                "SELECT COUNT(*) FROM Students WHERE Class_ID = ?", Long.class, classId);
        return n == null ? 0 : n;
    }

    private static final RowMapper<TeacherStudentRes> STUDENT_MAPPER = (rs, i) -> new TeacherStudentRes(
            rs.getInt("Student_ID"),
            rs.getString("Full_Name"),
            rs.getString("Email"),
            rs.getString("Class_Name"),
            rs.getDouble("Accuracy"),
            rs.getInt("Level"),
            rs.getInt("Current_Level_Progress")
    );

    /**
     * Học sinh của 1 lớp (phân trang 10 HS/trang). JOIN Students + Classes để lấy
     * Họ tên, Email, Tên lớp và Accuracy.
     */
    public List<TeacherStudentRes> findStudentsInClass(int classId, int limit, int offset) {
        String sql = """
                SELECT s.Student_ID, s.Full_Name, s.Email, c.Class_Name,
                       s.Accuracy, s.Level, s.Current_Level_Progress
                FROM Students s
                JOIN Classes c ON s.Class_ID = c.Class_ID
                WHERE c.Class_ID = ?
                ORDER BY s.Student_ID
                LIMIT ? OFFSET ?
                """;
        return jdbc.query(sql, STUDENT_MAPPER, classId, limit, offset);
    }

    /** Đọc lại 1 học sinh (kèm tên lớp) để refresh UI sau khi chỉnh điểm. */
    public Optional<TeacherStudentRes> findStudentSummary(int studentId) {
        String sql = """
                SELECT s.Student_ID, s.Full_Name, s.Email, c.Class_Name,
                       s.Accuracy, s.Level, s.Current_Level_Progress
                FROM Students s
                LEFT JOIN Classes c ON s.Class_ID = c.Class_ID
                WHERE s.Student_ID = ?
                """;
        return jdbc.query(sql, STUDENT_MAPPER, studentId).stream().findFirst();
    }

    /** Học sinh này có thuộc một lớp do giáo viên đó dạy không. */
    public boolean studentBelongsToTeacher(int studentId, int teacherId) {
        Integer n = jdbc.queryForObject("""
                SELECT COUNT(*)
                FROM Students s
                JOIN Classes c ON s.Class_ID = c.Class_ID
                WHERE s.Student_ID = ? AND c.Teacher_ID = ?
                """, Integer.class, studentId, teacherId);
        return n != null && n > 0;
    }

    /* =========================================================================
     * 3) Điều chỉnh điểm: gọi Stored Procedure sp_check_levelup(stud_id, add_points)
     * ========================================================================= */

    /** Cộng/trừ điểm cho học sinh thông qua Stored Procedure (tự xét lên cấp). */
    public void adjustPoints(int studentId, int points) {
        jdbc.update("CALL sp_check_levelup(?, ?)", studentId, points);
    }

    /* =========================================================================
     * 4) Tạo bài giảng - các INSERT đơn lẻ (transaction do Service quản lý)
     * ========================================================================= */

    /** Bước 1: INSERT Lessons, trả về Lesson_ID tự sinh. */
    public int insertLesson(int levelRequired, String title, int teacherId) {
        KeyHolder kh = new GeneratedKeyHolder();
        jdbc.update(conn -> {
            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO Lessons (Level_Required, Title, Teacher_ID) VALUES (?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, levelRequired);
            ps.setString(2, title);
            ps.setInt(3, teacherId);
            return ps;
        }, kh);
        return keyOf(kh);
    }

    /** Bước 2a: INSERT 1 từ vựng theo Lesson_ID. */
    public void insertVocabulary(int lessonId, String content, String meaning, String example) {
        jdbc.update(
                "INSERT INTO Vocabulary (Content, Meaning, Example, Lesson_ID) VALUES (?, ?, ?, ?)",
                content, meaning, example, lessonId);
    }

    /** Bước 2b: INSERT 1 cấu trúc ngữ pháp theo Lesson_ID. */
    public void insertGrammar(int lessonId, String content, String example) {
        jdbc.update(
                "INSERT INTO Grammar_Structures (Lesson_ID, Content, Example) VALUES (?, ?, ?)",
                lessonId, content, example);
    }

    /** Bước 3a: INSERT Quizzes (không có tên bài), trả về Quiz_ID tự sinh. */
    public int insertQuiz(int lessonId, int minimumPassScore, int possiblePoints) {
        KeyHolder kh = new GeneratedKeyHolder();
        jdbc.update(conn -> {
            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO Quizzes (Lesson_ID, Minimum_Pass_Score, Possible_Points) VALUES (?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, lessonId);
            ps.setInt(2, minimumPassScore);
            ps.setInt(3, possiblePoints);
            return ps;
        }, kh);
        return keyOf(kh);
    }

    /** Bước 3b: INSERT 1 câu hỏi theo Quiz_ID. */
    public void insertQuestion(int quizId, String content, String correctAnswer) {
        jdbc.update(
                "INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES (?, ?, ?)",
                quizId, content, correctAnswer);
    }

    private static int keyOf(KeyHolder kh) {
        Number key = kh.getKey();
        if (key == null) {
            throw new IllegalStateException("Không lấy được khoá tự sinh từ DB.");
        }
        return key.intValue();
    }
}
