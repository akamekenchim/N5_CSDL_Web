package com.hust.kawaiienglish.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class TestController {

    // Tiêm (Inject) công cụ thao tác Database trực tiếp của Spring
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/ping")
    public String ping() {
        return "Server is running perfectly!";
    }

    // Endpoint mới để test Database
    @GetMapping("/db-check")
    public String checkDatabaseConnection() {
        try {
            // Thử chạy một lệnh SQL thật: Lấy tên người đứng Top 1 từ View Bảng xếp hạng
            String sql = "SELECT Full_Name FROM v_leaderboard LIMIT 1";
            String topStudent = jdbcTemplate.queryForObject(sql, String.class);
            
            return "✅ KẾT NỐI DATABASE THÀNH CÔNG! \n" +
                   "Học sinh đang đứng Top 1 trong hệ thống hiện tại là: " + topStudent;
                   
        } catch (Exception e) {
            return "❌ KẾT NỐI THẤT BẠI. Lỗi chi tiết: " + e.getMessage();
        }
    }
}