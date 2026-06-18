package com.hust.kawaiienglish.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.hust.kawaiienglish.dto.request.AnswerItemReq;
import com.hust.kawaiienglish.dto.request.SubmitQuizReq;
import com.hust.kawaiienglish.dto.response.DashboardRes;
import com.hust.kawaiienglish.dto.response.QuestionResultRes;
import com.hust.kawaiienglish.dto.response.QuizQuestionRes;
import com.hust.kawaiienglish.dto.response.QuizSummaryRes;
import com.hust.kawaiienglish.dto.response.SubmitResultRes;
import com.hust.kawaiienglish.exception.ResourceNotFoundException;
import com.hust.kawaiienglish.model.AttemptRow;
import com.hust.kawaiienglish.repository.QuizRepository;
import com.hust.kawaiienglish.repository.StudentRepository;
import com.hust.kawaiienglish.repository.SubmissionRepository;

/**
 * Logic nghiệp vụ cho làm bài. Tầng này cố ý "mỏng": phần chấm điểm và cộng CLP
 * do Trigger + Stored Procedure trong DB tự xử lý khi ta INSERT bài nộp.
 */
@Service
public class QuizService {

    private final QuizRepository quizRepository;
    private final SubmissionRepository submissionRepository;
    private final StudentRepository studentRepository;

    public QuizService(QuizRepository quizRepository,
                       SubmissionRepository submissionRepository,
                       StudentRepository studentRepository) {
        this.quizRepository = quizRepository;
        this.submissionRepository = submissionRepository;
        this.studentRepository = studentRepository;
    }

    /**
     * Danh sách bài tập. Nếu truyền studentId, chỉ trả về bài tập mà học sinh đủ cấp độ làm
     * (theo Level_Required của bài giảng chứa bài tập đó).
     */
    public List<QuizSummaryRes> getAllQuizzes(Integer studentId) {
        if (studentId == null) {
            return quizRepository.findAllSummaries();
        }
        int level = studentRepository.findLevel(studentId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy học sinh với ID = " + studentId));
        return quizRepository.findSummariesForLevel(studentId, level);
    }

    public List<QuizQuestionRes> getQuestions(int quizId) {
        if (!quizRepository.existsById(quizId)) {
            throw new ResourceNotFoundException("Không tìm thấy bài tập với ID = " + quizId);
        }
        return quizRepository.findQuestions(quizId);
    }

    /**
     * Nộp toàn bộ bài làm. Mỗi câu là 1 INSERT vào Student_Submissions -> kích hoạt
     * Trigger tự tạo phiên (Attempt), chấm điểm, và khi đủ số câu thì gọi Stored Procedure
     * cộng CLP + xét lên level. Sau đó đọc lại kết quả từ DB để trả về.
     */
    public SubmitResultRes submitQuiz(SubmitQuizReq req) {
        if (req == null || req.studentId() == null || req.quizId() == null
                || req.answers() == null || req.answers().isEmpty()) {
            throw new IllegalArgumentException("Dữ liệu nộp bài không hợp lệ (thiếu studentId/quizId/answers).");
        }
        int studentId = req.studentId();
        int quizId = req.quizId();

        if (!studentRepository.existsById(studentId)) {
            throw new ResourceNotFoundException("Không tìm thấy học sinh với ID = " + studentId);
        }
        if (!quizRepository.existsById(quizId)) {
            throw new ResourceNotFoundException("Không tìm thấy bài tập với ID = " + quizId);
        }

        // Trạng thái TRƯỚC khi nộp (để so sánh có lên level không)
        DashboardRes before = studentRepository.findDashboard(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học sinh ID = " + studentId));
        int oldLevel = before.level();

        // Dọn phiên dang dở để mỗi lần làm lại là 1 phiên sạch
        submissionRepository.deleteInProgress(studentId, quizId);

        // Lần lượt nộp từng câu -> Trigger xử lý
        for (AnswerItemReq a : req.answers()) {
            if (a == null || a.questionId() == null) {
                continue;
            }
            String ans = a.answer() == null ? "" : a.answer().trim();
            submissionRepository.insertSubmission(studentId, a.questionId(), ans);
        }

        // Đọc lại phiên làm bài vừa hoàn tất
        AttemptRow attempt = submissionRepository.findLatestAttempt(studentId, quizId)
                .orElseThrow(() -> new IllegalStateException("Không tạo được phiên làm bài."));

        // Lấy nội dung + đáp án đúng để hiển thị lại cho học sinh
        Map<Integer, String[]> details = quizRepository.findQuestionDetails(quizId);
        List<QuestionResultRes> results = new ArrayList<>();
        for (AnswerItemReq a : req.answers()) {
            if (a == null || a.questionId() == null) {
                continue;
            }
            String[] d = details.get(a.questionId());
            String content = d != null ? d[0] : "";
            String correct = d != null ? d[1] : "";
            String your = a.answer() == null ? "" : a.answer().trim();
            boolean ok = correct != null && your.equalsIgnoreCase(correct.trim());
            results.add(new QuestionResultRes(a.questionId(), content, your, correct, ok));
        }

        // Trạng thái SAU khi nộp (DB đã tự cộng CLP / lên level)
        DashboardRes after = studentRepository.findDashboard(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học sinh ID = " + studentId));
        int newLevel = after.level();

        int tp = attempt.totalPoints();
        int aq = Math.max(1, attempt.amountQuestions());
        int pp = attempt.possiblePoints();
        int tpl = attempt.totalPointsLast();

        int pointsEarned = (int) Math.round((double) pp * tp / aq);
        int clpGain = (int) Math.max(0,
                Math.round((double) pp * tp / aq - (double) pp * tpl / aq));
        int minPass = quizRepository.findMinimumPassScore(quizId);
        boolean passed = pointsEarned >= minPass;

        return new SubmitResultRes(
                attempt.attemptId(), tp, attempt.amountQuestions(), pp, pointsEarned, clpGain,
                newLevel > oldLevel, oldLevel, newLevel,
                after.currentLevelProgress(), after.nextLevelClp(), after.accuracy(),
                minPass, passed, attempt.status(), results);
    }
}
