package com.hust.kawaiienglish.dto.response;

/**
 * Một lớp học do giáo viên phụ trách - mỗi lớp là một tab ở giao diện giáo viên.
 */
public record TeacherClassRes(
        int classId,
        String className,
        String cefrLevel,
        int numStudents
) {}
