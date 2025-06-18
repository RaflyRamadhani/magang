import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  File? _selectedImage;
  bool _isLoading = false;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadToCloudinary() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final cloudName = 'NAMA_CLOUDMU';
    final uploadPreset = 'UPLOAD_PRESET_MU';

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      final imageUrl = data['secure_url'];

      // Simpan URL ke Firestore
      await FirebaseFirestore.instance.collection('documents').add({
        'imageUrl': imageUrl,
        'uploaded_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload sukses!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload!'), backgroundColor: Colors.red),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Gambar")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : Text("Belum ada gambar"),
            SizedBox(height: 20),
            ElevatedButton(onPressed: pickImage, child: Text("Pilih Gambar")),
            ElevatedButton(
              onPressed: _isLoading ? null : uploadToCloudinary,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text("Upload ke Cloudinary"),
            ),
          ],
        ),
      ),
    );
  }
}
