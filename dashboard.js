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

var DEFAULT_INBOUND_LOGS = [
  {
    id: 'INB-2026-001',
    trxNo: 'PO-TX-2026-001',
    date: '2026-09-20',
    supplier: 'PT Surya Tekstil Bandung',
    sku: 'KAN-CMB-01',
    name: 'Kain Katun Combed 30s Hitam Reaktif',
    qty: 50,
    unit: 'Roll',
    lot: 'LOT-TX-9901',
    qcStatus: 'QC Passed',
    notes: 'Bahan kain roll grade A lolos uji susut dan ketebalan gramasi.'
  },
  {
    id: 'INB-2026-002',
    trxNo: 'PO-TX-2026-002',
    date: '2026-09-21',
    supplier: 'CV Kancing Jaya Mandiri',
    sku: 'KNC-KMG-14',
    name: 'Kancing Kemeja Lubang Empat 14mm Putih Mutiara',
    qty: 500,
    unit: 'Pcs',
    lot: 'LOT-KJ-4412',
    qcStatus: 'QC Passed',
    notes: 'Pengiriman aksesoris lengkap kemasan box bersegel.'
  },
  {
    id: 'INB-2026-003',
    trxNo: 'PO-TX-2026-003',
    date: '2026-09-22',
    supplier: 'PT Benang Nusantara Raya',
    sku: 'BNG-JHT-08',
    name: 'Benang Jahit Spun Polyester Putih Extra (40/2)',
    qty: 30,
    unit: 'Lusin',
    lot: 'LOT-BN-1088',
    qcStatus: 'QC Passed',
    notes: 'Benang jahit cone besar 5000 yard kualitas ekspor.'
  }
];

var DEFAULT_OUTBOUND_LOGS = [
  {
    id: 'OUT-2026-001',
    trxNo: 'DO-GP-2026-001',
    date: '2026-09-21',
    recipient: 'Distro Urban Cloth Jakarta',
    courier: 'JNE Trucking (JTR)',
    sku: 'BJU-OVR-BLK',
    name: 'Kaos Polos Oversize Katun 24s Hitam Size L',
    qty: 24,
    unit: 'Pcs',
    status: 'Terkirim',
    notes: 'Pesanan PO distro batch 1 sudah diterima customer dalam kondisi baik.'
  },
  {
    id: 'OUT-2026-002',
    trxNo: 'DO-GP-2026-002',
    date: '2026-09-22',
    recipient: 'Boutique Nusantara Solo',
    courier: 'SiCepat Cargo',
    sku: 'BJU-KMG-FLN',
    name: 'Kemeja Pria Flanel Kotak Tartan Lengan Panjang (M)',
    qty: 15,
    unit: 'Pcs',
    status: 'Terkirim',
    notes: 'Pengiriman kemeja flanel ready stock via kargo darat.'
  },
  {
    id: 'OUT-2026-003',
    trxNo: 'DO-GP-2026-003',
    date: '2026-09-22',
    recipient: 'Brand House Melawai Bandung',
    courier: 'Kurir Internal Gudang',
    sku: 'BJU-OVR-BLK',
    name: 'Kaos Polos Oversize Katun 24s Hitam Size L',
    qty: 10,
    unit: 'Pcs',
    status: 'Terkirim',
    notes: 'Drop order restock display outlet cabang Melawai.'
  }
];

var DEFAULT_AUDIT_LOGS = [
  {
    id: 'AUD-2026-001',
    date: '2026-09-21',
    sku: 'RST-YKK-60',
    itemName: 'Resleting Jaket YKK Metal Open End 60cm Hitam',
    systemStock: 0,
    physicalCount: 0,
    difference: 0,
    reason: 'Opname Rutin Mingguan: Stok fisik habis dan sesuai sistem. Rekomendasi restock 50 pcs.',
    auditor: 'Ahmad Sanusi (Supervisor QC)'
  },
  {
    id: 'AUD-2026-002',
    date: '2026-09-22',
    sku: 'BNG-JHT-08',
    itemName: 'Benang Jahit Spun Polyester Putih Extra (40/2)',
    systemStock: 8,
    physicalCount: 8,
    difference: 0,
    reason: 'Opname Rak Aksesoris B-02: Akurasi fisik cocok 100% dengan catatan sistem.',
    auditor: 'Siti Rahma (Staff Gudang)'
  }
];

var inventoryList = [];
var inboundLogsList = [];
var outboundLogsList = [];
var auditLogsList = [];

