package com.hust.kawaiienglish.dto.response;

import java.util.List;

/**
 * Bao đóng kết quả phân trang (Pagination/Limit) cho frontend.
 * content = dữ liệu trang hiện tại, kèm các chỉ số điều hướng.
 */
public record PageRes<T>(
        List<T> content,
        int page,
        int size,
        long totalElements,
        int totalPages
) {
    public static <T> PageRes<T> of(List<T> content, int page, int size, long totalElements) {
        int totalPages = size <= 0 ? 0 : (int) Math.ceil((double) totalElements / size);
        return new PageRes<>(content, page, size, totalElements, totalPages);
    }
}
