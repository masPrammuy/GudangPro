/**
 * ═══════════════════════════════════════════════════════════════════════════
 * GudangPro — Supabase Client & Authentication Helper
 * Mengelola koneksi ke Supabase, sesi autentikasi, serta fallback lokal
 * ═══════════════════════════════════════════════════════════════════════════
 */

(function (window) {
  'use strict';

  var STORAGE_URL_KEY = 'gp_supabase_url';
  var STORAGE_ANON_KEY = 'gp_supabase_anon_key';
  var ACCOUNTS_KEY = 'gp_accounts';

  // ── Kredensial Default Supabase untuk Web / Hosting ────────────────────────
  // Anda dapat langsung menempelkan URL & Anon Key Supabase di sini agar semua
  // pengunjung web Anda otomatis terhubung tanpa perlu mengisi modal setup.
  var DEFAULT_SUPABASE_URL = '';
  var DEFAULT_SUPABASE_ANON_KEY = '';

  var supabaseInstance = null;

  /**
   * Mengambil konfigurasi Supabase dari localStorage atau default config
   */
  function getSupabaseConfig() {
    return {
      url: localStorage.getItem(STORAGE_URL_KEY) || DEFAULT_SUPABASE_URL || '',
      anonKey: localStorage.getItem(STORAGE_ANON_KEY) || DEFAULT_SUPABASE_ANON_KEY || ''
    };
  }

  /**
   * Menyimpan konfigurasi Supabase ke localStorage
   */
  function saveSupabaseConfig(url, anonKey) {
    if (url && anonKey) {
      localStorage.setItem(STORAGE_URL_KEY, url.trim());
      localStorage.setItem(STORAGE_ANON_KEY, anonKey.trim());
      return initSupabase(url.trim(), anonKey.trim());
    } else {
      localStorage.removeItem(STORAGE_URL_KEY);
      localStorage.removeItem(STORAGE_ANON_KEY);
      supabaseInstance = null;
      return null;
    }
  }

  /**
   * Memeriksa apakah Supabase telah dikonfigurasi
   */
  function isSupabaseConfigured() {
    var config = getSupabaseConfig();
    return Boolean(config.url && config.anonKey && config.url.startsWith('http'));
  }

  /**
   * Inisialisasi Supabase Client SDK
   */
  function initSupabase(url, anonKey) {
    var targetUrl = url || localStorage.getItem(STORAGE_URL_KEY);
    var targetKey = anonKey || localStorage.getItem(STORAGE_ANON_KEY);

    if (!targetUrl || !targetKey || !targetUrl.startsWith('http')) {
      supabaseInstance = null;
      return null;
    }

    if (typeof window.supabase !== 'undefined' && typeof window.supabase.createClient === 'function') {
      try {
        supabaseInstance = window.supabase.createClient(targetUrl, targetKey, {
          auth: {
            persistSession: true,
            autoRefreshToken: true,
            detectSessionInUrl: true
          }
        });
        return supabaseInstance;
      } catch (err) {
        console.error('Error saat inisialisasi Supabase client:', err);
        supabaseInstance = null;
        return null;
      }
    } else {
      // Library Supabase belum siap, coba lagi nanti jika dipanggil
      return null;
    }
  }

  /**
   * Mendapatkan instance Supabase yang aktif
   */
  function getSupabase() {
    if (!supabaseInstance && isSupabaseConfigured()) {
      var config = getSupabaseConfig();
      initSupabase(config.url, config.anonKey);
    }
    return supabaseInstance;
  }

  /**
   * Pendaftaran akun baru (Registrasi)
   * Jika Supabase aktif: memanggil supabase.auth.signUp()
   * Jika belum terhubung: fallback ke database akun lokal (localStorage)
   */
  async function supabaseRegister(email, password, metadata) {
    var sb = getSupabase();

    if (sb) {
      try {
        var response = await sb.auth.signUp({
          email: email,
          password: password,
          options: {
            data: {
              full_name: metadata.name || '',
              role: metadata.role || 'Staff Gudang'
            }
          }
        });

        if (response.error) {
          return { success: false, error: response.error.message, mode: 'supabase' };
        }

        var user = response.data.user;
        var session = response.data.session;

        // Simpan juga ke akun lokal untuk sinkronisasi tampilan
        saveLocalAccount({
          id: user ? user.id : 'USR-' + Date.now(),
          name: metadata.name,
          email: email,
          role: metadata.role || 'Staff Gudang',
          source: 'supabase',
          status: 'Aktif',
          picture: ''
        });

        return {
          success: true,
          mode: 'supabase',
          user: user,
          session: session,
          requiresEmailConfirmation: !session && user && user.identities && user.identities.length > 0
        };
      } catch (err) {
        return { success: false, error: err.message || 'Terjadi kesalahan jaringan Supabase', mode: 'supabase' };
      }
    }

    // Fallback: Mode Lokal / Demo
    var accounts = getLocalAccounts();
    var exists = accounts.some(function (acc) {
      return acc.email.toLowerCase() === email.toLowerCase();
    });

    if (exists) {
      return { success: false, error: 'Email tersebut sudah terdaftar dalam sistem.', mode: 'local' };
    }

    var newAccount = {
      id: 'ACC-' + Date.now(),
      name: metadata.name || 'Pengguna Baru',
      email: email,
      password: password, // disimpan secara lokal untuk fallback login
      role: metadata.role || 'Staff Gudang',
      source: 'local',
      status: 'Aktif',
      picture: '',
      createdAt: new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })
    };

    accounts.push(newAccount);
    localStorage.setItem(ACCOUNTS_KEY, JSON.stringify(accounts));

    return {
      success: true,
      mode: 'local',
      user: {
        id: newAccount.id,
        email: newAccount.email,
        user_metadata: { full_name: newAccount.name, role: newAccount.role }
      }
    };
  }

  /**
   * Masuk (Login)
   * Jika Supabase aktif: memanggil supabase.auth.signInWithPassword()
   * Jika belum: validasi terhadap akun lokal dan akun demo bawaan
   */
  async function supabaseLogin(email, password) {
    var sb = getSupabase();

    if (sb) {
      try {
        var response = await sb.auth.signInWithPassword({
          email: email,
          password: password
        });

        if (response.error) {
          // Jika akun belum ditemukan di Supabase, cek apakah ada di akun lokal demo
          var localFallback = checkLocalLogin(email, password);
          if (localFallback) {
            return { success: true, mode: 'local', user: localFallback };
          }
          return { success: false, error: response.error.message, mode: 'supabase' };
        }

        var sbUser = response.data.user;
        var appUser = {
          id: sbUser.id,
          name: (sbUser.user_metadata && sbUser.user_metadata.full_name) || (sbUser.email ? sbUser.email.split('@')[0] : 'Pengguna'),
          email: sbUser.email,
          role: (sbUser.user_metadata && sbUser.user_metadata.role) || 'Staff Gudang',
          picture: (sbUser.user_metadata && sbUser.user_metadata.avatar_url) || '',
          source: 'supabase'
        };

        return { success: true, mode: 'supabase', user: appUser, session: response.data.session };
      } catch (err) {
        return { success: false, error: err.message || 'Koneksi ke Supabase gagal', mode: 'supabase' };
      }
    }

    // Login via Akun Lokal / Demo
    var userFound = checkLocalLogin(email, password);
    if (userFound) {
      return { success: true, mode: 'local', user: userFound };
    }

    return { success: false, error: 'Email atau kata sandi tidak cocok.', mode: 'local' };
  }

  /**
   * Keluar (Logout)
   */
  async function supabaseLogout() {
    var sb = getSupabase();
    if (sb) {
      try {
        await sb.auth.signOut();
      } catch (err) {
        console.warn('Supabase signOut error:', err);
      }
    }
    sessionStorage.removeItem('gp_user');
  }

  /**
   * Mendapatkan sesi aktif
   */
  async function supabaseGetSession() {
    var sb = getSupabase();
    if (sb) {
      try {
        var res = await sb.auth.getSession();
        if (res.data && res.data.session) {
          return res.data.session;
        }
      } catch (err) {
        console.warn('Gagal membaca sesi Supabase:', err);
      }
    }
    return null;
  }

  /**
   * Helper: Membaca daftar akun lokal
   */
  function getLocalAccounts() {
    try {
      return JSON.parse(localStorage.getItem(ACCOUNTS_KEY) || '[]');
    } catch (e) {
      return [];
    }
  }

  /**
   * Helper: Menyimpan akun ke database lokal
   */
  function saveLocalAccount(account) {
    try {
      var accounts = getLocalAccounts();
      var idx = accounts.findIndex(function (a) { return a.email.toLowerCase() === account.email.toLowerCase(); });
      if (idx >= 0) {
        accounts[idx] = Object.assign(accounts[idx], account);
      } else {
        accounts.push(account);
      }
      localStorage.setItem(ACCOUNTS_KEY, JSON.stringify(accounts));
    } catch (e) { }
  }

  /**
   * Helper: Verifikasi login akun lokal & demo
   */
  function checkLocalLogin(email, password) {
    var DEMO_USER = 'admin@gudangpro.id';
    var DEMO_PASS = 'Admin123!';

    if ((email === DEMO_USER || email === 'admin') && password === DEMO_PASS) {
      return {
        name: 'Admin Gudang',
        email: DEMO_USER,
        role: 'Administrator',
        picture: '',
        source: 'manual'
      };
    }

    var accounts = getLocalAccounts();
    var match = accounts.find(function (acc) {
      return acc.email.toLowerCase() === email.toLowerCase() && acc.password === password;
    });

    if (match) {
      return {
        name: match.name,
        email: match.email,
        role: match.role || 'Staff Gudang',
        picture: match.picture || '',
        source: match.source || 'local'
      };
    }

    return null;
  }

  // Auto-init saat script dieksekusi
  if (typeof window !== 'undefined') {
    window.GudangProSupabase = {
      getSupabase: getSupabase,
      getSupabaseConfig: getSupabaseConfig,
      saveSupabaseConfig: saveSupabaseConfig,
      isSupabaseConfigured: isSupabaseConfigured,
      initSupabase: initSupabase,
      register: supabaseRegister,
      login: supabaseLogin,
      logout: supabaseLogout,
      getSession: supabaseGetSession,
      getLocalAccounts: getLocalAccounts
    };
  }

})(window);
