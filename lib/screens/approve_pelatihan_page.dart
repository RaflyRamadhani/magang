import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApprovePelatihanPage extends StatelessWidget {
  const ApprovePelatihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pendaftaranRef = FirebaseFirestore.instance.collection(
      'pendaftaran_pelatihan',
    );

    return Scaffold(
      appBar: AppBar(title: const Text("ACC Pendaftaran Pelatihan")),
      body: StreamBuilder<QuerySnapshot>(
        stream: pendaftaranRef
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Tidak ada pendaftaran yang pending.'),
            );
          }

          final daftar = snapshot.data!.docs;

          return ListView.builder(
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              final data = daftar[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("👤 User ID: ${data['userId'] ?? 'Tidak ada'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📚 Pelatihan ID: ${data['pelatihanId'] ?? '-'}"),
                      Text("📌 Status: ${data['status'] ?? '-'}"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await pendaftaranRef.doc(daftar[index].id).update({
                        'status': 'approved',
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✅ Pendaftaran berhasil di-ACC!"),
                          ),
                        );
                      }
                    },
                    child: const Text("ACC"),
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
