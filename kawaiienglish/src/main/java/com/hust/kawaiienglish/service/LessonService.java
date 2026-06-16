package com.hust.kawaiienglish.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.hust.kawaiienglish.dto.response.LessonCatalogRes;
import com.hust.kawaiienglish.dto.response.LessonDetailRes;
import com.hust.kawaiienglish.exception.ResourceNotFoundException;
import com.hust.kawaiienglish.repository.LessonRepository;
import com.hust.kawaiienglish.repository.QuizRepository;
import com.hust.kawaiienglish.repository.StudentRepository;

/**
 * Logic nghiệp vụ cho bài giảng (danh mục + chi tiết từ vựng/ngữ pháp/bài tập).
 */
@Service
public class LessonService {

    private final LessonRepository lessonRepository;
    private final QuizRepository quizRepository;
    private final StudentRepository studentRepository;

    public LessonService(LessonRepository lessonRepository,
                         QuizRepository quizRepository,
                         StudentRepository studentRepository) {
        this.lessonRepository = lessonRepository;
        this.quizRepository = quizRepository;
        this.studentRepository = studentRepository;
    }

    /**
     * Danh mục bài giảng. Nếu truyền studentId, chỉ trả về bài giảng mà học sinh
     * đủ cấp độ để học (Level_Required <= Level của học sinh).
     */
    public List<LessonCatalogRes> getCatalog(Integer studentId) {
        if (studentId == null) {
            return lessonRepository.findCatalog();
        }
        int level = studentRepository.findLevel(studentId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy học sinh với ID = " + studentId));
        return lessonRepository.findCatalogForLevel(level);
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
                lessonRepository.findGrammar(lessonId),
                quizRepository.findByLessonId(lessonId));
    }
}
