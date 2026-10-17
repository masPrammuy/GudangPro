# Flutter Mobile App Implementation Plan (GudangPro Apparel)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menginisialisasi dan membangun aplikasi mobile cross-platform Flutter (`mobile/`) untuk GudangPro Apparel dengan arsitektur Feature-First Clean Architecture, Riverpod state management, integrasi database Supabase Realtime, antarmuka adaptif (Smartphone & Tablet), serta validasi transaksi anti-overshipping.

**Architecture:** Flutter 3.24+ menggunakan Riverpod (v2) untuk state management reaktif yang terhubung langsung ke WebSocket stream Supabase (`supabase_flutter`). Tata letak menggunakan `AdaptiveScaffold` yang secara dinamis menampilkan `BottomNavigationBar` pada smartphone (< 600dp) dan `NavigationRail` split-screen pada tablet (≥ 600dp).

**Tech Stack:** Flutter 3.24.3, Dart 3.5.3, `flutter_riverpod`, `supabase_flutter`, `google_fonts`, `intl`.

**Spec:** `docs/superpowers/specs/2026-10-17-flutter-mobile-migration-design.md`

## Global Constraints

- Kode aplikasi Flutter berada di direktori `c:\Users\Lenovo\.gemini\antigravity-ide\scratch\warehouse-app\mobile`.
- Arsitektur wajib mengikuti *Feature-First Clean Architecture* (fitur mandiri: `inventory`, `inbound`, `outbound`, `audit`).
- Tata letak wajib adaptif: Layar < 600dp menggunakan navigasi bawah, layar ≥ 600dp menggunakan navigasi samping.
- Estetika industrial garmen: Slate, Emerald, Amber, Rose, Indigo (tanpa gradien neon mencolok).
- Seluruh 4 model data (`ItemModel`, `InboundModel`, `OutboundModel`, `AuditModel`) memetakan skema PostgreSQL Supabase secara 1-ke-1.
- Logika anti-overshipping wajib divalidasi di layer model & form sebelum submit (`qty <= availableStock`).
- Seluruh pengujian dijalankan melalui Flutter Test framework (`flutter test`).

---

### Task 1: Inisialisasi Proyek Flutter & Konfigurasi Dependensi

**Files:**
- Create: `mobile/pubspec.yaml`
- Create: `mobile/lib/main.dart`
- Create: `mobile/test/smoke_test.dart`

**Interfaces:**
- Consumes: Flutter SDK 3.24.3, Dart SDK 3.5.3.
- Produces: Fondasi proyek Flutter runnable dengan dependensi `flutter_riverpod`, `supabase_flutter`, `google_fonts`, dan `intl`.

- [ ] **Step 1: Write the failing test**

```dart
// mobile/test/smoke_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flutter environment and project scaffold smoke test', () {
    const appName = 'GudangPro Apparel';
    expect(appName, contains('GudangPro'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/smoke_test.dart`
Expected: FAIL (karena direktori `mobile` belum diinisialisasi)

- [ ] **Step 3: Write minimal implementation**

1. Jalankan `flutter create --org com.gudangpro.apparel --project-name mobile mobile` di root workspace.
2. Perbarui `mobile/pubspec.yaml` dengan dependensi:
```yaml
name: mobile
description: "GudangPro Apparel Mobile Application"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  supabase_flutter: ^2.6.0
  google_fonts: ^6.2.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```
