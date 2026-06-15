package com.hust.kawaiienglish.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hust.kawaiienglish.dto.response.DashboardRes;
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

    @GetMapping("/{id}")
    public DashboardRes getDashboard(@PathVariable int id) {
        return studentService.getDashboard(id);
    }
}
