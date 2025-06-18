import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FormPendaftaranPage extends StatefulWidget {
  final String pelatihanId;
  final String judulPelatihan;

  const FormPendaftaranPage({
    super.key,
    required this.pelatihanId,
    required this.judulPelatihan,
  });

  @override
  State<FormPendaftaranPage> createState() => _FormPendaftaranPageState();
}

class _FormPendaftaranPageState extends State<FormPendaftaranPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  String? _jenisKelamin;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userId = _auth.currentUser?.uid;

      await FirebaseFirestore.instance.collection('pendaftaran_pelatihan').add({
        'userId': userId,
        'pelatihanId': widget.pelatihanId,
        'judulPelatihan': widget.judulPelatihan,
        'namaLengkap': _namaController.text,
        'nik': _nikController.text,
        'tempatLahir': _tempatLahirController.text,
        'tanggalLahir': _tanggalLahirController.text,
        'jenisKelamin': _jenisKelamin,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil dikirim!')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Pendaftaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Pelatihan: ${widget.judulPelatihan}"),
              const SizedBox(height: 16),

              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),

              TextFormField(
                controller: _nikController,
                decoration: const InputDecoration(labelText: 'NIK'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'NIK tidak boleh kosong' : null,
              ),

              TextFormField(
                controller: _tempatLahirController,
                decoration: const InputDecoration(labelText: 'Tempat Lahir'),
                validator: (value) =>
                    value!.isEmpty ? 'Tempat lahir tidak boleh kosong' : null,
              ),

              TextFormField(
                controller: _tanggalLahirController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir (DD-MM-YYYY)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Tanggal lahir tidak boleh kosong' : null,
              ),

              const SizedBox(height: 8),
              const Text("Jenis Kelamin:"),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                items: const [
                  DropdownMenuItem(
                    value: "Laki-laki",
                    child: Text("Laki-laki"),
                  ),
                  DropdownMenuItem(
                    value: "Perempuan",
                    child: Text("Perempuan"),
                  ),
                ],
                onChanged: (value) => setState(() {
                  _jenisKelamin = value;
                }),
                validator: (value) =>
                    value == null ? 'Pilih jenis kelamin' : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Kirim Pendaftaran"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