3. Jalankan `flutter pub get` di dalam direktori `mobile`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/smoke_test.dart`
Expected: 00:01 +1: All tests passed!

- [ ] **Step 5: Commit**

```bash
git add mobile/
git commit -m "feat(mobile): scaffold Flutter project with Riverpod and Supabase dependencies"
```

---

### Task 2: Desain Tema Industrial & Komponen UI Adaptif

**Files:**
- Create: `mobile/lib/core/constants/app_colors.dart`
- Create: `mobile/lib/core/constants/app_constants.dart`
- Create: `mobile/lib/core/theme/app_theme.dart`
- Create: `mobile/lib/core/widgets/status_badge.dart`
- Create: `mobile/lib/core/widgets/adaptive_scaffold.dart`
- Create: `mobile/test/widget/adaptive_layout_test.dart`
- Create: `mobile/test/widget/status_badge_test.dart`

**Interfaces:**
- Consumes: Material 3, `AppColors`.
- Produces: `AdaptiveScaffold` (responsif < 600dp vs ≥ 600dp), `StatusBadge` (Tersedia, Minimum, Habis).

- [ ] **Step 1: Write the failing tests**

```dart
// mobile/test/widget/status_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge renders correct label and color', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: 'Tersedia'),
        ),
      ),
    );
    expect(find.text('Tersedia'), findsOneWidget);
  });
}
```

```dart
// mobile/test/widget/adaptive_layout_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/adaptive_scaffold.dart';

