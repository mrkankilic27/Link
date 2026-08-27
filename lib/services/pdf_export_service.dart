import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  static Future<void> exportReceipt({
    required String title,
    required String rawText,
    required Map<String, dynamic> receiptData,
  }) async {
    final document = pw.Document();
    final rows = <pw.Widget>[
      pw.Text(
        title,
        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 16),
    ];
    const labels = {
      'total': 'Toplam',
      'subtotal': 'Ara toplam',
      'tax': 'KDV / Vergi',
      'date': 'Tarih',
      'time': 'Saat',
      'receiptNumber': 'Fiş no',
    };
    for (final entry in labels.entries) {
      final value = receiptData[entry.key];
      if (value != null) rows.add(pw.Text('${entry.value}: $value'));
    }
    final items = (receiptData['items'] as List?)?.whereType<Map>() ?? const [];
    if (items.isNotEmpty) {
      rows.add(pw.SizedBox(height: 12));
      rows.add(
        pw.Text('Ürünler', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );
      for (final item in items) {
        rows.add(pw.Text('${item['name']}: ${item['amount']}'));
      }
    }
    rows.add(pw.SizedBox(height: 16));
    rows.add(pw.Text('OCR metni'));
    rows.add(pw.Text(rawText));
    document.addPage(
      pw.MultiPage(
        build: (_) => rows,
      ),
    );
    await Printing.sharePdf(
      bytes: await document.save(),
      filename: 'link_receipt.pdf',
    );
  }
}
