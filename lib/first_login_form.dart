import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class FirstLoginForm extends StatefulWidget {
  const FirstLoginForm({super.key});

  @override
  State<FirstLoginForm> createState() => _FirstLoginFormState();
}

class _FirstLoginFormState extends State<FirstLoginForm> {
  final nicknameController = TextEditingController();
  final phoneController = TextEditingController();
  String gender = 'M';

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;

    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nickname': nicknameController.text.trim(),
        'gender': gender,
        'phone': phoneController.text.trim(),
        'email': email,
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completează profilul")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nicknameController, decoration: const InputDecoration(labelText: 'Nickname')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefon')),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: gender,
              onChanged: (val) => setState(() => gender = val!),
              items: const [
                DropdownMenuItem(value: 'M', child: Text("Masculin")),
                DropdownMenuItem(value: 'F', child: Text("Feminin")),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveProfile, child: const Text("Salvează și continuă")),
          ],
        ),
      ),
    );
  }
}
