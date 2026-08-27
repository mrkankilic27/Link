import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/local_storage_service.dart';
import '../services/theme_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  bool _kayitOlmaModu = false;
  bool _yukleniyor = false;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  // --- MIGRATION (YEREL VERİYİ BULUTA TAŞIMA) FONKSİYONU ---
  Future<void> _migrateGuestDataIfNeeded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      List<Map<String, dynamic>> guestHooks =
          await LocalStorageService.getGuestHooks();

      if (guestHooks.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final userHooksCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('hooks');

        for (var hook in guestHooks) {
          final docRef = userHooksCollection.doc();
          batch.set(docRef, {
            ...hook,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
        await LocalStorageService.clearGuestHooks();
      }
    } catch (e) {
      debugPrint("Migration Hatası: $e");
    }
  }

  Future<void> _girisVeyaKayitOl() async {
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();

    if (email.isEmpty || sifre.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('fillFields'.tr())));
      return;
    }

    setState(() {
      _yukleniyor = true;
    });

    try {
      if (_kayitOlmaModu) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: sifre,
        );
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('registerSuccess'.tr())));
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: sifre,
        );
      }

      await _migrateGuestDataIfNeeded();
    } on FirebaseAuthException catch (e) {
      String mesaj = 'errorGeneric'.tr();
      if (e.code == 'user-not-found') {
        mesaj = 'errorUserNotFound'.tr();
      } else if (e.code == 'wrong-password') {
        mesaj = 'errorWrongPassword'.tr();
      } else if (e.code == 'email-already-in-use') {
        mesaj = 'errorEmailInUse'.tr();
      } else if (e.code == 'weak-password') {
        mesaj = 'errorWeakPassword'.tr();
      } else {
        mesaj = e.message ?? mesaj;
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mesaj)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _yukleniyor = false;
        });
      }
    }
  }

  Future<void> _googleIleGiris() async {
    setState(() => _yukleniyor = true);
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      await _migrateGuestDataIfNeeded();
    } catch (e) {
      debugPrint("Google Giriş Hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google ile giriş başarısız: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _misafirGiris() async {
    setState(() => _yukleniyor = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Misafir giriş hatası: $e")));
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = ThemeManager.instance.isDarkMode;

    final String orTextStr = lang == 'tr'
        ? 'VEYA'
        : (lang == 'de' ? 'ODER' : 'OR');
    final String googleBtnStr = lang == 'tr'
        ? 'Google ile Devam Et'
        : (lang == 'de' ? 'Mit Google fortfahren' : 'Continue with Google');
    final String guestBtnStr = lang == 'tr'
        ? 'Misafir Olarak Devam Et'
        : (lang == 'de' ? 'Als Gast fortfahren' : 'Continue as Guest');

    return Scaffold(
      appBar: AppBar(
        title: Text(_kayitOlmaModu ? 'registerTitle'.tr() : 'loginTitle'.tr()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: isDarkMode ? 'Açık temaya geç' : 'Koyu temaya geç',
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ThemeManager.instance.toggleTheme(!isDarkMode);
            },
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale yeniDil) {
              context.setLocale(yeniDil);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Locale('tr', 'TR'),
                child: Text("Türkçe"),
              ),
              const PopupMenuItem(
                value: Locale('en', 'US'),
                child: Text("English"),
              ),
              const PopupMenuItem(
                value: Locale('de', 'DE'),
                child: Text("Deutsch"),
              ),
            ],
          ),
        ],
      ),
      body: ColoredBox(
        color: colorScheme.surface,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_person_outlined,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  _kayitOlmaModu ? 'createAccount'.tr() : 'welcomeMessage'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'emailLabel'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _sifreController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'passwordLabel'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _yukleniyor ? null : _girisVeyaKayitOl,
                    child: _yukleniyor
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _kayitOlmaModu
                                ? 'registerTitle'.tr()
                                : 'loginTitle'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        orTextStr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: colorScheme.primary),
                    ),
                    onPressed: _yukleniyor ? null : _googleIleGiris,
                    icon: Icon(
                      Icons.g_mobiledata,
                      size: 30,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      googleBtnStr,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: TextButton.icon(
                    onPressed: _yukleniyor ? null : _misafirGiris,
                    icon: Icon(
                      Icons.person_outline,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      guestBtnStr,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _kayitOlmaModu = !_kayitOlmaModu;
                    });
                  },
                  child: Text(
                    _kayitOlmaModu ? 'hasAccount'.tr() : 'noAccount'.tr(),
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
