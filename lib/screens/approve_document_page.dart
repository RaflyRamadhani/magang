import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApproveDocumentPage extends StatelessWidget {
  const ApproveDocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dokumenRef = FirebaseFirestore.instance.collection('dokumen');

    return Scaffold(
      appBar: AppBar(title: const Text("✅ ACC Dokumen")),
      body: StreamBuilder<QuerySnapshot>(
        stream: dokumenRef.where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Tidak ada dokumen yang perlu di-ACC."),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              final String judul = doc['judul'] ?? 'Tidak ada judul';
              final String fileName = doc.data().toString().contains('fileName')
                  ? doc['fileName']
                  : '(tidak tersedia)';

              return ListTile(
                title: Text(judul),
                subtitle: Text("File: $fileName"),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await dokumenRef.doc(doc.id).update({'status': 'approved'});

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Dokumen berhasil di-ACC!"),
                        ),
                      );
                    }
                  },
                  child: const Text("ACC"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
