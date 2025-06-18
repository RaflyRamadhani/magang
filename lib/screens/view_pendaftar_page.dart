import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewPendaftarPage extends StatelessWidget {
  const ViewPendaftarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Pendaftar Pelatihan")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pendaftaran_pelatihan')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendaftar = snapshot.data!.docs;

          if (pendaftar.isEmpty) {
            return const Center(child: Text("Belum ada pendaftaran."));
          }

          return ListView.builder(
            itemCount: pendaftar.length,
            itemBuilder: (context, index) {
              final data = pendaftar[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📚 Pelatihan: ${data['judulPelatihan'] ?? '-'}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text("👤 Nama: ${data['namaLengkap'] ?? '-'}"),
                      Text("🆔 NIK: ${data['nik'] ?? '-'}"),
                      Text("📍 Tempat Lahir: ${data['tempatLahir'] ?? '-'}"),
                      Text("📅 Tanggal Lahir: ${data['tanggalLahir'] ?? '-'}"),
                      Text("🚻 Jenis Kelamin: ${data['jenisKelamin'] ?? '-'}"),
                      Text("📌 Status: ${data['status'] ?? '-'}"),
                      Text(
                        "🕒 Tanggal Daftar: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : '-'}",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
