package com.hust.kawaiienglish.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hust.kawaiienglish.dto.response.DashboardRes;
import com.hust.kawaiienglish.dto.response.PageRes;
import com.hust.kawaiienglish.dto.response.StudentSummaryRes;
import com.hust.kawaiienglish.service.StudentService;

/**
 * API học sinh: danh sách (màn hình đăng nhập) và trang cá nhân (dashboard).
 */
@RestController
@RequestMapping("/api/students")
public class StudentController {

    private final StudentService studentService;

    public StudentController(StudentService studentService) {
        this.studentService = studentService;
    }

    @GetMapping
    public List<StudentSummaryRes> getAll() {
        return studentService.getAllStudents();
    }

    /** Danh sách học sinh có phân trang (10 HS/trang) cho Profile Switcher. */
    @GetMapping("/page")
    public PageRes<StudentSummaryRes> getPage(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return studentService.getStudentPage(page, size);
    }

    @GetMapping("/{id}")
    public DashboardRes getDashboard(@PathVariable int id) {
        return studentService.getDashboard(id);
    }
}
