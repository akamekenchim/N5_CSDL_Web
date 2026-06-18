/* ==========================================================================
   teacher.js - Trang giáo viên
   - Xem học sinh theo từng lớp (tab theo Class_ID), JOIN hiển thị tên/email/lớp/accuracy
   - Tăng/giảm điểm: CALL sp_check_levelup(studentId, points)
   - Tạo bài giảng: wizard 3 bước, gửi 1 lần -> backend chạy trong 1 transaction
   ========================================================================== */

const tState = {
    classId: null,
    page: 0,
    totalPages: 1,
    step: 1,
};

const STUDENTS_PER_PAGE = 10;

async function initTeacher() {
    const me = await requireTeacher();       // xác thực Session, redirect nếu hết hạn
    if (!me) return;
    document.getElementById('who-name').textContent = me.fullName;

    // Điều hướng giữa 2 view
    document.getElementById('nav-students').addEventListener('click', (e) => { e.preventDefault(); showView('students'); });
    document.getElementById('nav-create').addEventListener('click', (e) => { e.preventDefault(); showView('create'); });

    // Pager học sinh
    document.getElementById('st-prev').addEventListener('click', () => { if (tState.page > 0) { tState.page--; loadStudents(); } });
    document.getElementById('st-next').addEventListener('click', () => { if (tState.page < tState.totalPages - 1) { tState.page++; loadStudents(); } });

    buildWizardFields();
    await loadClasses();
}

function showView(which) {
    document.getElementById('view-students').classList.toggle('hidden', which !== 'students');
    document.getElementById('view-create').classList.toggle('hidden', which !== 'create');
    document.getElementById('nav-students').classList.toggle('active', which === 'students');
    document.getElementById('nav-create').classList.toggle('active', which === 'create');
}

/* ----------------------- Lớp & học sinh ----------------------- */

async function loadClasses() {
    const tabs = document.getElementById('class-tabs');
    tabs.innerHTML = '<div class="loading">Đang tải lớp...</div>';
    try {
        const classes = await getJSON('/teachers/me/classes');
        if (!classes.length) {
            tabs.innerHTML = '<div class="empty">Bạn chưa được phân công lớp nào.</div>';
            document.getElementById('students-box').innerHTML = '';
            return;
        }
        tabs.innerHTML = classes.map(c => `
            <button class="class-tab" data-id="${c.classId}">
                ${esc(c.className)}
                <span class="badge cefr">${esc(c.cefrLevel)}</span>
                <span class="badge">${c.numStudents} HS</span>
            </button>`).join('');
        tabs.querySelectorAll('.class-tab').forEach(tab => {
            tab.addEventListener('click', () => selectClass(parseInt(tab.dataset.id, 10)));
        });
        selectClass(classes[0].classId);   // mở lớp đầu tiên
    } catch (e) {
        tabs.innerHTML = `<div class="empty">😢 ${esc(e.message)}</div>`;
    }
}

function selectClass(classId) {
    tState.classId = classId;
    tState.page = 0;
    document.querySelectorAll('.class-tab').forEach(t =>
        t.classList.toggle('active', parseInt(t.dataset.id, 10) === classId));
    loadStudents();
}

async function loadStudents() {
    const box = document.getElementById('students-box');
    const pager = document.getElementById('students-pager');
    box.innerHTML = '<div class="loading">Đang tải học sinh...</div>';
    pager.classList.add('hidden');
    try {
        const res = await getJSON(
            `/teachers/me/classes/${tState.classId}/students?page=${tState.page}&size=${STUDENTS_PER_PAGE}`);
        tState.totalPages = Math.max(1, res.totalPages);
        if (!res.content.length) {
            box.innerHTML = '<div class="empty">Lớp này chưa có học sinh.</div>';
            return;
        }
        box.innerHTML = res.content.map(renderStudentRow).join('');
        box.querySelectorAll('.stu-row').forEach(row => {
            const id = parseInt(row.dataset.id, 10);
            row.querySelector('.btn-adjust').addEventListener('click', () => adjustPoints(id, row));
        });
        // Pager
        pager.classList.remove('hidden');
        document.getElementById('st-info').textContent =
            `Trang ${res.page + 1}/${tState.totalPages} · ${res.totalElements} HS`;
        document.getElementById('st-prev').disabled = res.page <= 0;
        document.getElementById('st-next').disabled = res.page >= tState.totalPages - 1;
    } catch (e) {
        box.innerHTML = `<div class="empty">😢 ${esc(e.message)}</div>`;
    }
}

function renderStudentRow(s) {
    const acc = (s.accuracy * 100).toFixed(1);
    return `
        <div class="stu-row card" data-id="${s.studentId}">
            <div class="stu-main">
                <div class="avatar">${avatarFor(s.studentId)}</div>
                <div>
                    <div class="name">${esc(s.fullName)}</div>
                    <div class="muted">${esc(s.email || '')}</div>
                    <div class="meta">
                        <span class="badge">🏫 ${esc(s.className || '—')}</span>
                        <span class="badge level">Lv.${s.level}</span>
                        <span class="badge cefr">🎯 ${acc}%</span>
                        <span class="badge">CLP ${s.currentLevelProgress}</span>
                    </div>
                </div>
            </div>
            <div class="stu-actions">
                <input class="pt-input" type="number" placeholder="± điểm" value="10" step="10">
                <button class="btn sm btn-adjust">Xác nhận</button>
            </div>
        </div>`;
}

