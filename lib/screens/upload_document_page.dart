import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadDocumentPage extends StatefulWidget {
  const UploadDocumentPage({super.key});

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  String _fileName = '';
  XFile? _pickedFile;
  TextEditingController titleController = TextEditingController();
  bool _isUploading = false;

  Future selectFile() async {
    final typeGroup = XTypeGroup(
      label: 'documents',
      extensions: ['pdf', 'doc', 'docx'],
    );
    final result = await openFile(acceptedTypeGroups: [typeGroup]);

    if (result == null) return;

    setState(() {
      _pickedFile = result;
      _fileName = result.name;
    });
  }

  Future uploadFile() async {
    if (_pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await _pickedFile!.readAsBytes();
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/deczljiop/auto/upload",
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'flutter_unsigned'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: _pickedFile!.name,
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final urlDownload = data['secure_url'];

        await FirebaseFirestore.instance.collection('dokumen').add({
          'judul': titleController.text,
          'url': urlDownload,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dokumen berhasil diunggah!")),
        );

        setState(() {
          _pickedFile = null;
          _fileName = '';
          titleController.clear();
        });
      } else {
        throw Exception("Gagal upload ke Cloudinary");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Dokumen")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Judul Dokumen"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: selectFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Pilih Dokumen"),
            ),
            if (_fileName.isNotEmpty) Text("File: $_fileName"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickedFile != null && !_isUploading
                  ? uploadFile
                  : null,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
