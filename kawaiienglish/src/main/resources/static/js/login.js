/* ==========================================================================
   login.js - Màn hình chọn vai trò (Profile Switcher) + phân trang
   - Học sinh: 10 hồ sơ/trang  -> /students/page
   - Giáo viên: 3 hồ sơ/trang   -> /teachers   (chọn -> ghi Teacher_ID vào Session)
   ========================================================================== */

const PAGE_SIZE = { student: 10, teacher: 3 };

const state = {
    role: 'student',
    page: 0,
    totalPages: 1,
};

function initLogin() {
    document.querySelectorAll('.role-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            if (btn.dataset.role === state.role) return;
            document.querySelectorAll('.role-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            state.role = btn.dataset.role;
            state.page = 0;
            loadPage();
        });
    });
    document.getElementById('pg-prev').addEventListener('click', () => {
        if (state.page > 0) { state.page--; loadPage(); }
    });
    document.getElementById('pg-next').addEventListener('click', () => {
        if (state.page < state.totalPages - 1) { state.page++; loadPage(); }
    });
    loadPage();
}

async function loadPage() {
    const grid = document.getElementById('profile-grid');
    const pager = document.getElementById('pager');
    grid.innerHTML = '<div class="loading">Đang tải danh sách...</div>';
    pager.classList.add('hidden');

    try {
        const size = PAGE_SIZE[state.role];
        const path = state.role === 'student'
            ? `/students/page?page=${state.page}&size=${size}`
            : `/teachers?page=${state.page}&size=${size}`;
        const res = await getJSON(path);   // PageRes { content, page, size, totalElements, totalPages }
        state.totalPages = Math.max(1, res.totalPages);

        if (!res.content.length) {
            grid.innerHTML = `<div class="empty">${state.role === 'student'
                ? 'Chưa có học sinh nào trong hệ thống.'
                : 'Chưa có giáo viên nào. (Dữ liệu giáo viên sẽ được import sau.)'}</div>`;
            return;
        }

        grid.innerHTML = state.role === 'student'
            ? res.content.map(renderStudentCard).join('')
            : res.content.map(renderTeacherCard).join('');

        if (state.role === 'student') {
            grid.querySelectorAll('.student-card').forEach(card => {
                card.addEventListener('click', () => {
                    setCurrentStudent(card.dataset.id, card.dataset.name);
                    window.location.href = 'dashboard.html';
                });
            });
        } else {
            grid.querySelectorAll('.student-card').forEach(card => {
                card.addEventListener('click', () => loginAsTeacher(card.dataset.id, card.dataset.name));
            });
        }

        renderPager(res);
    } catch (e) {
        grid.innerHTML = `<div class="empty">😢 Không tải được danh sách.<br>${esc(e.message)}</div>`;
    }
}

function renderStudentCard(s) {
    return `
        <div class="student-card" data-id="${s.studentId}" data-name="${esc(s.fullName)}">
            <div class="avatar">${avatarFor(s.studentId)}</div>
            <div class="name">${esc(s.fullName)}</div>
            <div class="meta">
                <span class="badge level">Lv.${s.level}</span>
                <span class="badge cefr">${esc(s.assessmentCefr || '?')}</span>
            </div>
            <div class="meta">${esc(s.className || 'Chưa xếp lớp')}</div>
        </div>`;
}

function renderTeacherCard(t) {
    return `
        <div class="student-card teacher-card" data-id="${t.teacherId}" data-name="${esc(t.fullName)}">
            <div class="avatar">👩‍🏫</div>
            <div class="name">${esc(t.fullName)}</div>
            <div class="meta muted">${esc(t.email || '')}</div>
            <div class="meta"><span class="badge">${t.classCount} lớp phụ trách</span></div>
        </div>`;
}

function renderPager(res) {
    const pager = document.getElementById('pager');
    pager.classList.remove('hidden');
    document.getElementById('pg-info').textContent =
        `Trang ${res.page + 1}/${state.totalPages} · ${res.totalElements} hồ sơ`;
    document.getElementById('pg-prev').disabled = res.page <= 0;
    document.getElementById('pg-next').disabled = res.page >= state.totalPages - 1;
}

/** Chọn giáo viên -> server lưu Teacher_ID vào HttpSession -> vào trang giáo viên. */
async function loginAsTeacher(id, name) {
    try {
        const t = await postJSON(`/teachers/${id}/login`, {});
        setCurrentTeacher(t.teacherId, t.fullName);
        window.location.href = 'teacher.html';
    } catch (e) {
        alert('Không đăng nhập được giáo viên: ' + e.message);
    }
}

document.addEventListener('DOMContentLoaded', initLogin);
