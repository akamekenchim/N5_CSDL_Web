/* ==========================================================================
   leaderboard.js - Bảng vàng vinh danh (đọc từ view v_leaderboard)
   ========================================================================== */

async function initLeaderboard() {
    requireStudent();
    renderWho();
    const meId = getCurrentStudentId();
    const wrap = document.getElementById('lb-body');
    wrap.innerHTML = '<div class="loading">Đang tải bảng xếp hạng...</div>';

    try {
        const rows = await getJSON('/leaderboard');
        if (!rows.length) {
            wrap.innerHTML = '<div class="empty">Chưa có dữ liệu xếp hạng.</div>';
            return;
        }
        const medal = (rank) => rank === 1 ? '🥇' : rank === 2 ? '🥈' : rank === 3 ? '🥉' : '#' + rank;
        wrap.innerHTML = `
            <table class="table">
                <thead>
                    <tr><th>Hạng</th><th>Học sinh</th><th>Lớp</th><th>Level</th><th>CLP</th><th>Độ chính xác</th></tr>
                </thead>
                <tbody>
                    ${rows.map(r => `
                        <tr class="${r.studentId === meId ? 'me' : ''}">
                            <td class="rank-medal">${medal(r.rankPosition)}</td>
                            <td>${avatarFor(r.studentId)} ${esc(r.fullName)}${r.studentId === meId ? ' (bạn)' : ''}</td>
                            <td>${esc(r.className || '—')}</td>
                            <td><span class="badge level">Lv.${r.level}</span></td>
                            <td>${r.currentLevelProgress}</td>
                            <td>${(r.accuracy * 100).toFixed(1)}%</td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        `;
    } catch (e) {
        wrap.innerHTML = `<div class="empty">😢 ${esc(e.message)}</div>`;
    }
}

document.addEventListener('DOMContentLoaded', initLeaderboard);
