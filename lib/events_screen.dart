import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Evenimente")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').orderBy('date').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final data = events[index].data() as Map<String, dynamic>;
              final isPast = data['date'].toDate().isBefore(DateTime.now());
              final isJoined = (data['participants'] as List<dynamic>).contains(userId);

              return ListTile(
                title: Text(data['name']),
                subtitle: Text("📍 ${data['location']} • ${data['date'].toDate().toLocal()}"),
                trailing: isPast
                    ? const Text("Finalizat")
                    : isJoined
                        ? const Text("Înscris", style: TextStyle(color: Colors.green))
                        : const Text("Disponibil"),
              );
            },
          );
        },
      ),
    );
  }
}
