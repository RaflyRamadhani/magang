import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  String email = '', password = '', name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Admin")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Nama'),
              onChanged: (val) => name = val,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (val) => email = val,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              onChanged: (val) => password = val,
            ),
            ElevatedButton(
              onPressed: () async {
                var result = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(result.user!.uid)
                    .set({
                      'uid': result.user!.uid,
                      'name': name,
                      'email': email,
                      'role': 'admin',
                      'status': 'approved',
                    });

                Navigator.pop(context);
              },
              child: Text("Simpan Admin"),
            ),
          ],
        ),
      ),
    );
  }
}
