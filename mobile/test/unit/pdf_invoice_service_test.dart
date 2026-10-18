import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/pdf_invoice_service.dart';
import 'package:mobile/features/inventory/data/item_model.dart';

void main() {
  group('PdfInvoiceService Unit Tests', () {
    final mockItem = ItemModel(
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
