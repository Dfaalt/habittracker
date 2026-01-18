import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import 'add_habit_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Habit> habits = [];

  void addHabit(String title) {
    setState(() {
      habits.add(Habit(title: title));
    });
  }

  double get progress {
    if (habits.isEmpty) return 0;
    final done = habits.where((h) => h.isDone).length;
    return done / habits.length;
  }

  void resetProgress() {
    setState(() {
      for (var habit in habits) {
        habit.isDone = false;
      }
    });
  }

  void showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all habit progress?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Progress reset')));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Habit deleted')));
  }

  void showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              deleteHabit(index);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Habits by Dfaalt'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: habits.isEmpty ? null : showResetDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitPage()),
          );
          if (result != null) addHabit(result);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('${(progress * 100).toInt()}% completed'),
            const SizedBox(height: 16),
            Expanded(
              child: habits.isEmpty
                  ? const Center(
                      child: Text(
                        'No habits yet.\nTap + to add one!',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            children: habits.map((habit) {
                              return HabitCard(
                                habit: habit,
                                onChanged: (value) {
                                  setState(() {
                                    habit.isDone = value!;
                                  });
                                },
                                onDelete: () =>
                                    showDeleteDialog(habits.indexOf(habit)),
                              );
                            }).toList(),
                          );
                        }
                        return ListView.builder(
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            return HabitCard(
                              habit: habits[index],
                              onChanged: (value) {
                                setState(() {
                                  habits[index].isDone = value!;
                                });
                              },
                              onDelete: () => showDeleteDialog(index),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
