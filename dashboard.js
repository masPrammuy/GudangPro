/* ─── GudangPro — Enterprise Dashboard Logic ────────────────────────────────────
   1. Autentikasi Guard & User Profile Rendering
   2. Manajemen Data Stok & Inventaris Interaktif
   3. Tambah, Update, & Hapus Barang Gudang
   4. Filter Kategori & Pencarian Realtime
   5. Sinkronisasi Sesi Supabase & Logout
─────────────────────────────────────────────────────────────────────────────── */

'use strict';

var DEFAULT_INVENTORY = [
  { id: '1', sku: 'SKU-ELK-042', name: 'Barcode Scanner Wireless 2D Honeywell', category: 'Elektronik', location: 'Rak A-01', qty: 38, status: 'Tersedia' },
  { id: '2', sku: 'SKU-PKG-110', name: 'Kardus Box Single Wall 30x20x15 cm', category: 'Packaging & Kertas', location: 'Zona B-04', qty: 650, status: 'Tersedia' },
  { id: '3', sku: 'SKU-ELK-088', name: 'Thermal Receipt Printer Bluetooth 80mm', category: 'Elektronik', location: 'Rak A-03', qty: 7, status: 'Menipis' },
  { id: '4', sku: 'SKU-LGS-201', name: 'Hand Pallet Truck Hydraulic 3 Ton', category: 'Perlengkapan Logistik', location: 'Zona Transit C', qty: 2, status: 'Menipis' },
  { id: '5', sku: 'SKU-PKG-024', name: 'Stretch Film Plastik Wrapping 50cm', category: 'Packaging & Kertas', location: 'Zona B-02', qty: 120, status: 'Tersedia' },
  { id: '6', sku: 'SKU-SPR-315', name: 'Roda Castor Heavy Duty Pallet 4 Inch', category: 'Sparepart & Alat', location: 'Rak C-05', qty: 0, status: 'Habis' }
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
      welcomeMethod.innerHTML = '<span class="source-tag google" style="font-size:0.75rem;"><svg width="12" height="12" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/></svg> Akun Google</span>';
    } else if (isSupabase) {
      welcomeMethod.innerHTML = '<span class="source-tag" style="background:rgba(16,185,129,0.12); color:#10b981; border:1px solid rgba(16,185,129,0.3); padding:2px 8px; border-radius:5px; font-weight:600; font-size:0.75rem; display:inline-flex; align-items:center; gap:5px;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M11.95 2L3 13.5h7.5L8.5 22l11.5-12.5h-7.5L14 2h-2.05z" fill="#10B981"/></svg> Supabase Cloud</span>';
    } else {
      var srcLabel = user.source === 'local' ? 'Akun Lokal Gudang' : 'Kredensial Manual';
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

// ── INVENTORY MANAGEMENT LOGIC ──────────────────────────────────────────────

function initInventory() {
  try {
    var saved = localStorage.getItem('gp_inventory');
    inventoryList = saved ? JSON.parse(saved) : DEFAULT_INVENTORY.slice();
  } catch (e) {
    inventoryList = DEFAULT_INVENTORY.slice();
  }

  renderInventoryTable();
  updateStats();
}

function saveInventory() {
  try {
    localStorage.setItem('gp_inventory', JSON.stringify(inventoryList));
  } catch (e) { }
  updateStats();
}

function updateStats() {
  var statTotalSku = document.getElementById('statTotalSku');
  var statLowStock = document.getElementById('statLowStock');

  if (statTotalSku) {
    statTotalSku.textContent = (inventoryList.length + 2474).toLocaleString('id-ID');
  }

  if (statLowStock) {
    var lowCount = inventoryList.filter(function (i) { return i.qty < 10; }).length;
    statLowStock.textContent = lowCount;
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
    emptyRow.innerHTML = '<td colspan="7" class="empty-state">Tidak ada barang yang cocok dengan filter pencarian.</td>';
    tbody.appendChild(emptyRow);
    if (paginationInfo) paginationInfo.textContent = 'Menampilkan 0 barang';
    return;
  }

  filtered.forEach(function (item) {
    var tr = document.createElement('tr');

    var badgeClass = 'badge-green';
    if (item.qty === 0) {
      badgeClass = 'badge-red';
      item.status = 'Habis';
    } else if (item.qty < 10) {
      badgeClass = 'badge-orange';
      item.status = 'Menipis';
    } else {
      badgeClass = 'badge-green';
      item.status = 'Tersedia';
    }

    var catBadge = 'badge-blue';
    if (item.category.indexOf('Packaging') !== -1) catBadge = 'badge-purple';
    else if (item.category.indexOf('Logistik') !== -1) catBadge = 'badge-teal';
    else if (item.category.indexOf('Sparepart') !== -1) catBadge = 'badge-orange';

    tr.innerHTML =
      '<td class="td-sku"><strong><span class="barcode-lines">||| | ||</span>' + escapeHtml(item.sku) + '</strong></td>' +
      '<td><strong>' + escapeHtml(item.name) + '</strong></td>' +
      '<td><span class="badge ' + catBadge + '">' + escapeHtml(item.category) + '</span></td>' +
      '<td><span class="rack-badge"><svg width="12" height="12" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="16" rx="2" stroke="currentColor" stroke-width="1.8"/><line x1="3" y1="10" x2="21" y2="10" stroke="currentColor" stroke-width="1.8"/><line x1="3" y1="15" x2="21" y2="15" stroke="currentColor" stroke-width="1.8"/><line x1="12" y1="4" x2="12" y2="20" stroke="currentColor" stroke-width="1.8"/></svg> ' + escapeHtml(item.location) + '</span></td>' +
      '<td><strong style="font-size:0.95rem;">' + item.qty + '</strong> <span style="font-size:0.75rem; color:var(--muted);">Unit</span></td>' +
      '<td><span class="badge ' + badgeClass + '">' + item.status + '</span></td>' +
      '<td style="text-align:right;">' +
        '<div class="td-actions" style="justify-content:flex-end;">' +
          '<button type="button" class="btn btn-secondary btn-sm btn-action-add" data-id="' + item.id + '" title="Tambah 10 Unit">+10</button>' +
          '<button type="button" class="btn btn-secondary btn-sm btn-action-sub" data-id="' + item.id + '" title="Kurangi 5 Unit">-5</button>' +
          '<button type="button" class="btn btn-danger btn-sm btn-action-del" data-id="' + item.id + '" title="Hapus Barang">' +
            '<svg width="13" height="13" viewBox="0 0 24 24" fill="none"><polyline points="3 6 5 6 21 6" stroke="currentColor" stroke-width="2"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2" stroke="currentColor" stroke-width="2"/></svg>' +
          '</button>' +
        '</div>' +
      '</td>';

    tbody.appendChild(tr);
  });

  if (paginationInfo) {
    paginationInfo.textContent = 'Menampilkan ' + filtered.length + ' dari ' + inventoryList.length + ' barang';
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
        showToast('Stok ' + item.sku + ' bertambah +10 unit.', 'success');
      }
    };
  });

  subBtns.forEach(function (btn) {
    btn.onclick = function () {
      var id = btn.getAttribute('data-id');
      var item = inventoryList.find(function (i) { return i.id === id; });
      if (item) {
        if (item.qty <= 0) {
          showToast('Stok ' + item.sku + ' sudah 0 (habis).', 'error');
          return;
        }
        item.qty = Math.max(0, item.qty - 5);
        saveInventory();
        renderInventoryTable(getCurrentKeyword(), getCurrentCat());
        showToast('Stok ' + item.sku + ' berkurang -5 unit.', 'info');
      }
    };
  });

  delBtns.forEach(function (btn) {
    btn.onclick = function () {
      var id = btn.getAttribute('data-id');
      var idx = inventoryList.findIndex(function (i) { return i.id === id; });
      if (idx !== -1) {
        var name = inventoryList[idx].name;
        inventoryList.splice(idx, 1);
        saveInventory();
        renderInventoryTable(getCurrentKeyword(), getCurrentCat());
        showToast('Barang "' + name + '" berhasil dihapus dari inventaris.', 'info');
      }
    };
  });
}

