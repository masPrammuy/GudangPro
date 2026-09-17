/* ─── GudangPro Apparel — Sistem Manajemen Produksi & Stok Konveksi ──────────────
   1. Autentikasi Guard & User Profile Rendering
   2. Manajemen Data Stok Bahan Kain, Aksesoris, & Baju Jadi
   3. Fitur Peringatan Dini Stok Minimum (Low Stock Alert System)
   4. Tambah, Update (+10/-5), & Hapus Item Produksi
   5. Filter Kategori Konveksi & Pencarian Realtime
   6. Sinkronisasi Sesi Supabase & Logout
─────────────────────────────────────────────────────────────────────────────── */

'use strict';

var DEFAULT_INVENTORY = [
  { id: '1', sku: 'KAN-CMB-01', name: 'Kain Katun Combed 30s Hitam Reaktif', category: 'Kain & Bahan Baku', location: 'Rak Kain A-01', qty: 45, minStock: 15, unit: 'Roll', status: 'Tersedia' },
  { id: '2', sku: 'BNG-JHT-08', name: 'Benang Jahit Spun Polyester Putih Extra (40/2)', category: 'Aksesoris Jahit', location: 'Rak Aksesoris B-02', qty: 8, minStock: 20, unit: 'Lusin', status: 'Menipis' },
  { id: '3', sku: 'KNC-KMG-14', name: 'Kancing Kemeja Lubang Empat 14mm Putih Mutiara', category: 'Aksesoris Jahit', location: 'Rak Aksesoris B-05', qty: 450, minStock: 100, unit: 'Pcs', status: 'Tersedia' },
  { id: '4', sku: 'CUT-KAOS-L', name: 'Pola Potong Kaos Polos Lengan Pendek Combed (L)', category: 'Pola & Hasil Cutting', location: 'Meja Cutting C-01', qty: 65, minStock: 25, unit: 'Lusin', status: 'Tersedia' },
  { id: '5', sku: 'BJU-OVR-BLK', name: 'Kaos Polos Oversize Katun 24s Hitam Size L (Siap Kirim)', category: 'Baju Jadi (Siap Kirim)', location: 'Rak Baju D-03', qty: 6, minStock: 30, unit: 'Pcs', status: 'Menipis' },
  { id: '6', sku: 'RST-YKK-60', name: 'Resleting Jaket YKK Metal Open End 60cm Hitam', category: 'Aksesoris Jahit', location: 'Rak Aksesoris B-01', qty: 0, minStock: 50, unit: 'Pcs', status: 'Habis' },
  { id: '7', sku: 'BJU-KMG-FLN', name: 'Kemeja Pria Flanel Kotak Tartan Lengan Panjang (M)', category: 'Baju Jadi (Siap Kirim)', location: 'Rak Baju D-01', qty: 32, minStock: 15, unit: 'Pcs', status: 'Tersedia' },
  { id: '8', sku: 'PKG-OPP-30', name: 'Plastik Kemasan Baju OPP Seal Tebal 30x40 cm + Hangtag', category: 'Packaging & Hangtag', location: 'Rak Packing D-05', qty: 500, minStock: 150, unit: 'Pcs', status: 'Tersedia' }
];

var inventoryList = [];

