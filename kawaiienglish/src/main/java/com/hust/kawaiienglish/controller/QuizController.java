package com.hust.kawaiienglish.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hust.kawaiienglish.dto.request.SubmitQuizReq;
import com.hust.kawaiienglish.dto.response.QuizQuestionRes;
import com.hust.kawaiienglish.dto.response.QuizSummaryRes;
import com.hust.kawaiienglish.dto.response.SubmitResultRes;
import com.hust.kawaiienglish.service.QuizService;

/**
 * API bài tập: danh sách quiz, lấy câu hỏi (ẩn đáp án), và nộp bài.
 */
@RestController
@RequestMapping("/api/quizzes")
public class QuizController {

    private final QuizService quizService;

    public QuizController(QuizService quizService) {
        this.quizService = quizService;
    }

    @GetMapping
    public List<QuizSummaryRes> getAll(@RequestParam(required = false) Integer studentId) {
        return quizService.getAllQuizzes(studentId);
    }

    @GetMapping("/{id}/questions")
    public List<QuizQuestionRes> getQuestions(@PathVariable int id) {
        return quizService.getQuestions(id);
    }

    @PostMapping("/submit")
    public SubmitResultRes submit(@RequestBody SubmitQuizReq request) {
        return quizService.submitQuiz(request);
    }
}
