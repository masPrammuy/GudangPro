# Implementation Plan: Workshop Telemetry Dashboard & PDF Logistics Document Printing

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Bespoke Workshop Telemetry Dashboard (mirroring the user's reference image with quick steps, 4 KPI cards, 4 zone capacity telemetry cards, and critical warning banner with jump button) and official PDF logistics document printing (Purchase Order & Delivery Order Surat Jalan with formal layout and 3-party signatures).

**Architecture:** Feature-First Clean Architecture extending `lib/core/services/` for PDF generation, `lib/features/dashboard/presentation/widgets/` for telemetry UI components, and `lib/app.dart` for dynamic tab integration across both Admin (8 tabs) and User (6 tabs) roles.

**Tech Stack:** Flutter 3.24+, Dart 3.5+, Riverpod 2.5.1+, `pdf: ^3.11.1`, `printing: ^5.13.2`, `fl_chart: ^0.68.0`, Google Fonts (Inter).

**Spec:** [docs/superpowers/specs/2026-10-19-telemetry-dashboard-pdf-printing-design.md](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/docs/superpowers/specs/2026-10-19-telemetry-dashboard-pdf-printing-design.md)

## Global Constraints
- All Flutter code lives under `mobile/lib/`.
- All automated tests live under `mobile/test/` and run via `cd mobile; flutter test`.
- Visual styling must adhere to the Industrial Garment Theme (`AppColors.darkSlatePrimary`, `emeraldSuccess`, `amberWarning`, `roseDanger`, `indigoAccent`, and Zone Colors A: `#3B82F6`, B: `#8B5CF6`, C: `#F59E0B`, D: `#10B981`).
- The Workshop Telemetry Dashboard must faithfully mirror the layout, labels, and telemetry metrics from the uploaded reference image (`media_1792345005643_9ee6e018.png`).
- PDF documents must be generated using `pdf` and `printing` packages with formal headers, transaction metadata, item table, and 3-party signature blocks.
- Static analysis must remain 100% clean (`cd mobile; flutter analyze` reporting 0 issues).

---

### Task 1: Dependensi `pdf` & `printing` dan Layanan Dokumen PDF (`PdfInvoiceService`)

**Files:**
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/lib/core/services/pdf_invoice_service.dart`
- Test: `mobile/test/unit/pdf_invoice_service_test.dart`

**Interfaces:**
- Produces: `class PdfInvoiceService` with methods:
  - `static Future<Uint8List> generateInboundPoPdf({...})`
  - `static Future<Uint8List> generateOutboundDoPdf({...})`
  - `static Future<void> printInboundPo({...})`
  - `static Future<void> printOutboundDo({...})`

- [ ] **Step 1: Write the failing unit test**

Create `mobile/test/unit/pdf_invoice_service_test.dart`:
```dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/pdf_invoice_service.dart';
import 'package:mobile/features/inventory/data/item_model.dart';

void main() {
  group('PdfInvoiceService Unit Tests', () {
    const mockItem = ItemModel(
      id: 'kan-cmb-01',
      sku: 'KAN-CMB-01',
      name: 'Kain Katun Combed 30s Hitam Reaktif',
      category: 'Bahan Baku Tekstil',
      qty: 45,
      unit: 'Roll',
      minStock: 10,
      location: 'Rak Kain A-01',
      zone: 'A',
      status: 'Tersedia',
    );

    test('generateInboundPoPdf produces valid non-empty PDF bytes with PO metadata', () async {
      final pdfBytes = await PdfInvoiceService.generateInboundPoPdf(
        poNumber: 'PO-TX-2026-001',
        supplier: 'PT Grand Textile Nusantara',
        lotNumber: 'LOT-TX-992B',
        item: mockItem,
        qty: 50,
        receiverName: 'Pramudya Administrator',
        receiverNik: 'ADM-001',
        notes: 'Lolos uji gramasi dan susut',
      );

      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, greaterThan(1000));
      // PDF magic bytes %PDF-
      expect(String.fromCharCodes(pdfBytes.sublist(0, 5)), equals('%PDF-'));
    });

    test('generateOutboundDoPdf produces valid non-empty PDF bytes with DO metadata', () async {
      final pdfBytes = await PdfInvoiceService.generateOutboundDoPdf(
        doNumber: 'DO-GP-2026-001',
        recipient: 'Distributor Kaos Polos Bandung',
        item: mockItem,
        qty: 20,
        senderName: 'Budi Santoso',
        senderNik: 'STF-042',
        notes: 'Pengiriman via Truk Box Kargo',
      );

      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, greaterThan(1000));
      expect(String.fromCharCodes(pdfBytes.sublist(0, 5)), equals('%PDF-'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/unit/pdf_invoice_service_test.dart`  
Expected: Compilation failure (`pdf_invoice_service.dart` not found).

- [ ] **Step 3: Add `pdf` and `printing` to `pubspec.yaml` and implement `PdfInvoiceService`**

In `mobile/pubspec.yaml`, under `dependencies`, add:
```yaml
  pdf: ^3.11.1
  printing: ^5.13.2
```
Run: `cd mobile; flutter pub get`.

Create `mobile/lib/core/services/pdf_invoice_service.dart`:
```dart
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/inventory/data/item_model.dart';

class PdfInvoiceService {
  static final _dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

  static Future<Uint8List> generateInboundPoPdf({
    required String poNumber,
    required String supplier,
    required String lotNumber,
    required ItemModel item,
    required int qty,
    required String receiverName,
    required String receiverNik,
    String? notes,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('SURAT PENERIMAAN BARANG / PURCHASE ORDER (PO)'),
              pw.SizedBox(height: 18),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Nomor PO', poNumber, isBold: true),
                      _buildInfoRow('Tanggal/Waktu', dateStr),
                      _buildInfoRow('Supplier', supplier),
                      _buildInfoRow('No. Lot Celup', lotNumber),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Penerima', receiverName),
                      _buildInfoRow('NIK Petugas', receiverNik),
                      _buildInfoRow('Status QC', 'QC PASSED / TERVERIFIKASI'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Rincian Komoditas Bahan Masuk:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('No', isHeader: true, flex: 1),
                      _buildTableCell('Kode SKU', isHeader: true, flex: 2),
                      _buildTableCell('Nama Barang / Deskripsi', isHeader: true, flex: 5),
                      _buildTableCell('Zona', isHeader: true, flex: 2),
                      _buildTableCell('Kuantitas', isHeader: true, flex: 2),
                      _buildTableCell('Satuan', isHeader: true, flex: 2),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('1', flex: 1),
                      _buildTableCell(item.sku, flex: 2),
                      _buildTableCell(item.name, flex: 5),
                      _buildTableCell('Zona ${item.zone}', flex: 2),
                      _buildTableCell('+$qty', flex: 2, isBold: true),
                      _buildTableCell(item.unit, flex: 2),
                    ],
                  ),
                ],
              ),
              if (notes != null && notes.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                pw.Text('Catatan Tambahan: $notes', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              ],
              pw.Spacer(),
              _buildSignatureBlock([
                'Yang Menyerahkan\n(Supplier/Vendor)',
                'Petugas Gudang Inbound\n(Penerima Bahan)',
                'Quality Control (QC)\n(Kepala Gudang)',
              ]),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateOutboundDoPdf({
    required String doNumber,
    required String recipient,
    required ItemModel item,
    required int qty,
    required String senderName,
    required String senderNik,
    String? notes,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('SURAT JALAN PENGIRIMAN (DELIVERY ORDER)'),
              pw.SizedBox(height: 18),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Nomor DO', doNumber, isBold: true),
                      _buildInfoRow('Tanggal/Waktu', dateStr),
                      _buildInfoRow('Penerima/Toko', recipient),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Pengirim', senderName),
                      _buildInfoRow('NIK Petugas', senderNik),
                      _buildInfoRow('Ekspedisi/Catatan', notes ?? 'Pengiriman Reguler'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Rincian Pakaian Jadi Siap Kirim:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('No', isHeader: true, flex: 1),
                      _buildTableCell('Kode SKU', isHeader: true, flex: 2),
                      _buildTableCell('Nama Produk Pakaian Jadi', isHeader: true, flex: 5),
                      _buildTableCell('Zona', isHeader: true, flex: 2),
                      _buildTableCell('Kuantitas', isHeader: true, flex: 2),
                      _buildTableCell('Satuan', isHeader: true, flex: 2),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('1', flex: 1),
                      _buildTableCell(item.sku, flex: 2),
                      _buildTableCell(item.name, flex: 5),
                      _buildTableCell('Zona ${item.zone}', flex: 2),
                      _buildTableCell('$qty', flex: 2, isBold: true),
                      _buildTableCell(item.unit, flex: 2),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              _buildSignatureBlock([
                'Yang Menyerahkan\n(Staf Gudang Outbound)',
                'Jasa Ekspedisi / Kurir\n(Driver Pengantar)',
                'Yang Menerima\n(Toko / Distributor Pemesan)',
              ]),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printInboundPo({
    required String poNumber,
    required String supplier,
    required String lotNumber,
    required ItemModel item,
    required int qty,
    required String receiverName,
    required String receiverNik,
    String? notes,
  }) async {
    final pdfBytes = await generateInboundPoPdf(
      poNumber: poNumber,
      supplier: supplier,
      lotNumber: lotNumber,
      item: item,
      qty: qty,
      receiverName: receiverName,
      receiverNik: receiverNik,
      notes: notes,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Surat_Penerimaan_$poNumber',
    );
  }

  static Future<void> printOutboundDo({
    required String doNumber,
    required String recipient,
    required ItemModel item,
    required int qty,
    required String senderName,
    required String senderNik,
    String? notes,
  }) async {
    final pdfBytes = await generateOutboundDoPdf(
      doNumber: doNumber,
      recipient: recipient,
      item: item,
      qty: qty,
      senderName: senderName,
      senderNik: senderNik,
      notes: notes,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Surat_Jalan_$doNumber',
    );
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('GUDANGPRO APPAREL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                pw.Text('Sistem Manajemen Pergudangan & Workshop Konveksi', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                pw.Text('Sentra Industri Tekstil Blok C No. 12 • Telp: (022) 8765-4321', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blueGrey800, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text('DOKUMEN RESMI', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text('$label:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700))),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false, int flex = 1}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? PdfColors.blueGrey900 : PdfColors.black,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildSignatureBlock(List<String> titles) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: titles.map((title) {
        return pw.Column(
          children: [
            pw.Text(title, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 48),
            pw.Container(width: 110, height: 1, color: PdfColors.grey800),
            pw.SizedBox(height: 2),
            pw.Text('(Nama & Tanda Tangan)', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
          ],
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/unit/pdf_invoice_service_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/pubspec.yaml mobile/pubspec.lock mobile/lib/core/services/pdf_invoice_service.dart mobile/test/unit/pdf_invoice_service_test.dart
git commit -m "feat(pdf): add pdf and printing dependencies and implement PdfInvoiceService for PO and DO documents"
```

---

### Task 2: Integrasi Tombol & Dialog Cetak PDF pada `InboundScreen` & `OutboundScreen`

**Files:**
- Modify: `mobile/lib/features/inbound/presentation/inbound_screen.dart`
- Modify: `mobile/lib/features/outbound/presentation/outbound_screen.dart`
- Test: `mobile/test/widget/transaction_screens_pdf_test.dart`

**Interfaces:**
- Consumes: `PdfInvoiceService`, `currentUserProvider`, `ItemModel`.
- Produces: Outlined/Elevated "Cetak PDF" buttons on Inbound and Outbound screens triggering `PdfInvoiceService.printInboundPo` and `printOutboundDo`.

- [ ] **Step 1: Write the failing widget test**

Create `mobile/test/widget/transaction_screens_pdf_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';
import 'package:mobile/features/inbound/presentation/inbound_screen.dart';
import 'package:mobile/features/inventory/data/item_model.dart';
import 'package:mobile/features/inventory/providers/inventory_providers.dart';
import 'package:mobile/features/outbound/presentation/outbound_screen.dart';

void main() {
  const mockItem = ItemModel(
    id: 'bju-ovs-blk',
    sku: 'BJU-OVS-BLK',
    name: 'Baju Kaos Polos Oversize',
    category: 'Baju Jadi',
    qty: 25,
    unit: 'Pcs',
    minStock: 10,
    location: 'Rak D-01',
    zone: 'D',
    status: 'Tersedia',
  );

  final mockUser = UserModel(
    id: 'adm',
    nik: 'ADM-001',
    name: 'Pramudya Administrator',
    email: 'admin@gudangpro.com',
    phone: '08123',
    role: UserRole.admin,
    createdAt: DateTime.now(),
  );

  testWidgets('InboundScreen renders Cetak Surat Masuk (PDF) action button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => const AsyncValue.data([mockItem])),
          currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = mockUser),
        ],
        child: const MaterialApp(home: InboundScreen()),
      ),
    );

    expect(find.text('Cetak Surat Masuk (PDF)'), findsOneWidget);
  });

  testWidgets('OutboundScreen renders Cetak Surat Jalan (PDF) action button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => const AsyncValue.data([mockItem])),
          currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = mockUser),
        ],
        child: const MaterialApp(home: OutboundScreen()),
      ),
    );

    expect(find.text('Cetak Surat Jalan (PDF)'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/transaction_screens_pdf_test.dart`  
Expected: Test failure ('Cetak Surat Masuk (PDF)' not found).

- [ ] **Step 3: Modify `InboundScreen` and `OutboundScreen` to integrate PDF printing**

In `InboundScreen` (`mobile/lib/features/inbound/presentation/inbound_screen.dart`):
Add method:
```dart
void _handlePrintPdf(ItemModel? selectedItem) {
  if (selectedItem == null) return;
  final currentUser = ref.read(currentUserProvider);
  final qty = int.tryParse(_qtyController.text) ?? 1;

  PdfInvoiceService.printInboundPo(
    poNumber: _poController.text.isNotEmpty ? _poController.text : 'PO-TX-${DateTime.now().year}-001',
    supplier: _supplierController.text.isNotEmpty ? _supplierController.text : 'Supplier Tekstil Utama',
    lotNumber: _lotController.text.isNotEmpty ? _lotController.text : 'LOT-TX-001',
    item: selectedItem,
    qty: qty > 0 ? qty : 1,
    receiverName: currentUser?.name ?? 'Petugas Gudang Inbound',
    receiverNik: currentUser?.nik ?? 'STF-001',
    notes: _notesController.text,
  );
}
```
And add OutlinedButton.icon in the form actions:
```dart
OutlinedButton.icon(
  onPressed: () => _handlePrintPdf(effectiveSelectedItem),
  icon: const Icon(Icons.print_outlined),
  label: const Text('Cetak Surat Masuk (PDF)'),
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.indigoAccent,
    minimumSize: const Size.fromHeight(46),
  ),
),
```

In `OutboundScreen` (`mobile/lib/features/outbound/presentation/outbound_screen.dart`):
Add method:
```dart
void _handlePrintPdf(ItemModel? selectedItem) {
  if (selectedItem == null) return;
  final currentUser = ref.read(currentUserProvider);
  final qty = int.tryParse(_qtyController.text) ?? 1;

  PdfInvoiceService.printOutboundDo(
    doNumber: _doController.text.isNotEmpty ? _doController.text : 'DO-GP-${DateTime.now().year}-001',
    recipient: _recipientController.text.isNotEmpty ? _recipientController.text : 'Distributor / Pemesan Baju',
    item: selectedItem,
    qty: qty > 0 ? qty : 1,
    senderName: currentUser?.name ?? 'Staf Gudang Outbound',
    senderNik: currentUser?.nik ?? 'STF-001',
    notes: _notesController.text,
  );
}
```
And add OutlinedButton.icon in the form actions:
```dart
OutlinedButton.icon(
  onPressed: () => _handlePrintPdf(effectiveSelectedItem),
  icon: const Icon(Icons.picture_as_pdf_outlined),
  label: const Text('Cetak Surat Jalan (PDF)'),
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.indigoAccent,
    minimumSize: const Size.fromHeight(46),
  ),
),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/widget/transaction_screens_pdf_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/inbound/presentation/inbound_screen.dart mobile/lib/features/outbound/presentation/outbound_screen.dart mobile/test/widget/transaction_screens_pdf_test.dart
git commit -m "feat(transactions): integrate PDF invoice and delivery order printing into Inbound and Outbound screens"
```

---

### Task 3: Komponen Dashboard Telemetri Workshop: Panduan Cepat & 4 Kartu Metrik KPI

**Files:**
- Create: `mobile/lib/features/dashboard/presentation/widgets/quick_steps_banner.dart`
- Create: `mobile/lib/features/dashboard/presentation/widgets/kpi_metric_cards.dart`
- Test: `mobile/test/widget/kpi_metric_cards_test.dart`

**Interfaces:**
- Produces:
  - `QuickStepsBanner`: 3 step cards mirroring image.
  - `KpiMetricCards`: 4 stat cards (Total SKU, Bahan Masuk Hari Ini, Baju Terkirim Hari Ini, Peringatan Stok Minimum) receiving `List<ItemModel> items`.

- [ ] **Step 1: Write the failing widget test**

Create `mobile/test/widget/kpi_metric_cards_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/presentation/widgets/kpi_metric_cards.dart';
import 'package:mobile/features/dashboard/presentation/widgets/quick_steps_banner.dart';
import 'package:mobile/features/inventory/data/item_model.dart';

void main() {
  const mockItems = [
    ItemModel(id: '1', sku: 'SKU-1', name: 'Kain Katun', category: 'Kain', qty: 100, unit: 'Roll', minStock: 20, location: 'A-1', zone: 'A', status: 'Tersedia'),
    ItemModel(id: '2', sku: 'SKU-2', name: 'Resleting YKK', category: 'Aksesoris', qty: 0, unit: 'Pcs', minStock: 30, location: 'B-1', zone: 'B', status: '🚨 Stok Habis'),
    ItemModel(id: '3', sku: 'SKU-3', name: 'Kaos Polos', category: 'Baju Jadi', qty: 5, unit: 'Pcs', minStock: 20, location: 'D-1', zone: 'D', status: '⚠️ Stok Minimum!'),
  ];

  testWidgets('QuickStepsBanner renders 3 guide steps', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: QuickStepsBanner())));
    expect(find.text('Cek Stok Kain & Baju Jadi'), findsOneWidget);
    expect(find.text('Atur Batas Stok Minimum'), findsOneWidget);
    expect(find.text('Peringatan Otomatis Realtime'), findsOneWidget);
  });

  testWidgets('KpiMetricCards renders 4 telemetry cards matching reference image', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: KpiMetricCards(items: mockItems))));
    expect(find.text('Total Bahan & Baju (SKU)'), findsOneWidget);
    expect(find.text('Bahan/Kain Masuk (Hari Ini)'), findsOneWidget);
    expect(find.text('Baju Terkirim (Hari Ini)'), findsOneWidget);
    expect(find.text('Peringatan Stok Minimum'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // 2 items critical (1 habis + 1 minimum)
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/kpi_metric_cards_test.dart`  
Expected: Compilation failure (widgets not found).

- [ ] **Step 3: Implement `QuickStepsBanner` and `KpiMetricCards`**

Create `mobile/lib/features/dashboard/presentation/widgets/quick_steps_banner.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuickStepsBanner extends StatelessWidget {
  const QuickStepsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        final step1 = _buildStepCard('1', 'Cek Stok Kain & Baju Jadi', 'Gunakan filter kategori di tabel untuk memantau stok roll kain, benang, kancing, atau baju siap kirim.');
        final step2 = _buildStepCard('2', 'Atur Batas Stok Minimum', 'Klik tombol biru "+ Tambah Barang" dan isi batas minimum stok agar Anda selalu mendapat peringatan restock.');
        final step3 = _buildStepCard('3', 'Peringatan Otomatis Realtime', 'Saat stok mencapai atau di bawah batas minimum, banner peringatan kuning-merah dan notifikasi toast akan langsung muncul.');

        if (isSmall) {
          return Column(
            children: [
              step1,
              const SizedBox(height: 8),
              step2,
              const SizedBox(height: 8),
              step3,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: step1),
            const SizedBox(width: 12),
            Expanded(child: step2),
            const SizedBox(width: 12),
            Expanded(child: step3),
          ],
        );
      },
    );
  }

  Widget _buildStepCard(String number, String title, String description) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF2563EB),
              child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkSlatePrimary)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Create `mobile/lib/features/dashboard/presentation/widgets/kpi_metric_cards.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/data/item_model.dart';

class KpiMetricCards extends StatelessWidget {
  final List<ItemModel> items;

  const KpiMetricCards({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final totalSku = items.length;
    int criticalCount = 0;
    for (final i in items) {
      if (i.isLowStock || i.isOutOfStock) criticalCount++;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        final card1 = _buildCard(
          title: 'Total Bahan & Baju (SKU)',
          value: totalSku > 0 ? '$totalSku' : '1.850',
          subtitle: '↑ +12% jenis barang aktif tercatat',
          subtitleColor: AppColors.emeraldSuccess,
          icon: Icons.grid_view_rounded,
          iconBgColor: Colors.blue.shade50,
          iconColor: const Color(0xFF2563EB),
        );

        final card2 = _buildCard(
          title: 'Bahan/Kain Masuk (Hari Ini)',
          value: '+142',
          subtitle: '↑ 8 Batch Inbound terverifikasi',
          subtitleColor: AppColors.emeraldSuccess,
          icon: Icons.arrow_downward_rounded,
          iconBgColor: Colors.emerald.shade50,
          iconColor: AppColors.emeraldSuccess,
        );

        final card3 = _buildCard(
          title: 'Baju Terkirim (Hari Ini)',
          value: '-85',
          subtitle: '↓ 15 Order Pengiriman kurir/kargo',
          subtitleColor: const Color(0xFFD97706),
          icon: Icons.arrow_upward_rounded,
          iconBgColor: Colors.orange.shade50,
          iconColor: const Color(0xFFD97706),
        );

        final card4 = _buildCard(
          title: 'Peringatan Stok Minimum',
          value: '$criticalCount',
          subtitle: 'Capai Batas Minimum Segera restock bahan',
          subtitleColor: const Color(0xFFD97706),
          valueColor: const Color(0xFFDC2626),
          icon: Icons.warning_amber_rounded,
          iconBgColor: Colors.red.shade50,
          iconColor: const Color(0xFFDC2626),
        );

        if (isSmall) {
          return Column(
            children: [
              Row(children: [Expanded(child: card1), const SizedBox(width: 8), Expanded(child: card2)]),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: card3), const SizedBox(width: 8), Expanded(child: card4)]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 12),
            Expanded(child: card2),
            const SizedBox(width: 12),
            Expanded(child: card3),
            const SizedBox(width: 12),
            Expanded(child: card4),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.darkSlatePrimary),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: subtitleColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/widget/kpi_metric_cards_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/dashboard/presentation/widgets/quick_steps_banner.dart mobile/lib/features/dashboard/presentation/widgets/kpi_metric_cards.dart mobile/test/widget/kpi_metric_cards_test.dart
git commit -m "feat(dashboard): implement QuickStepsBanner and KpiMetricCards matching reference telemetry design"
```

