import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  File? _imageFile;
  final picker = ImagePicker();
  bool isLoading = false;

  Future<void> takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> sendReport() async {
    if (_imageFile == null) return;
    setState(() => isLoading = true);

    try {
      // 1. Upload imagine
      final ref = FirebaseStorage.instance
          .ref()
          .child('reports')
          .child(DateTime.now().millisecondsSinceEpoch.toString() + '.jpg');
      await ref.putFile(_imageFile!);
      final imageUrl = await ref.getDownloadURL();

      // 2. Obține locația
      final location = Location();
      final locData = await location.getLocation();

      // 3. Salvează în Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'imageUrl': imageUrl,
        'lat': locData.latitude,
        'lng': locData.longitude,
        'timestamp': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Raport trimis cu succes!")));
      Navigator.pop(context); // întoarce-te la Home

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Eroare: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    takePhoto();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Raportează o problemă")),
      body: _imageFile == null
          ? const Center(child: Text("Nu s-a făcut nicio poză"))
          : Column(
              children: [
                Expanded(child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton.icon(
                        onPressed: takePhoto,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refă poza"),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text("Anulează"),
                      ),
                      ElevatedButton.icon(
                        onPressed: sendReport,
                        icon: const Icon(Icons.send),
                        label: const Text("Trimite"),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