async function adjustPoints(studentId, row) {
    const input = row.querySelector('.pt-input');
    const points = parseInt(input.value, 10);
    if (isNaN(points)) { alert('Nhập số điểm hợp lệ (âm hoặc dương).'); return; }
    const btn = row.querySelector('.btn-adjust');
    btn.disabled = true;
    btn.textContent = '...';
    try {
        const updated = await postJSON(`/teachers/students/${studentId}/points`, { points });
        // Cập nhật tại chỗ + nhấp nháy báo thành công
        const acc = (updated.accuracy * 100).toFixed(1);
        row.querySelector('.meta').innerHTML = `
            <span class="badge">🏫 ${esc(updated.className || '—')}</span>
            <span class="badge level">Lv.${updated.level}</span>
            <span class="badge cefr">🎯 ${acc}%</span>
            <span class="badge">CLP ${updated.currentLevelProgress}</span>`;
        row.classList.add('flash-ok');
        setTimeout(() => row.classList.remove('flash-ok'), 900);
    } catch (e) {
        alert('Không cập nhật được điểm: ' + e.message);
    } finally {
        btn.disabled = false;
        btn.textContent = 'Xác nhận';
    }
}

/* ----------------------- Wizard tạo bài giảng ----------------------- */

function buildWizardFields() {
    const vbox = document.getElementById('vocab-fields');
    vbox.innerHTML = Array.from({ length: 5 }, (_, i) => `
        <div class="mini-grid3">
            <input class="vc-content" type="text" placeholder="Từ vựng #${i + 1}">
            <input class="vc-meaning" type="text" placeholder="Nghĩa">
            <input class="vc-example" type="text" placeholder="Ví dụ">
        </div>`).join('');

    const gbox = document.getElementById('grammar-fields');
    gbox.innerHTML = Array.from({ length: 2 }, (_, i) => `
        <div class="mini-grid2">
            <input class="gr-content" type="text" placeholder="Cấu trúc ngữ pháp #${i + 1}">
            <input class="gr-example" type="text" placeholder="Ví dụ">
        </div>`).join('');

    const qbox = document.getElementById('question-fields');
    qbox.innerHTML = Array.from({ length: 3 }, (_, i) => `
        <div class="mini-grid2">
            <input class="qs-content" type="text" placeholder="Câu hỏi #${i + 1}">
            <input class="qs-answer" type="text" placeholder="Đáp án đúng">
        </div>`).join('');
}

function goStep(n) {
    tState.step = n;
    document.querySelectorAll('.wstep').forEach(s =>
        s.classList.toggle('active', parseInt(s.dataset.step, 10) <= n));
    document.querySelectorAll('.wstep-panel').forEach(p =>
        p.classList.toggle('hidden', parseInt(p.dataset.panel, 10) !== n));
}

function collectList(selPairs) {
    // selPairs: mảng các bộ selector cùng độ dài -> trả về mảng object theo keys
    const rowsByFirst = document.querySelectorAll(selPairs[0].sel);
    const out = [];
    rowsByFirst.forEach((_, idx) => {
        const obj = {};
        selPairs.forEach(p => {
            const el = document.querySelectorAll(p.sel)[idx];
            obj[p.key] = el ? el.value.trim() : '';
        });
        out.push(obj);
    });
    return out;
}

async function submitLesson() {
    const payload = {
        title: document.getElementById('f-title').value.trim(),
        levelRequired: parseInt(document.getElementById('f-level').value, 10),
        vocabulary: collectList([
            { sel: '.vc-content', key: 'content' },
            { sel: '.vc-meaning', key: 'meaning' },
            { sel: '.vc-example', key: 'example' },
        ]),
        grammar: collectList([
            { sel: '.gr-content', key: 'content' },
            { sel: '.gr-example', key: 'example' },
        ]),
        minimumPassScore: parseInt(document.getElementById('f-minpass').value, 10),
        possiblePoints: parseInt(document.getElementById('f-possible').value, 10),
        questions: collectList([
            { sel: '.qs-content', key: 'content' },
            { sel: '.qs-answer', key: 'correctAnswer' },
        ]),
    };

    if (!payload.title) { alert('Vui lòng nhập tiêu đề bài giảng (Bước 1).'); goStep(1); return; }

    const btn = document.getElementById('btn-create');
    btn.disabled = true;
    btn.textContent = 'Đang lưu...';
    try {
        const r = await postJSON('/teachers/lessons', payload);
        document.getElementById('create-result').innerHTML = `
            <div class="card fade-in" style="border:2px solid var(--ok)">
                <h3>🎉 Tạo bài giảng thành công!</h3>
                <div class="muted">Tất cả được ghi trong cùng 1 transaction.</div>
                <div class="meta" style="margin-top:10px">
                    <span class="badge">Lesson_ID = ${r.lessonId}</span>
                    <span class="badge">Quiz_ID = ${r.quizId}</span>
                    <span class="badge">${r.vocabularyCount} từ vựng</span>
                    <span class="badge">${r.grammarCount} ngữ pháp</span>
                    <span class="badge">${r.questionCount} câu hỏi</span>
                </div>
            </div>`;
        fireConfetti();
    } catch (e) {
        alert('Tạo bài giảng thất bại: ' + e.message);
    } finally {
        btn.disabled = false;
        btn.textContent = '✅ Tạo bài giảng';
    }
}

document.addEventListener('DOMContentLoaded', initTeacher);
