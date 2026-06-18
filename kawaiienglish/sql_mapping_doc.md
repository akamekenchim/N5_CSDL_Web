# SQL Mapping Document — Tính năng Giáo viên (KawaiiEnglish)

Tài liệu này liệt kê **tường tận** các câu lệnh SQL ngầm (INSERT / SELECT / CALL) mà từng
tính năng Spring Boot thực thi, kèm theo **Controller → Service → Repository** tương ứng.

- Kiến trúc: `Controller (REST) → Service (nghiệp vụ) → Repository (JdbcTemplate)`.
- Tất cả SQL chạy qua `org.springframework.jdbc.core.JdbcTemplate` (tham số `?` là PreparedStatement).
- Database mục tiêu: `n5_kawaiienglish_1`.

Mục lục:
1. [Profile Switcher: vai trò + phân trang + Session](#1-profile-switcher)
2. [Giáo viên: xem học sinh theo lớp + chỉnh điểm](#2-giáo-viên-xem-học-sinh--chỉnh-điểm)
3. [Giáo viên: tạo bài giảng (1 transaction)](#3-giáo-viên-tạo-bài-giảng-1-transaction)
4. [Học sinh: highlight đã xem/đã làm + điểm cao nhất](#4-học-sinh-highlight--điểm-cao-nhất)
5. [Bảng tra cứu nhanh Endpoint → SQL](#5-bảng-tra-cứu-nhanh)

---

## 1. Profile Switcher

Màn hình chọn vai trò (`index.html` + `js/login.js`): chuyển giữa **Học sinh** (10 hồ sơ/trang)
và **Giáo viên** (3 hồ sơ/trang). Chọn một giáo viên → lưu `Teacher_ID` vào **HttpSession**.

### 1.1. Danh sách học sinh có phân trang (10 HS/trang)

- **Controller**: `StudentController.getPage()` — `GET /api/students/page?page=&size=`
- **Service**: `StudentService.getStudentPage()`
- **Repository**: `StudentRepository.countAll()` + `findSummariesPage()`

```sql
-- Đếm tổng (tính totalPages)
SELECT COUNT(*) FROM Students;

-- Lấy 1 trang (size = 10, offset = page*size)
SELECT s.Student_ID, s.Full_Name, s.Level, s.Assessment_CEFR, c.Class_Name
FROM Students s
LEFT JOIN Classes c ON s.Class_ID = c.Class_ID
ORDER BY s.Student_ID
LIMIT ? OFFSET ?;
```

### 1.2. Danh sách giáo viên có phân trang (3 GV/trang)

- **Controller**: `TeacherController.list()` — `GET /api/teachers?page=&size=3`
- **Service**: `TeacherService.getTeacherPage()`
- **Repository**: `TeacherRepository.countTeachers()` + `findTeacherPage()`

```sql
SELECT COUNT(*) FROM Teacher;

SELECT t.Teacher_ID, t.Full_Name, t.Email,
       (SELECT COUNT(*) FROM Classes c WHERE c.Teacher_ID = t.Teacher_ID) AS Class_Count
FROM Teacher t
ORDER BY t.Teacher_ID
LIMIT ? OFFSET ?;
```

### 1.3. "Đăng nhập" giáo viên → ghi Teacher_ID vào Session

- **Controller**: `TeacherController.login()` — `POST /api/teachers/{id}/login`
  - Sau khi xác thực, gọi `session.setAttribute("TEACHER_ID", teacherId)` (khóa hằng `SESSION_TEACHER_ID`).
- **Service**: `TeacherService.requireTeacher()`
- **Repository**: `TeacherRepository.findTeacherById()`

```sql
SELECT t.Teacher_ID, t.Full_Name, t.Email,
       (SELECT COUNT(*) FROM Classes c WHERE c.Teacher_ID = t.Teacher_ID) AS Class_Count
FROM Teacher t
WHERE t.Teacher_ID = ?;
```

- `GET /api/teachers/me` (`TeacherController.me()`): đọc `TEACHER_ID` từ Session rồi chạy lại
  truy vấn trên để khôi phục phiên ở frontend.
- `POST /api/teachers/logout`: `session.removeAttribute("TEACHER_ID")` (không có SQL).

> **Lưu ý bảo mật:** các endpoint `/api/teachers/me/**` luôn lấy `Teacher_ID` từ **Session**,
> không tin tưởng giá trị do client gửi lên.

---

## 2. Giáo viên: xem học sinh & chỉnh điểm

Trang `teacher.html` + `js/teacher.js`.

### 2.1. Các lớp do giáo viên dạy (mỗi lớp = 1 tab)

- **Controller**: `TeacherController.myClasses()` — `GET /api/teachers/me/classes`
- **Service**: `TeacherService.getClasses(teacherId_from_session)`
- **Repository**: `TeacherRepository.findClassesByTeacher()`

Câu lệnh lõi đúng theo yêu cầu (bổ sung tên lớp/cấp độ/sĩ số để hiển thị tab):

```sql
-- Yêu cầu gốc: SELECT class_id FROM classes WHERE teacher_id = <Teacher_ID_hien_tai>
SELECT Class_ID, Class_Name, CEFR_Level, No_of_Students
FROM Classes
WHERE Teacher_ID = ?            -- ? = Teacher_ID lấy từ Session
ORDER BY Class_ID;
```

### 2.2. Danh sách học sinh trong 1 lớp (tab) — JOIN + phân trang

- **Controller**: `TeacherController.studentsOfClass()` — `GET /api/teachers/me/classes/{classId}/students?page=&size=10`
- **Service**: `TeacherService.getStudentsInClass()` (chặn lớp không thuộc giáo viên → 401)
- **Repository**: `classBelongsToTeacher()` + `countStudentsInClass()` + `findStudentsInClass()`

```sql
-- Kiểm tra quyền: lớp có thuộc giáo viên đang đăng nhập không
SELECT COUNT(*) FROM Classes WHERE Class_ID = ? AND Teacher_ID = ?;

-- Đếm để phân trang
SELECT COUNT(*) FROM Students WHERE Class_ID = ?;

-- JOIN Students + Classes: Basic Info (Họ tên, Email), Tên lớp, Accuracy (+ level, CLP)
SELECT s.Student_ID, s.Full_Name, s.Email, c.Class_Name,
       s.Accuracy, s.Level, s.Current_Level_Progress
FROM Students s
JOIN Classes c ON s.Class_ID = c.Class_ID
WHERE c.Class_ID = ?
ORDER BY s.Student_ID
LIMIT ? OFFSET ?;
```

### 2.3. Tăng/giảm điểm trực tiếp → gọi Stored Procedure

- **Controller**: `TeacherController.adjustPoints()` — `POST /api/teachers/students/{studentId}/points`
  - Body: `{ "points": <int âm hoặc dương> }`
- **Service**: `TeacherService.adjustPoints()` (chặn học sinh không thuộc lớp của giáo viên → 401)
- **Repository**: `studentBelongsToTeacher()` + `adjustPoints()` + `findStudentSummary()`

```sql
-- Kiểm tra quyền: học sinh có thuộc một lớp do giáo viên này dạy không
SELECT COUNT(*)
FROM Students s
JOIN Classes c ON s.Class_ID = c.Class_ID
WHERE s.Student_ID = ? AND c.Teacher_ID = ?;

-- Gọi Stored Procedure (tự cộng/trừ CLP & xét lên cấp). stud_id = id học sinh đang xét
CALL sp_check_levelup(?, ?);     -- (stud_id, add_points)

-- Đọc lại học sinh để refresh UI
SELECT s.Student_ID, s.Full_Name, s.Email, c.Class_Name,
       s.Accuracy, s.Level, s.Current_Level_Progress
FROM Students s
LEFT JOIN Classes c ON s.Class_ID = c.Class_ID
WHERE s.Student_ID = ?;
```

---

## 3. Giáo viên: tạo bài giảng (1 transaction)

Wizard 3 bước ở frontend, nhưng **gửi 1 lần** và backend ghi **toàn bộ trong cùng 1 transaction**
(`@Transactional` trên `TeacherService.createLesson`). Nếu bất kỳ bước nào lỗi → **rollback tất cả**.

- **Controller**: `TeacherController.createLesson()` — `POST /api/teachers/lessons`
- **Service**: `TeacherService.createLesson(teacherId_from_session, req)` — `@Transactional`
- **Repository**: `TeacherRepository.insertLesson / insertVocabulary / insertGrammar / insertQuiz / insertQuestion`

**Bước 1 — INSERT Lessons, lấy `Lesson_ID` tự sinh** (`Teacher_ID` lấy từ Session, qua `GeneratedKeyHolder`):

```sql
INSERT INTO Lessons (Level_Required, Title, Teacher_ID) VALUES (?, ?, ?);
-- Lesson_ID = LAST_INSERT_ID() (đọc qua KeyHolder)
```

**Bước 2 — INSERT 5 từ vựng + 2 cấu trúc ngữ pháp** (dùng `Lesson_ID` vừa lấy):

```sql
-- Lặp 5 lần
INSERT INTO Vocabulary (Content, Meaning, Example, Lesson_ID) VALUES (?, ?, ?, ?);

-- Lặp 2 lần
INSERT INTO Grammar_Structures (Lesson_ID, Content, Example) VALUES (?, ?, ?);
```

**Bước 3 — INSERT Quizzes (không có tên bài), lấy `Quiz_ID` tự sinh; rồi INSERT 3 câu hỏi**:

```sql
-- Schema Quizzes KHÔNG có cột tên bài -> chỉ nhập mốc điểm qua & tổng điểm
INSERT INTO Quizzes (Lesson_ID, Minimum_Pass_Score, Possible_Points) VALUES (?, ?, ?);
-- Quiz_ID = LAST_INSERT_ID() (đọc qua KeyHolder)

-- Lặp 3 lần
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES (?, ?, ?);
```

Trả về: `{ lessonId, quizId, vocabularyCount, grammarCount, questionCount }`.

---

## 4. Học sinh: highlight & điểm cao nhất

### 4.1. Đổi màu nền bài giảng "đã xem" / "đã làm"

- **Bài giảng "đã xem"**: đánh dấu phía client trong `localStorage` (`markLessonViewed` / `isLessonViewed`
  trong `js/api.js`), vì "đã xem" là hành vi người dùng.
- **Bài giảng "đã làm bài tập"** (cờ `attempted` từ DB):
  - **Controller**: `LessonController.getCatalog()` — `GET /api/lessons?studentId=`
  - **Repository**: `LessonRepository.findCatalogForLevel()`

```sql
SELECT v.*,
       EXISTS(SELECT 1 FROM Quizzes qz
              JOIN Attempts a ON a.Quiz_ID = qz.Quiz_ID
              WHERE qz.Lesson_ID = v.Lesson_ID AND a.Student_ID = ?) AS Attempted
FROM v_lesson_catalog v
WHERE v.Level_Required <= ?
ORDER BY v.Lesson_ID;
```

- **Bài tập "đã làm"** (cờ `attempted`): xem 4.2 (cùng truy vấn với điểm cao nhất).

Frontend (`lessons.js`, `quiz.js`) gắn class CSS `.seen` (nền gradient khác trắng) + nhãn "✓ Đã học / ✓ Đã làm".

### 4.2. Hiển thị điểm cao nhất từng đạt của mỗi bài tập

- **Controller (danh sách bài tập)**: `QuizController.getAll()` — `GET /api/quizzes?studentId=`
- **Controller (bài tập trong 1 bài giảng)**: `LessonController.getDetail()` — `GET /api/lessons/{id}?studentId=`
- **Service**: `QuizService.getAllQuizzes()` / `LessonService.getDetail()`
- **Repository**: `QuizRepository.findSummariesForLevel()` / `findByLessonId(studentId, lessonId)`

Hai cột phụ thuộc `Student_ID` được nhúng vào truy vấn tóm tắt bài tập:

```sql
SELECT qz.Quiz_ID, l.Title, l.Level_Required, qz.Possible_Points, qz.Minimum_Pass_Score,
       COUNT(q.Question_ID) AS Num_Questions,
       -- Đã có lượt làm bài này chưa (đổi màu nền)
       EXISTS(SELECT 1 FROM Attempts a2
              WHERE a2.Student_ID = ? AND a2.Quiz_ID = qz.Quiz_ID) AS Attempted,
       -- ĐIỂM CAO NHẤT TỪNG ĐẠT — đúng câu lệnh yêu cầu:
       (SELECT COALESCE(MAX(at.Total_Points), 0) FROM Attempts at
        WHERE at.Student_ID = ? AND at.Quiz_ID = qz.Quiz_ID AND at.Status = 'COMPLETED') AS Best_Score
FROM Quizzes qz
JOIN Lessons l   ON qz.Lesson_ID = l.Lesson_ID
JOIN Questions q ON q.Quiz_ID = qz.Quiz_ID
WHERE l.Level_Required <= ?            -- biến thể theo bài giảng dùng: WHERE qz.Lesson_ID = ?
GROUP BY qz.Quiz_ID, l.Title, l.Level_Required, qz.Possible_Points, qz.Minimum_Pass_Score
ORDER BY qz.Quiz_ID;
```

Câu lệnh điểm cao nhất theo đúng đặc tả:

```sql
SELECT COALESCE(MAX(total_points), 0)
FROM attempts
WHERE student_id = <ID_hoc_sinh_hien_tai>
  AND quiz_id = <ID_quiz>
  AND status = 'COMPLETED';
```

> **Tránh nhầm tên:** cột DB là `Total_Points`. Trong DTO `QuizSummaryRes` đặt tên trường là
> **`bestScore`**, nhãn UI hiển thị là **"🏆 Điểm cao nhất từng đạt"** (`X / numQuestions`),
> để không trùng/nhầm với trường dữ liệu gốc.

---

## 5. Bảng tra cứu nhanh

| Tính năng | HTTP Endpoint | Controller | Loại SQL chính |
|---|---|---|---|
| HS phân trang (10/trang) | `GET /api/students/page` | `StudentController.getPage` | `SELECT … LIMIT ? OFFSET ?` + `COUNT(*)` |
| GV phân trang (3/trang) | `GET /api/teachers` | `TeacherController.list` | `SELECT … LIMIT ? OFFSET ?` + `COUNT(*)` |
| Đăng nhập GV (lưu Session) | `POST /api/teachers/{id}/login` | `TeacherController.login` | `SELECT … FROM Teacher WHERE Teacher_ID=?` |
| GV hiện tại | `GET /api/teachers/me` | `TeacherController.me` | `SELECT … FROM Teacher WHERE Teacher_ID=?` |
| Lớp của GV (tabs) | `GET /api/teachers/me/classes` | `TeacherController.myClasses` | `SELECT … FROM Classes WHERE Teacher_ID=?` |
| HS trong lớp (JOIN) | `GET /api/teachers/me/classes/{id}/students` | `TeacherController.studentsOfClass` | `SELECT … Students JOIN Classes … LIMIT/OFFSET` |
| Tăng/giảm điểm | `POST /api/teachers/students/{id}/points` | `TeacherController.adjustPoints` | `CALL sp_check_levelup(?, ?)` |
| Tạo bài giảng (1 transaction) | `POST /api/teachers/lessons` | `TeacherController.createLesson` | `INSERT` Lessons/Vocabulary/Grammar_Structures/Quizzes/Questions |
| Catalog bài giảng (cờ đã làm) | `GET /api/lessons?studentId=` | `LessonController.getCatalog` | `SELECT … EXISTS(… Attempts …) AS Attempted` |
| Chi tiết bài giảng | `GET /api/lessons/{id}?studentId=` | `LessonController.getDetail` | bài tập kèm `Best_Score` (xem 4.2) |
| Danh sách bài tập (điểm cao nhất) | `GET /api/quizzes?studentId=` | `QuizController.getAll` | `SELECT … MAX(Total_Points) … AS Best_Score` |

### Phân quyền & lỗi
- Thiếu Session giáo viên hoặc thao tác ngoài lớp/học sinh của mình → `UnauthorizedException` → HTTP **401**.
- Không tìm thấy bản ghi → `ResourceNotFoundException` → HTTP **404**.
- Dữ liệu nhập sai (vd không đủ 5 từ vựng / 2 ngữ pháp / 3 câu hỏi, level ngoài 1..6) → `IllegalArgumentException` → HTTP **400**.
