import 'package:flutter/material.dart';

class HabitListPage extends StatelessWidget {
  const HabitListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Habits")),
      body: ListView(
        children: const [
          // For now, static demo cards. Later we’ll fetch from Firestore
          HabitCard(title: "Drink Water", streak: 5, frequency: "Daily"),
          HabitCard(title: "Read 10 pages", streak: 2, frequency: "Daily"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to Add Habit page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  final String title;
  final int streak;
  final String frequency;

  const HabitCard({
    super.key,
    required this.title,
    required this.streak,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Frequency: $frequency"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            Text("$streak days"),
          ],
        ),
      ),
    );
  }
}
