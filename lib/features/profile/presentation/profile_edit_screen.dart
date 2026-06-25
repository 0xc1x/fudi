import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../auth/presentation/auth_state_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  bool _saving = false;
  String _originalEmail = '';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authSessionNotifierProvider).profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _originalEmail = profile?.email ?? '';
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: FudiColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FudiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: FudiColors.secondary,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: FudiColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FudiSpacing.sm),
              Center(
              child: FudiPressableScale(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Cambiar foto',
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              ),
              const SizedBox(height: FudiSpacing.xl),
              Text('Nombre completo', style: FudiTypography.labelMedium),
              const SizedBox(height: FudiSpacing.xs),
              TextFormField(
                controller: _nameController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                decoration: InputDecoration(
                  hintText: 'Tu nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.md,
                    vertical: FudiSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: FudiSpacing.lg),
              Text('Correo electrónico', style: FudiTypography.labelMedium),
              const SizedBox(height: FudiSpacing.xs),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Correo inválido';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'usuario@correo.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.md,
                    vertical: FudiSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: FudiSpacing.lg),
              Text('Teléfono', style: FudiTypography.labelMedium),
              const SizedBox(height: FudiSpacing.xs),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+57 300 123 4567',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.md,
                    vertical: FudiSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: FudiSpacing.lg),
              Text('Ciudad', style: FudiTypography.labelMedium),
              const SizedBox(height: FudiSpacing.xs),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'Bogotá',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.md,
                    vertical: FudiSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: FudiSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: FudiPressableScale(
                  onTap: _saving ? null : _saveProfile,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: FudiColors.primary,
                      borderRadius: BorderRadius.circular(FudiRadius.lg),
                    ),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Guardar cambios',
                              style: FudiTypography.labelMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FudiSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return 'F';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final newEmail = _emailController.text.trim();

      await supabase.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'email': newEmail,
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'city': _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
      }).eq('id', userId);

      if (newEmail != _originalEmail) {
        await supabase.auth.updateUser(UserAttributes(email: newEmail));
      }

      ref.invalidate(authSessionNotifierProvider);

      if (mounted) {
        final message = newEmail != _originalEmail
            ? 'Perfil actualizado. Revisa tu nuevo correo para confirmar el cambio.'
            : 'Perfil actualizado';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: FudiColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
