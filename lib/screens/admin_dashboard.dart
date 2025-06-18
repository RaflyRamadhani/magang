import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/upload_document');
              },
              child: const Text("📤 Upload Dokumen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
              child: const Text("👤 Edit Profil"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/upload_berita');
              },
              child: const Text("📰 Upload Berita"),
            ),
            const SizedBox(height: 16),
            const Center(child: Text("Selamat Datang Admin!")),
          ],
        ),
      ),
    );
  }
}
