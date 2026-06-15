package com.hust.kawaiienglish.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.hust.kawaiienglish.dto.response.DashboardRes;
import com.hust.kawaiienglish.dto.response.StudentSummaryRes;
import com.hust.kawaiienglish.exception.ResourceNotFoundException;
import com.hust.kawaiienglish.repository.LeaderboardRepository;
import com.hust.kawaiienglish.repository.StudentRepository;

/**
 * Logic nghiệp vụ cho học sinh: lấy danh sách và thông tin trang cá nhân.
 */
@Service
public class StudentService {

    private final StudentRepository studentRepository;
    private final LeaderboardRepository leaderboardRepository;

    public StudentService(StudentRepository studentRepository, LeaderboardRepository leaderboardRepository) {
        this.studentRepository = studentRepository;
        this.leaderboardRepository = leaderboardRepository;
    }

    public List<StudentSummaryRes> getAllStudents() {
        return studentRepository.findAllSummaries();
    }

    /** Thông tin dashboard + thứ hạng (rank) ghép từ bảng xếp hạng. */
    public DashboardRes getDashboard(int studentId) {
        DashboardRes base = studentRepository.findDashboard(studentId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy học sinh với ID = " + studentId));
        Integer rank = leaderboardRepository.findRank(studentId);
        return new DashboardRes(
                base.studentId(), base.studentName(), base.studentEmail(),
                base.level(), base.currentLevelProgress(), base.nextLevelClp(),
                base.accuracy(), base.totalAnswered(), base.totalCorrect(),
                base.assessmentCefr(), base.className(), base.teacherName(),
                rank);
    }
}
