import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadBeritaPage extends StatefulWidget {
  const UploadBeritaPage({super.key});

  @override
  State<UploadBeritaPage> createState() => _UploadBeritaPageState();
}

class _UploadBeritaPageState extends State<UploadBeritaPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController isiController = TextEditingController();
  File? selectedImage;
  bool loading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    const cloudName = 'deczljiop';
    const uploadPreset = 'flutter_unsigned';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      return data['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> uploadBerita() async {
    if (judulController.text.isEmpty ||
        isiController.text.isEmpty ||
        selectedImage == null)
      return;

    setState(() => loading = true);

    final imageUrl = await uploadToCloudinary(selectedImage!);
    if (imageUrl != null) {
      await FirebaseFirestore.instance.collection('berita').add({
        'judul': judulController.text,
        'isi': isiController.text,
        'gambar': imageUrl,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Berita berhasil diunggah")),
      );
      judulController.clear();
      isiController.clear();
      setState(() => selectedImage = null);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Gagal upload gambar")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Berita")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: judulController,
              decoration: const InputDecoration(labelText: 'Judul Berita'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: isiController,
              decoration: const InputDecoration(labelText: 'Isi Berita'),
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pilih Gambar"),
            ),
            if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(selectedImage!),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : uploadBerita,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("📤 Upload Berita"),
            ),
          ],
        ),
      ),
    );
  }
}
