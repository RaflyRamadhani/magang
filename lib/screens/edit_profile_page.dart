import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instansiController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = user?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _instansiController.text = data['instansi'] ?? '';
        _emailController.text = user?.email ?? '';
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;

    try {
      final uid = user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'instansi': _instansiController.text.trim(),
          'email': _emailController.text.trim(),
        });

        // Update email jika berubah
        if (_emailController.text.trim() != user?.email) {
          await user!.updateEmail(_emailController.text.trim());
        }

        // Update password jika diisi
        if (_passwordController.text.isNotEmpty) {
          await user!.updatePassword(_passwordController.text.trim());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profil berhasil diperbarui")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Gagal memperbarui: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const inputDecorationStyle = OutlineInputBorder();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama",
                  border: inputDecorationStyle,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "No. HP",
                  border: inputDecorationStyle,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instansiController,
                decoration: const InputDecoration(
                  labelText: "Instansi/Asal",
                  border: inputDecorationStyle,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: inputDecorationStyle,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Email wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Baru (kosongkan jika tidak diganti)",
                  border: inputDecorationStyle,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return "Password minimal 6 karakter";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Simpan Perubahan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
