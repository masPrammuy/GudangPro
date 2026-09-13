/* ─── GudangPro — Logged-In Welcome Screen ───────────────────────────────────
   Tampilan sederhana dan elegan setelah pengguna berhasil masuk:
   1. Autentikasi Guard (redirect ke index.html jika sesi tidak ditemukan)
   2. Menampilkan informasi akun yang sedang login (Nama, Email, Avatar, Metode)
   3. Opsi keluar (Logout) untuk kembali ke halaman login
─────────────────────────────────────────────────────────────────────────── */

'use strict';

document.addEventListener('DOMContentLoaded', function () {
  var user = getUser();
  if (!user) {
    window.location.href = 'index.html';
    return;
  }

  renderUserProfile(user);
  bindEvents();
});

function getUser() {
  try {
    var raw = sessionStorage.getItem('gp_user');
    return raw ? JSON.parse(raw) : null;
  } catch (e) {
    return null;
  }
}

function renderUserProfile(user) {
  // Topbar
  var headerName   = document.getElementById('headerUserName');
  var headerEmail  = document.getElementById('headerUserEmail');
  var headerAvatar = document.getElementById('headerAvatar');

  if (headerName) headerName.textContent = user.name || 'Pengguna';
  if (headerEmail) headerEmail.textContent = user.email || '';
  if (headerAvatar) renderAvatar(headerAvatar, user.name, user.picture, 28);

  // Main Welcome Card
  var welcomeName   = document.getElementById('welcomeName');
  var welcomeEmail  = document.getElementById('welcomeEmail');
  var welcomeRole   = document.getElementById('welcomeRole');
  var welcomeAvatar = document.getElementById('welcomeAvatar');
  var welcomeMethod = document.getElementById('welcomeMethod');
  var welcomeTime   = document.getElementById('welcomeLoginTime');
  var welcomeBadge  = document.getElementById('welcomeSourceBadge');

  if (welcomeName) welcomeName.textContent = user.name || 'Pengguna';
  if (welcomeEmail) welcomeEmail.textContent = user.email || '';
  if (welcomeRole) welcomeRole.textContent = user.role || 'Staff Gudang';

  var timeStr = user.loginTime || new Date().toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) + ' WIB';
  var dateStr = user.loginDate || new Date().toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'short', year: 'numeric' });
  if (welcomeTime) {
    welcomeTime.textContent = dateStr + ' • ' + timeStr;
  }

  var isGoogle = (user.source === 'google');
  var isSupabase = (user.source === 'supabase');

  if (welcomeMethod) {
    if (isGoogle) {
      welcomeMethod.innerHTML = '<span class="source-tag google"><svg width="14" height="14" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/></svg> Akun Google</span>';
    } else if (isSupabase) {
      welcomeMethod.innerHTML = '<span class="source-tag" style="background:rgba(16,185,129,0.12); color:#10b981; border:1px solid rgba(16,185,129,0.3); padding:4px 9px; border-radius:6px; font-weight:600; font-size:0.8rem; display:inline-flex; align-items:center; gap:6px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M11.95 2L3 13.5h7.5L8.5 22l11.5-12.5h-7.5L14 2h-2.05z" fill="#10B981"/></svg> Supabase Cloud Auth</span>';
    } else {
      var srcLabel = user.source === 'local' ? 'Akun Lokal Gudang' : 'Kredensial Manual';
      welcomeMethod.innerHTML = '<span class="source-tag manual"><svg width="14" height="14" viewBox="0 0 24 24" fill="none"><rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" stroke-width="2"/><path d="M7 11V7a5 5 0 0110 0v4" stroke="currentColor" stroke-width="2"/></svg> ' + srcLabel + '</span>';
    }
  }

  if (welcomeBadge) {
    if (isGoogle) {
      welcomeBadge.className = 'source-badge google';
      welcomeBadge.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/></svg>';
    } else if (isSupabase) {
      welcomeBadge.className = 'source-badge';
      welcomeBadge.style.background = '#10b981';
      welcomeBadge.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M11.95 2L3 13.5h7.5L8.5 22l11.5-12.5h-7.5L14 2h-2.05z" fill="#ffffff"/></svg>';
    } else {
      welcomeBadge.className = 'source-badge manual';
      welcomeBadge.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none"><rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" stroke-width="2"/><path d="M7 11V7a5 5 0 0110 0v4" stroke="currentColor" stroke-width="2"/></svg>';
    }
  }

  if (welcomeAvatar) {
    renderAvatar(welcomeAvatar, user.name, user.picture, 76);
  }
}

function renderAvatar(container, name, pictureUrl, size) {
  container.innerHTML = '';
  if (pictureUrl) {
    var img = document.createElement('img');
    img.src = pictureUrl;
    img.alt = name || 'User Avatar';
    img.className = 'avatar-img';
    img.onerror = function () {
      container.innerHTML = '<span class="avatar-initial">' + (name ? name.charAt(0).toUpperCase() : 'U') + '</span>';
    };
    container.appendChild(img);
  } else {
    var initial = name ? name.trim().charAt(0).toUpperCase() : 'U';
    var span = document.createElement('span');
    span.className = 'avatar-initial';
    span.textContent = initial;
    container.appendChild(span);
  }
}

async function logout() {
  showToast('Sedang keluar dari sesi...', 'info');
  if (window.GudangProSupabase) {
    try {
      await window.GudangProSupabase.logout();
    } catch (e) { }
  }
  setTimeout(function () {
    sessionStorage.removeItem('gp_user');
    window.location.href = 'index.html';
  }, 350);
}

function bindEvents() {
  var btnLogout = document.getElementById('btnLogout');
  var btnLogoutMain = document.getElementById('btnLogoutMain');

  if (btnLogout) btnLogout.addEventListener('click', logout);
  if (btnLogoutMain) btnLogoutMain.addEventListener('click', logout);
}

var toastTimer;
function showToast(msg, type) {
  var toast = document.getElementById('toast');
  if (!toast) return;
  clearTimeout(toastTimer);
  toast.textContent = msg;
  toast.className = 'toast ' + (type || 'info');
  requestAnimationFrame(function () { toast.classList.add('show'); });
  toastTimer = setTimeout(function () { toast.classList.remove('show'); }, 3000);
}
