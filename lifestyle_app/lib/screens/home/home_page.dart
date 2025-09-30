import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../habits/add_habit_page.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 👤 Profile Button
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(user.displayName ?? user.email ?? "My Habits"),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: firestoreService.getUserHabits(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final habits = snapshot.data!.docs;

          if (habits.isEmpty) {
            return const Center(child: Text('No habits yet. Add one!'));
          }

          return ListView(
            children: habits.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final completedDates = List<String>.from(
                data['completedDates'] ?? [],
              );
              final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
              final isCompletedToday = completedDates.contains(today);

              return HabitCard(
                docRef: doc.reference,
                title: data['title'] ?? '',
                frequency: data['frequency'] ?? 'Daily',
                completedDates: completedDates,
                isCompletedToday: isCompletedToday,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            backgroundColor: Colors.redAccent,
          ),
          FloatingActionButton(
            heroTag: 'addFab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHabitPage()),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  final DocumentReference docRef;
  final String title;
  final String frequency;
  final List<String> completedDates;
  final bool isCompletedToday;

  const HabitCard({
    super.key,
    required this.docRef,
    required this.title,
    required this.frequency,
    required this.completedDates,
    required this.isCompletedToday,
  });

  int _calculateStreak() {
    if (completedDates.isEmpty) return 0;

    completedDates.sort((a, b) => b.compareTo(a)); // newest first
    int streak = 1;
    DateTime last = DateTime.parse(completedDates.first);

    for (int i = 1; i < completedDates.length; i++) {
      DateTime current = DateTime.parse(completedDates[i]);
      if (last.difference(current).inDays == 1) {
        streak++;
        last = current;
      } else {
        break;
      }
    }
    return streak;
  }

  List<bool> _generateWeeklyProgress() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final completedSet = completedDates.toSet();

    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayStr = formatter.format(day);
      return completedSet.contains(dayStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final weeklyProgress = _generateWeeklyProgress();

    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Frequency: $frequency"),
              leading: Checkbox(
                value: isCompletedToday,
                onChanged: (checked) async {
                  final updatedDates = List<String>.from(completedDates);
                  final firestoreService = FirestoreService();
                  final user = FirebaseAuth.instance.currentUser;

                  if (checked == true && !updatedDates.contains(today)) {
                    updatedDates.add(today);

                    // ✅ Award points for checking in
                    if (user != null) {
                      await firestoreService.updateUserPoints(user.uid, 10);
                    }
                  } else if (checked == false && updatedDates.contains(today)) {
                    updatedDates.remove(today);

                    // ❌ Optionally remove points
                    if (user != null) {
                      await firestoreService.updateUserPoints(user.uid, -10);
                    }
                  }

                  await docRef.update({'completedDates': updatedDates});
                },
              ),

              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  Text("${_calculateStreak()} days"),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final isDone = weeklyProgress[i];
                return Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? Colors.green : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = DateTime.now().subtract(Duration(days: 6 - i));
                final shortDay = DateFormat('E').format(day); // Mon, Tue...
                return SizedBox(
                  width: 20,
                  child: Text(
                    shortDay[0], // Just the first letter
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
