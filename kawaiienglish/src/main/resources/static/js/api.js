/* ==========================================================================
   api.js - Cấu hình gọi API + quản lý "phiên đăng nhập" học sinh (localStorage)
   ========================================================================== */

const API_BASE = '/api';

/** GET trả về JSON. Ném lỗi nếu status != 2xx. */
async function getJSON(path) {
    const res = await fetch(API_BASE + path);
    if (!res.ok) {
        const msg = await safeMessage(res);
        throw new Error(msg);
    }
    return res.json();
}

/** POST JSON body, trả về JSON. */
async function postJSON(path, body) {
    const res = await fetch(API_BASE + path, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
    });
    if (!res.ok) {
        const msg = await safeMessage(res);
        throw new Error(msg);
    }
    return res.json();
}

async function safeMessage(res) {
    try {
        const data = await res.json();
        return data.message || ('Lỗi ' + res.status);
    } catch (e) {
        return 'Lỗi ' + res.status;
    }
}

/* ----- Phiên học sinh hiện tại ----- */
function setCurrentStudent(id, name) {
    localStorage.setItem('ke_student_id', id);
    localStorage.setItem('ke_student_name', name || '');
}
function getCurrentStudentId() {
    const v = localStorage.getItem('ke_student_id');
    return v ? parseInt(v, 10) : null;
}
function getCurrentStudentName() {
    return localStorage.getItem('ke_student_name') || '';
}
function logout() {
    localStorage.removeItem('ke_student_id');
    localStorage.removeItem('ke_student_name');
    window.location.href = 'index.html';
}

/** Buộc phải chọn học sinh trước; nếu chưa thì quay về trang chọn. */
function requireStudent() {
    const id = getCurrentStudentId();
    if (!id) {
        window.location.href = 'index.html';
        return null;
    }
    return id;
}

/* ----- Phiên giáo viên hiện tại -----
   Teacher_ID chính thức nằm trong HttpSession của server; localStorage chỉ giữ bản sao
   để tiện hiển thị tên / điều hướng phía client. */
function setCurrentTeacher(id, name) {
    localStorage.setItem('ke_teacher_id', id);
    localStorage.setItem('ke_teacher_name', name || '');
}
function getCurrentTeacherId() {
    const v = localStorage.getItem('ke_teacher_id');
    return v ? parseInt(v, 10) : null;
}
function getCurrentTeacherName() {
    return localStorage.getItem('ke_teacher_name') || '';
}
async function logoutTeacher() {
    try { await postJSON('/teachers/logout', {}); } catch (e) { /* bỏ qua */ }
    localStorage.removeItem('ke_teacher_id');
    localStorage.removeItem('ke_teacher_name');
    window.location.href = 'index.html';
}

/**
 * Buộc phải đăng nhập giáo viên (có Session trên server). Xác thực qua /teachers/me;
 * nếu Session hết hạn thì quay về trang chọn vai trò.
 */
async function requireTeacher() {
    try {
        const me = await getJSON('/teachers/me');
        setCurrentTeacher(me.teacherId, me.fullName);
        return me;
    } catch (e) {
        window.location.href = 'index.html';
        return null;
    }
}

/** Hiển thị tên học sinh hiện tại lên thanh điều hướng (nếu có ô #who-name). */
function renderWho() {
    const el = document.getElementById('who-name');
    if (el) el.textContent = getCurrentStudentName() || ('HS #' + (getCurrentStudentId() || '?'));
}

/* ----- Đánh dấu bài giảng "đã xem" (lưu client theo từng học sinh) -----
   "Đã xem" là hành vi phía người dùng nên lưu ở localStorage; còn "đã làm bài tập"
   được suy ra từ DB (cờ attempted trả về từ API). */
function _viewedKey() {
    return 'ke_viewed_lessons_' + (getCurrentStudentId() || '0');
}
function markLessonViewed(lessonId) {
    const set = new Set(getViewedLessons());
    set.add(parseInt(lessonId, 10));
    localStorage.setItem(_viewedKey(), JSON.stringify([...set]));
}
function getViewedLessons() {
    try {
        return JSON.parse(localStorage.getItem(_viewedKey()) || '[]');
    } catch (e) {
        return [];
    }
}
function isLessonViewed(lessonId) {
    return getViewedLessons().includes(parseInt(lessonId, 10));
}

/** Chống XSS đơn giản khi chèn chuỗi vào HTML. */
function esc(s) {
    if (s === null || s === undefined) return '';
    return String(s)
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
}

/** Emoji avatar theo id cho vui mắt. */
function avatarFor(id) {
    const set = ['🦊', '🐱', '🐰', '🐼', '🐶', '🐨', '🦄', '🐯', '🐸', '🐧', '🐹', '🦉'];
    return set[(id || 0) % set.length];
}

/** Pháo hoa confetti khi lên cấp. */
function fireConfetti() {
    const layer = document.createElement('div');
    layer.className = 'confetti-layer';
    const colors = ['#ff8fb1', '#a78bfa', '#6ee7c7', '#7dd3fc', '#fde68a'];
    for (let i = 0; i < 80; i++) {
        const c = document.createElement('div');
        c.className = 'confetti';
        c.style.left = Math.random() * 100 + 'vw';
        c.style.background = colors[i % colors.length];
        c.style.animationDelay = (Math.random() * 0.4) + 's';
        c.style.animationDuration = (1.2 + Math.random()) + 's';
        layer.appendChild(c);
    }
    document.body.appendChild(layer);
    setTimeout(() => layer.remove(), 2600);
}
