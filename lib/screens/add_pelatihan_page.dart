import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPelatihanPage extends StatefulWidget {
  const AddPelatihanPage({super.key});

  @override
  State<AddPelatihanPage> createState() => _AddPelatihanPageState();
}

class _AddPelatihanPageState extends State<AddPelatihanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _tanggalPelatihan;

  void _simpanPelatihan() async {
    if (_formKey.currentState!.validate() && _tanggalPelatihan != null) {
      await FirebaseFirestore.instance.collection('pelatihan').add({
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'tanggal': Timestamp.fromDate(_tanggalPelatihan!),
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelatihan berhasil ditambahkan!')),
      );

      _judulController.clear();
      _deskripsiController.clear();
      setState(() {
        _tanggalPelatihan = null;
      });
    }
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _tanggalPelatihan = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Pelatihan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: "Judul Pelatihan"),
                validator: (value) =>
                    value!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                validator: (value) =>
                    value!.isEmpty ? "Deskripsi tidak boleh kosong" : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _tanggalPelatihan == null
                          ? "Belum pilih tanggal"
                          : "Tanggal: ${DateFormat('dd-MM-yyyy').format(_tanggalPelatihan!)}",
                    ),
                  ),
                  TextButton(
                    onPressed: _pilihTanggal,
                    child: const Text("Pilih Tanggal"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpanPelatihan,
                child: const Text("💾 Simpan Pelatihan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
