import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService firestoreService = FirestoreService();
  String selectedHabit = "Run"; // default selected habit
  final user = FirebaseAuth.instance.currentUser;

  final habitOptions = ["Run", "Read Books", "Drink Water"];

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? "Anonymous",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(user?.email ?? ""),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Dropdown for habit selection
            Row(
              children: [
                const Text(
                  "Leaderboard for: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedHabit,
                  items: habitOptions
                      .map(
                        (habit) =>
                            DropdownMenuItem(value: habit, child: Text(habit)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedHabit = value;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "🏆 Leaderboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Habit-specific leaderboard
            StreamBuilder(
              stream: firestoreService.getLeaderboardByHabit("Run"),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final habits = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final data = habits[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Text("#${index + 1}"),
                      title: Text(data['ownerName'] ?? "Unknown User"),
                      subtitle: Text("Points: ${data['points']}"),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