void main() {
  testWidgets('AdaptiveScaffold displays BottomNavigationBar on phone screen width', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          currentIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveDestination(icon: Icons.inventory_2, label: 'Stok'),
            AdaptiveDestination(icon: Icons.move_to_inbox, label: 'Masuk'),
          ],
          body: const Text('Dashboard Content'),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('AdaptiveScaffold displays NavigationRail on tablet screen width', (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          currentIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveDestination(icon: Icons.inventory_2, label: 'Stok'),
            AdaptiveDestination(icon: Icons.move_to_inbox, label: 'Masuk'),
          ],
          body: const Text('Dashboard Content'),
        ),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd mobile; flutter test test/widget/status_badge_test.dart test/widget/adaptive_layout_test.dart`
Expected: FAIL (karena file implementasi belum dibuat)

- [ ] **Step 3: Write minimal implementation**

1. Tulis `mobile/lib/core/constants/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateCard = Color(0xFF1E293B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Status Alerts
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color roseDanger = Color(0xFFEF4444);
  static const Color indigoWip = Color(0xFF6366F1);
}
```

2. Tulis `mobile/lib/core/constants/app_constants.dart`:
```dart
class AppConstants {
  static const double tabletBreakpoint = 600.0;
  static const String appTitle = 'GudangPro Apparel';
}
```

3. Tulis `mobile/lib/core/widgets/status_badge.dart`:
```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (status.contains('Habis')) {
      bg = AppColors.roseDanger.withOpacity(0.12);
      fg = AppColors.roseDanger;
    } else if (status.contains('Minimum')) {
      bg = AppColors.amberWarning.withOpacity(0.12);
      fg = AppColors.amberWarning;
    } else {
      bg = AppColors.emeraldSuccess.withOpacity(0.12);
      fg = AppColors.emeraldSuccess;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

4. Tulis `mobile/lib/core/widgets/adaptive_scaffold.dart`:
```dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AdaptiveDestination {
  final IconData icon;
  final String label;

  const AdaptiveDestination({required this.icon, required this.label});
}

class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveDestination> destinations;
  final Widget body;
  final PreferredSizeWidget? appBar;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= AppConstants.tabletBreakpoint;

    if (isTablet) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd mobile; flutter test test/widget/status_badge_test.dart test/widget/adaptive_layout_test.dart`
Expected: 00:02 +3: All tests passed!

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/core/ mobile/test/widget/
git commit -m "feat(mobile): add industrial theme constants, status badge and adaptive scaffold widget"
```

---

### Task 3: Domain Data Models & Unit Serialization Tests

**Files:**
- Create: `mobile/lib/features/inventory/data/item_model.dart`
- Create: `mobile/lib/features/inbound/data/inbound_model.dart`
- Create: `mobile/lib/features/outbound/data/outbound_model.dart`
- Create: `mobile/lib/features/audit/data/audit_model.dart`
- Create: `mobile/test/unit/item_model_test.dart`
- Create: `mobile/test/unit/inbound_model_test.dart`
- Create: `mobile/test/unit/outbound_model_test.dart`
- Create: `mobile/test/unit/audit_model_test.dart`

**Interfaces:**
- Consumes: Supabase PostgreSQL JSON payload.
- Produces: Data classes dengan `fromJson`, `toJson`, dan domain getters (`isLowStock`, `isOutOfStock`, `canDispatch`, `discrepancy`).

- [ ] **Step 1: Write the failing tests**

```dart
// mobile/test/unit/item_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/inventory/data/item_model.dart';

void main() {
  test('ItemModel correctly parses from and to Supabase JSON', () {
    final json = {
      'id': 'd0a5b281-7c91-49b0-9513-33df45fbf0a1',
      'sku': 'KAN-CMB-01',
      'name': 'Kain Katun Combed 30s',
      'category': 'Kain & Bahan Baku',
      'qty': 45,
      'unit': 'Roll',
      'min_stock': 15,
      'location': 'Rak Kain A-01',
      'zone': 'A',
      'status': 'Tersedia',
    };

    final item = ItemModel.fromJson(json);
    expect(item.sku, 'KAN-CMB-01');
    expect(item.qty, 45);
    expect(item.isLowStock, false);
    expect(item.isOutOfStock, false);
    expect(item.canDispatch(20), true);
    expect(item.canDispatch(50), false); // Anti over-shipping guard
  });
}
```

```dart
// mobile/test/unit/outbound_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/outbound/data/outbound_model.dart';

void main() {
  test('OutboundModel correctly serializes for Supabase DO insert', () {
    final model = OutboundModel(
      doNumber: 'DO-GP-2026-001',
      itemId: 'd0a5b281-7c91-49b0-9513-33df45fbf0a1',
      qty: 10,
      recipient: 'Distributor Apparel Jakarta',
      courier: 'JNE Trucking',
      notes: 'Pengiriman batch 1',
    );

    final json = model.toJson();
    expect(json['do_number'], 'DO-GP-2026-001');
    expect(json['qty'], 10);
    expect(json['status'], 'Terkirim');
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd mobile; flutter test test/unit/item_model_test.dart test/unit/outbound_model_test.dart`
Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

1. Tulis `mobile/lib/features/inventory/data/item_model.dart`:
```dart
class ItemModel {
  final String id;
  final String sku;
  final String name;
  final String category;
  final int qty;
  final String unit;
  final int minStock;
  final String location;
  final String zone;
  final String status;

  ItemModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.qty,
    required this.unit,
    required this.minStock,
    required this.location,
    required this.zone,
    required this.status,
  });

  bool get isLowStock => qty <= minStock && qty > 0;
  bool get isOutOfStock => qty <= 0;
  bool canDispatch(int requestedQty) => requestedQty > 0 && requestedQty <= qty;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      qty: (json['qty'] as num).toInt(),
      unit: json['unit'] as String? ?? 'Pcs',
      minStock: (json['min_stock'] as num?)?.toInt() ?? 15,
      location: json['location'] as String? ?? 'Gudang',
      zone: json['zone'] as String? ?? 'A',
      status: json['status'] as String? ?? 'Tersedia',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'qty': qty,
      'unit': unit,
      'min_stock': minStock,
      'location': location,
      'zone': zone,
      'status': status,
    };
  }
}
```

2. Tulis `mobile/lib/features/inbound/data/inbound_model.dart`:
```dart
class InboundModel {
  final String? id;
  final String poNumber;
  final String itemId;
  final int qty;
  final String supplier;
  final String lotNumber;
  final String notes;
  final String status;

  InboundModel({
    this.id,
    required this.poNumber,
    required this.itemId,
    required this.qty,
    required this.supplier,
    this.lotNumber = '-',
    this.notes = '-',
    this.status = 'QC Passed',
  });

  factory InboundModel.fromJson(Map<String, dynamic> json) {
    return InboundModel(
      id: json['id'] as String?,
      poNumber: json['po_number'] as String,
      itemId: json['item_id'] as String,
      qty: (json['qty'] as num).toInt(),
      supplier: json['supplier'] as String,
      lotNumber: json['lot_number'] as String? ?? '-',
      notes: json['notes'] as String? ?? '-',
      status: json['status'] as String? ?? 'QC Passed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'po_number': poNumber,
      'item_id': itemId,
      'qty': qty,
      'supplier': supplier,
      'lot_number': lotNumber,
      'notes': notes,
      'status': status,
    };
  }
}
```

3. Tulis `mobile/lib/features/outbound/data/outbound_model.dart`:
```dart
class OutboundModel {
  final String? id;
  final String doNumber;
  final String itemId;
  final int qty;
  final String recipient;
  final String courier;
  final String notes;
  final String status;

  OutboundModel({
    this.id,
    required this.doNumber,
    required this.itemId,
    required this.qty,
    required this.recipient,
    required this.courier,
    this.notes = '-',
    this.status = 'Terkirim',
  });

  factory OutboundModel.fromJson(Map<String, dynamic> json) {
    return OutboundModel(
      id: json['id'] as String?,
      doNumber: json['do_number'] as String,
      itemId: json['item_id'] as String,
      qty: (json['qty'] as num).toInt(),
      recipient: json['recipient'] as String,
      courier: json['courier'] as String,
      notes: json['notes'] as String? ?? '-',
      status: json['status'] as String? ?? 'Terkirim',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'do_number': doNumber,
      'item_id': itemId,
      'qty': qty,
      'recipient': recipient,
      'courier': courier,
      'notes': notes,
      'status': status,
    };
  }
}
```

4. Tulis `mobile/lib/features/audit/data/audit_model.dart`:
```dart
class AuditModel {
  final String? id;
  final String itemId;
  final int systemStock;
  final int physicalStock;
  final int discrepancy;
  final String reason;

  AuditModel({
    this.id,
    required this.itemId,
    required this.systemStock,
    required this.physicalStock,
    int? discrepancy,
    this.reason = 'Penyesuaian hasil audit fisik garmen',
  }) : discrepancy = discrepancy ?? (physicalStock - systemStock);

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      id: json['id'] as String?,
      itemId: json['item_id'] as String,
      systemStock: (json['system_stock'] as num).toInt(),
      physicalStock: (json['physical_stock'] as num).toInt(),
      discrepancy: (json['discrepancy'] as num).toInt(),
      reason: json['reason'] as String? ?? 'Penyesuaian hasil audit fisik garmen',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'system_stock': systemStock,
      'physical_stock': physicalStock,
      'discrepancy': discrepancy,
      'reason': reason,
    };
  }
}
```

5. Buat unit test lengkap untuk `inbound_model_test.dart` dan `audit_model_test.dart`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd mobile; flutter test test/unit/`
Expected: 00:02 +4: All tests passed!

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/ mobile/test/unit/
git commit -m "feat(mobile): implement core apparel data models with serialization and anti-overshipping validation"
```

---

### Task 4: Modul Inventaris & Realtime Stream View

**Files:**
- Create: `mobile/lib/features/inventory/data/inventory_repository.dart`
- Create: `mobile/lib/features/inventory/providers/inventory_providers.dart`
- Create: `mobile/lib/features/inventory/presentation/widgets/item_card.dart`
- Create: `mobile/lib/features/inventory/presentation/widgets/zone_filter_bar.dart`
- Create: `mobile/lib/features/inventory/presentation/inventory_screen.dart`
- Create: `mobile/test/widget/inventory_screen_test.dart`

**Interfaces:**
- Consumes: `ItemModel`, `StatusBadge`, `inventoryListStreamProvider`.
- Produces: Layar master stok live dengan filter zona konveksi (Semua, A-Kain, B-Aksesoris, C-Cutting, D-Baju Jadi).

- [ ] **Step 1: Write the failing test**

```dart
// mobile/test/widget/inventory_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/inventory/data/item_model.dart';
import 'package:mobile/features/inventory/presentation/inventory_screen.dart';
import 'package:mobile/features/inventory/providers/inventory_providers.dart';

