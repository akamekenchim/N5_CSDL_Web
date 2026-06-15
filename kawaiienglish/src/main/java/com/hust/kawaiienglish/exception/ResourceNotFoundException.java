package com.hust.kawaiienglish.exception;

/**
 * Ném ra khi không tìm thấy tài nguyên (VD: học sinh / bài tập không tồn tại).
 */
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