document.addEventListener('DOMContentLoaded', function () {
  var user = getUser();
  if (!user) {
    window.location.href = 'index.html';
    return;
  }

  renderUserProfile(user);
  initInventory();
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
  // Topbar / Sidebar Header
  var headerName   = document.getElementById('headerUserName');
  var headerEmail  = document.getElementById('headerUserEmail');
  var headerAvatar = document.getElementById('headerAvatar');

  if (headerName) headerName.textContent = user.name || 'Pengguna';
  if (headerEmail) headerEmail.textContent = user.email || '';
  if (headerAvatar) renderAvatar(headerAvatar, user.name, user.picture, 32);

  // Main Banner
  var welcomeName   = document.getElementById('welcomeName');
  var welcomeEmail  = document.getElementById('welcomeEmail');
  var welcomeRole   = document.getElementById('welcomeRole');
  var welcomeAvatar = document.getElementById('welcomeAvatar');
  var welcomeMethod = document.getElementById('welcomeMethod');
  var welcomeTime   = document.getElementById('welcomeLoginTime');
  var welcomeBadge  = document.getElementById('welcomeSourceBadge');

  if (welcomeName) welcomeName.textContent = user.name || 'Pengguna';
  if (welcomeEmail) welcomeEmail.textContent = user.email || '';
  if (welcomeRole) welcomeRole.textContent = user.role || 'Staff Konveksi';

  var timeStr = user.loginTime || new Date().toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) + ' WIB';
  var dateStr = user.loginDate || new Date().toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'short', year: 'numeric' });
  if (welcomeTime) {
    welcomeTime.textContent = dateStr + ' • ' + timeStr;
  }

  var isGoogle = (user.source === 'google');
  var isSupabase = (user.source === 'supabase');

  if (welcomeMethod) {
    if (isGoogle) {
      welcomeMethod.innerHTML = '<span class="source-tag google" style="font-size:0.75rem;"><svg width="12" height="12" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/></svg> Akun Google</span>';
    } else if (isSupabase) {
      welcomeMethod.innerHTML = '<span class="source-tag" style="background:rgba(16,185,129,0.12); color:#10b981; border:1px solid rgba(16,185,129,0.3); padding:2px 8px; border-radius:5px; font-weight:600; font-size:0.75rem; display:inline-flex; align-items:center; gap:5px;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M11.95 2L3 13.5h7.5L8.5 22l11.5-12.5h-7.5L14 2h-2.05z" fill="#10B981"/></svg> Supabase Cloud</span>';
    } else {
      var srcLabel = user.source === 'local' ? 'Akun Lokal Konveksi' : 'Kredensial Manual';
      welcomeMethod.innerHTML = '<span class="source-tag manual" style="font-size:0.75rem;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none"><rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" stroke-width="2"/><path d="M7 11V7a5 5 0 0110 0v4" stroke="currentColor" stroke-width="2"/></svg> ' + srcLabel + '</span>';
    }
  }

  if (welcomeBadge) {
    if (isGoogle) {
      welcomeBadge.className = 'source-badge google';
      welcomeBadge.innerHTML = '<svg width="12" height="12" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/></svg>';
    } else if (isSupabase) {
      welcomeBadge.className = 'source-badge';
      welcomeBadge.style.background = '#10b981';
      welcomeBadge.innerHTML = '<svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M11.95 2L3 13.5h7.5L8.5 22l11.5-12.5h-7.5L14 2h-2.05z" fill="#ffffff"/></svg>';
    } else {
      welcomeBadge.className = 'source-badge manual';
      welcomeBadge.innerHTML = '<svg width="12" height="12" viewBox="0 0 24 24" fill="none"><rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" stroke-width="2"/><path d="M7 11V7a5 5 0 0110 0v4" stroke="currentColor" stroke-width="2"/></svg>';
    }
  }

  if (welcomeAvatar) {
    renderAvatar(welcomeAvatar, user.name, user.picture, 54);
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

// ── INVENTORY MANAGEMENT LOGIC (APPAREL & LOW-STOCK ALERT) ─────────────────

function initInventory() {
  try {
    var saved = localStorage.getItem('gp_apparel_inventory');
    if (!saved) {
      // Migrate old generic inventory if exists or use new apparel default
      inventoryList = DEFAULT_INVENTORY.slice();
      localStorage.setItem('gp_apparel_inventory', JSON.stringify(inventoryList));
    } else {
      inventoryList = JSON.parse(saved);
    }
  } catch (e) {
    inventoryList = DEFAULT_INVENTORY.slice();
  }

  // Ensure every item has minStock and unit
  inventoryList.forEach(function (item) {
    if (typeof item.minStock === 'undefined' || item.minStock === null) {
      item.minStock = 15;
    }
    if (!item.unit) {
      item.unit = 'Pcs';
    }
  });

  renderInventoryTable();
  updateStats();
}

function saveInventory() {
  try {
    localStorage.setItem('gp_apparel_inventory', JSON.stringify(inventoryList));
  } catch (e) { }
  updateStats();
}

function updateStats() {
  var statTotalSku = document.getElementById('statTotalSku');
  var statLowStock = document.getElementById('statLowStock');

  if (statTotalSku) {
    statTotalSku.textContent = (inventoryList.length + 1842).toLocaleString('id-ID');
  }

  var lowItems = inventoryList.filter(function (i) {
    var min = typeof i.minStock === 'number' ? i.minStock : 15;
    return i.qty <= min;
  });

  if (statLowStock) {
    statLowStock.textContent = lowItems.length;
    if (lowItems.length > 0) {
      statLowStock.style.color = 'var(--error)';
    } else {
      statLowStock.style.color = 'var(--success)';
    }
  }

  renderLowStockAlertBanner(lowItems);
}

function renderLowStockAlertBanner(lowItems) {
  var banner = document.getElementById('lowStockAlertBanner');
  var countBadge = document.getElementById('lowStockCountBadge');
  var tagsContainer = document.getElementById('lowStockItemTags');

  if (!banner) return;

  if (lowItems.length === 0) {
    banner.style.display = 'none';
    return;
  }

  banner.style.display = 'flex';

  if (countBadge) {
    countBadge.textContent = lowItems.length + ' Item Kritis';
  }

  if (tagsContainer) {
    tagsContainer.innerHTML = '';
    lowItems.forEach(function (item) {
      var tag = document.createElement('span');
      var isZero = item.qty === 0;
      tag.className = 'low-stock-tag' + (isZero ? ' zero' : '');
      tag.innerHTML = (isZero ? '🚨 Habis: ' : '⚠️ ') + escapeHtml(item.name) +
        ' <strong>(' + item.qty + ' / Min: ' + item.minStock + ' ' + (item.unit || 'Pcs') + ')</strong>';
      tagsContainer.appendChild(tag);
    });
  }
}

function renderInventoryTable(filterKeyword, filterCat) {
  var tbody = document.getElementById('inventoryTableBody');
  var paginationInfo = document.getElementById('paginationInfo');
  if (!tbody) return;

  var keyword = (filterKeyword || '').toLowerCase().trim();
  var cat = filterCat || '';

  var filtered = inventoryList.filter(function (item) {
    var matchKeyword = !keyword ||
      item.name.toLowerCase().indexOf(keyword) !== -1 ||
      item.sku.toLowerCase().indexOf(keyword) !== -1 ||
      item.location.toLowerCase().indexOf(keyword) !== -1;
    var matchCat = !cat || item.category === cat;
    return matchKeyword && matchCat;
  });

  tbody.innerHTML = '';

  if (filtered.length === 0) {
    var emptyRow = document.createElement('tr');
    emptyRow.innerHTML = '<td colspan="7" class="empty-state">Tidak ada bahan atau pakaian yang cocok dengan filter pencarian.</td>';
    tbody.appendChild(emptyRow);
    if (paginationInfo) paginationInfo.textContent = 'Menampilkan 0 item';
    return;
  }

  filtered.forEach(function (item) {
    var tr = document.createElement('tr');

    var minThreshold = typeof item.minStock === 'number' ? item.minStock : 15;
    var isZero = (item.qty === 0);
    var isLow = (item.qty <= minThreshold);

    if (isZero) {
      tr.className = 'row-danger';
      item.status = '🚨 Stok Habis';
    } else if (isLow) {
      tr.className = 'row-warning';
      item.status = '⚠️ Stok Minimum!';
    } else {
      item.status = 'Tersedia';
    }

    // Category badge class
    var catBadge = 'badge-blue';
    if (item.category.indexOf('Kain') !== -1) catBadge = 'badge-kain';
    else if (item.category.indexOf('Aksesoris') !== -1) catBadge = 'badge-aksesoris';
    else if (item.category.indexOf('Cutting') !== -1) catBadge = 'badge-cutting';
    else if (item.category.indexOf('Baju Jadi') !== -1) catBadge = 'badge-baju';
    else if (item.category.indexOf('Packaging') !== -1 || item.category.indexOf('Hangtag') !== -1) catBadge = 'badge-kemasan';

    // Status Badge Markup
    var statusMarkup = '';
    if (isZero) {
      statusMarkup = '<span class="badge badge-red" style="font-weight:700;">🚨 Stok Habis</span>';
    } else if (isLow) {
      statusMarkup = '<span class="badge badge-orange" style="border:1.5px solid #d97706; font-weight:700;">⚠️ Stok Minimum!</span>';
    } else {
      statusMarkup = '<span class="badge badge-green">Tersedia</span>';
    }

    // Stock Column Markup with Minimum Threshold Hint
    var stockDetailHint = '';
    if (isZero) {
      stockDetailHint = '<span class="stock-zero-hint">🚨 Habis! (Batas Min: ' + minThreshold + ')</span>';
    } else if (isLow) {
      stockDetailHint = '<span class="stock-min-hint">⚠️ Sisa ' + item.qty + ' (Batas Min: ' + minThreshold + ')</span>';
    } else {
      stockDetailHint = '<span style="font-size:0.72rem; color:var(--muted); display:block;">Aman (Min: ' + minThreshold + ' ' + (item.unit || 'Pcs') + ')</span>';
    }

    tr.innerHTML =
      '<td class="td-sku"><strong><span class="barcode-lines">||| | ||</span>' + escapeHtml(item.sku) + '</strong></td>' +
      '<td><strong>' + escapeHtml(item.name) + '</strong></td>' +
      '<td><span class="badge ' + catBadge + '">' + escapeHtml(item.category) + '</span></td>' +
      '<td><span class="rack-badge"><svg width="12" height="12" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="16" rx="2" stroke="currentColor" stroke-width="1.8"/><line x1="3" y1="10" x2="21" y2="10" stroke="currentColor" stroke-width="1.8"/><line x1="3" y1="15" x2="21" y2="15" stroke="currentColor" stroke-width="1.8"/><line x1="12" y1="4" x2="12" y2="20" stroke="currentColor" stroke-width="1.8"/></svg> ' + escapeHtml(item.location) + '</span></td>' +
      '<td>' +
        '<strong style="font-size:0.95rem;">' + item.qty + '</strong> ' +
        '<span style="font-size:0.78rem; color:var(--text-muted); font-weight:600;">' + (item.unit || 'Pcs') + '</span>' +
        stockDetailHint +
      '</td>' +
      '<td>' + statusMarkup + '</td>' +
      '<td style="text-align:right;">' +
        '<div class="td-actions" style="justify-content:flex-end;">' +
          '<button type="button" class="btn btn-secondary btn-sm btn-action-add" data-id="' + item.id + '" title="Tambah 10 ' + (item.unit || 'Unit') + '">+10</button>' +
          '<button type="button" class="btn btn-secondary btn-sm btn-action-sub" data-id="' + item.id + '" title="Kurangi 5 ' + (item.unit || 'Unit') + '">-5</button>' +
          '<button type="button" class="btn btn-danger btn-sm btn-action-del" data-id="' + item.id + '" title="Hapus Item">' +
            '<svg width="13" height="13" viewBox="0 0 24 24" fill="none"><polyline points="3 6 5 6 21 6" stroke="currentColor" stroke-width="2"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2" stroke="currentColor" stroke-width="2"/></svg>' +
          '</button>' +
        '</div>' +
      '</td>';

    tbody.appendChild(tr);
  });

  if (paginationInfo) {
    paginationInfo.textContent = 'Menampilkan ' + filtered.length + ' dari ' + inventoryList.length + ' item bahan & pakaian';
  }

  attachTableActionListeners();
}

function attachTableActionListeners() {
  var addBtns = document.querySelectorAll('.btn-action-add');
  var subBtns = document.querySelectorAll('.btn-action-sub');
  var delBtns = document.querySelectorAll('.btn-action-del');

  addBtns.forEach(function (btn) {
    btn.onclick = function () {
      var id = btn.getAttribute('data-id');
      var item = inventoryList.find(function (i) { return i.id === id; });
      if (item) {
        item.qty += 10;
        saveInventory();
        renderInventoryTable(getCurrentKeyword(), getCurrentCat());
        showToast('Stok ' + item.name + ' bertambah +10 ' + (item.unit || 'Pcs') + '.', 'success');
      }
    };
  });

  subBtns.forEach(function (btn) {
    btn.onclick = function () {
      var id = btn.getAttribute('data-id');
      var item = inventoryList.find(function (i) { return i.id === id; });
      if (item) {
        if (item.qty <= 0) {
          showToast('⚠️ Stok ' + item.name + ' sudah 0 (habis)! Segera lakukan pengadaan.', 'error');
          return;
        }

        var oldQty = item.qty;
        item.qty = Math.max(0, item.qty - 5);
        var minThreshold = typeof item.minStock === 'number' ? item.minStock : 15;

        saveInventory();
        renderInventoryTable(getCurrentKeyword(), getCurrentCat());

        // Peringatan Stok Minimum Real-Time
        if (item.qty === 0) {
          showToast('🚨 PERINGATAN KRITIS: Stok ' + item.name + ' telah HABIS (0)!', 'error');
        } else if (item.qty <= minThreshold && oldQty > minThreshold) {
          showToast('⚠️ PERINGATAN: Stok ' + item.name + ' tersisa ' + item.qty + ' ' + (item.unit || 'Pcs') + ' (mencapai batas minimum ' + minThreshold + ')!', 'error');
        } else if (item.qty <= minThreshold) {
          showToast('⚠️ Stok ' + item.name + ' berkurang menjadi ' + item.qty + ' ' + (item.unit || 'Pcs') + ' (di bawah batas minimum ' + minThreshold + ').', 'info');
        } else {
          showToast('Stok ' + item.name + ' berkurang -5 ' + (item.unit || 'Pcs') + '.', 'info');
        }
      }
    };
  });

  delBtns.forEach(function (btn) {
    btn.onclick = function () {
      var id = btn.getAttribute('data-id');
      var item = inventoryList.find(function (i) { return i.id === id; });
      if (item) {
        if (confirm('Yakin ingin menghapus item "' + item.name + '" dari sistem inventaris konveksi?')) {
          inventoryList = inventoryList.filter(function (i) { return i.id !== id; });
          saveInventory();
          renderInventoryTable(getCurrentKeyword(), getCurrentCat());
          showToast('Item "' + item.name + '" berhasil dihapus.', 'info');
        }
      }
    };
  });
}

function getCurrentKeyword() {
  var invSearch = document.getElementById('inventorySearchInput');
  return invSearch ? invSearch.value : '';
}

function getCurrentCat() {
  var catFilter = document.getElementById('filterCategory');
  return catFilter ? catFilter.value : '';
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

// ── MODAL TAMBAH BARANG ─────────────────────────────────────────────────────

function openAddModal() {
  var overlay = document.getElementById('addInventoryModalOverlay');
  if (overlay) {
    overlay.style.display = 'flex';
    document.body.style.overflow = 'hidden';
    var skuInput = document.getElementById('itemSku');
    if (skuInput) skuInput.focus();
  }
}

function hideAddModal() {
  var overlay = document.getElementById('addInventoryModalOverlay');
  if (overlay) {
    overlay.style.display = 'none';
    document.body.style.overflow = '';
  }
}

// ── EVENT BINDINGS ──────────────────────────────────────────────────────────

function bindEvents() {
  var btnLogout = document.getElementById('btnLogout');
  var btnLogoutMain = document.getElementById('btnLogoutMain');
  if (btnLogout) btnLogout.addEventListener('click', logout);
  if (btnLogoutMain) btnLogoutMain.addEventListener('click', logout);

  // Onboarding Banner (Panduan Pengguna Baru Konveksi)
  var onboardingBanner = document.getElementById('onboardingBanner');
  var btnDismiss = document.getElementById('btnDismissOnboarding');
  if (onboardingBanner && localStorage.getItem('gp_hide_apparel_onboarding') === 'true') {
    onboardingBanner.style.display = 'none';
  }
  if (btnDismiss && onboardingBanner) {
    btnDismiss.addEventListener('click', function () {
      onboardingBanner.style.display = 'none';
      try {
        localStorage.setItem('gp_hide_apparel_onboarding', 'true');
      } catch (e) { }
      showToast('Panduan konveksi disembunyikan. Anda dapat membukanya kembali kapan saja.', 'info');
    });
  }

  // Tombol scroll ke tabel saat klik di low stock alert banner
  var btnScrollToLowStock = document.getElementById('btnScrollToLowStock');
  if (btnScrollToLowStock) {
    btnScrollToLowStock.addEventListener('click', function () {
      var invSec = document.getElementById('inventorySection');
      if (invSec) {
        invSec.scrollIntoView({ behavior: 'smooth' });
      }
    });
  }

  // Modal Tambah Barang
  var btnOpenAdd = document.getElementById('btnOpenAddModal');
  var btnOpenAddTable = document.getElementById('btnOpenAddModalTable');
  var closeAddModal = document.getElementById('closeAddModal');
  var btnCancelAdd = document.getElementById('btnCancelAddModal');
  var addForm = document.getElementById('addInventoryForm');
  var modalOverlay = document.getElementById('addInventoryModalOverlay');

  if (btnOpenAdd) btnOpenAdd.addEventListener('click', openAddModal);
  if (btnOpenAddTable) btnOpenAddTable.addEventListener('click', openAddModal);
  if (closeAddModal) closeAddModal.addEventListener('click', hideAddModal);
  if (btnCancelAdd) btnCancelAdd.addEventListener('click', hideAddModal);
  if (modalOverlay) {
    modalOverlay.addEventListener('click', function (e) {
      if (e.target === modalOverlay) hideAddModal();
    });
  }

  // Submit Tambah Barang (Bahan Kain, Aksesoris & Baju Jadi)
  if (addForm) {
    addForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var sku = (document.getElementById('itemSku').value || '').trim().toUpperCase();
      var name = (document.getElementById('itemName').value || '').trim();
      var cat = document.getElementById('itemCategory').value;
      var loc = (document.getElementById('itemLocation').value || '').trim();
      var unit = document.getElementById('itemUnit') ? document.getElementById('itemUnit').value : 'Pcs';
      var qty = parseInt(document.getElementById('itemQty').value, 10) || 0;
      var minStockInput = document.getElementById('itemMinStock');
      var minStock = minStockInput ? (parseInt(minStockInput.value, 10) || 15) : 15;

      if (!sku || !name || !loc) {
        showToast('Mohon lengkapi data barang dan lokasi penyimpanan.', 'error');
        return;
      }

      var newItem = {
        id: 'APL-' + Date.now(),
        sku: sku,
        name: name,
        category: cat,
        location: loc,
        unit: unit,
        qty: qty,
        minStock: minStock,
        status: qty === 0 ? '🚨 Stok Habis' : (qty <= minStock ? '⚠️ Stok Minimum!' : 'Tersedia')
      };

      inventoryList.unshift(newItem);
      saveInventory();
      renderInventoryTable(getCurrentKeyword(), getCurrentCat());
      hideAddModal();
      addForm.reset();

      if (qty <= minStock) {
        showToast('Item baru "' + name + '" dicatat. PERINGATAN: Stok saat ini (' + qty + ' ' + unit + ') telah mencapai atau di bawah batas minimum (' + minStock + ')!', 'error');
      } else {
        showToast('Item baru "' + name + '" (' + qty + ' ' + unit + ') berhasil dicatat!', 'success');
      }
    });
  }

  // Filter & Search
  var invSearch = document.getElementById('inventorySearchInput');
  var globSearch = document.getElementById('globalSearchInput');
  var catFilter = document.getElementById('filterCategory');

  if (invSearch) {
    invSearch.addEventListener('input', function () {
      renderInventoryTable(invSearch.value, getCurrentCat());
    });
  }

  if (globSearch) {
    globSearch.addEventListener('input', function () {
      renderInventoryTable(globSearch.value, getCurrentCat());
      if (invSearch) invSearch.value = globSearch.value;
    });
  }

  if (catFilter) {
    catFilter.addEventListener('change', function () {
      renderInventoryTable(getCurrentKeyword(), catFilter.value);
    });
  }

  // Sidebar dummy navigasi toast
  var navInbound = document.getElementById('navInbound');
  var navOutbound = document.getElementById('navOutbound');
  var navRacks = document.getElementById('navRacks');
  var navAudit = document.getElementById('navAudit');

  if (navInbound) navInbound.onclick = function (e) { e.preventDefault(); showToast('Membuka modul Bahan Baku Masuk (Roll Kain & Aksesoris)...', 'info'); };
  if (navOutbound) navOutbound.onclick = function (e) { e.preventDefault(); showToast('Membuka modul Pengiriman Baju Jadi (Kargo & Kurir)...', 'info'); };
  if (navRacks) navRacks.onclick = function (e) { e.preventDefault(); showToast('Membuka denah rak gulungan kain & baju jadi...', 'info'); };
  if (navAudit) navAudit.onclick = function (e) { e.preventDefault(); showToast('Membuka audit stok fisik & barcode garmen...', 'info'); };
}

async function logout() {
  showToast('Sedang keluar dari sesi workshop...', 'info');
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

var toastTimer;
function showToast(msg, type) {
  var toast = document.getElementById('toast');
  if (!toast) return;
  clearTimeout(toastTimer);
  toast.textContent = msg;
  toast.className = 'toast ' + (type || 'info');
  requestAnimationFrame(function () { toast.classList.add('show'); });
  toastTimer = setTimeout(function () { toast.classList.remove('show'); }, 4000);
}
