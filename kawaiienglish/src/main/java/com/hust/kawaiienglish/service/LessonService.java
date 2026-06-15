package com.hust.kawaiienglish.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.hust.kawaiienglish.dto.response.LessonCatalogRes;
import com.hust.kawaiienglish.dto.response.LessonDetailRes;
import com.hust.kawaiienglish.exception.ResourceNotFoundException;
import com.hust.kawaiienglish.repository.LessonRepository;

/**
 * Logic nghiệp vụ cho bài giảng (danh mục + chi tiết từ vựng/ngữ pháp).
 */
@Service
public class LessonService {

    private final LessonRepository lessonRepository;

    public LessonService(LessonRepository lessonRepository) {
        this.lessonRepository = lessonRepository;
    }

    public List<LessonCatalogRes> getCatalog() {
        return lessonRepository.findCatalog();
    }

    public LessonDetailRes getDetail(int lessonId) {
        LessonCatalogRes info = lessonRepository.findCatalogById(lessonId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy bài giảng với ID = " + lessonId));
        return new LessonDetailRes(
                info.lessonId(),
                info.lessonTitle(),
                info.levelRequired(),
                info.teacherName(),
                lessonRepository.findVocabulary(lessonId),
                lessonRepository.findGrammar(lessonId));
    }
}
