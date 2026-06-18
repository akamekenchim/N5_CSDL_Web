package com.hust.kawaiienglish.exception;

/**
 * Ném ra khi truy cập chức năng giáo viên mà chưa "đăng nhập" (chưa có Teacher_ID trong Session),
 * hoặc cố thao tác trên lớp/học sinh không thuộc quyền quản lý của mình.
 */
public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super(message);
    }
}
