import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'package:uuid/uuid.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  const AddHabitPage({super.key});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  int _selectedFrequency = 1; // 1 = Daily, 2 = Weekly, 3 = Monthly
  List<bool> _selectedDays = List.filled(7, false);
  IconData _selectedIcon = Icons.star;
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  final _availableIcons = [
    Icons.directions_run,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.book,
    Icons.water_drop,
    Icons.restaurant,
    Icons.bed,
    Icons.computer,
    Icons.music_note,
    Icons.brush,
    Icons.star,
    Icons.favorite,
  ];

  final _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFrequency == 2 && !_selectedDays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day for weekly habits'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final habit = Habit(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        frequency: HabitFrequency.values[_selectedFrequency - 1],
        selectedDays: _selectedDays,
        reminderTime: _reminderTime,
        createdAt: DateTime.now(),
        icon: _selectedIcon,
        color: _selectedColor,
      );

      await ref.read(habitsProvider.notifier).createHabit(habit);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating habit: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Habit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Icon and Color Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Icon',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 56,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableIcons.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final icon = _availableIcons[index];
                            final isSelected = icon == _selectedIcon;
                            return InkWell(
                              onTap: () => setState(() => _selectedIcon = icon),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _selectedColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? _selectedColor
                                        : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected
                                      ? _selectedColor
                                      : colorScheme.onSurface,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = color == _selectedColor;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Morning Run',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add some details about your habit',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 1,
                  label: Text('Daily'),
                  icon: Icon(Icons.calendar_today),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('Weekly'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment(
                  value: 3,
                  label: Text('Monthly'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {_selectedFrequency},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedFrequency = newSelection.first;
                });
              },
            ),
            if (_selectedFrequency == 2) ...[
              const SizedBox(height: 16),
              Text(
                'Select Days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: _selectedDays,
                onPressed: (index) {
                  setState(() {
                    _selectedDays[index] = !_selectedDays[index];
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('M'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('T'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('W'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('T'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('F'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('S'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('S'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(
                _reminderTime.format(context),
                style: TextStyle(color: colorScheme.primary),
              ),
              leading: const Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (newTime != null) {
                  setState(() {
                    _reminderTime = newTime;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _saveHabit,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Create Habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
