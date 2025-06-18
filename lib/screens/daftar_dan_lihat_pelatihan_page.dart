import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'FormPendaftaranPage.dart'; // Pastikan file ini sudah dibuat dan path sesuai

class DaftarDanLihatPelatihanPage extends StatelessWidget {
  const DaftarDanLihatPelatihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Pelatihan Tersedia")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pelatihan').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pelatihanList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pelatihanList.length,
            itemBuilder: (context, index) {
              var pelatihan = pelatihanList[index];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('pendaftaran_pelatihan')
                    .where('userId', isEqualTo: userId)
                    .where('pelatihanId', isEqualTo: pelatihan.id)
                    .get(),
                builder: (context, snapshotPendaftaran) {
                  if (!snapshotPendaftaran.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  final daftarData = snapshotPendaftaran.data!.docs;
                  final sudahDaftar = daftarData.isNotEmpty;
                  final status = sudahDaftar ? daftarData.first['status'] : '';

                  Timestamp? tanggal = pelatihan['tanggal'];
                  String tanggalFormatted = tanggal != null
                      ? "${tanggal.toDate().day}-${tanggal.toDate().month}-${tanggal.toDate().year}"
                      : "Tidak ada tanggal";

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(pelatihan['judul']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pelatihan['deskripsi']),
                          const SizedBox(height: 5),
                          Text("📅 Tanggal: $tanggalFormatted"),
                          if (sudahDaftar)
                            Text(
                              "✅ Status: $status",
                              style: const TextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                      trailing: sudahDaftar
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              child: const Text("Daftar"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormPendaftaranPage(
                                      pelatihanId: pelatihan.id,
                                      judulPelatihan: pelatihan['judul'],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
