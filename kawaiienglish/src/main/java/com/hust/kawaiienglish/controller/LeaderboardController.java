package com.hust.kawaiienglish.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hust.kawaiienglish.dto.response.LeaderboardRowRes;
import com.hust.kawaiienglish.service.LeaderboardService;

/**
 * API bảng xếp hạng.
 */
@RestController
@RequestMapping("/api/leaderboard")
public class LeaderboardController {

    private final LeaderboardService leaderboardService;

    public LeaderboardController(LeaderboardService leaderboardService) {
        this.leaderboardService = leaderboardService;
    }

    @GetMapping
    public List<LeaderboardRowRes> getLeaderboard() {
        return leaderboardService.getLeaderboard();
    }
}
