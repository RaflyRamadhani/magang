import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class LihatBeritaPage extends StatelessWidget {
  const LihatBeritaPage({super.key});

  String formatTanggal(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Berita Terbaru")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('berita')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final beritaList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: beritaList.length,
            itemBuilder: (context, index) {
              var berita = beritaList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailBeritaPage(
                        judul: berita['judul'],
                        isi: berita['isi'],
                        gambar: berita['gambar'],
                        tanggal: formatTanggal(berita['createdAt']),
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          berita['gambar'],
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              berita['judul'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatTanggal(berita['createdAt']),
                              style: TextStyle(color: Colors.grey[600]),
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
        },
      ),
    );
  }
}

class DetailBeritaPage extends StatelessWidget {
  final String judul;
  final String isi;
  final String gambar;
  final String tanggal;

  const DetailBeritaPage({
    super.key,
    required this.judul,
    required this.isi,
    required this.gambar,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(judul)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(gambar),
          ),
          const SizedBox(height: 16),
          Text(
            judul,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(tanggal, style: TextStyle(color: Colors.grey[600])),
          const Divider(height: 24),
          Text(
            isi,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
