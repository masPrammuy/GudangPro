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

  // Supabase Integration Elements
  var sbStatusBadge = document.getElementById('sbStatusBadge');
  var sbStatusDot = document.getElementById('sbStatusDot');
  var sbStatusText = document.getElementById('sbStatusText');
  var btnOpenSbModal = document.getElementById('btnOpenSbModal');
  var supabaseModalOverlay = document.getElementById('supabaseModalOverlay');
  var closeSbModal = document.getElementById('closeSbModal');
  var inputSbUrl = document.getElementById('inputSbUrl');
  var inputSbAnonKey = document.getElementById('inputSbAnonKey');
  var btnSaveSbConfig = document.getElementById('btnSaveSbConfig');
  var btnResetSbConfig = document.getElementById('btnResetSbConfig');

  // Auth Mode Tabs Elements
  var tabBtnLogin = document.getElementById('tabBtnLogin');
  var tabBtnRegister = document.getElementById('tabBtnRegister');
  var loginSection = document.getElementById('loginSection');
  var registerSection = document.getElementById('registerSection');
  var toRegisterLink = document.getElementById('toRegisterLink');
  var toLoginLink = document.getElementById('toLoginLink');

  // Registration Form Elements
  var regForm = document.getElementById('registerForm');
  var btnRegister = document.getElementById('btnRegister');
  var regNameEl = document.getElementById('regName');
  var regEmailEl = document.getElementById('regEmail');
  var regRoleEl = document.getElementById('regRole');
  var regPasswordEl = document.getElementById('regPassword');
  var regConfirmPasswordEl = document.getElementById('regConfirmPassword');
  var toggleRegPwd = document.getElementById('toggleRegPassword');
  var toggleRegConfirmPwd = document.getElementById('toggleRegConfirmPassword');

  var groupRegName = document.getElementById('group-reg-name');
  var groupRegEmail = document.getElementById('group-reg-email');
  var groupRegRole = document.getElementById('group-reg-role');
  var groupRegPass = document.getElementById('group-reg-password');
  var groupRegConfirm = document.getElementById('group-reg-confirm');

  var errRegName = document.getElementById('reg-name-error');
  var errRegEmail = document.getElementById('reg-email-error');
  var errRegRole = document.getElementById('reg-role-error');
  var errRegPass = document.getElementById('reg-password-error');
  var errRegConfirm = document.getElementById('reg-confirm-error');

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

  // Pre-fill Supabase inputs
  if (window.GudangProSupabase) {
    var sbCfg = window.GudangProSupabase.getSupabaseConfig();
    if (inputSbUrl && sbCfg.url) inputSbUrl.value = sbCfg.url;
    if (inputSbAnonKey && sbCfg.anonKey) inputSbAnonKey.value = sbCfg.anonKey;
  }

  // Demo credentials (login manual)
  var DEMO_USER = 'admin@gudangpro.id';
  var DEMO_PASS = 'Admin123!';

  // ── Redirect jika sudah login ──────────────────────────────────────────────
  if (sessionStorage.getItem('gp_user')) {
    window.location.href = 'dashboard.html';
    return;
  }

  // ── Supabase Integration Status & Modal ─────────────────────────────────────
  function updateSupabaseStatusUI() {
    if (!sbStatusDot || !sbStatusText) return;
    if (window.GudangProSupabase && window.GudangProSupabase.isSupabaseConfigured()) {
      sbStatusDot.classList.add('connected');
      sbStatusText.textContent = 'Supabase: Terhubung (Cloud Auth Aktif)';
    } else {
      sbStatusDot.classList.remove('connected');
      sbStatusText.textContent = 'Supabase: Mode Lokal (Offline/Demo)';
    }
  }

  function openSupabaseModal() {
    if (supabaseModalOverlay) {
      supabaseModalOverlay.style.display = 'flex';
      document.body.style.overflow = 'hidden';
      if (inputSbUrl) inputSbUrl.focus();
    }
  }

  function hideSupabaseModal() {
    if (supabaseModalOverlay) {
      supabaseModalOverlay.style.display = 'none';
      document.body.style.overflow = '';
    }
  }

  if (btnOpenSbModal) btnOpenSbModal.addEventListener('click', openSupabaseModal);
  if (closeSbModal) closeSbModal.addEventListener('click', hideSupabaseModal);
  if (supabaseModalOverlay) {
    supabaseModalOverlay.addEventListener('click', function (e) {
      if (e.target === supabaseModalOverlay) hideSupabaseModal();
    });
  }

  if (btnSaveSbConfig) {
    btnSaveSbConfig.addEventListener('click', function () {
      var url = (inputSbUrl.value || '').trim();
      var key = (inputSbAnonKey.value || '').trim();

      if (!url || !url.startsWith('http')) {
        showToast('Project URL Supabase harus diawali https://', 'error');
        if (inputSbUrl) inputSbUrl.focus();
        return;
      }
      if (!key) {
        showToast('API Key (anon/public) Supabase wajib diisi.', 'error');
        if (inputSbAnonKey) inputSbAnonKey.focus();
        return;
      }

      if (window.GudangProSupabase) {
        window.GudangProSupabase.saveSupabaseConfig(url, key);
        updateSupabaseStatusUI();
        hideSupabaseModal();
        showToast('Supabase berhasil dihubungkan!', 'success');
      }
    });
  }

  if (btnResetSbConfig) {
    btnResetSbConfig.addEventListener('click', function () {
      if (window.GudangProSupabase) {
        window.GudangProSupabase.saveSupabaseConfig('', '');
        if (inputSbUrl) inputSbUrl.value = '';
        if (inputSbAnonKey) inputSbAnonKey.value = '';
        updateSupabaseStatusUI();
        hideSupabaseModal();
        showToast('Konfigurasi Supabase dihapus. Beralih ke mode lokal demo.', 'info');
      }
    });
  }

  updateSupabaseStatusUI();

  // ── Auth Mode Tabs Switcher ────────────────────────────────────────────────
  function switchAuthTab(mode) {
    if (mode === 'register') {
      if (tabBtnLogin) tabBtnLogin.classList.remove('active');
      if (tabBtnRegister) tabBtnRegister.classList.add('active');
      if (loginSection) loginSection.style.display = 'none';
      if (registerSection) {
        registerSection.style.display = 'block';
        if (regNameEl) regNameEl.focus();
      }
    } else {
      if (tabBtnRegister) tabBtnRegister.classList.remove('active');
      if (tabBtnLogin) tabBtnLogin.classList.add('active');
      if (registerSection) registerSection.style.display = 'none';
      if (loginSection) {
        loginSection.style.display = 'block';
        if (usernameEl) usernameEl.focus();
      }
    }
  }

  if (tabBtnLogin) {
    tabBtnLogin.addEventListener('click', function () { switchAuthTab('login'); });
  }
  if (tabBtnRegister) {
    tabBtnRegister.addEventListener('click', function () { switchAuthTab('register'); });
  }
  if (toRegisterLink) {
    toRegisterLink.addEventListener('click', function (e) {
      e.preventDefault();
      switchAuthTab('register');
    });
  }
  if (toLoginLink) {
    toLoginLink.addEventListener('click', function (e) {
      e.preventDefault();
      switchAuthTab('login');
    });
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

  // ── Password toggles ───────────────────────────────────────────────────────
  if (togglePwd && passwordEl) {
    togglePwd.addEventListener('click', function () {
      var isPass = passwordEl.type === 'password';
      passwordEl.type = isPass ? 'text' : 'password';
      togglePwd.querySelector('.eye-open').style.display = isPass ? 'none' : '';
      togglePwd.querySelector('.eye-closed').style.display = isPass ? '' : 'none';
    });
  }

  if (toggleRegPwd && regPasswordEl) {
    toggleRegPwd.addEventListener('click', function () {
      var isPass = regPasswordEl.type === 'password';
      regPasswordEl.type = isPass ? 'text' : 'password';
      toggleRegPwd.querySelector('.eye-open').style.display = isPass ? 'none' : '';
      toggleRegPwd.querySelector('.eye-closed').style.display = isPass ? '' : 'none';
    });
  }

  if (toggleRegConfirmPwd && regConfirmPasswordEl) {
    toggleRegConfirmPwd.addEventListener('click', function () {
      var isPass = regConfirmPasswordEl.type === 'password';
      regConfirmPasswordEl.type = isPass ? 'text' : 'password';
      toggleRegConfirmPwd.querySelector('.eye-open').style.display = isPass ? 'none' : '';
      toggleRegConfirmPwd.querySelector('.eye-closed').style.display = isPass ? '' : 'none';
    });
  }

  // ── Validation Helpers ─────────────────────────────────────────────────────
  function showErr(group, el, msg) {
    if (group) group.classList.add('has-error');
    if (el) el.textContent = msg;
  }

  function clearErr(group, el) {
    if (group) group.classList.remove('has-error');
    if (el) el.textContent = '';
  }

  function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  // ── Login Validation ───────────────────────────────────────────────────────
  function validateLogin() {
    var ok = true;
    var u = usernameEl ? usernameEl.value.trim() : '';
    var p = passwordEl ? passwordEl.value : '';

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

  if (usernameEl) usernameEl.addEventListener('input', function () { clearErr(groupUser, errUser); });
  if (passwordEl) passwordEl.addEventListener('input', function () { clearErr(groupPass, errPass); });

  // ── Registration Validation ────────────────────────────────────────────────
  function validateRegister() {
    var ok = true;
    var name = regNameEl ? regNameEl.value.trim() : '';
    var email = regEmailEl ? regEmailEl.value.trim() : '';
    var p = regPasswordEl ? regPasswordEl.value : '';
    var cp = regConfirmPasswordEl ? regConfirmPasswordEl.value : '';

    if (!name) {
      showErr(groupRegName, errRegName, 'Nama lengkap wajib diisi.');
      ok = false;
    } else {
      clearErr(groupRegName, errRegName);
    }

    if (!email) {
      showErr(groupRegEmail, errRegEmail, 'Email wajib diisi.');
      ok = false;
    } else if (!isValidEmail(email)) {
      showErr(groupRegEmail, errRegEmail, 'Format email tidak valid (contoh: staff@gudangpro.id).');
      ok = false;
    } else {
      clearErr(groupRegEmail, errRegEmail);
    }

    if (!p) {
      showErr(groupRegPass, errRegPass, 'Kata sandi wajib diisi.');
      ok = false;
    } else if (p.length < 6) {
      showErr(groupRegPass, errRegPass, 'Kata sandi minimal 6 karakter.');
      ok = false;
    } else {
      clearErr(groupRegPass, errRegPass);
    }

    if (!cp) {
      showErr(groupRegConfirm, errRegConfirm, 'Ulangi kata sandi Anda.');
      ok = false;
    } else if (cp !== p) {
      showErr(groupRegConfirm, errRegConfirm, 'Konfirmasi kata sandi tidak cocok.');
      ok = false;
    } else {
      clearErr(groupRegConfirm, errRegConfirm);
    }

    return ok;
  }

  if (regNameEl) regNameEl.addEventListener('input', function () { clearErr(groupRegName, errRegName); });
  if (regEmailEl) regEmailEl.addEventListener('input', function () { clearErr(groupRegEmail, errRegEmail); });
  if (regPasswordEl) regPasswordEl.addEventListener('input', function () { clearErr(groupRegPass, errRegPass); });
  if (regConfirmPasswordEl) regConfirmPasswordEl.addEventListener('input', function () { clearErr(groupRegConfirm, errRegConfirm); });

  // ── Form Submit: Login (Supabase + Local Fallback) ──────────────────────────
  if (form) {
    form.addEventListener('submit', async function (e) {
      e.preventDefault();
      if (!validateLogin()) return;

      var u = usernameEl.value.trim();
      var p = passwordEl.value;

      btnLogin.disabled = true;
      btnText.style.display = 'none';
      btnLoader.style.display = '';

      try {
        var res = await window.GudangProSupabase.login(u, p);
        if (res.success) {
          showToast('Login berhasil! Mengarahkan...', 'success');
          setTimeout(function () {
            loginSuccess(res.user);
          }, 600);
        } else {
          btnLogin.disabled = false;
          btnText.style.display = '';
          btnLoader.style.display = 'none';
          showErr(groupPass, errPass, res.error || 'Email atau kata sandi salah.');
          showToast(res.error || 'Login gagal. Cek kembali kredensial Anda.', 'error');
        }
      } catch (err) {
        btnLogin.disabled = false;
        btnText.style.display = '';
        btnLoader.style.display = 'none';
        showToast('Terjadi kesalahan saat memproses login.', 'error');
      }
    });
  }

  // ── Form Submit: Register Akun Baru (Supabase Auth) ─────────────────────────
  if (regForm) {
    regForm.addEventListener('submit', async function (e) {
      e.preventDefault();
      if (!validateRegister()) return;

      var name = regNameEl.value.trim();
      var email = regEmailEl.value.trim();
      var role = regRoleEl ? regRoleEl.value : 'Staff Gudang';
      var password = regPasswordEl.value;

      var regBtnText = btnRegister.querySelector('.btn-text');
      var regBtnLoader = btnRegister.querySelector('.btn-loader');

      btnRegister.disabled = true;
      if (regBtnText) regBtnText.style.display = 'none';
      if (regBtnLoader) regBtnLoader.style.display = '';

      try {
        var res = await window.GudangProSupabase.register(email, password, {
          name: name,
          role: role
        });

        btnRegister.disabled = false;
        if (regBtnText) regBtnText.style.display = '';
        if (regBtnLoader) regBtnLoader.style.display = 'none';

        if (res.success) {
          if (res.requiresEmailConfirmation) {
            showToast('Pendaftaran berhasil! Silakan cek email Anda untuk konfirmasi akun.', 'info');
            // Reset form dan pindah ke tab login
            regForm.reset();
            setTimeout(function () {
              switchAuthTab('login');
              if (usernameEl) usernameEl.value = email;
              if (passwordEl) passwordEl.focus();
            }, 1500);
          } else {
            showToast('Akun ' + name + ' berhasil didaftarkan!', 'success');
            var newUser = {
              name: name,
              email: email,
              role: role,
              picture: '',
              source: (res.mode === 'supabase' ? 'supabase' : 'local')
            };
            setTimeout(function () {
              loginSuccess(newUser);
            }, 700);
          }
        } else {
          showErr(groupRegEmail, errRegEmail, res.error || 'Gagal mendaftarkan akun.');
          showToast(res.error || 'Pendaftaran gagal. Periksa kembali data Anda.', 'error');
        }
      } catch (err) {
        btnRegister.disabled = false;
        if (regBtnText) regBtnText.style.display = '';
        if (regBtnLoader) regBtnLoader.style.display = 'none';
        showToast('Terjadi kesalahan jaringan saat registrasi.', 'error');
      }
    });
  }

  // ── Login success ──────────────────────────────────────────────────────────
  function loginSuccess(user) {
    user.loginTime = new Date().toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' });
    user.loginDate = new Date().toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
    if (!user.role) {
      user.role = (user.email === DEMO_USER || (user.email && user.email.indexOf('admin') !== -1)) ? 'Administrator' : 'Staff Gudang';
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
    toast.className = 'toast ' + (type || 'info');
    requestAnimationFrame(function () { toast.classList.add('show'); });
    toastTimer = setTimeout(function () { toast.classList.remove('show'); }, 3500);
  }

  // ── Lupa sandi & register ──────────────────────────────────────────────────
  var forgotLink = document.getElementById('forgotPasswordLink');
  if (forgotLink) {
    forgotLink.addEventListener('click', function (e) {
      e.preventDefault();
      showToast('Hubungi administrator atau periksa email pemulihan Supabase Anda.', 'info');
    });
  }

});

