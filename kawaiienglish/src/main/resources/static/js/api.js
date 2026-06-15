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

/** Hiển thị tên học sinh hiện tại lên thanh điều hướng (nếu có ô #who-name). */
function renderWho() {
    const el = document.getElementById('who-name');
    if (el) el.textContent = getCurrentStudentName() || ('HS #' + (getCurrentStudentId() || '?'));
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
