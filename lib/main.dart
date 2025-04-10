import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenGuard',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String message = "Se verifică conexiunea...";

  @override
  void initState() {
    super.initState();
    testFirebaseConnection();
  }

  Future<void> testFirebaseConnection() async {
    try {
      // O interogare simplă: citește prima colecție (sau o creează)
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').add({'timestamp': Timestamp.now()});
      setState(() {
        message = "✅ Firebase conectat cu succes!";
      });
    } catch (e) {
      setState(() {
        message = "❌ Eroare la conectarea cu Firebase: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GreenGuard")),
      body: Center(child: Text(message)),
    );
  }
}
