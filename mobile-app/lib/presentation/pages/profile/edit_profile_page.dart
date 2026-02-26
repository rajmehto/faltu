import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final RxBool _isSaving = false.obs;

  @override
  void initState() {
    super.initState();
    final user = Get.find<AuthService>().currentUser;
    if (user != null) {
      _displayNameController.text = user.profile.displayName;
      _usernameController.text = user.username;
      _bioController.text = user.profile.bio ?? '';
      _locationController.text = user.profile.city ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _isSaving.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Get.snackbar('Success', 'Profile updated', backgroundColor: AppTheme.successColor.withOpacity(0.9));
        context.pop();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile', backgroundColor: AppTheme.errorColor.withOpacity(0.9));
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
        title: const Text('Edit Profile'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
        actions: [
          Obx(() => TextButton(
            onPressed: _isSaving.value ? null : _save,
            child: Text('Save', style: TextStyle(color: _isSaving.value ? AppTheme.textMuted : AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.cardDark,
                      child: Icon(Icons.person, size: 48, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppTextField(
                controller: _displayNameController,
                label: 'Display Name',
                hint: 'Your display name',
                prefixIcon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Display name is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'your_username',
                prefixIcon: Icons.alternate_email,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Username is required';
                  if (v.length < 3) return 'At least 3 characters';
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) return 'Only letters, numbers and underscore';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Tell something about yourself...',
                prefixIcon: Icons.info_outline,
                maxLines: 3,
                maxLength: 150,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'City, Country',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 32),
              Obx(() => GradientButton(
                onPressed: _isSaving.value ? null : _save,
                isLoading: _isSaving.value,
                child: const Text('Save Changes'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
