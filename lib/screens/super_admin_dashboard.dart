import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './add_admin_page.dart';
import './add_pelatihan_page.dart';
import './approve_document_page.dart';
import './edit_profile_page.dart';
import './upload_document_page.dart';
import './view_pendaftar_page.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final _firestore = FirebaseFirestore.instance;

  Widget buildGridItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color ?? Colors.deepPurple,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text("Super Admin Dashboard"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            buildGridItem(
              icon: Icons.check_circle_outline,
              title: "ACC Pendaftaran\nPelatihan",
              onTap: () => Navigator.pushNamed(context, '/approve_pelatihan'),
            ),
            buildGridItem(
              icon: Icons.person_add,
              title: "Tambah Admin",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAdminPage()),
              ),
              color: Colors.blue,
            ),
            buildGridItem(
              icon: Icons.upload_file,
              title: "Upload Dokumen",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadDocumentPage()),
              ),
              color: Colors.teal,
            ),
            buildGridItem(
              icon: Icons.book,
              title: "Tambah Pelatihan",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPelatihanPage()),
              ),
              color: Colors.orange,
            ),
            buildGridItem(
              icon: Icons.verified,
              title: "ACC Dokumen",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApproveDocumentPage()),
              ),
              color: Colors.green,
            ),
            buildGridItem(
              icon: Icons.list_alt,
              title: "Lihat Data\nPendaftar",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewPendaftarPage()),
              ),
              color: Colors.deepOrange,
            ),
            buildGridItem(
              icon: Icons.edit,
              title: "Edit Profil",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
              color: Colors.indigo,
            ),
            buildGridItem(
              icon: Icons.description,
              title: "Lihat Semua\nDokumen",
              onTap: () => Navigator.pushNamed(context, '/view_documents'),
              color: Colors.brown,
            ),
          ],
        ),
      ),
    );
  }
}
