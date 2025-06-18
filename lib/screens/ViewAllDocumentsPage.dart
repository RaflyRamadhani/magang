import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewAllDocumentsPage extends StatelessWidget {
  const ViewAllDocumentsPage({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membuka dokumen.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dokumenRef = FirebaseFirestore.instance.collection('dokumen');

    return Scaffold(
      appBar: AppBar(title: const Text("📄 Daftar Semua Dokumen")),
      body: StreamBuilder<QuerySnapshot>(
        stream: dokumenRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada dokumen."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String judul = data['judul'] ?? 'Tanpa judul';
              final String url = data['url'] ?? '';
              final String status = data['status'] ?? 'unknown';
              final String uploader = data.containsKey('uploaded_by')
                  ? data['uploaded_by']
                  : 'N/A';

              return ListTile(
                title: Text(judul),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status: $status"),
                    Text("Uploader: $uploader"),
                    TextButton(
                      onPressed: () => _launchURL(context, url),
                      child: const Text("Lihat Dokumen"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
