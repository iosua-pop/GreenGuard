import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'home_screen.dart';

class EventTrackingScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventTrackingScreen({super.key, required this.eventId, required this.eventData});

  @override
  State<EventTrackingScreen> createState() => _EventTrackingScreenState();
}

class _EventTrackingScreenState extends State<EventTrackingScreen> {
  Timer? trackingTimer;
  Location location = Location();
  bool isEnded = false;

  @override
  void initState() {
    super.initState();
    startTracking();
  }

  void startTracking() {
    trackingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final now = DateTime.now();
      final end = (widget.eventData['end'] as Timestamp).toDate();

      if (now.isAfter(end)) {
        stopTracking();
        setState(() {
          isEnded = true;
        });
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final loc = await location.getLocation();

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('tracking')
          .doc(user.uid)
          .collection('locations')
          .add({
        'lat': loc.latitude,
        'lng': loc.longitude,
        'timestamp': Timestamp.now(),
      });
    });
  }

  void stopTracking() {
    trackingTimer?.cancel();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  void dispose() {
    trackingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 🚫 Blocăm ieșirea
      child: Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: AppBar(
          title: const Text("Eveniment în desfășurare"),
          automaticallyImplyLeading: false, // fără săgeată back
        ),
        body: Center(
          child: isEnded
              ? const Text("Evenimentul s-a încheiat. Revenim în Home...")
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("📍 Se face tracking la poziția ta..."),
                    const SizedBox(height: 20),
                    Text("Eveniment: ${widget.eventData['name']}", style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                  ],
                ),
        ),
      ),
    );
  }
}
