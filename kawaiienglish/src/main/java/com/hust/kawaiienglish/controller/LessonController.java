package com.hust.kawaiienglish.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hust.kawaiienglish.dto.response.LessonCatalogRes;
import com.hust.kawaiienglish.dto.response.LessonDetailRes;
import com.hust.kawaiienglish.service.LessonService;

/**
 * API bài giảng: danh mục và chi tiết (từ vựng + ngữ pháp).
 */
@RestController
@RequestMapping("/api/lessons")
public class LessonController {

    private final LessonService lessonService;

    public LessonController(LessonService lessonService) {
        this.lessonService = lessonService;
    }

    @GetMapping
    public List<LessonCatalogRes> getCatalog(@RequestParam(required = false) Integer studentId) {
        return lessonService.getCatalog(studentId);
    }

    @GetMapping("/{id}")
    public LessonDetailRes getDetail(@PathVariable int id,
                                     @RequestParam(required = false) Integer studentId) {
        return lessonService.getDetail(id, studentId);
    }
}
