/* ==========================================================================
   login.js - Màn hình chọn học sinh (index.html)
   ========================================================================== */

async function initLogin() {
    const grid = document.getElementById('student-grid');
    try {
        const students = await getJSON('/students');
        if (!students.length) {
            grid.innerHTML = '<div class="empty">Chưa có học sinh nào trong hệ thống.</div>';
            return;
        }
        grid.innerHTML = students.map(s => `
            <div class="student-card" data-id="${s.studentId}" data-name="${esc(s.fullName)}">
                <div class="avatar">${avatarFor(s.studentId)}</div>
                <div class="name">${esc(s.fullName)}</div>
                <div class="meta">
                    <span class="badge level">Lv.${s.level}</span>
                    <span class="badge cefr">${esc(s.assessmentCefr || '?')}</span>
                </div>
                <div class="meta">${esc(s.className || 'Chưa xếp lớp')}</div>
            </div>
        `).join('');

        grid.querySelectorAll('.student-card').forEach(card => {
            card.addEventListener('click', () => {
                setCurrentStudent(card.dataset.id, card.dataset.name);
                window.location.href = 'dashboard.html';
            });
        });
    } catch (e) {
        grid.innerHTML = `<div class="empty">😢 Không tải được danh sách học sinh.<br>${esc(e.message)}</div>`;
    }
}

document.addEventListener('DOMContentLoaded', initLogin);