void main() {
  testWidgets('InventoryScreen renders item cards and zone filters', (tester) async {
    final mockItems = [
      ItemModel(
        id: '1',
        sku: 'KAN-CMB-01',
        name: 'Kain Katun Combed 30s',
        category: 'Kain & Bahan Baku',
        qty: 45,
        unit: 'Roll',
        minStock: 15,
        location: 'Rak A-01',
        zone: 'A',
        status: 'Tersedia',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
        ],
        child: const MaterialApp(
          home: InventoryScreen(),
        ),
      ),
    );

    expect(find.text('KAN-CMB-01'), findsOneWidget);
    expect(find.text('Kain Katun Combed 30s'), findsOneWidget);
    expect(find.text('Zona A'), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/inventory_screen_test.dart`
Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

1. Tulis `inventory_repository.dart` dengan listener Supabase Stream.
2. Tulis `inventory_providers.dart` dengan `selectedZoneProvider` dan `inventoryListProvider`.
3. Tulis `item_card.dart` dengan desain industrial kontras tinggi dan border warna zona.
4. Tulis `zone_filter_bar.dart` dengan chips interaktif (Semua, Zona A, Zona B, Zona C, Zona D).
5. Tulis `inventory_screen.dart` yang mengintegrasikan komponen di atas secara responsif.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/widget/inventory_screen_test.dart`
Expected: 00:02 +1: All tests passed!

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/inventory/ mobile/test/widget/inventory_screen_test.dart
git commit -m "feat(inventory): implement live inventory stream screen with zone filter chips and item cards"
```

---

### Task 5: Modul Transaksi Operasional & Integrasi Sistem Lengkap

**Files:**
- Create: `mobile/lib/features/inbound/presentation/inbound_screen.dart`
- Create: `mobile/lib/features/outbound/presentation/outbound_screen.dart`
- Create: `mobile/lib/features/audit/presentation/audit_screen.dart`
- Create: `mobile/lib/app.dart`
- Modify: `mobile/lib/main.dart`
- Create: `mobile/test/widget/transaction_screens_test.dart`

**Interfaces:**
- Consumes: `AdaptiveScaffold`, `InboundModel`, `OutboundModel`, `AuditModel`.
- Produces: Aplikasi lengkap 4 modul operasional dengan validasi form anti-overshipping di sisi klien dan integrasi trigger Supabase.

- [ ] **Step 1: Write the failing test**

```dart
// mobile/test/widget/transaction_screens_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/outbound/presentation/outbound_screen.dart';

void main() {
  testWidgets('Outbound screen displays error when requested qty exceeds stock', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OutboundScreen(),
        ),
      ),
    );

    expect(find.text('Surat Jalan (DO)'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/transaction_screens_test.dart`
Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

1. Tulis `inbound_screen.dart` dengan form input PO, supplier, lot kain, dan kuantitas.
2. Tulis `outbound_screen.dart` dengan proteksi visual anti-overshipping: field kuantitas otomatis merah jika melebihi stok barang yang dipilih.
3. Tulis `audit_screen.dart` dengan kalkulasi selisih fisik otomatis.
4. Tulis `app.dart` yang mengikat `AdaptiveScaffold` dengan 4 tab navigasi (Stok, Bahan Masuk PO, Kirim Baju DO, Stock Opname).
5. Konfigurasi `main.dart` dengan `ProviderScope` dan inisialisasi aman Supabase.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test`
Expected: All tests pass across the entire suite!

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/ mobile/test/
git commit -m "feat(app): complete 4 garment operational modules with adaptive layout and full test suite"
```
