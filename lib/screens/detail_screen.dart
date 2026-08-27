import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'feedback_screen.dart'; // Geri bildirim ekranını içeri aktarıyoruz
import '../services/pdf_export_service.dart';

class DetailScreen extends StatelessWidget {
  final String baslik;
  final Object? kiyafet;
  final Object? fis;
  final String not;
  final Map<String, dynamic> receiptData;

  const DetailScreen({
    super.key,
    required this.baslik,
    required this.kiyafet,
    required this.fis,
    required this.not,
    this.receiptData = const {},
  });

  Widget _imageWidget(Object? image) {
    if (image is File) {
      return Image.file(
        image,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageErrorPlaceholder(),
      );
    }

    if (image is XFile) {
      return Image.network(
        image.path,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageErrorPlaceholder(),
      );
    }

    if (image is String && image.trim().isNotEmpty) {
      final uri = Uri.tryParse(image);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return Image.network(
          image,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _ImageErrorPlaceholder(),
        );
      }

      return Image.file(
        File(image),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageErrorPlaceholder(),
      );
    }

    return const _ImageErrorPlaceholder();
  }

  Widget _receiptFields(BuildContext context) {
    final labels = <String, String>{
      'total': 'Toplam',
      'subtotal': 'Ara toplam',
      'tax': 'KDV / Vergi',
      'date': 'Tarih',
      'time': 'Saat',
      'receiptNumber': 'Fiş no',
    };
    final fields = labels.entries
        .where((entry) => receiptData[entry.key] != null)
        .toList();
    final items =
        (receiptData['items'] as List?)
            ?.whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList() ??
        const <Map<String, dynamic>>[];
    if (fields.isEmpty && items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Algılanan Fiş Bilgileri',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ...fields.map(
                (field) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(field.value),
                  trailing: Text('${receiptData[field.key]}'),
                ),
              ),
              if (items.isNotEmpty) ...[
                const Divider(),
                ...items.map(
                  (item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${item['name']}'),
                    trailing: Text('${item['amount']}'),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _silmeOnayiAl(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Eşleşmeyi Sil"),
          content: const Text(
            "Bu kıyafet ve fiş eşleşmesini silmek istediğinize emin misiniz?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, 'sil');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(baslik),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // --- GERİ BİLDİRİM BUTONU ---
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'PDF olarak paylaş',
            onPressed: () => PdfExportService.exportReceipt(
              title: baslik,
              rawText: not,
              receiptData: receiptData,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.feedback_outlined, color: Colors.teal),
            tooltip: "Geri Bildirim Ver",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
          // --- SİLME BUTONU ---
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _silmeOnayiAl(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                baslik,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Kıyafet Fotoğrafı",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _imageWidget(kiyafet),
            ),
            const SizedBox(height: 20),
            const Text(
              "Fiş Fotoğrafı",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _imageWidget(fis),
            ),
            const SizedBox(height: 20),
            if (not.isNotEmpty) ...[
              Text(
                'ocrSummary'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  not,
                  style: const TextStyle(fontSize: 14, color: Colors.teal),
                ),
              ),
            ],
            _receiptFields(context),
          ],
        ),
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 250,
      child: Center(child: Icon(Icons.broken_image)),
    );
  }
}