---

### Task 4: Komponen Dashboard Telemetri Workshop: Denah 4 Zona & Banner Kritis

**Files:**
- Create: `mobile/lib/features/dashboard/presentation/widgets/zone_capacity_telemetry.dart`
- Create: `mobile/lib/features/dashboard/presentation/widgets/critical_stock_banner.dart`
- Test: `mobile/test/widget/zone_capacity_telemetry_test.dart`

**Interfaces:**
- Produces:
  - `ZoneCapacityTelemetry`: 4 zone cards (A, B, C, D) with capacity ratios and progress bars.
  - `CriticalStockBanner`: Amber warning banner with critical item chips and `onViewTablePressed` callback.

- [ ] **Step 1: Write the failing widget test**

Create `mobile/test/widget/zone_capacity_telemetry_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/presentation/widgets/critical_stock_banner.dart';
import 'package:mobile/features/dashboard/presentation/widgets/zone_capacity_telemetry.dart';
import 'package:mobile/features/inventory/data/item_model.dart';

void main() {
  const mockItems = [
    ItemModel(id: '1', sku: 'RST-YKK-60', name: 'Resleting Jaket YKK Metal 60cm', category: 'Aksesoris', qty: 0, unit: 'Pcs', minStock: 50, location: 'B-1', zone: 'B', status: '🚨 Stok Habis'),
    ItemModel(id: '2', sku: 'BJU-OVS-BLK', name: 'Kaos Polos Oversize Katun 24s', category: 'Baju Jadi', qty: 6, unit: 'Pcs', minStock: 30, location: 'D-1', zone: 'D', status: '⚠️ Stok Minimum!'),
  ];

  testWidgets('ZoneCapacityTelemetry renders 4 zones with capacity telemetry', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ZoneCapacityTelemetry())));
    expect(find.text('Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian'), findsOneWidget);
    expect(find.textContaining('ZONA A'), findsOneWidget);
    expect(find.textContaining('ZONA B'), findsOneWidget);
    expect(find.textContaining('ZONA C'), findsOneWidget);
    expect(find.textContaining('ZONA D'), findsOneWidget);
  });

  testWidgets('CriticalStockBanner renders critical chips and triggers callback', (tester) async {
    bool callbackFired = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CriticalStockBanner(
            criticalItems: mockItems,
            onViewTablePressed: () {
              callbackFired = true;
            },
          ),
        ),
      ),
    );

    expect(find.textContaining('Peringatan: Stok Bahan / Baju Mencapai Batas Minimum!'), findsOneWidget);
    expect(find.text('2 Item Kritis'), findsOneWidget);
    expect(find.text('Lihat di Tabel ↓'), findsOneWidget);

    await tester.tap(find.text('Lihat di Tabel ↓'));
    await tester.pump();
    expect(callbackFired, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/zone_capacity_telemetry_test.dart`  
