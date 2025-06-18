import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DaftarDokumenPage extends StatelessWidget {
  const DaftarDokumenPage({super.key});

  Future<void> _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak bisa membuka URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📄 Daftar Dokumen")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dokumen')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("Belum ada dokumen."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['judul'] ?? 'Tanpa Judul'),
                  subtitle: Text("Status: ${data['status']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.open_in_new),
                    onPressed: () {
                      _openUrl(data['url']);
                    },
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
