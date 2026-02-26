import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class ScheduleStreamPage extends StatefulWidget {
  const ScheduleStreamPage({super.key});

  @override
  State<ScheduleStreamPage> createState() => _ScheduleStreamPageState();
}

class _ScheduleStreamPageState extends State<ScheduleStreamPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  String _category = 'Gaming';
  final RxBool _isSaving = false.obs;

  static const _categories = ['Gaming', 'Music', 'Dance', 'Talk', 'Sports', 'Cooking', 'Education', 'Fashion'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
      builder: (ctx, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (time == null) return;
    setState(() => _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _isSaving.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Get.snackbar('Scheduled!', 'Your stream has been scheduled', backgroundColor: AppTheme.successColor.withOpacity(0.9));
        context.pop();
      }
    } finally {
      _isSaving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Schedule Stream'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Stream Title',
                hint: 'Enter your stream title',
                prefixIcon: Icons.title,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Tell viewers what to expect...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppTheme.cardDark,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.category_outlined, color: AppTheme.textMuted),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule, color: AppTheme.textMuted),
                title: const Text('Scheduled Time', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                subtitle: Text(
                  '${_scheduledAt.day}/${_scheduledAt.month}/${_scheduledAt.year} at ${_scheduledAt.hour.toString().padLeft(2, '0')}:${_scheduledAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                trailing: TextButton(onPressed: _pickDateTime, child: const Text('Change')),
              ),
              const SizedBox(height: 32),
              Obx(() => GradientButton(onPressed: _isSaving.value ? null : _save, isLoading: _isSaving.value, child: const Text('Schedule Stream'))),
            ],
          ),
        ),
      ),
    );
  }
}
