import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/fudi_exception.dart';
import '../../../core/error/fudi_exception_l10n.dart';
import '../../../core/routing/route_names.dart';
import 'auth_state_provider.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() =>
      _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(authSessionNotifierProvider.notifier)
          .clearPasswordRecoveryFlag();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(newPassword: _passwordController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contraseña actualizada. Inicia sesión con tu nueva contraseña.',
          ),
        ),
      );
      context.go(RouteNames.loginPath);
    } catch (error) {
      if (!mounted) return;
      final message = error is FudiException
          ? error.userMessage()
          : 'No pudimos actualizar tu contraseña.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar contraseña')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Define una nueva contraseña',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por seguridad, te pediremos iniciar sesión de nuevo después del cambio.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nueva contraseña',
                        helperText: 'Mínimo 8 caracteres',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (value.length < 8) {
                          return 'La contraseña debe tener al menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirma tu contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: Text(
                        isLoading
                            ? 'Actualizando...'
                            : 'Guardar nueva contraseña',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(RouteNames.loginPath),
                      child: const Text('Volver al login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
