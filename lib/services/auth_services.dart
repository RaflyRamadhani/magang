import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Register User Baru
  Future<void> registerUser(String name, String email, String password) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': name,
        'email': email,
        'role': 'user',
        'status': 'pending',
      });
    } on FirebaseAuthException catch (e) {
      throw Exception('Register Gagal: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Login Email & Password dan Ambil Role
  Future<String> login(String email, String password) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      var userDoc = await _db.collection('users').doc(result.user!.uid).get();

      if (!userDoc.exists) {
        throw Exception('Data pengguna tidak ditemukan.');
      }

      return userDoc['role'];
    } on FirebaseAuthException catch (e) {
      throw Exception('Login Gagal: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Login dengan Google
  Future<String> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception("Login Google dibatalkan");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user == null) throw Exception("Gagal login dengan Google");

      DocumentSnapshot userDoc = await _db
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Jika user belum ada di Firestore, tambahkan
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'role': 'user',
          'status': 'pending',
        });
        return 'user';
      } else {
        return userDoc['role'];
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Login Google Gagal: ${e.message}');
    } catch (e) {
      throw Exception('Login Google Error: $e');
    }
  }
}
