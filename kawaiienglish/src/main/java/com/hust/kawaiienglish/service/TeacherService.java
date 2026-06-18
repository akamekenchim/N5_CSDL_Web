package com.hust.kawaiienglish.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.hust.kawaiienglish.dto.request.CreateLessonReq;
import com.hust.kawaiienglish.dto.request.LessonGrammarReq;
import com.hust.kawaiienglish.dto.request.LessonQuestionReq;
import com.hust.kawaiienglish.dto.request.LessonVocabReq;
import com.hust.kawaiienglish.dto.response.CreateLessonRes;
import com.hust.kawaiienglish.dto.response.PageRes;
import com.hust.kawaiienglish.dto.response.TeacherClassRes;
import com.hust.kawaiienglish.dto.response.TeacherStudentRes;
import com.hust.kawaiienglish.dto.response.TeacherSummaryRes;
import com.hust.kawaiienglish.exception.ResourceNotFoundException;
import com.hust.kawaiienglish.exception.UnauthorizedException;
import com.hust.kawaiienglish.repository.TeacherRepository;

/**
 * Logic nghiệp vụ cho vai trò Giáo viên.
 */
@Service
public class TeacherService {

    /** Số bản ghi con cố định theo yêu cầu workflow tạo bài giảng. */
    private static final int REQUIRED_VOCAB = 5;
    private static final int REQUIRED_GRAMMAR = 2;
    private static final int REQUIRED_QUESTIONS = 3;

    private final TeacherRepository teacherRepository;

    public TeacherService(TeacherRepository teacherRepository) {
        this.teacherRepository = teacherRepository;
    }

    /* ----- Profile switcher ----- */

    public PageRes<TeacherSummaryRes> getTeacherPage(int page, int size) {
        int p = Math.max(0, page);
        int s = Math.max(1, size);
        long total = teacherRepository.countTeachers();
        List<TeacherSummaryRes> content = teacherRepository.findTeacherPage(s, p * s);
        return PageRes.of(content, p, s, total);
    }

    /** Xác thực giáo viên tồn tại (dùng khi "đăng nhập" và lưu Teacher_ID vào Session). */
    public TeacherSummaryRes requireTeacher(int teacherId) {
        return teacherRepository.findTeacherById(teacherId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy giáo viên với ID = " + teacherId));
    }

    /* ----- Quản lý lớp & học sinh ----- */

    public List<TeacherClassRes> getClasses(int teacherId) {
        return teacherRepository.findClassesByTeacher(teacherId);
    }

    public PageRes<TeacherStudentRes> getStudentsInClass(int teacherId, int classId, int page, int size) {
        if (!teacherRepository.classBelongsToTeacher(classId, teacherId)) {
            throw new UnauthorizedException("Lớp #" + classId + " không thuộc quyền quản lý của bạn.");
        }
        int p = Math.max(0, page);
        int s = Math.max(1, size);
        long total = teacherRepository.countStudentsInClass(classId);
        List<TeacherStudentRes> content = teacherRepository.findStudentsInClass(classId, s, p * s);
        return PageRes.of(content, p, s, total);
    }

    /**
     * Tăng/giảm điểm cho 1 học sinh -> gọi Stored Procedure sp_check_levelup.
     * points có thể âm hoặc dương. Trả về thông tin học sinh đã cập nhật.
     */
    public TeacherStudentRes adjustPoints(int teacherId, int studentId, Integer points) {
        if (points == null) {
            throw new IllegalArgumentException("Thiếu số điểm cần cộng/trừ.");
        }
        if (!teacherRepository.studentBelongsToTeacher(studentId, teacherId)) {
            throw new UnauthorizedException(
                    "Học sinh #" + studentId + " không thuộc lớp nào của bạn.");
        }
        teacherRepository.adjustPoints(studentId, points);
        return teacherRepository.findStudentSummary(studentId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy học sinh với ID = " + studentId));
    }

    /* ----- Tạo bài giảng (1 transaction) ----- */

    /**
     * Workflow tạo bài giảng 3 bước, chạy trọn vẹn trong 1 transaction:
     * nếu bất kỳ bước nào lỗi thì toàn bộ được rollback.
     */
    @Transactional
    public CreateLessonRes createLesson(int teacherId, CreateLessonReq req) {
        validate(req);

        // Bước 1: Lessons -> lấy Lesson_ID tự sinh
        int lessonId = teacherRepository.insertLesson(req.levelRequired(), req.title().trim(), teacherId);

        // Bước 2: 5 từ vựng + 2 ngữ pháp theo Lesson_ID
        for (LessonVocabReq v : req.vocabulary()) {
            teacherRepository.insertVocabulary(lessonId,
                    safe(v.content()), safe(v.meaning()), safe(v.example()));
        }
        for (LessonGrammarReq g : req.grammar()) {
            teacherRepository.insertGrammar(lessonId, safe(g.content()), safe(g.example()));
        }

        // Bước 3: Quizzes -> lấy Quiz_ID tự sinh; rồi 3 câu hỏi theo Quiz_ID
        int quizId = teacherRepository.insertQuiz(lessonId, req.minimumPassScore(), req.possiblePoints());
        for (LessonQuestionReq q : req.questions()) {
            teacherRepository.insertQuestion(quizId, safe(q.content()), safe(q.correctAnswer()));
        }

        return new CreateLessonRes(lessonId, quizId,
                req.vocabulary().size(), req.grammar().size(), req.questions().size());
    }

    private void validate(CreateLessonReq req) {
        if (req == null) {
            throw new IllegalArgumentException("Thiếu dữ liệu tạo bài giảng.");
        }
        if (req.title() == null || req.title().isBlank()) {
            throw new IllegalArgumentException("Tiêu đề bài giảng không được để trống.");
        }
        if (req.levelRequired() == null || req.levelRequired() < 1 || req.levelRequired() > 6) {
            throw new IllegalArgumentException("Level_Required phải nằm trong khoảng 1..6.");
        }
        if (req.vocabulary() == null || req.vocabulary().size() != REQUIRED_VOCAB) {
            throw new IllegalArgumentException("Cần đúng " + REQUIRED_VOCAB + " từ vựng.");
        }
        if (req.grammar() == null || req.grammar().size() != REQUIRED_GRAMMAR) {
            throw new IllegalArgumentException("Cần đúng " + REQUIRED_GRAMMAR + " cấu trúc ngữ pháp.");
        }
        if (req.minimumPassScore() == null || req.minimumPassScore() < 0) {
            throw new IllegalArgumentException("Mốc điểm qua (Minimum_Pass_Score) không hợp lệ.");
        }
        if (req.possiblePoints() == null || req.possiblePoints() < 0) {
            throw new IllegalArgumentException("Tổng điểm (Possible_Points) không hợp lệ.");
        }
        if (req.questions() == null || req.questions().size() != REQUIRED_QUESTIONS) {
            throw new IllegalArgumentException("Cần đúng " + REQUIRED_QUESTIONS + " câu hỏi.");
        }
    }

    private static String safe(String s) {
        return s == null ? "" : s.trim();
    }
}
