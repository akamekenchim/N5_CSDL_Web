package com.hust.kawaiienglish.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hust.kawaiienglish.dto.request.AdjustPointsReq;
import com.hust.kawaiienglish.dto.request.CreateLessonReq;
import com.hust.kawaiienglish.dto.response.CreateLessonRes;
import com.hust.kawaiienglish.dto.response.PageRes;
import com.hust.kawaiienglish.dto.response.TeacherClassRes;
import com.hust.kawaiienglish.dto.response.TeacherStudentRes;
import com.hust.kawaiienglish.dto.response.TeacherSummaryRes;
import com.hust.kawaiienglish.exception.UnauthorizedException;
import com.hust.kawaiienglish.service.TeacherService;

import jakarta.servlet.http.HttpSession;

/**
 * API cho vai trò Giáo viên. Teacher_ID đang "đăng nhập" được lưu trong HttpSession
 * (khoá {@link #SESSION_TEACHER_ID}); các chức năng quản lý đọc thẳng từ Session,
 * không tin tưởng Teacher_ID do client gửi lên.
 */
@RestController
@RequestMapping("/api/teachers")
public class TeacherController {

    public static final String SESSION_TEACHER_ID = "TEACHER_ID";

    private final TeacherService teacherService;

    public TeacherController(TeacherService teacherService) {
        this.teacherService = teacherService;
    }

    /* ----- Profile switcher (3 giáo viên / trang) ----- */

    @GetMapping
    public PageRes<TeacherSummaryRes> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "3") int size) {
        return teacherService.getTeacherPage(page, size);
    }

    /** Chọn 1 giáo viên -> ghi nhớ Teacher_ID vào Session. */
    @PostMapping("/{id}/login")
    public TeacherSummaryRes login(@PathVariable int id, HttpSession session) {
        TeacherSummaryRes teacher = teacherService.requireTeacher(id);
        session.setAttribute(SESSION_TEACHER_ID, teacher.teacherId());
        return teacher;
    }

    /** Giáo viên đang đăng nhập trong Session (dùng để khôi phục phiên ở frontend). */
    @GetMapping("/me")
    public TeacherSummaryRes me(HttpSession session) {
        return teacherService.requireTeacher(currentTeacherId(session));
    }

    @PostMapping("/logout")
    public void logout(HttpSession session) {
        session.removeAttribute(SESSION_TEACHER_ID);
    }

    /* ----- Quản lý lớp & học sinh ----- */

    @GetMapping("/me/classes")
    public List<TeacherClassRes> myClasses(HttpSession session) {
        return teacherService.getClasses(currentTeacherId(session));
    }

    @GetMapping("/me/classes/{classId}/students")
    public PageRes<TeacherStudentRes> studentsOfClass(
            @PathVariable int classId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpSession session) {
        return teacherService.getStudentsInClass(currentTeacherId(session), classId, page, size);
    }

    /** Cộng/trừ điểm cho học sinh -> CALL sp_check_levelup(studentId, points). */
    @PostMapping("/students/{studentId}/points")
    public TeacherStudentRes adjustPoints(
            @PathVariable int studentId,
            @RequestBody AdjustPointsReq req,
            HttpSession session) {
        return teacherService.adjustPoints(currentTeacherId(session), studentId,
                req == null ? null : req.points());
    }

    /* ----- Tạo bài giảng (1 transaction) ----- */

    @PostMapping("/lessons")
    public CreateLessonRes createLesson(@RequestBody CreateLessonReq req, HttpSession session) {
        return teacherService.createLesson(currentTeacherId(session), req);
    }

    /* ----- Helper ----- */

    private int currentTeacherId(HttpSession session) {
        Object v = session.getAttribute(SESSION_TEACHER_ID);
        if (v == null) {
            throw new UnauthorizedException("Bạn chưa đăng nhập với vai trò Giáo viên.");
        }
        return (int) v;
    }
}