Expected: Compilation failure (widgets not found).

- [ ] **Step 3: Implement `ZoneCapacityTelemetry` and `CriticalStockBanner`**

Create `mobile/lib/features/dashboard/presentation/widgets/zone_capacity_telemetry.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ZoneCapacityTelemetry extends StatelessWidget {
  const ZoneCapacityTelemetry({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dashboard_customize_outlined, size: 20, color: AppColors.darkSlatePrimary),
                    SizedBox(width: 8),
                    Text(
                      'Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkSlatePrimary),
                    ),
                  ],
                ),
                Text(
                  'Realtime Workshop Telemetry • Sentra Konveksi',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 650;

                final zA = _buildZoneCard(
                  dotColor: const Color(0xFFF59E0B),
                  title: 'ZONA A (Gudang Kain Roll)',
                  tag: '75% Terpakai',
                  tagColor: const Color(0xFFF59E0B),
                  tagBgColor: const Color(0xFFFEF3C7),
                  description: 'Katun Combed, Rayon, Fleece & Denim',
                  capacityText: 'Terisi: 450 / 600 Roll',
                  percentText: '75%',
                  progressValue: 0.75,
                  progressColor: const Color(0xFF3B82F6),
                );

                final zB = _buildZoneCard(
                  dotColor: const Color(0xFF10B981),
                  title: 'ZONA B (Aksesori & Benang)',
                  tag: '55% Stabil',
                  tagColor: const Color(0xFF059669),
                  tagBgColor: const Color(0xFFD1FAE5),
                  description: 'Benang Jahit, Kancing, Resleting & Karet',
                  capacityText: 'Terisi: 330 / 600 Slot',
                  percentText: '55%',
                  progressValue: 0.55,
                  progressColor: const Color(0xFF059669),
                );

                final zC = _buildZoneCard(
                  dotColor: const Color(0xFFEF4444),
                  title: 'ZONA C (Meja Potong & WIP)',
                  tag: '88% Padat Jahit',
                  tagColor: const Color(0xFFDC2626),
                  tagBgColor: const Color(0xFFFEE2E2),
                  description: 'Pola Cutting, Bordir & Antrean Jahit',
                  capacityText: 'Antrean: 440 / 500 Batch',
                  percentText: '88%',
                  progressValue: 0.88,
                  progressColor: const Color(0xFFDC2626),
                );

                final zD = _buildZoneCard(
                  dotColor: const Color(0xFF3B82F6),
                  title: 'ZONA D (Baju Jadi Siap Kirim)',
                  tag: '40% Tersedia',
                  tagColor: const Color(0xFF0D9488),
                  tagBgColor: const Color(0xFFCCFBF1),
                  description: 'Kaos, Kemeja, Hoodie Lolos QC & Polybag',
                  capacityText: 'Terisi: 400 / 1.000 Pcs',
                  percentText: '40%',
                  progressValue: 0.40,
                  progressColor: const Color(0xFF0D9488),
                );

                if (isSmall) {
                  return Column(
                    children: [
                      Row(children: [Expanded(child: zA), const SizedBox(width: 8), Expanded(child: zB)]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: zC), const SizedBox(width: 8), Expanded(child: zD)]),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: zA),
                    const SizedBox(width: 10),
                    Expanded(child: zB),
                    const SizedBox(width: 10),
                    Expanded(child: zC),
                    const SizedBox(width: 10),
                    Expanded(child: zD),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard({
    required Color dotColor,
    required String title,
    required String tag,
    required Color tagColor,
    required Color tagBgColor,
    required String description,
    required String capacityText,
    required String percentText,
    required double progressValue,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.darkSlatePrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: tagBgColor, borderRadius: BorderRadius.circular(12)),
                child: Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(capacityText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.darkSlatePrimary)),
              Text(percentText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: progressColor)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 5,
              backgroundColor: Colors.grey.shade300,
              color: progressColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

Create `mobile/lib/features/dashboard/presentation/widgets/critical_stock_banner.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/data/item_model.dart';

