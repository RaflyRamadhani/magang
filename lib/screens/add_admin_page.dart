import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  String email = '', password = '', name = '';
  bool isLoading = false;

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Background Gradasi
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8EAF6), Color(0xFF7986CB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 📄 Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 48,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Tambah Admin Baru",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 👤 Nama
                      TextField(
                        decoration: _inputStyle("Nama", Icons.person),
                        onChanged: (val) => name = val,
                      ),
                      const SizedBox(height: 16),

                      // 📧 Email
                      TextField(
                        decoration: _inputStyle("Email", Icons.email),
                        onChanged: (val) => email = val,
                      ),
                      const SizedBox(height: 16),

                      // 🔒 Password
                      TextField(
                        obscureText: true,
                        decoration: _inputStyle("Password", Icons.lock),
                        onChanged: (val) => password = val,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Menyimpan...",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )
                              : const Text(
                                  "Simpan Admin",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),

                          onPressed: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  try {
                                    var result = await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                          email: email,
                                          password: password,
                                        );

                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(result.user!.uid)
                                        .set({
                                          'uid': result.user!.uid,
                                          'name': name,
                                          'email': email,
                                          'role': 'admin',
                                          'status': 'approved',
                                        });

                                    if (!mounted) return;
                                    _showAlert(
                                      "Berhasil",
                                      "Admin berhasil ditambahkan.",
                                    );
                                    Navigator.pop(context);
                                  } catch (e) {
                                    _showAlert(
                                      "Gagal",
                                      e.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    );
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
