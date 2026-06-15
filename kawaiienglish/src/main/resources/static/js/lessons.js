/* ==========================================================================
   lessons.js - Danh mục bài giảng + chi tiết (từ vựng & ngữ pháp)
   ========================================================================== */

async function initLessons() {
    requireStudent();
    renderWho();
    await loadCatalog();
}

async function loadCatalog() {
    document.getElementById('lesson-detail').classList.add('hidden');
    const list = document.getElementById('lesson-list');
    list.classList.remove('hidden');
    const wrap = document.getElementById('lesson-cards');
    wrap.innerHTML = '<div class="loading">Đang tải bài giảng...</div>';
    try {
        const lessons = await getJSON('/lessons');
        if (!lessons.length) {
            wrap.innerHTML = '<div class="empty">Chưa có bài giảng nào.</div>';
            return;
        }
        wrap.innerHTML = lessons.map(l => `
            <div class="quiz-card" data-id="${l.lessonId}">
                <h3>📖 ${esc(l.lessonTitle)}</h3>
                <div class="info">
                    <span class="badge cefr">Yêu cầu Lv.${l.levelRequired}</span>
                    <span class="badge">👩‍🏫 ${esc(l.teacherName)}</span>
                </div>
            </div>
        `).join('');
        wrap.querySelectorAll('.quiz-card').forEach(card => {
            card.addEventListener('click', () => loadDetail(parseInt(card.dataset.id, 10)));
        });
    } catch (e) {
        wrap.innerHTML = `<div class="empty">😢 ${esc(e.message)}</div>`;
    }
}

async function loadDetail(lessonId) {
    document.getElementById('lesson-list').classList.add('hidden');
    const box = document.getElementById('lesson-detail');
    box.classList.remove('hidden');
    box.innerHTML = '<div class="loading">Đang tải nội dung...</div>';
    try {
        const d = await getJSON('/lessons/' + lessonId);
        const vocab = d.vocabulary.length
            ? d.vocabulary.map(v => `
                <div class="vocab-item">
                    <div class="word">${esc(v.content)}</div>
                    <div class="mean">${esc(v.meaning)}</div>
                    <div class="ex">“${esc(v.example)}”</div>
                </div>`).join('')
            : '<div class="muted">Chưa có từ vựng.</div>';

        const grammar = d.grammar.length
            ? d.grammar.map(g => `
                <div class="grammar-item">
                    <div class="struct">${esc(g.content)}</div>
                    <div class="ex">VD: ${esc(g.example)}</div>
                </div>`).join('')
            : '<div class="muted">Chưa có ngữ pháp.</div>';

        box.innerHTML = `
            <div class="card fade-in">
                <button class="btn ghost sm" onclick="loadCatalog()">← Quay lại danh sách</button>
                <h2 style="margin:14px 0 4px">${esc(d.lessonTitle)}</h2>
                <div class="muted">Yêu cầu Level ${d.levelRequired} &middot; Giáo viên: ${esc(d.teacherName)}</div>

                <h3 style="margin-top:24px">📝 Từ vựng</h3>
                ${vocab}

                <h3 style="margin-top:24px">📐 Cấu trúc ngữ pháp</h3>
                ${grammar}
            </div>
        `;
    } catch (e) {
        box.innerHTML = `<div class="empty">😢 ${esc(e.message)}</div>`;
    }
}

document.addEventListener('DOMContentLoaded', initLessons);
