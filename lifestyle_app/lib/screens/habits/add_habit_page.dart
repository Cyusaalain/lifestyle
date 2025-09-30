import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedHabit;
  String frequency = 'Daily';
  bool loading = false;

  final _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedHabit,
                items: const [
                  DropdownMenuItem(value: 'Run', child: Text('Run')),
                  DropdownMenuItem(
                    value: 'Read Books',
                    child: Text('Read Books'),
                  ),
                  DropdownMenuItem(
                    value: 'Drink Water',
                    child: Text('Drink Water'),
                  ),
                ],
                onChanged: (val) => setState(() => selectedHabit = val),
                decoration: const InputDecoration(labelText: 'Habit'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Select a habit' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: frequency,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                ],
                onChanged: (val) => setState(() => frequency = val!),
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: loading ? null : _addHabit,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Add Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addHabit() async {
    if (_formKey.currentState!.validate() && user != null) {
      setState(() => loading = true);

      try {
        await _firestoreService.createHabit(
          user!.uid,
          selectedHabit!, //
          frequency: frequency,
        );
        if (mounted) Navigator.pop(context); // go back to habit list
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => loading = false);
      }
    }
  }
}
