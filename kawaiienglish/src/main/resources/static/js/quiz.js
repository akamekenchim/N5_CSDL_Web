/* ==========================================================================
   quiz.js - Danh sách bài tập -> làm bài -> nộp -> xem kết quả
   ========================================================================== */

let currentQuiz = null;     // { quizId, lessonTitle }
let currentQuestions = [];

const elList   = () => document.getElementById('quiz-list');
const elTake   = () => document.getElementById('quiz-take');
const elResult = () => document.getElementById('quiz-result');

function showView(which) {
    elList().classList.toggle('hidden', which !== 'list');
    elTake().classList.toggle('hidden', which !== 'take');
    elResult().classList.toggle('hidden', which !== 'result');
}

async function initQuiz() {
    const id = requireStudent();
    if (!id) return;
    renderWho();

    // Nếu mở từ trang bài giảng (quiz.html?quizId=...) thì vào thẳng bài tập đó
    const params = new URLSearchParams(location.search);
    const presetId = params.get('quizId');
    if (presetId) {
        startQuiz(parseInt(presetId, 10), params.get('t') || ('Bài tập #' + presetId));
    } else {
        await loadQuizList();
    }
}

async function loadQuizList() {
    showView('list');
    const wrap = document.getElementById('quiz-cards');
    wrap.innerHTML = '<div class="loading">Đang tải danh sách bài tập...</div>';
    try {
        // Chỉ lấy bài tập phù hợp cấp độ của học sinh hiện tại
        const quizzes = await getJSON('/quizzes?studentId=' + getCurrentStudentId());
        if (!quizzes.length) {
            wrap.innerHTML = '<div class="empty">Chưa có bài tập nào phù hợp với cấp độ của bạn.</div>';
            return;
        }
        wrap.innerHTML = quizzes.map(q => `
            <div class="quiz-card ${q.attempted ? 'seen' : ''}" data-id="${q.quizId}" data-title="${esc(q.lessonTitle)}">
                ${q.attempted ? '<span class="seen-tag">✓ Đã làm</span>' : ''}
                <h3>📘 ${esc(q.lessonTitle)}</h3>
                <div class="muted">Bài tập #${q.quizId}</div>
                <div class="info">
                    <span class="badge">${q.numQuestions} câu hỏi</span>
                    <span class="badge level">${q.possiblePoints} điểm</span>
                    <span class="badge cefr">Yêu cầu Lv.${q.levelRequired}</span>
                </div>
                ${q.attempted ? `<div class="best-score">🏆 Điểm cao nhất từng đạt: <strong>${q.bestScore}/${q.numQuestions}</strong></div>` : ''}
            </div>
        `).join('');
        wrap.querySelectorAll('.quiz-card').forEach(card => {
            card.addEventListener('click', () =>
                startQuiz(parseInt(card.dataset.id, 10), card.dataset.title));
        });
    } catch (e) {
        wrap.innerHTML = `<div class="empty">😢 ${esc(e.message)}</div>`;
    }
}

async function startQuiz(quizId, title) {
    showView('take');
    const body = document.getElementById('take-body');
    document.getElementById('take-title').textContent = title;
    body.innerHTML = '<div class="loading">Đang tải câu hỏi...</div>';
    try {
        currentQuestions = await getJSON(`/quizzes/${quizId}/questions`);
        currentQuiz = { quizId, lessonTitle: title };
        body.innerHTML = currentQuestions.map((q, i) => `
            <div class="question">
                <span class="q-no">Câu ${i + 1}</span>
                <div class="q-text">${esc(q.content)}</div>
                <input class="answer-input" type="text" autocomplete="off"
                       data-qid="${q.questionId}" placeholder="Nhập đáp án của bạn...">
            </div>
        `).join('');
    } catch (e) {
        body.innerHTML = `<div class="empty">😢 ${esc(e.message)}</div>`;
    }
}

async function submitQuiz() {
    const id = getCurrentStudentId();
    const inputs = Array.from(document.querySelectorAll('#take-body .answer-input'));
    const answers = inputs.map(inp => ({
        questionId: parseInt(inp.dataset.qid, 10),
        answer: inp.value.trim()
    }));

    if (answers.some(a => !a.answer)) {
        if (!confirm('Bạn còn câu chưa trả lời. Vẫn nộp bài chứ?')) return;
    }

    const btn = document.getElementById('btn-submit');
    btn.disabled = true;
    btn.textContent = 'Đang chấm...';
    try {
        const result = await postJSON('/quizzes/submit', {
            studentId: id,
            quizId: currentQuiz.quizId,
            answers
        });
        renderResult(result);
    } catch (e) {
        alert('Nộp bài thất bại: ' + e.message);
    } finally {
        btn.disabled = false;
        btn.textContent = '✅ Nộp bài';
    }
}

function renderResult(r) {
    showView('result');
    const wrap = document.getElementById('result-body');

    const levelUp = r.leveledUp
        ? `<div class="levelup-tag">🎉 LÊN CẤP! Lv.${r.oldLevel} → Lv.${r.newLevel} 🎉</div>`
        : '';
    const passTag = r.passed
        ? '<span class="badge" style="background:var(--ok);color:#fff">ĐẠT</span>'
        : '<span class="badge" style="background:var(--bad);color:#fff">CHƯA ĐẠT</span>';

    const items = r.questions.map((q, i) => `
        <div class="result-item ${q.correct ? 'ok' : ''}">
            <div class="row">
                <span class="q-no">Câu ${i + 1}</span>
                <span class="verdict ${q.correct ? '' : 'no'}">${q.correct ? '✓ Đúng' : '✗ Sai'}</span>
            </div>
            <div class="q-text" style="margin-top:6px">${esc(q.content)}</div>
            <div class="ans-line">Bạn trả lời:
                <span class="${q.correct ? 'correct' : 'yours'}">${esc(q.yourAnswer) || '(bỏ trống)'}</span>
            </div>
            ${q.correct ? '' : `<div class="ans-line">Đáp án đúng: <span class="correct">${esc(q.correctAnswer)}</span></div>`}
        </div>
    `).join('');

    wrap.innerHTML = `
        <div class="result-banner fade-in">
            <div class="score">${r.correctCount}/${r.totalQuestions}</div>
            <div class="muted">câu trả lời đúng &nbsp; ${passTag}</div>
            <div class="clp">+${r.clpGain} CLP ✨</div>
            <div class="muted" style="margin-top:6px">
                Điểm quy đổi: ${r.pointsEarned}/${r.possiblePoints} &middot;
                Level hiện tại: <strong>${r.newLevel}</strong> &middot;
                Độ chính xác: <strong>${(r.accuracy * 100).toFixed(1)}%</strong>
            </div>
            ${levelUp}
        </div>
        <h3>📋 Xem lại bài làm</h3>
        ${items}
        <div class="row" style="justify-content:center; margin-top:22px">
            <button class="btn" onclick="loadQuizList()">📝 Làm bài khác</button>
            <a class="btn purple" href="dashboard.html">🏠 Về trang cá nhân</a>
        </div>
    `;

    if (r.leveledUp) fireConfetti();
}

document.addEventListener('DOMContentLoaded', initQuiz);
