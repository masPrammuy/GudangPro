// Google OAuth 2.0 Client ID Resmi
var GOOGLE_CLIENT_ID = '1010556449565-8rha2490e78uoajron0gi5b5pt3kqkv7.apps.googleusercontent.com';
var storedClientId = localStorage.getItem('gp_google_client_id') || GOOGLE_CLIENT_ID;

// Pastikan tersimpan di localStorage
localStorage.setItem('gp_google_client_id', GOOGLE_CLIENT_ID);

document.addEventListener('DOMContentLoaded', function () {

  var form = document.getElementById('loginForm');
  var btnLogin = document.getElementById('btnLogin');
  var btnText = btnLogin.querySelector('.btn-text');
  var btnLoader = btnLogin.querySelector('.btn-loader');
  var usernameEl = document.getElementById('username');
  var passwordEl = document.getElementById('password');
  var togglePwd = document.getElementById('togglePassword');
  var toast = document.getElementById('toast');
  var groupUser = document.getElementById('group-username');
  var groupPass = document.getElementById('group-password');
  var errUser = document.getElementById('username-error');
  var errPass = document.getElementById('password-error');
  var googleBtn = document.getElementById('googleSignInBtn');

  // Google Modal Elements
  var gModalOverlay = document.getElementById('googleModalOverlay');
  var closeGoogleModal = document.getElementById('closeGoogleModal');
  var gAccountsList = document.getElementById('gAccountsList');
  var btnUseOtherGoogle = document.getElementById('btnUseOtherGoogle');
  var customGoogleForm = document.getElementById('customGoogleForm');
  var btnCancelCustomGoogle = document.getElementById('btnCancelCustomGoogle');
  var btnSubmitCustomGoogle = document.getElementById('btnSubmitCustomGoogle');
  var customGName = document.getElementById('customGName');
  var customGEmail = document.getElementById('customGEmail');
  var toggleClientIdConfig = document.getElementById('toggleClientIdConfig');
  var clientIdBox = document.getElementById('clientIdBox');
  var inputGoogleClientId = document.getElementById('inputGoogleClientId');
  var btnSaveClientId = document.getElementById('btnSaveClientId');

  // Google Cloud Guide Modal Elements
  var gCloudGuideModalOverlay = document.getElementById('googleCloudGuideModalOverlay');
  var closeGuideModal = document.getElementById('closeGuideModal');
  var btnOpenCloudGuide = document.getElementById('btnOpenCloudGuide');
  var btnCopyOrigin = document.getElementById('btnCopyOrigin');
  var originUrlCode = document.getElementById('originUrlCode');
  var guideInputClientId = document.getElementById('guideInputClientId');
  var btnConnectGoogleCloud = document.getElementById('btnConnectGoogleCloud');
  var btnUseDemoGoogle = document.getElementById('btnUseDemoGoogle');
  var gStatusDot = document.getElementById('gStatusDot');
  var gStatusText = document.getElementById('gStatusText');
  var officialGoogleBtn = document.getElementById('officialGoogleBtn');

  // Set current window origin in the copy code box
  if (originUrlCode) {
    originUrlCode.textContent = window.location.origin;
  }

  if (inputGoogleClientId && storedClientId) {
    inputGoogleClientId.value = storedClientId;
  }
  if (guideInputClientId && storedClientId) {
    guideInputClientId.value = storedClientId;
  }

  // Demo credentials (login manual)
  var DEMO_USER = 'admin@gudangpro.id';
  var DEMO_PASS = 'Admin123!';

  // ── Redirect jika sudah login ──────────────────────────────────────────────
  if (sessionStorage.getItem('gp_user')) {
    window.location.href = 'dashboard.html';
    return;
  }

  // ── Google Sign-In & Google Cloud Integration ───────────────────────────────
  function updateCloudStatusUI(connected) {
    if (gStatusDot && gStatusText) {
      if (connected) {
        gStatusDot.classList.add('connected');
        gStatusText.textContent = 'Google Cloud: Terhubung (OAuth 2.0 Aktif)';
      } else {
        gStatusDot.classList.remove('connected');
        gStatusText.textContent = 'Google Cloud: Belum Terhubung';
      }
    }
  }

  function initGoogle() {
    if (typeof google === 'undefined' || !google.accounts) {
      setTimeout(initGoogle, 300);
      return;
    }

    var activeClientId = localStorage.getItem('gp_google_client_id') || GOOGLE_CLIENT_ID;

    if (activeClientId && activeClientId !== 'YOUR_GOOGLE_CLIENT_ID') {
      try {
        google.accounts.id.initialize({
          client_id: activeClientId,
          callback: handleGoogleCredential,
          auto_select: false,
          cancel_on_tap_outside: true,
        });

        // Render tombol resmi Google Identity Services
        if (officialGoogleBtn) {
          officialGoogleBtn.innerHTML = '';
          officialGoogleBtn.style.display = 'flex';
          officialGoogleBtn.style.justifyContent = 'center';
          googleBtn.style.display = 'none';

          google.accounts.id.renderButton(officialGoogleBtn, {
            theme: 'outline',
            size: 'large',
            width: '320',
            text: 'signin_with',
            shape: 'rectangular',
            logo_alignment: 'left'
          });
        }

        // Tampilkan prompt Google One-Tap jika memungkinkan
        google.accounts.id.prompt(function () { });

        updateCloudStatusUI(true);
        return;
      } catch (e) {
        console.warn('Google Cloud GSI Init Error:', e);
      }
    }

    // Belum terhubung
    updateCloudStatusUI(false);
    if (officialGoogleBtn) officialGoogleBtn.style.display = 'none';
    if (googleBtn) googleBtn.style.display = 'flex';
  }

  function handleGoogleCredential(response) {
    if (!response || !response.credential) return;
    var payload = parseJwt(response.credential);
    if (!payload) {
      showToast('Gagal membaca data akun Google. Coba lagi.', 'error');
      return;
    }
    var user = {
      name: payload.name || payload.given_name || (payload.email ? payload.email.split('@')[0] : 'Pengguna Google'),
      email: payload.email || '',
      picture: payload.picture || '',
      source: 'google',
      role: 'Staff Gudang'
    };
    showToast('Login Google Cloud berhasil!', 'success');
    setTimeout(function () { loginSuccess(user); }, 600);
  }

  // Klik tombol "Masuk dengan Google" (ketika Client ID belum dikonfigurasi)
  googleBtn.addEventListener('click', function () {
    var activeClientId = localStorage.getItem('gp_google_client_id');
    if (!activeClientId || activeClientId === 'YOUR_GOOGLE_CLIENT_ID') {
      // Tampilkan panduan untuk menghubungkan Google Cloud
      openCloudGuideModal();
    } else {
      openGoogleChooserModal();
    }
  });

  // Modal Panduan Google Cloud
  function openCloudGuideModal() {
    if (gCloudGuideModalOverlay) {
      gCloudGuideModalOverlay.style.display = 'flex';
      document.body.style.overflow = 'hidden';
      if (guideInputClientId) guideInputClientId.focus();
    }
  }

  function hideCloudGuideModal() {
    if (gCloudGuideModalOverlay) {
      gCloudGuideModalOverlay.style.display = 'none';
      document.body.style.overflow = '';
    }
  }

  if (btnOpenCloudGuide) {
    btnOpenCloudGuide.addEventListener('click', openCloudGuideModal);
  }

  if (closeGuideModal) {
    closeGuideModal.addEventListener('click', hideCloudGuideModal);
  }

  if (gCloudGuideModalOverlay) {
    gCloudGuideModalOverlay.addEventListener('click', function (e) {
      if (e.target === gCloudGuideModalOverlay) hideCloudGuideModal();
    });
  }

  // Salin URL origin
  if (btnCopyOrigin && originUrlCode) {
    btnCopyOrigin.addEventListener('click', function () {
      var url = originUrlCode.textContent.trim();
      navigator.clipboard.writeText(url).then(function () {
        btnCopyOrigin.textContent = 'Tersalin!';
        showToast('URL ' + url + ' berhasil disalin!', 'success');
        setTimeout(function () { btnCopyOrigin.textContent = 'Salin URL'; }, 2000);
      }).catch(function () {
        showToast('Gagal menyalin otomatis. Silakan salin manual: ' + url, 'error');
      });
    });
  }

  // Simpan & Hubungkan Google Cloud
  if (btnConnectGoogleCloud && guideInputClientId) {
    btnConnectGoogleCloud.addEventListener('click', function () {
      var cid = (guideInputClientId.value || '').trim();
      if (!cid) {
        showToast('Tempelkan Google Client ID Anda terlebih dahulu.', 'error');
        guideInputClientId.focus();
        return;
      }

      localStorage.setItem('gp_google_client_id', cid);
      GOOGLE_CLIENT_ID = cid;
      hideCloudGuideModal();
      showToast('Google Cloud Client ID disimpan! Mengaktifkan tombol resmi...', 'success');
      initGoogle();
    });
  }

  // Opsi gunakan pilihan akun Google demo
  if (btnUseDemoGoogle) {
    btnUseDemoGoogle.addEventListener('click', function () {
      hideCloudGuideModal();
      openGoogleChooserModal();
    });
  }

  function openGoogleChooserModal() {
    gModalOverlay.style.display = 'flex';
    document.body.style.overflow = 'hidden';
  }

  function hideGoogleChooserModal() {
    gModalOverlay.style.display = 'none';
    document.body.style.overflow = '';
    if (customGoogleForm) customGoogleForm.style.display = 'none';
  }

  if (closeGoogleModal) {
    closeGoogleModal.addEventListener('click', hideGoogleChooserModal);
  }

  if (gModalOverlay) {
    gModalOverlay.addEventListener('click', function (e) {
      if (e.target === gModalOverlay) hideGoogleChooserModal();
    });
  }

  // Pilih salah satu akun dari daftar akun Google
  if (gAccountsList) {
    var accItems = gAccountsList.querySelectorAll('.g-account-item');
    accItems.forEach(function (item) {
      item.addEventListener('click', function () {
        var name = item.getAttribute('data-name');
        var email = item.getAttribute('data-email');
        var pic = item.getAttribute('data-pic') || '';
        item.style.opacity = '0.6';
        showToast('Menghubungkan akun Google ' + email + '...', 'info');
        setTimeout(function () {
          loginSuccess({
            name: name,
            email: email,
            picture: pic,
            source: 'google'
          });
        }, 600);
      });
    });
  }

  // Tombol "Gunakan akun Google lain"
  if (btnUseOtherGoogle && customGoogleForm) {
    btnUseOtherGoogle.addEventListener('click', function () {
      customGoogleForm.style.display = customGoogleForm.style.display === 'none' ? 'block' : 'none';
      if (customGoogleForm.style.display === 'block') {
        customGName.focus();
      }
    });
  }

  if (btnCancelCustomGoogle && customGoogleForm) {
    btnCancelCustomGoogle.addEventListener('click', function () {
      customGoogleForm.style.display = 'none';
    });
  }

  if (btnSubmitCustomGoogle) {
    btnSubmitCustomGoogle.addEventListener('click', function () {
      var name = (customGName.value || '').trim();
      var email = (customGEmail.value || '').trim();

      if (!name) {
        showToast('Nama akun Google wajib diisi.', 'error');
        customGName.focus();
        return;
      }
      if (!email || email.indexOf('@') === -1) {
        showToast('Masukkan format email Google yang valid.', 'error');
        customGEmail.focus();
        return;
      }

      showToast('Menghubungkan ke ' + email + '...', 'info');
      btnSubmitCustomGoogle.disabled = true;
      setTimeout(function () {
        loginSuccess({
          name: name,
          email: email,
          picture: '',
          source: 'google'
        });
      }, 700);
    });
  }

  // Konfigurasi Client ID Google
  if (toggleClientIdConfig && clientIdBox) {
    toggleClientIdConfig.addEventListener('click', function () {
      clientIdBox.style.display = clientIdBox.style.display === 'none' ? 'block' : 'none';
    });
  }

  if (btnSaveClientId && inputGoogleClientId) {
    btnSaveClientId.addEventListener('click', function () {
      var val = inputGoogleClientId.value.trim();
      if (val) {
        localStorage.setItem('gp_google_client_id', val);
        GOOGLE_CLIENT_ID = val;
        showToast('Google Client ID berhasil disimpan!', 'success');
        initGoogle();
      } else {
        localStorage.removeItem('gp_google_client_id');
        GOOGLE_CLIENT_ID = 'YOUR_GOOGLE_CLIENT_ID';
        showToast('Client ID dikosongkan. Menggunakan mode interaktif.', 'info');
      }
    });
  }

  // Decode JWT payload (untuk token Google)
  function parseJwt(token) {
    try {
      var base64 = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
      return JSON.parse(atob(base64));
    } catch (e) { return null; }
  }

  // Init setelah DOM siap
  initGoogle();

  // ── Password toggle ────────────────────────────────────────────────────────
  togglePwd.addEventListener('click', function () {
    var isPass = passwordEl.type === 'password';
    passwordEl.type = isPass ? 'text' : 'password';
    togglePwd.querySelector('.eye-open').style.display = isPass ? 'none' : '';
    togglePwd.querySelector('.eye-closed').style.display = isPass ? '' : 'none';
  });

  // ── Validation ─────────────────────────────────────────────────────────────
  function validate() {
    var ok = true;
    var u = usernameEl.value.trim();
    var p = passwordEl.value;

    if (!u) {
      showErr(groupUser, errUser, 'Email atau username tidak boleh kosong.');
      ok = false;
    } else {
      clearErr(groupUser, errUser);
    }
    if (!p) {
      showErr(groupPass, errPass, 'Kata sandi tidak boleh kosong.');
      ok = false;
    } else if (p.length < 6) {
      showErr(groupPass, errPass, 'Minimal 6 karakter.');
      ok = false;
    } else {
      clearErr(groupPass, errPass);
    }
    return ok;
  }

  function showErr(group, el, msg) {
    group.classList.add('has-error');
    el.textContent = msg;
  }

  function clearErr(group, el) {
    group.classList.remove('has-error');
    el.textContent = '';
  }

  usernameEl.addEventListener('input', function () { clearErr(groupUser, errUser); });
  passwordEl.addEventListener('input', function () { clearErr(groupPass, errPass); });

  // ── Form submit (login manual) ─────────────────────────────────────────────
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    if (!validate()) return;

    var u = usernameEl.value.trim();
    var p = passwordEl.value;

    btnLogin.disabled = true;
    btnText.style.display = 'none';
    btnLoader.style.display = '';

    setTimeout(function () {
      if ((u === DEMO_USER || u === 'admin') && p === DEMO_PASS) {
        var user = {
          name: 'Admin Gudang',
          email: DEMO_USER,
          picture: '',
          source: 'manual',
        };
        showToast('Login berhasil! Mengarahkan...', 'success');
        setTimeout(function () { loginSuccess(user); }, 800);
      } else {
        btnLogin.disabled = false;
        btnText.style.display = '';
        btnLoader.style.display = 'none';
        showErr(groupPass, errPass, 'Username atau kata sandi salah.');
        showToast('Login gagal. Cek kembali kredensial Anda.', 'error');
      }
    }, 1200);
  });

  // ── Login success ──────────────────────────────────────────────────────────
  function loginSuccess(user) {
    user.loginTime = new Date().toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' });
    user.loginDate = new Date().toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
    if (!user.role) {
      user.role = (user.email === DEMO_USER || user.email.indexOf('admin') !== -1) ? 'Administrator' : 'Staff Gudang';
    }
    sessionStorage.setItem('gp_user', JSON.stringify(user));
    syncAccountToStorage(user);
    window.location.href = 'dashboard.html';
  }

  function syncAccountToStorage(user) {
    try {
      var accounts = JSON.parse(localStorage.getItem('gp_accounts') || '[]');
      var existing = accounts.find(function (a) { return a.email.toLowerCase() === user.email.toLowerCase(); });
      if (!existing) {
        accounts.push({
          id: 'ACC-' + Date.now(),
          name: user.name,
          email: user.email,
          role: user.role,
          source: user.source || 'manual',
          status: 'Aktif',
          picture: user.picture || '',
          createdAt: new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })
        });
        localStorage.setItem('gp_accounts', JSON.stringify(accounts));
      }
    } catch (e) { }
  }

  // ── Toast ──────────────────────────────────────────────────────────────────
  var toastTimer;
  function showToast(msg, type) {
    clearTimeout(toastTimer);
    toast.textContent = msg;
    toast.className = 'toast ' + type;
    requestAnimationFrame(function () { toast.classList.add('show'); });
    toastTimer = setTimeout(function () { toast.classList.remove('show'); }, 3500);
  }

  // ── Lupa sandi & register ──────────────────────────────────────────────────
  document.getElementById('forgotPasswordLink').addEventListener('click', function (e) {
    e.preventDefault();
    showToast('Hubungi administrator untuk reset kata sandi.', 'error');
  });

  document.getElementById('registerLink').addEventListener('click', function (e) {
    e.preventDefault();
    showToast('Hubungi admin untuk pembuatan akun baru.', 'error');
  });

});
