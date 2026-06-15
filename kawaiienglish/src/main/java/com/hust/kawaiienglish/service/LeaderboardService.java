package com.hust.kawaiienglish.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.hust.kawaiienglish.dto.response.LeaderboardRowRes;
import com.hust.kawaiienglish.repository.LeaderboardRepository;

/**
 * Logic nghiệp vụ cho bảng xếp hạng.
 */
@Service
public class LeaderboardService {

    private final LeaderboardRepository leaderboardRepository;

    public LeaderboardService(LeaderboardRepository leaderboardRepository) {
        this.leaderboardRepository = leaderboardRepository;
    }

    public List<LeaderboardRowRes> getLeaderboard() {
        return leaderboardRepository.findAll();
    }
}
