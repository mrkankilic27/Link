import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/ocr_service.dart';
import '../services/image_service.dart';

class NewLinkScreen extends StatefulWidget {
  const NewLinkScreen({super.key});

  @override
  State<NewLinkScreen> createState() => _NewLinkScreenState();
}

class _NewLinkScreenState extends State<NewLinkScreen> {
  File? _kiyafetResmi;
  File? _fisResmi;
  String _fisMetni = '';
  bool _taraniyor = false;

  final TextEditingController _baslikController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _baslikController.dispose();
    super.dispose();
  }

  void _fotografKaynagiSec(bool isKiyafet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: Text('cameraOption'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _resimAl(isKiyafet, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.teal),
                title: Text('galleryOption'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _resimAl(isKiyafet, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resimAl(bool isKiyafet, ImageSource source) async {
    try {
      final XFile? foto = await _picker.pickImage(source: source);
      if (foto != null) {
        File sikistirilmisFoto = await ImageService.fotografSikistir(
          File(foto.path),
        );

        setState(() {
          if (isKiyafet) {
            _kiyafetResmi = sikistirilmisFoto;
          } else {
            _fisResmi = sikistirilmisFoto;
            _taraniyor = true;
          }
        });

        if (!isKiyafet) {
          String okunanYazi = await OcrService.fisiMetneDonustur(_fisResmi!);
          setState(() {
            _fisMetni = okunanYazi;
            _taraniyor = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _taraniyor = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fotoğraf seçilirken bir hata oluştu: $e")),
        );
      }
    }
  }

  void _linkleVeGeriDon() {
    if (_kiyafetResmi == null || _fisResmi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen hem kıyafet hem de fiş fotoğrafı ekleyin!"),
        ),
      );
      return;
    }

    String baslik = _baslikController.text.trim();
    if (baslik.isEmpty) {
      baslik = "İsimsiz Eşleşme";
    }

    Navigator.pop(context, {
      'baslik': baslik,
      'kiyafet': _kiyafetResmi,
      'fis': _fisResmi,
      'not': _fisMetni,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('newHookButton'.tr()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _baslikController,
              decoration: InputDecoration(
                labelText: 'newNameLabel'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _fotografKaynagiSec(true),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: _kiyafetResmi != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _kiyafetResmi!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.checkroom,
                              size: 45,
                              color: Colors.teal,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'clothesPhoto'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _fotografKaynagiSec(false),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: _taraniyor
                      ? const CircularProgressIndicator()
                      : _fisResmi != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _fisResmi!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              size: 45,
                              color: Colors.teal,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'receiptPhoto'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_fisMetni.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${'ocrSummary'.tr()}: $_fisMetni",
                  style: const TextStyle(fontSize: 14, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _linkleVeGeriDon,
                icon: const Icon(Icons.link),
                label: Text(
                  'linkItButton'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
