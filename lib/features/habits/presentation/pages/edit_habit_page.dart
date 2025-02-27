import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';

class EditHabitPage extends ConsumerStatefulWidget {
  final Habit habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  ConsumerState<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends ConsumerState<EditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TimeOfDay _reminderTime;
  late int _selectedFrequency;
  late List<bool> _selectedDays;
  late IconData _selectedIcon;
  late Color _selectedColor;
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _descriptionController =
        TextEditingController(text: widget.habit.description ?? '');
    _reminderTime = widget.habit.reminderTime;

    // Set frequency radio
    switch (widget.habit.frequency) {
      case HabitFrequency.daily:
        _selectedFrequency = 0;
        break;
      case HabitFrequency.weekly:
        _selectedFrequency = 1;
        break;
      case HabitFrequency.monthly:
        _selectedFrequency = 2;
        break;
    }

    _selectedDays = List.from(widget.habit.selectedDays);
    _selectedIcon = widget.habit.icon;
    _selectedColor = widget.habit.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  border: OutlineInputBorder(),
                ),
                validator: Habit.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                validator: Habit.validateDescription,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Frequency',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildFrequencySelector(),
              const SizedBox(height: 24),
              Text(
                'Reminder Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildTimeSelector(context),
              const SizedBox(height: 24),
              Text(
                'Icon & Color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildIconAndColorSelector(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveHabit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      children: [
        RadioListTile<int>(
          title: const Text('Daily'),
          value: 0,
          groupValue: _selectedFrequency,
          onChanged: (value) {
            setState(() {
              _selectedFrequency = value!;
            });
          },
        ),
        RadioListTile<int>(
          title: const Text('Weekly'),
          value: 1,
          groupValue: _selectedFrequency,
          onChanged: (value) {
            setState(() {
              _selectedFrequency = value!;
            });
          },
        ),
        if (_selectedFrequency == 1) _buildWeekdaySelector(),
        RadioListTile<int>(
          title: const Text('Monthly'),
          value: 2,
          groupValue: _selectedFrequency,
          onChanged: (value) {
            setState(() {
              _selectedFrequency = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('Select days:'),
          ),
          Wrap(
            spacing: 4,
            children: List.generate(7, (index) {
              return FilterChip(
                label: Text(days[index]),
                selected: _selectedDays[index],
                onSelected: (selected) {
                  setState(() {
                    _selectedDays[index] = selected;
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _reminderTime,
        );
        if (picked != null) {
          setState(() {
            _reminderTime = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time),
            const SizedBox(width: 12),
            Text(
              _reminderTime.format(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconAndColorSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Icon'),
              const SizedBox(height: 8),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIcon = _availableIcons[index];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == _availableIcons[index]
                              ? _selectedColor.withOpacity(0.3)
                              : Colors.transparent,
                          border: Border.all(
                            color: _selectedIcon == _availableIcons[index]
                                ? _selectedColor
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(_availableIcons[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Color'),
              const SizedBox(height: 8),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColor = _availableColors[index];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _availableColors[index],
                          border: Border.all(
                            color: _selectedColor == _availableColors[index]
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
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
    );
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the appropriate frequency enum
        final frequency = HabitFrequency.values[_selectedFrequency];

        // Create an updated habit from the existing one
        final updatedHabit = widget.habit.copyWith(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          frequency: frequency,
          selectedDays: _selectedDays,
          reminderTime: _reminderTime,
          icon: _selectedIcon,
          color: _selectedColor,
        );

        // Update the habit
        await ref.read(habitsProvider.notifier).updateHabit(updatedHabit);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