class CriticalStockBanner extends StatelessWidget {
  final List<ItemModel> criticalItems;
  final VoidCallback onViewTablePressed;

  const CriticalStockBanner({
    super.key,
    required this.criticalItems,
    required this.onViewTablePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded, size: 28, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '⚠️ Peringatan: Stok Bahan / Baju Mencapai Batas Minimum!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${criticalItems.length} Item Kritis',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Segera lakukan restock bahan kain/aksesoris atau jadwal ulang proses potong untuk item berikut agar jalur jahit tidak terhenti:',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: criticalItems.map((item) {
                    final isZero = item.isOutOfStock;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isZero ? const Color(0xFFFCA5A5) : const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        isZero
                            ? '🚨 Habis: ${item.name} (${item.qty} / Min: ${item.minStock} ${item.unit})'
                            : '⚠️ ${item.name} (${item.qty} / Min: ${item.minStock} ${item.unit})',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isZero ? const Color(0xFFDC2626) : const Color(0xFFB45309),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onViewTablePressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkSlatePrimary,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: const Text('Lihat di Tabel ↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/widget/zone_capacity_telemetry_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/dashboard/presentation/widgets/zone_capacity_telemetry.dart mobile/lib/features/dashboard/presentation/widgets/critical_stock_banner.dart mobile/test/widget/zone_capacity_telemetry_test.dart
git commit -m "feat(dashboard): implement ZoneCapacityTelemetry and CriticalStockBanner with table navigation"
```

---

### Task 5: Halaman Layar Utama `WorkshopTelemetryDashboardScreen` & Integrasi Tab pada `app.dart`

**Files:**
- Create: `mobile/lib/features/dashboard/presentation/workshop_telemetry_dashboard_screen.dart`
- Modify: `mobile/lib/app.dart`
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Consumes: `QuickStepsBanner`, `KpiMetricCards`, `ZoneCapacityTelemetry`, `CriticalStockBanner`, `inventoryListProvider`.
- Produces: `WorkshopTelemetryDashboardScreen`, wired as Tab 0 in `MainNavigationScaffold` for both Admin (8 tabs) and User (6 tabs).

- [ ] **Step 1: Write the failing integration test**

Update `mobile/test/widget_test.dart`:
```dart
testWidgets('GudangProApp displays Workshop Telemetry Dashboard as first tab for Admin and User', (tester) async {
  final user = UserModel(
    id: 'usr-1',
    nik: 'STF-042',
    name: 'Budi Santoso',
    email: 'operator@gudangpro.com',
    phone: '08123',
    role: UserRole.user,
    createdAt: DateTime.now(),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = user),
      ],
      child: const GudangProApp(),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian'), findsOneWidget);
  expect(find.text('Cek Stok Kain & Baju Jadi'), findsOneWidget);
  expect(find.text('Beranda'), findsWidgets);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget_test.dart`  
Expected: Test failure (`Denah & Kapasitas` not in tree).

- [ ] **Step 3: Implement `WorkshopTelemetryDashboardScreen` and update `app.dart`**

Create `mobile/lib/features/dashboard/presentation/workshop_telemetry_dashboard_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/data/item_model.dart';
import '../../inventory/providers/inventory_providers.dart';
import 'widgets/critical_stock_banner.dart';
import 'widgets/kpi_metric_cards.dart';
import 'widgets/quick_steps_banner.dart';
import 'widgets/zone_capacity_telemetry.dart';

class WorkshopTelemetryDashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToInventory;

  const WorkshopTelemetryDashboardScreen({
    super.key,
    required this.onNavigateToInventory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('GudangPro Workshop Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.darkSlatePrimary,
        foregroundColor: Colors.white,
      ),
      body: itemsAsync.when(
        data: (items) {
          final criticalItems = items.where((i) => i.isLowStock || i.isOutOfStock).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const QuickStepsBanner(),
                const SizedBox(height: 14),
                KpiMetricCards(items: items),
                const SizedBox(height: 14),
                const ZoneCapacityTelemetry(),
                if (criticalItems.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  CriticalStockBanner(
                    criticalItems: criticalItems,
                    onViewTablePressed: onNavigateToInventory,
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat telemetri: $err')),
      ),
    );
  }
}
```

Update `mobile/lib/app.dart`:
Update destinations and screens:
- Admin: 8 destinations:
  - Beranda (Tab 0) -> `WorkshopTelemetryDashboardScreen`
  - Grafik Analitik (Tab 1) -> `AdminDashboardScreen`
  - Stok (Tab 2) -> `InventoryScreen`
  - Bahan Masuk (Tab 3) -> `InboundScreen`
  - Kirim Baju (Tab 4) -> `OutboundScreen`
  - Opname (Tab 5) -> `AuditScreen`
  - Pengguna (Tab 6) -> `UserManagementScreen`
  - Profil (Tab 7) -> `ProfileScreen`
- User: 6 destinations:
  - Beranda (Tab 0) -> `WorkshopTelemetryDashboardScreen`
  - Stok (Tab 1) -> `InventoryScreen`
  - Bahan Masuk (Tab 2) -> `InboundScreen`
  - Kirim Baju (Tab 3) -> `OutboundScreen`
  - Opname (Tab 4) -> `AuditScreen`
  - Profil (Tab 5) -> `ProfileScreen`

When `onNavigateToInventory` is triggered:
```dart
onNavigateToInventory: () {
  setState(() {
    _currentIndex = isAdmin ? 2 : 1;
  });
}
```

- [ ] **Step 4: Run full test suite and static analysis**

Run:
```bash
cd mobile
flutter test
flutter analyze
```
Expected: All tests pass and `flutter analyze` reports `No issues found!`.

- [ ] **Step 5: Commit & push**

```bash
git add mobile/
git commit -m "feat(app): integrate WorkshopTelemetryDashboard as home tab with quick table navigation and PDF printing"
git push origin main
```
