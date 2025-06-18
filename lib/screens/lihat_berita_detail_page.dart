import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailBeritaPage extends StatefulWidget {
  final String judul;
  final String isi;
  final String gambar;

  const DetailBeritaPage({
    super.key,
    required this.judul,
    required this.isi,
    required this.gambar,
  });

  @override
  State<DetailBeritaPage> createState() => _DetailBeritaPageState();
}

class _DetailBeritaPageState extends State<DetailBeritaPage> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _commentController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('berita')
        .doc(widget.judul) // gunakan judul sebagai ID unik berita
        .collection('komentar')
        .add({
          'uid': user.uid,
          'email': user.email,
          'komentar': _commentController.text.trim(),
          'createdAt': Timestamp.now(),
        });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.judul)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.network(widget.gambar),
          const SizedBox(height: 16),
          Text(
            widget.judul,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(widget.isi, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          const Text(
            "Komentar:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // 🔽 Komentar dari Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('berita')
                .doc(widget.judul)
                .collection('komentar')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final comments = snapshot.data!.docs;

              return Column(
                children: comments.map((doc) {
                  return ListTile(
                    title: Text(doc['email'] ?? 'Anonim'),
                    subtitle: Text(doc['komentar']),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Tulis komentar...",
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _submitComment,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
