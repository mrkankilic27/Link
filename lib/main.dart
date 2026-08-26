import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/new_link_screen.dart';
import 'screens/detail_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
        Locale('de', 'DE'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr', 'TR'),
      child: const LinkApp(),
    ),
  );
}

class LinkApp extends StatelessWidget {
  const LinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'appTitle'.tr(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  List<Map<String, dynamic>> _linkListesi = [];
  List<Map<String, dynamic>> _filtrelenmisListe = [];
  bool _yukleniyor = true;
  bool _aramaAcikMi = false;
  final TextEditingController _aramaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verileriYukle();
    _aramaController.addListener(_aramaFiltrele);
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  void _aramaFiltrele() {
    final aramaMetni = _aramaController.text.toLowerCase();
    setState(() {
      if (aramaMetni.isEmpty) {
        _filtrelenmisListe = _linkListesi;
      } else {
        _filtrelenmisListe = _linkListesi.where((item) {
          final baslik = item['baslik'].toString().toLowerCase();
          final notVerisi = item['not'].toString().toLowerCase();
          return baslik.contains(aramaMetni) || notVerisi.contains(aramaMetni);
        }).toList();
      }
    });
  }

  void _ismiGuncelleDialog(int index, Map<String, dynamic> mevcutKayit) {
    TextEditingController controller = TextEditingController(
      text: mevcutKayit['baslik'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('editTitle'.tr()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'newNameLabel'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancelButton'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                setState(() {
                  mevcutKayit['baslik'] = controller.text.trim().isEmpty
                      ? "İsimsiz Eşleşme"
                      : controller.text.trim();
                  _filtrelenmisListe = _linkListesi;
                });
                await _hafizayiGuncelle();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kayıt ismi başarıyla güncellendi!"),
                    ),
                  );
                }
              },
              child: Text('saveButton'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _geriBildirimDialogGoster() {
    final TextEditingController mesajController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.feedback, color: Colors.teal),
              const SizedBox(width: 8),
              Text('feedbackTitle'.tr()),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'feedbackDesc'.tr(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mesajController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'feedbackHint'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancelButton'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                String mesaj = mesajController.text.trim();
                if (mesaj.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lütfen boş bir mesaj göndermeyin."),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('feedbackSuccess'.tr())));
              },
              child: Text('feedbackSend'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verileriYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kayitliVeri = prefs.getString('linkler');

      if (kayitliVeri != null) {
        List<dynamic> cozulmusVeri = jsonDecode(kayitliVeri);
        setState(() {
          _linkListesi = cozulmusVeri.map((item) {
            return {
              'baslik': item['baslik'] ?? 'İsimsiz Eşleşme',
              'kiyafet': File(item['kiyafet']),
              'fis': File(item['fis']),
              'not': item['not'] ?? '',
            };
          }).toList();
          _filtrelenmisListe = _linkListesi;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Veriler yüklenirken hata oluştu: $e")),
        );
      }
    } finally {
      setState(() {
        _yukleniyor = false;
      });
    }
  }

  Future<void> _hafizayiGuncelle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kaydedilecekListe = _linkListesi.map((item) {
        return {
          'baslik': item['baslik'],
          'kiyafet': (item['kiyafet'] as File).path,
          'fis': (item['fis'] as File).path,
          'not': item['not'],
        };
      }).toList();
      await prefs.setString('linkler', jsonEncode(kaydedilecekListe));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Kayıt güncellenemedi: $e")));
      }
    }
  }

  Future<void> _yeniLinkEkleVeKaydet(
    String baslik,
    File geciciKiyafet,
    File geciciFis,
    String fisNotu,
  ) async {
    try {
      final dizin = await getApplicationDocumentsDirectory();
      final zamanDamgasi = DateTime.now().millisecondsSinceEpoch.toString();

      final kaliciKiyafetYolu = '${dizin.path}/kiyafet_$zamanDamgasi.jpg';
      final kaliciFisYolu = '${dizin.path}/fis_$zamanDamgasi.jpg';

      final kaliciKiyafet = await geciciKiyafet.copy(kaliciKiyafetYolu);
      final kaliciFis = await geciciFis.copy(kaliciFisYolu);

      setState(() {
        _linkListesi.add({
          'baslik': baslik,
          'kiyafet': kaliciKiyafet,
          'fis': kaliciFis,
          'not': fisNotu,
        });
        _filtrelenmisListe = _linkListesi;
      });

      await _hafizayiGuncelle();

      bool sunucuyaGittiMi = await ApiService.sunucuyaGonder(
        kiyafet: kaliciKiyafet,
        fis: kaliciFis,
        not: fisNotu,
      );

      if (mounted) {
        if (sunucuyaGittiMi) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Eşleşme sunucuya başarıyla senkronize edildi."),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sunucuya ulaşılamadı, veri yerelde saklandı."),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Yeni link eklenirken hata oluştu: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _aramaAcikMi
            ? TextField(
                controller: _aramaController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "İsim veya OCR metninde ara...",
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              )
            : Text('appTitle'.tr()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_aramaAcikMi ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _aramaAcikMi = !_aramaAcikMi;
                if (!_aramaAcikMi) {
                  _aramaController.clear();
                  _filtrelenmisListe = _linkListesi;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.support_agent),
            tooltip: "Geri Bildirim Ver",
            onPressed: _geriBildirimDialogGoster,
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale yeniDil) {
              context.setLocale(yeniDil);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem(
                value: Locale('tr', 'TR'),
                child: Text('Türkçe'),
              ),
              const PopupMenuItem(
                value: Locale('en', 'US'),
                child: Text('English'),
              ),
              const PopupMenuItem(
                value: Locale('de', 'DE'),
                child: Text('Deutsch'),
              ),
            ],
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _filtrelenmisListe.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'emptyGalleryText'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtrelenmisListe.length,
              itemBuilder: (context, index) {
                final item = _filtrelenmisListe[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final sonuc = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            baslik: item['baslik'] as String,
                            kiyafet: item['kiyafet'] as File,
                            fis: item['fis'] as File,
                            not: item['not'] as String,
                          ),
                        ),
                      );

                      if (sonuc == 'sil') {
                        setState(() {
                          _linkListesi.removeWhere(
                            (element) => element == item,
                          );
                          _filtrelenmisListe = _linkListesi;
                        });
                        await _hafizayiGuncelle();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['baslik'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                tooltip: "İsmi Düzenle",
                                onPressed: () =>
                                    _ismiGuncelleDialog(index, item),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    item['kiyafet'] as File,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Icon(
                                  Icons.link,
                                  size: 32,
                                  color: Colors.teal,
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    item['fis'] as File,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item['not'].toString().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${'ocrSummary'.tr()}: ${item['not']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final sonuc = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewLinkScreen()),
          );

          if (sonuc != null) {
            final gelenVeri = sonuc as Map<String, dynamic>;
            await _yeniLinkEkleVeKaydet(
              gelenVeri['baslik'] as String,
              gelenVeri['kiyafet'] as File,
              gelenVeri['fis'] as File,
              gelenVeri['not'] as String,
            );
          }
        },
        icon: const Icon(Icons.add_link),
        label: Text('newHookButton'.tr()),
      ),
    );
  }
}