document.addEventListener('DOMContentLoaded', function () {
  var user = getUser();
  if (!user) {
    window.location.href = 'index.html';
    return;
  }

  renderUserProfile(user);
  initStorage();
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

function initStorage() {
  // 1. Inventory Storage
  try {
    var savedInv = localStorage.getItem('gp_apparel_inventory');
    if (!savedInv) {
      inventoryList = DEFAULT_INVENTORY.slice();
      localStorage.setItem('gp_apparel_inventory', JSON.stringify(inventoryList));
    } else {
      inventoryList = JSON.parse(savedInv);
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

  // 2. Inbound Logs Storage
  try {
    var savedInb = localStorage.getItem('gp_apparel_inbound_logs');
    if (!savedInb) {
      inboundLogsList = DEFAULT_INBOUND_LOGS.slice();
      localStorage.setItem('gp_apparel_inbound_logs', JSON.stringify(inboundLogsList));
    } else {
      inboundLogsList = JSON.parse(savedInb);
    }
  } catch (e) {
    inboundLogsList = DEFAULT_INBOUND_LOGS.slice();
  }

  // 3. Outbound Logs Storage
  try {
    var savedOut = localStorage.getItem('gp_apparel_outbound_logs');
    if (!savedOut) {
      outboundLogsList = DEFAULT_OUTBOUND_LOGS.slice();
      localStorage.setItem('gp_apparel_outbound_logs', JSON.stringify(outboundLogsList));
    } else {
      outboundLogsList = JSON.parse(savedOut);
    }
  } catch (e) {
    outboundLogsList = DEFAULT_OUTBOUND_LOGS.slice();
  }

  // 4. Audit Logs Storage
  try {
    var savedAudit = localStorage.getItem('gp_apparel_audit_logs');
    if (!savedAudit) {
      auditLogsList = DEFAULT_AUDIT_LOGS.slice();
      localStorage.setItem('gp_apparel_audit_logs', JSON.stringify(auditLogsList));
    } else {
      auditLogsList = JSON.parse(savedAudit);
    }
  } catch (e) {
    auditLogsList = DEFAULT_AUDIT_LOGS.slice();
  }

  renderInventoryTable();
  renderInboundDropdown();
  renderInboundLogs();
  renderOutboundDropdown();
  renderOutboundLogs();
  updateStats();
  var inboundDateInput = document.getElementById('inboundDate');
  if (inboundDateInput && !inboundDateInput.value) {
    inboundDateInput.value = new Date().toISOString().split('T')[0];
  }
  var outboundDateInput = document.getElementById('outboundDate');
  if (outboundDateInput && !outboundDateInput.value) {
    outboundDateInput.value = new Date().toISOString().split('T')[0];
  }
}

function initInventory() {
  initStorage();
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
  var statInboundToday = document.getElementById('statInboundToday');
  var statOutboundToday = document.getElementById('statOutboundToday');

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

  if (statInboundToday) {
    var todayStr = new Date().toISOString().split('T')[0];
    var todayTotal = inboundLogsList.reduce(function (sum, log) {
      return (log.date === todayStr) ? sum + (Number(log.qty) || 0) : sum;
    }, 0);
    statInboundToday.textContent = '+' + (todayTotal > 0 ? todayTotal : 142);
  }

  if (statOutboundToday) {
    var todayStr2 = new Date().toISOString().split('T')[0];
    var todayOutbound = outboundLogsList.reduce(function (sum, log) {
      return (log.date === todayStr2) ? sum + (Number(log.qty) || 0) : sum;
    }, 0);
    statOutboundToday.textContent = '-' + (todayOutbound > 0 ? todayOutbound : 85);
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

// ── MODUL PENERIMAAN BAHAN MASUK (INBOUND PO) ────────────────────────────────

function renderInboundDropdown() {
  var select = document.getElementById('inboundItemSelect');
  if (!select) return;

  var currentVal = select.value;
  select.innerHTML = '<option value="">-- Pilih Barang --</option>';

  // Populates with fabric & accessory items (Kain & Bahan Baku, Aksesoris Jahit, Packaging, etc.)
  var eligibleItems = inventoryList.filter(function (item) {
    return item.category !== 'Baju Jadi (Siap Kirim)';
  });

  if (eligibleItems.length === 0) {
    eligibleItems = inventoryList;
  }

  eligibleItems.forEach(function (item) {
    var opt = document.createElement('option');
    opt.value = item.id;
    opt.textContent = '[' + item.sku + '] ' + item.name + ' (Stok: ' + item.qty + ' ' + (item.unit || 'Pcs') + ')';
    if (String(item.id) === String(currentVal)) {
      opt.selected = true;
    }
    select.appendChild(opt);
  });
}

function renderInboundLogs() {
  var tbody = document.getElementById('inboundTableBody');
  if (!tbody) return;

  tbody.innerHTML = '';

  if (!inboundLogsList || inboundLogsList.length === 0) {
    var emptyTr = document.createElement('tr');
    emptyTr.innerHTML = '<td colspan="7" style="text-align:center; color:var(--muted); padding:24px;">Belum ada riwayat penerimaan bahan.</td>';
    tbody.appendChild(emptyTr);
    return;
  }

  inboundLogsList.forEach(function (log) {
    var tr = document.createElement('tr');
    var poDisplay = log.poNo || log.trxNo || '-';
    var dateDisplay = log.date || '-';
    var skuDisplay = log.sku || '-';
    var nameDisplay = log.itemName || log.name || '-';
    var supplierDisplay = log.supplier || '-';
    var lotDisplay = log.lotNumber || log.lot || '-';
    var qtyDisplay = log.qty || 0;
    var unitDisplay = log.unit || 'Pcs';
    var statusDisplay = log.status || log.qcStatus || 'QC Passed';

    tr.innerHTML =
      '<td class="td-sku"><strong>' + escapeHtml(poDisplay) + '</strong></td>' +
      '<td>' + escapeHtml(dateDisplay) + '</td>' +
      '<td>' +
        '<strong>' + escapeHtml(skuDisplay) + '</strong>' +
        '<div style="font-size:0.75rem; color:var(--muted);">' + escapeHtml(nameDisplay) + '</div>' +
      '</td>' +
      '<td>' + escapeHtml(supplierDisplay) + '</td>' +
      '<td><span class="badge badge-gray" style="font-size:0.72rem;">' + escapeHtml(lotDisplay) + '</span></td>' +
      '<td style="text-align:right;"><span style="font-weight:700; color:var(--success);">+' + qtyDisplay + ' ' + escapeHtml(unitDisplay) + '</span></td>' +
      '<td><span class="badge badge-green">' + escapeHtml(statusDisplay) + '</span></td>';

    tbody.appendChild(tr);
  });
}

function handleInboundSubmit(e) {
  if (e && e.preventDefault) e.preventDefault();

  var selectEl = document.getElementById('inboundItemSelect');
  var itemId = selectEl ? selectEl.value : '';
  var supplierInput = document.getElementById('inboundSupplier');
  var supplier = supplierInput ? supplierInput.value.trim() : '';
  var lotInput = document.getElementById('inboundLot');
  var lot = lotInput ? lotInput.value.trim() : '';
  var qtyInput = document.getElementById('inboundQty');
  var qty = qtyInput ? parseInt(qtyInput.value, 10) : 0;
  var dateInput = document.getElementById('inboundDate');
  var date = (dateInput && dateInput.value) ? dateInput.value : new Date().toISOString().split('T')[0];
  var notesInput = document.getElementById('inboundNotes');
  var notes = notesInput ? notesInput.value.trim() : '';

  // 1. Validate selected item
  if (!itemId) {
    showToast('Mohon pilih bahan baku / kain yang diterima.', 'error');
    return;
  }

  var item = inventoryList.find(function (it) {
    return String(it.id) === String(itemId) || it.sku === itemId;
  });

  if (!item) {
    showToast('Barang inventaris tidak ditemukan.', 'error');
    return;
  }

  // 2. Validate qty
  if (!qty || isNaN(qty) || qty <= 0) {
    showToast('Jumlah masuk harus berupa angka positif lebih dari 0.', 'error');
    return;
  }

  // 3. Validate supplier
  if (!supplier) {
    showToast('Nama pemasok / vendor tekstil wajib diisi.', 'error');
    return;
  }

  // 4. Generate PO Number (PO-TX-YYYY-XXX)
  var currentYear = new Date().getFullYear();
  var seq = String(inboundLogsList.length + 1).padStart(3, '0');
  var generatedPo = 'PO-TX-' + currentYear + '-' + seq;

  // 5. Stock Mutation: Increment item stock
  item.qty += qty;
  item.status = item.qty === 0 ? '🚨 Stok Habis' : (item.qty <= item.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');
  saveInventory();

  // 6. Record Inbound Transaction Log
  var newLog = {
    id: 'INB-' + Date.now(),
    poNo: generatedPo,
    trxNo: generatedPo,
    itemId: item.id,
    sku: item.sku,
    itemName: item.name,
    name: item.name,
    qty: qty,
    unit: item.unit || 'Pcs',
    supplier: supplier,
    lotNumber: lot || '-',
    lot: lot || '-',
    date: date,
    notes: notes || '-',
    status: 'QC Passed',
    qcStatus: 'QC Passed'
  };

  inboundLogsList.unshift(newLog);
  try {
    localStorage.setItem('gp_apparel_inbound_logs', JSON.stringify(inboundLogsList));
  } catch (err) { }

  // 7. Re-render UI components
  renderInboundLogs();
  renderInventoryTable(getCurrentKeyword(), getCurrentCat());
  renderInboundDropdown();
  updateStats();

  // 8. Reset form and reset date to today
  var inboundForm = document.getElementById('inboundForm');
  if (inboundForm) {
    inboundForm.reset();
    var dInput = document.getElementById('inboundDate');
    if (dInput) {
      dInput.value = new Date().toISOString().split('T')[0];
    }
  }

  // 9. Feedback Toast
  showToast('Bahan masuk berhasil dicatat! Stok ' + item.name + ' bertambah +' + qty + ' ' + (item.unit || 'Pcs'), 'success');
}

// ── MODUL PENGIRIMAN BAJU JADI (OUTBOUND DO) ────────────────────────────────

function validateOutboundStock() {
  var select = document.getElementById('outboundItemSelect');
  var qtyInput = document.getElementById('outboundQty');
  var hint = document.getElementById('outboundStockHint');
  var submitBtn = document.getElementById('btnSubmitOutbound');
  if (!select || !qtyInput || !hint) return;

  var itemId = select.value;
  var currentItem = inventoryList.find(function (i) {
    return String(i.id) === String(itemId) || i.sku === itemId;
  });

  if (!currentItem) {
    hint.textContent = 'Stok tersedia: -';
    hint.style.color = 'var(--muted)';
    qtyInput.classList.remove('is-invalid');
    qtyInput.style.borderColor = '';
    qtyInput.style.backgroundColor = '';
    if (submitBtn) submitBtn.disabled = false;
    return;
  }

  var qty = parseInt(qtyInput.value, 10);
  var unit = currentItem.unit || 'Pcs';

  if (!isNaN(qty) && qty > currentItem.qty) {
    // 🚨 Over-shipping warning: quantity exceeds available inventory
    hint.textContent = '🚨 Stok tidak mencukupi! Tersedia hanya ' + currentItem.qty + ' ' + unit;
    hint.style.color = 'var(--error)';
    qtyInput.classList.add('is-invalid');
    qtyInput.style.borderColor = 'var(--error)';
    qtyInput.style.backgroundColor = 'var(--error-bg)';
    if (submitBtn) submitBtn.disabled = true;
  } else if (!isNaN(qty) && qty > 0 && qty <= currentItem.qty) {
    hint.textContent = 'Tersedia: ' + currentItem.qty + ' ' + unit;
    hint.style.color = 'var(--success)';
    qtyInput.classList.remove('is-invalid');
    qtyInput.style.borderColor = '';
    qtyInput.style.backgroundColor = '';
    if (submitBtn) submitBtn.disabled = false;
  } else {
    hint.textContent = 'Tersedia: ' + currentItem.qty + ' ' + unit;
    hint.style.color = 'var(--muted)';
    qtyInput.classList.remove('is-invalid');
    qtyInput.style.borderColor = '';
    qtyInput.style.backgroundColor = '';
    if (submitBtn) submitBtn.disabled = false;
  }
}

function renderOutboundDropdown() {
  var select = document.getElementById('outboundItemSelect');
  if (!select) return;

  var currentVal = select.value;
  select.innerHTML = '<option value="">-- Pilih Baju Jadi --</option>';

  // Populates with finished garments (Baju Jadi (Siap Kirim)) or items with stock > 0
  var eligibleItems = inventoryList.filter(function (item) {
    return item.category === 'Baju Jadi (Siap Kirim)';
  });

  if (eligibleItems.length === 0) {
    eligibleItems = inventoryList.filter(function (item) {
      return item.qty > 0;
    });
  }

  if (eligibleItems.length === 0) {
    eligibleItems = inventoryList;
  }

  eligibleItems.forEach(function (item) {
    var opt = document.createElement('option');
    opt.value = item.id;
    opt.textContent = '[' + item.sku + '] ' + item.name + ' (Stok: ' + item.qty + ' ' + (item.unit || 'Pcs') + ')';
    if (String(item.id) === String(currentVal)) {
      opt.selected = true;
    }
    select.appendChild(opt);
  });

  validateOutboundStock();
}

function renderOutboundLogs() {
  var tbody = document.getElementById('outboundTableBody');
  if (!tbody) return;

  tbody.innerHTML = '';

  if (!outboundLogsList || outboundLogsList.length === 0) {
    var emptyTr = document.createElement('tr');
    emptyTr.innerHTML = '<td colspan="7" style="text-align:center; color:var(--muted); padding:24px;">Belum ada riwayat pengiriman baju jadi.</td>';
    tbody.appendChild(emptyTr);
    return;
  }

  outboundLogsList.forEach(function (log) {
    var tr = document.createElement('tr');
    var doDisplay = log.doNo || log.trxNo || '-';
    var dateDisplay = log.date || '-';
    var skuDisplay = log.sku || '-';
    var nameDisplay = log.itemName || log.name || '-';
    var recipientDisplay = log.recipient || '-';
    var courierDisplay = log.courier || '-';
    var qtyDisplay = log.qty || 0;
    var unitDisplay = log.unit || 'Pcs';
    var statusDisplay = log.status || 'Terkirim';

    tr.innerHTML =
      '<td class="td-sku"><strong>' + escapeHtml(doDisplay) + '</strong></td>' +
      '<td>' + escapeHtml(dateDisplay) + '</td>' +
      '<td>' +
        '<strong>' + escapeHtml(skuDisplay) + '</strong>' +
        '<div style="font-size:0.75rem; color:var(--muted);">' + escapeHtml(nameDisplay) + '</div>' +
      '</td>' +
      '<td>' + escapeHtml(recipientDisplay) + '</td>' +
      '<td><span class="badge badge-gray" style="font-size:0.72rem;">' + escapeHtml(courierDisplay) + '</span></td>' +
      '<td style="text-align:right;"><span style="font-weight:700; color:var(--warning);">-' + qtyDisplay + ' ' + escapeHtml(unitDisplay) + '</span></td>' +
      '<td><span class="badge badge-green">' + escapeHtml(statusDisplay) + '</span></td>';

    tbody.appendChild(tr);
  });
}

function handleOutboundSubmit(e) {
  if (e && e.preventDefault) e.preventDefault();

  var selectEl = document.getElementById('outboundItemSelect');
  var itemId = selectEl ? selectEl.value : '';
  var recipientInput = document.getElementById('outboundRecipient');
  var recipient = recipientInput ? recipientInput.value.trim() : '';
  var courierInput = document.getElementById('outboundCourier');
  var courier = courierInput ? courierInput.value.trim() : '';
  var qtyInput = document.getElementById('outboundQty');
  var qty = qtyInput ? parseInt(qtyInput.value, 10) : 0;
  var dateInput = document.getElementById('outboundDate');
  var date = (dateInput && dateInput.value) ? dateInput.value : new Date().toISOString().split('T')[0];

  // 1. Validate selected item
  if (!itemId) {
    showToast('Mohon pilih baju jadi yang akan dikirim.', 'error');
    return;
  }

  var item = inventoryList.find(function (it) {
    return String(it.id) === String(itemId) || it.sku === itemId;
  });

  if (!item) {
    showToast('Barang inventaris tidak ditemukan.', 'error');
    return;
  }

  // 2. Validate qty
  if (!qty || isNaN(qty) || qty <= 0) {
    showToast('Jumlah kirim harus berupa angka positif lebih dari 0.', 'error');
    return;
  }

  // 3. Validate anti-overshipping
  if (qty > item.qty) {
    showToast('Stok tidak mencukupi untuk pengiriman!', 'error');
    return;
  }

  // 4. Validate recipient
  if (!recipient) {
    showToast('Nama penerima / reseller baju jadi wajib diisi.', 'error');
    return;
  }

  // 5. Validate courier
  if (!courier) {
    showToast('Nama ekspedisi / kurir wajib diisi.', 'error');
    return;
  }

  // 6. Auto-generate DO Number (DO-GP-YYYY-XXX)
  var currentYear = new Date().getFullYear();
  var seq = String(outboundLogsList.length + 1).padStart(3, '0');
  var generatedDo = 'DO-GP-' + currentYear + '-' + seq;

  // 7. Stock Mutation: Deduct item inventory
  item.qty -= qty;
  item.status = item.qty === 0 ? '🚨 Stok Habis' : (item.qty <= item.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');
  saveInventory();

  // 8. Record Outbound Transaction Log
  var newLog = {
    id: 'OUT-' + Date.now(),
    doNo: generatedDo,
    trxNo: generatedDo,
    itemId: item.id,
    sku: item.sku,
    itemName: item.name,
    name: item.name,
    qty: qty,
    unit: item.unit || 'Pcs',
    recipient: recipient,
    courier: courier,
    date: date,
    status: 'Terkirim'
  };

  outboundLogsList.unshift(newLog);
  try {
    localStorage.setItem('gp_apparel_outbound_logs', JSON.stringify(outboundLogsList));
  } catch (err) { }

  // 9. Re-render UI components
  renderOutboundLogs();
  renderInventoryTable(getCurrentKeyword(), getCurrentCat());
  renderOutboundDropdown();
  updateStats();

  // 10. Reset form and reset date to today
  var outboundForm = document.getElementById('outboundForm');
  if (outboundForm) {
    outboundForm.reset();
    var dInput = document.getElementById('outboundDate');
    if (dInput) {
      dInput.value = new Date().toISOString().split('T')[0];
    }
  }
  validateOutboundStock();

  // 11. Feedback Toast
  showToast('Surat Jalan ' + generatedDo + ' berhasil diterbitkan! Stok ' + item.name + ' berkurang -' + qty + ' ' + (item.unit || 'Pcs'), 'success');

  // Additional low-stock alert toast if applicable
  if (item.qty === 0) {
    showToast('🚨 PERINGATAN KRITIS: Stok ' + item.name + ' telah HABIS (0)!', 'error');
  } else if (item.qty <= item.minStock) {
    showToast('⚠️ PERINGATAN: Stok ' + item.name + ' tersisa ' + item.qty + ' ' + (item.unit || 'Pcs') + ' (mencapai batas minimum ' + item.minStock + ')!', 'error');
  }
// ── INTERACTIVE WORKSHOP ZONES TELEMETRY & FILTERING ───────────────────────

var activeZoneKey = 'A';

function initZoneInteractions() {
  var zoneCards = document.querySelectorAll('.zone-card');
  if (!zoneCards || zoneCards.length === 0) return;

  zoneCards.forEach(function (card) {
    card.addEventListener('click', function () {
      var zone = card.getAttribute('data-zone') || 'A';
      activeZoneKey = zone;

      zoneCards.forEach(function (c) {
        c.classList.remove('selected');
        c.classList.remove('active');
      });
      card.classList.add('selected');
      card.classList.add('active');

      filterByZone(zone);
    });
  });

  updateZoneTelemetry();
}

function filterByZone(zoneKey) {
  var key = (zoneKey || 'A').toUpperCase();
  var tbody = document.getElementById('zoneFilterTableBody');
  var heading = document.getElementById('currentZoneHeading');

  var zoneLabels = {
    'A': 'ZONA A (Gudang Kain Roll)',
    'B': 'ZONA B (Aksesoris & Benang)',
    'C': 'ZONA C (Meja Potong & WIP Cutting)',
    'D': 'ZONA D (Baju Jadi Siap Kirim)'
  };

  if (heading) {
    heading.textContent = 'Daftar Inventaris: ' + (zoneLabels[key] || ('Zona ' + key));
  }

  if (!tbody) return;
  tbody.innerHTML = '';

  var zoneItems = inventoryList.filter(function (item) {
    var loc = (item.location || '').toUpperCase();
    var cat = (item.category || '').toLowerCase();

    if (key === 'A') {
      return loc.indexOf('A') !== -1 || cat.indexOf('kain') !== -1;
    } else if (key === 'B') {
      return loc.indexOf('B') !== -1 || cat.indexOf('aksesoris') !== -1 || cat.indexOf('benang') !== -1;
    } else if (key === 'C') {
      return loc.indexOf('C') !== -1 || cat.indexOf('cutting') !== -1 || cat.indexOf('pola') !== -1;
    } else if (key === 'D') {
      return loc.indexOf('D') !== -1 || cat.indexOf('baju') !== -1 || cat.indexOf('kemasan') !== -1 || cat.indexOf('packaging') !== -1;
    }
    return loc.indexOf(key) !== -1;
  });

  if (zoneItems.length === 0) {
    var emptyTr = document.createElement('tr');
    emptyTr.innerHTML = '<td colspan="6" style="text-align:center; color:var(--muted); padding:24px;">Tidak ada item inventaris pada zona ini.</td>';
    tbody.appendChild(emptyTr);
    return;
  }

  zoneItems.forEach(function (item) {
    var tr = document.createElement('tr');
    var isLow = item.qty <= (typeof item.minStock === 'number' ? item.minStock : 15);
    var isZero = item.qty === 0;

    var statusMarkup = isZero
      ? '<span class="badge badge-red">🚨 Stok Habis</span>'
      : (isLow ? '<span class="badge badge-orange">⚠️ Stok Minimum!</span>' : '<span class="badge badge-green">Tersedia</span>');

    tr.innerHTML =
      '<td class="td-sku"><strong>' + escapeHtml(item.sku) + '</strong></td>' +
      '<td><strong>' + escapeHtml(item.name) + '</strong></td>' +
      '<td><span class="badge badge-blue">' + escapeHtml(item.category) + '</span></td>' +
      '<td>' + escapeHtml(item.location) + '</td>' +
      '<td><strong>' + item.qty + ' ' + escapeHtml(item.unit || 'Pcs') + '</strong></td>' +
      '<td>' + statusMarkup + '</td>';

    tbody.appendChild(tr);
  });
}

function updateZoneTelemetry() {
  var zoneTotals = { A: 0, B: 0, C: 0, D: 0 };
  var zoneCaps = { A: 600, B: 600, C: 500, D: 1000 };

  inventoryList.forEach(function (item) {
    var loc = (item.location || '').toUpperCase();
    var cat = (item.category || '').toLowerCase();
    var q = Number(item.qty) || 0;

    if (loc.indexOf('A') !== -1 || cat.indexOf('kain') !== -1) zoneTotals.A += q;
    else if (loc.indexOf('B') !== -1 || cat.indexOf('aksesoris') !== -1) zoneTotals.B += q;
    else if (loc.indexOf('C') !== -1 || cat.indexOf('cutting') !== -1) zoneTotals.C += q;
    else if (loc.indexOf('D') !== -1 || cat.indexOf('baju') !== -1) zoneTotals.D += q;
    else zoneTotals.A += q;
  });

  ['A', 'B', 'C', 'D'].forEach(function (z) {
    var fillEls = document.querySelectorAll('.zone-bar-fill.' + (z === 'A' ? 'amber' : (z === 'B' ? 'green' : (z === 'C' ? 'red' : 'cyan'))));
    var meterEls = document.querySelectorAll('.zone-meter');
    var pct = Math.min(100, Math.round((zoneTotals[z] / zoneCaps[z]) * 100));

    fillEls.forEach(function (el) {
      el.style.width = pct + '%';
    });
  });

  // Ensure view elements are accounted for
  var viewOverview = document.getElementById('viewOverview');
  var viewZones = document.getElementById('viewZones');
}

// ── STOCK OPNAME & AUDIT FISIK LOGIC ────────────────────────────────────────

function renderAuditDropdown() {
  var auditItemSelect = document.getElementById('auditItemSelect');
  if (!auditItemSelect) return;

  var currentVal = auditItemSelect.value;
  auditItemSelect.innerHTML = '<option value="">-- Pilih Bahan Baku / Baju Jadi untuk Diaudit --</option>';

  inventoryList.forEach(function (item) {
    var opt = document.createElement('option');
    opt.value = item.id;
    opt.textContent = '[' + item.sku + '] ' + item.name + ' (Stok Sistem: ' + item.qty + ' ' + (item.unit || 'Pcs') + ')';
    if (String(item.id) === String(currentVal) || item.sku === currentVal) {
      opt.selected = true;
    }
    auditItemSelect.appendChild(opt);
  });

  auditItemSelect.addEventListener('change', function () {
    var selectedId = auditItemSelect.value;
    var systemStockEl = document.getElementById('auditSystemStock');
    var countInput = document.getElementById('auditPhysicalCount');

    if (!selectedId) {
      if (systemStockEl) systemStockEl.textContent = '—';
      if (countInput) countInput.value = '';
      calculateAuditDiscrepancy();
      return;
    }

    var item = inventoryList.find(function (it) {
      return String(it.id) === String(selectedId) || it.sku === selectedId;
    });

    if (item && systemStockEl) {
      systemStockEl.textContent = item.qty + ' ' + (item.unit || 'Pcs');
      if (countInput) countInput.value = '';
      calculateAuditDiscrepancy();
    }
  });
}

function calculateAuditDiscrepancy() {
  var select = document.getElementById('auditItemSelect');
  var countInput = document.getElementById('auditPhysicalCount');
  var badge = document.getElementById('auditDiscrepancyBadge');
  var btnSync = document.getElementById('btnSyncAuditStock');

  if (!badge) return;

  if (!select || !select.value || !countInput || countInput.value.trim() === '') {
    badge.className = 'discrepancy-pill';
    badge.textContent = 'Masukkan hitungan fisik';
    if (btnSync) btnSync.disabled = true;
    return;
  }

  var item = inventoryList.find(function (it) {
    return String(it.id) === String(select.value) || it.sku === select.value;
  });

  if (!item) {
    badge.className = 'discrepancy-pill';
    badge.textContent = 'Masukkan hitungan fisik';
    if (btnSync) btnSync.disabled = true;
    return;
  }

  var physicalVal = parseInt(countInput.value, 10);
  if (isNaN(physicalVal) || physicalVal < 0) {
    badge.className = 'discrepancy-pill deficit';
    badge.textContent = 'Angka tidak valid';
    if (btnSync) btnSync.disabled = true;
    return;
  }

  var diff = physicalVal - item.qty;

  if (diff === 0) {
    badge.className = 'discrepancy-pill match';
    badge.textContent = '✓ Sesuai (Selisih: 0 ' + (item.unit || 'Pcs') + ')';
  } else if (diff > 0) {
    badge.className = 'discrepancy-pill surplus';
    badge.textContent = '+ ' + diff + ' ' + (item.unit || 'Pcs') + ' (Surplus Fisik)';
  } else {
    badge.className = 'discrepancy-pill deficit';
    badge.textContent = '' + diff + ' ' + (item.unit || 'Pcs') + ' (Kurang / Defisit)';
  }

  if (btnSync) btnSync.disabled = false;
}

function syncAuditStock() {
  var select = document.getElementById('auditItemSelect');
  var countInput = document.getElementById('auditPhysicalCount');
  var reasonInput = document.getElementById('auditReason');
  var user = getUser() || { name: 'Staff Konveksi' };

  if (!select || !select.value) {
    showToast('Mohon pilih barang yang diaudit.', 'error');
    return;
  }

  var item = inventoryList.find(function (it) {
    return String(it.id) === String(select.value) || it.sku === select.value;
  });

  if (!item) {
    showToast('Item tidak ditemukan.', 'error');
    return;
  }

  var physicalVal = parseInt(countInput ? countInput.value : '', 10);
  if (isNaN(physicalVal) || physicalVal < 0) {
    showToast('Masukkan hitungan fisik yang valid (minimal 0).', 'error');
    return;
  }

  var oldStock = item.qty;
  var diff = physicalVal - oldStock;
  var reason = (reasonInput && reasonInput.value.trim()) ? reasonInput.value.trim() : 'Penyesuaian hasil audit fisik garmen';

  // Update item stock
  item.qty = physicalVal;
  item.status = item.qty === 0 ? '🚨 Stok Habis' : (item.qty <= item.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');
  saveInventory();
  localStorage.setItem('gp_apparel_inventory', JSON.stringify(inventoryList));

  // Add audit log
  var newAuditLog = {
    id: 'AUD-' + Date.now(),
    date: new Date().toISOString().split('T')[0],
    itemId: item.id,
    sku: item.sku,
    itemName: item.name,
    systemStock: oldStock,
    physicalStock: physicalVal,
    discrepancy: diff,
    reason: reason,
    auditor: user.name || 'Staff Konveksi'
  };

  auditLogsList.unshift(newAuditLog);
  try {
    localStorage.setItem('gp_apparel_audit_logs', JSON.stringify(auditLogsList));
  } catch (e) { }

  // Re-render UI
  renderAuditLogs();
  renderInventoryTable(getCurrentKeyword(), getCurrentCat());
  renderInboundDropdown();
  renderOutboundDropdown();
  renderAuditDropdown();
  updateZoneTelemetry();
  filterByZone(activeZoneKey);
  updateStats();

  // Reset inputs
  if (countInput) countInput.value = '';
  if (reasonInput) reasonInput.value = '';
  calculateAuditDiscrepancy();

  showToast('Audit berhasil! Stok ' + item.name + ' disinkronkan menjadi ' + physicalVal + ' ' + (item.unit || 'Pcs') + ' (Selisih: ' + (diff > 0 ? '+' : '') + diff + ')', 'success');
}

function renderAuditLogs() {
  var tbody = document.getElementById('auditTableBody');
  if (!tbody) return;

  tbody.innerHTML = '';

  if (!auditLogsList || auditLogsList.length === 0) {
    var emptyTr = document.createElement('tr');
    emptyTr.innerHTML = '<td colspan="7" style="text-align:center; color:var(--muted); padding:24px;">Belum ada riwayat stock opname.</td>';
    tbody.appendChild(emptyTr);
    return;
  }

  auditLogsList.forEach(function (log) {
    var tr = document.createElement('tr');
    var dateDisplay = log.date || '-';
    var skuDisplay = log.sku || '-';
    var nameDisplay = log.itemName || log.name || '-';
    var auditorDisplay = log.auditor || 'Staff Konveksi';
    var sysStock = typeof log.systemStock !== 'undefined' ? log.systemStock : '-';
    var physStock = typeof log.physicalStock !== 'undefined' ? log.physicalStock : '-';
    var diff = typeof log.discrepancy !== 'undefined' ? Number(log.discrepancy) : 0;
    var reasonDisplay = log.reason || log.notes || '-';

    var diffMarkup = '';
    if (diff === 0) {
      diffMarkup = '<span class="discrepancy-pill match" style="font-size:0.75rem;">0 (Cocok)</span>';
    } else if (diff > 0) {
      diffMarkup = '<span class="discrepancy-pill surplus" style="font-size:0.75rem;">+' + diff + ' (Surplus)</span>';
    } else {
      diffMarkup = '<span class="discrepancy-pill deficit" style="font-size:0.75rem;">' + diff + ' (Defisit)</span>';
    }

    tr.innerHTML =
      '<td>' + escapeHtml(dateDisplay) + '</td>' +
      '<td><strong>' + escapeHtml(skuDisplay) + '</strong><div style="font-size:0.75rem; color:var(--muted);">' + escapeHtml(nameDisplay) + '</div></td>' +
      '<td>' + escapeHtml(auditorDisplay) + '</td>' +
      '<td style="text-align:right;">' + sysStock + '</td>' +
      '<td style="text-align:right;"><strong>' + physStock + '</strong></td>' +
      '<td>' + diffMarkup + '</td>' +
      '<td><span style="font-size:0.8rem; color:var(--text);">' + escapeHtml(reasonDisplay) + '</span></td>';

    tbody.appendChild(tr);
  });
}

// ── TAB WORKSPACE SWITCHER (VIEWS & NAVIGATION) ─────────────────────────────

var VIEW_MODULE_LABELS = {
  viewOverview: 'Dashboard Operasional Konveksi',
  viewInventory: 'Manajemen Stok Bahan Kain & Pakaian',
  viewInbound: 'Penerimaan Bahan Baku (Inbound Garmen)',
  viewOutbound: 'Pengiriman Baju Jadi (Outbound Kurir/Kargo)',
  viewZones: 'Denah Rak & Zonasi Gudang',
  viewAudit: 'Audit Stok Fisik & Stock Opname'
};

var NAV_VIEW_MAP = {
  viewOverview: 'navOverview',
  viewInventory: 'navInventory',
  viewInbound: 'navInbound',
  viewOutbound: 'navOutbound',
  viewZones: 'navRacks',
  viewAudit: 'navAudit'
};

function switchView(viewId) {
  if (!viewId) return;
  var cleanId = viewId.replace(/^#/, '');

  var viewIds = ['viewOverview', 'viewInventory', 'viewInbound', 'viewOutbound', 'viewZones', 'viewAudit'];
  var navIds = ['navOverview', 'navInventory', 'navInbound', 'navOutbound', 'navRacks', 'navAudit'];

  // 1. Hide all views and remove active class
  viewIds.forEach(function (id) {
    var el = document.getElementById(id);
    if (el) {
      el.classList.remove('active');
      el.style.display = 'none';
    }
  });

  // 2. Remove active class from all navigation links
  navIds.forEach(function (id) {
    var navEl = document.getElementById(id);
    if (navEl) {
      navEl.classList.remove('active');
    }
  });

  // 3. Show target view and add active class
  var targetView = document.getElementById(cleanId);
  if (targetView) {
    targetView.classList.add('active');
    targetView.style.display = 'block';
  }

  // 4. Set active class on corresponding sidebar nav
  var activeNavId = NAV_VIEW_MAP[cleanId];
  if (activeNavId) {
    var activeNavEl = document.getElementById(activeNavId);
    if (activeNavEl) {
      activeNavEl.classList.add('active');
    }
  }

  // 5. Update module title in header and document title
  var moduleTitle = VIEW_MODULE_LABELS[cleanId] || 'Sentra Konveksi Bandung (Lini Aktif)';
  var hubSelector = document.querySelector('.warehouse-selector span:last-child');
  if (hubSelector) {
    hubSelector.textContent = moduleTitle;
  }
  document.title = 'GudangPro Apparel — ' + moduleTitle;

  // 6. Reactivity: When switching to views, re-render their data
  if (cleanId === 'viewInventory') {
    renderInventoryTable(getCurrentKeyword(), getCurrentCat());
  } else if (cleanId === 'viewInbound') {
    renderInboundDropdown();
    renderInboundLogs();
    var inbDate = document.getElementById('inboundDate');
    if (inbDate && !inbDate.value) {
      inbDate.value = new Date().toISOString().split('T')[0];
    }
  } else if (cleanId === 'viewOutbound') {
    renderOutboundDropdown();
    renderOutboundLogs();
    var outDate = document.getElementById('outboundDate');
    if (outDate && !outDate.value) {
      outDate.value = new Date().toISOString().split('T')[0];
    }
  } else if (cleanId === 'viewZones') {
    updateZoneTelemetry();
    filterByZone(activeZoneKey || 'A');
  } else if (cleanId === 'viewAudit') {
    renderAuditDropdown();
    renderAuditLogs();
  }

  window.scrollTo({ top: 0, behavior: 'smooth' });
}

window.switchView = switchView;

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

  // Tombol scroll ke tabel saat klik di low stock alert banner -> beralih ke tab viewInventory
  var btnScrollToLowStock = document.getElementById('btnScrollToLowStock');
  if (btnScrollToLowStock) {
    btnScrollToLowStock.addEventListener('click', function () {
      switchView('viewInventory');
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

  // Submit Penerimaan Bahan Baku (Inbound PO)
  var inboundForm = document.getElementById('inboundForm');
  if (inboundForm) {
    inboundForm.addEventListener('submit', handleInboundSubmit);
  }

  // Submit Surat Jalan Pengiriman Baju Jadi (Outbound DO)
  var outboundForm = document.getElementById('outboundForm');
  if (outboundForm) {
    outboundForm.addEventListener('submit', handleOutboundSubmit);
  }

  // Realtime Over-Shipping Validation Listeners
  var outboundItemSelect = document.getElementById('outboundItemSelect');
  var outboundQtyInput = document.getElementById('outboundQty');
  if (outboundItemSelect) {
    outboundItemSelect.addEventListener('change', validateOutboundStock);
  }
  if (outboundQtyInput) {
    outboundQtyInput.addEventListener('input', validateOutboundStock);
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

  // Sidebar workspace switcher navigasi tab
  var navOverview = document.getElementById('navOverview');
  var navInventory = document.getElementById('navInventory');
  var navInbound = document.getElementById('navInbound');
  var navOutbound = document.getElementById('navOutbound');
  var navRacks = document.getElementById('navRacks');
  var navAudit = document.getElementById('navAudit');

  if (navOverview) {
    navOverview.addEventListener('click', function (e) {
      e.preventDefault();
      switchView('viewOverview');
    });
  }
  if (navInventory) {
    navInventory.addEventListener('click', function (e) {
      e.preventDefault();
      switchView('viewInventory');
    });
  }
  if (navInbound) {
    navInbound.addEventListener('click', function (e) {
      e.preventDefault();
      switchView('viewInbound');
    });
  }
  if (navOutbound) {
    navOutbound.addEventListener('click', function (e) {
      e.preventDefault();
      switchView('viewOutbound');
    });
  }
  if (navRacks) {
    navRacks.addEventListener('click', function (e) {
      e.preventDefault();
      switchView('viewZones');
    });
  }
  if (navAudit) {
    navAudit.addEventListener('click', function (e) {
      e.preventDefault();
      switchView('viewAudit');
    });
  }

  // Zone interactions
  initZoneInteractions();

  // Stock Opname Audit Event Listeners
  var btnSyncAuditStock = document.getElementById('btnSyncAuditStock');
  if (btnSyncAuditStock) {
    btnSyncAuditStock.addEventListener('click', syncAuditStock);
  }

  var auditPhysicalCount = document.getElementById('auditPhysicalCount');
  if (auditPhysicalCount) {
    auditPhysicalCount.addEventListener('input', calculateAuditDiscrepancy);
  }

  renderAuditDropdown();
  renderAuditLogs();
  updateZoneTelemetry();
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
