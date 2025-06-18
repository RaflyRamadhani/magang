import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserPelatihanListPage extends StatelessWidget {
  const UserPelatihanListPage({super.key});

  void daftarPelatihan(String pelatihanId, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Silakan login terlebih dahulu.")));
      return;
    }

    final daftarRef = FirebaseFirestore.instance
        .collection('pelatihan')
        .doc(pelatihanId)
        .collection('pendaftar');

    // Cek apakah sudah pernah daftar
    final existing = await daftarRef.doc(user.uid).get();
    if (existing.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kamu sudah mendaftar pelatihan ini.")),
      );
      return;
    }

    await daftarRef.doc(user.uid).set({
      'user_id': user.uid,
      'email': user.email,
      'waktu_daftar': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Berhasil mendaftar pelatihan!")));
  }

  @override
  Widget build(BuildContext context) {
    final pelatihanRef = FirebaseFirestore.instance.collection('pelatihan');

    return Scaffold(
      appBar: AppBar(title: Text("Daftar Pelatihan")),
      body: StreamBuilder(
        stream: pelatihanRef
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final pelatihans = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pelatihans.length,
            itemBuilder: (context, index) {
              final pelatihan = pelatihans[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(pelatihan['judul']),
                  subtitle: Text(
                    "${pelatihan['deskripsi']}\nTanggal: ${pelatihan['tanggal']}",
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () => daftarPelatihan(pelatihan.id, context),
                    child: Text("Daftar"),
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