function getCurrentKeyword() {
  var s1 = document.getElementById('inventorySearchInput');
  var s2 = document.getElementById('globalSearchInput');
  return (s1 && s1.value) || (s2 && s2.value) || '';
}

function getCurrentCat() {
  var catEl = document.getElementById('filterCategory');
  return catEl ? catEl.value : '';
}

function escapeHtml(text) {
  var map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
  return (text || '').replace(/[&<>"']/g, function (m) { return map[m]; });
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

  // Onboarding Banner (Panduan Pengguna Baru)
  var onboardingBanner = document.getElementById('onboardingBanner');
  var btnDismiss = document.getElementById('btnDismissOnboarding');
  if (onboardingBanner && localStorage.getItem('gp_hide_onboarding') === 'true') {
    onboardingBanner.style.display = 'none';
  }
  if (btnDismiss && onboardingBanner) {
    btnDismiss.addEventListener('click', function () {
      onboardingBanner.style.display = 'none';
      try {
        localStorage.setItem('gp_hide_onboarding', 'true');
      } catch (e) { }
      showToast('Panduan disembunyikan. Anda dapat membukanya kembali dari menu.', 'info');
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

  // Submit Tambah Barang
  if (addForm) {
    addForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var sku = (document.getElementById('itemSku').value || '').trim().toUpperCase();
      var name = (document.getElementById('itemName').value || '').trim();
      var cat = document.getElementById('itemCategory').value;
      var loc = (document.getElementById('itemLocation').value || '').trim();
      var qty = parseInt(document.getElementById('itemQty').value, 10) || 0;

      if (!sku || !name || !loc) {
        showToast('Mohon lengkapi semua data barang.', 'error');
        return;
      }

      var newItem = {
        id: 'ITM-' + Date.now(),
        sku: sku,
        name: name,
        category: cat,
        location: loc,
        qty: qty,
        status: qty === 0 ? 'Habis' : (qty < 10 ? 'Menipis' : 'Tersedia')
      };

      inventoryList.unshift(newItem);
      saveInventory();
      renderInventoryTable(getCurrentKeyword(), getCurrentCat());
      hideAddModal();
      addForm.reset();
      showToast('Barang baru "' + name + '" berhasil ditambahkan!', 'success');
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

  if (navInbound) navInbound.onclick = function (e) { e.preventDefault(); showToast('Membuka modul Barang Masuk (Inbound)...', 'info'); };
  if (navOutbound) navOutbound.onclick = function (e) { e.preventDefault(); showToast('Membuka modul Barang Keluar (Outbound)...', 'info'); };
  if (navRacks) navRacks.onclick = function (e) { e.preventDefault(); showToast('Membuka manajemen Rak & Zona...', 'info'); };
  if (navAudit) navAudit.onclick = function (e) { e.preventDefault(); showToast('Membuka modul Audit Barcode...', 'info'); };
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

var toastTimer;
function showToast(msg, type) {
  var toast = document.getElementById('toast');
  if (!toast) return;
  clearTimeout(toastTimer);
  toast.textContent = msg;
  toast.className = 'toast ' + (type || 'info');
  requestAnimationFrame(function () { toast.classList.add('show'); });
  toastTimer = setTimeout(function () { toast.classList.remove('show'); }, 3500);
}
