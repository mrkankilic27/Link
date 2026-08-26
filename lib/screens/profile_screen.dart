import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/theme_service.dart'; // <-- Tema Servisi Eklendi

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'Misafir Kullanıcı';

    // AnimatedBuilder ile ThemeManager dinleniyor, böylece switch anlık güncelleniyor
    return AnimatedBuilder(
      animation: ThemeManager.instance,
      builder: (context, _) {
        final isDarkMode = ThemeManager.instance.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: Text('profileTitle'.tr()),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // --- DİL SEÇİMİ ---
                      ListTile(
                        leading: const Icon(Icons.language, color: Colors.teal),
                        title: Text('changeLanguage'.tr()),
                        trailing: DropdownButton<Locale>(
                          value: context.locale,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: Locale('tr', 'TR'),
                              child: Text('Türkçe'),
                            ),
                            DropdownMenuItem(
                              value: Locale('en', 'US'),
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: Locale('de', 'DE'),
                              child: Text('Deutsch'),
                            ),
                          ],
                          onChanged: (Locale? yeniDil) {
                            if (yeniDil != null) {
                              context.setLocale(yeniDil);
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      // --- MANUEL KOYU MOD SWITCH'İ ---
                      SwitchListTile(
                        secondary: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Colors.teal,
                        ),
                        title: Text('darkMode'.tr()),
                        value: isDarkMode,
                        onChanged: (bool value) {
                          ThemeManager.instance.toggleTheme(value);
                        },
                      ),
                      const Divider(height: 1),
                      // --- ÇIKIŞ YAP ---
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          'logoutTitle'.tr(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          _cikisYapmaOnayiGoster(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _cikisYapmaOnayiGoster(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('logoutTitle'.tr()),
          content: Text('logoutMessage'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancelButton'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text('logoutTitle'.tr()),
            ),
          ],
        );
      },
    );
  }
}
