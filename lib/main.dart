import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/UploadBeritaPage.dart';
import 'screens/ViewAllDocumentsPage.dart';
import 'screens/admin_dashboard.dart';
import 'screens/approve_pelatihan_page.dart';
import 'screens/daftar_dan_lihat_pelatihan_page.dart';
import 'screens/daftar_dokumen_page.dart';
import 'screens/edit_profile_page.dart';
import 'screens/lihat_berita_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/super_admin_dashboard.dart';
import 'screens/upload_document_page.dart';
import 'screens/user_home.dart';
import 'screens/user_pelatihan_list.dart';
import 'screens/view_pendaftar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pelatihan Kemendagri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Halaman awal
      home: const LoginPage(),

      // Daftar route
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/user_home': (context) => const UserHome(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/super_admin_dashboard': (context) => const SuperAdminDashboard(),
        '/approve_pelatihan': (context) => const ApprovePelatihanPage(),
        '/user_pelatihan': (context) => const UserPelatihanListPage(),
        '/edit_profile': (context) => const EditProfilePage(),
        '/pelatihan_user': (context) => const DaftarDanLihatPelatihanPage(),
        '/lihat_berita': (context) => const LihatBeritaPage(),
        '/daftar_dokumen': (context) => const DaftarDokumenPage(),
        '/upload_document': (context) => const UploadDocumentPage(),
        '/view_documents': (context) => const ViewAllDocumentsPage(),
        '/view_pendaftar': (context) => const ViewPendaftarPage(), // y
        '/upload_berita': (context) => const UploadBeritaPage(),
        '/lihat_berita': (context) => const LihatBeritaPage(),
        '/upload_berita': (context) => const UploadBeritaPage(),
      },
    );
  }
}
