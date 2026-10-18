import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/inventory/data/item_model.dart';

class PdfInvoiceService {
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
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

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
              pw.Text(
                'Rincian Komoditas Bahan Masuk:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
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
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

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
              pw.Text(
                'Rincian Pakaian Jadi Siap Kirim:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
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
              if (notes != null && notes.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                pw.Text('Catatan Tambahan: $notes', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              ],
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
                pw.Text(
                  'GUDANGPRO APPAREL',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.Text(
                  'Sistem Manajemen Pergudangan & Workshop Konveksi',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.Text(
                  'Sentra Industri Tekstil Blok C No. 12 | Telp: (022) 8765-4321',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blueGrey800, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'DOKUMEN RESMI',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    int flex = 1,
  }) {
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
            pw.Text(
              '(Nama & Tanda Tangan)',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ],
        );
      }).toList(),
    );
  }
}
