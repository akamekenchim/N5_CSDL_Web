package com.hust.kawaiienglish.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class TestController {

    @GetMapping("/ping")
    public String pingSystem() {
        return "Xin chào Gia Anh và Bình Minh! Hệ thống Kawaii English Backend đã chạy thành công ở cổng 8080!";
    }
}