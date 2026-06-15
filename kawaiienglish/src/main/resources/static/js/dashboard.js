/* ==========================================================================
   dashboard.js - Trang cá nhân: Level, thanh CLP, độ chính xác, thứ hạng
   ========================================================================== */

async function initDashboard() {
    const id = requireStudent();
    if (!id) return;
    renderWho();

    const box = document.getElementById('dash');
    try {
        const d = await getJSON('/students/' + id);
        setCurrentStudent(id, d.studentName);
        renderWho();

        const acc = (d.accuracy * 100);
        const next = d.nextLevelClp;
        const pct = next ? Math.min(100, Math.round((d.currentLevelProgress / next) * 100)) : 100;
        const progressLabel = next
            ? `${d.currentLevelProgress} / ${next} CLP`
            : `${d.currentLevelProgress} CLP (MAX)`;

        box.innerHTML = `
            <div class="card fade-in">
                <div class="row">
                    <div class="avatar spin-pulse">${avatarFor(d.studentId)}</div>
                    <div>
                        <div class="page-title" style="margin:0">${esc(d.studentName)}</div>
                        <div class="muted">${esc(d.studentEmail || '')}</div>
                        <div class="row" style="margin-top:8px">
                            <span class="badge level">Level ${d.level}</span>
                            <span class="badge cefr">${esc(d.assessmentCefr || '?')}</span>
                            <span class="badge">🏆 Hạng ${d.rankPosition ?? '-'}</span>
                        </div>
                    </div>
                </div>

                <div style="margin-top:22px">
                    <div class="row"><strong>Tiến độ lên cấp</strong><div class="spacer"></div>
                        <span class="muted">${progressLabel}</span></div>
                    <div class="progress" style="margin-top:8px">
                        <span id="xp-bar"></span>
                        <div class="label">${pct}%</div>
                    </div>
                </div>

                <div class="grid cols-3" style="margin-top:22px">
                    <div class="stat"><div class="num">${acc.toFixed(1)}%</div><div class="cap">Độ chính xác</div></div>
                    <div class="stat"><div class="num">${d.totalCorrect}</div><div class="cap">Câu đúng</div></div>
                    <div class="stat"><div class="num">${d.totalAnswered}</div><div class="cap">Đã trả lời</div></div>
                </div>

                <div class="grid cols-2" style="margin-top:18px">
                    <div class="stat"><div class="num" style="font-size:1.15rem">${esc(d.className || '—')}</div><div class="cap">Lớp học</div></div>
                    <div class="stat"><div class="num" style="font-size:1.15rem">${esc(d.teacherName || '—')}</div><div class="cap">Giáo viên chủ nhiệm</div></div>
                </div>

                <div class="row" style="margin-top:24px; justify-content:center">
                    <a class="btn" href="quiz.html">📝 Vào làm bài</a>
                    <a class="btn purple" href="leaderboard.html">🏆 Bảng xếp hạng</a>
                    <a class="btn ghost" href="lessons.html">📚 Học bài giảng</a>
                </div>
            </div>
        `;
        // Hiệu ứng nạp thanh XP
        requestAnimationFrame(() => {
            document.getElementById('xp-bar').style.width = pct + '%';
        });
    } catch (e) {
        box.innerHTML = `<div class="empty">😢 Không tải được trang cá nhân.<br>${esc(e.message)}</div>`;
    }
}

document.addEventListener('DOMContentLoaded', initDashboard);
