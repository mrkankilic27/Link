import 'dart:io';

import 'package:flutter/material.dart';

import 'feedback_screen.dart'; // Geri bildirim ekranını içeri aktarıyoruz

class DetailScreen extends StatelessWidget {
  final String baslik;
  final File kiyafet;
  final File fis;
  final String not;

  const DetailScreen({
    super.key,
    required this.baslik,
    required this.kiyafet,
    required this.fis,
    required this.not,
  });

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
              child: Image.file(
                kiyafet,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Fiş Fotoğrafı",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                fis,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            if (not.isNotEmpty) ...[
              const Text(
                "OCR Fiş Özeti",
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
          ],
        ),
      ),
    );
  }
}
