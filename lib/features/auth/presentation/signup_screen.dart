import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/fudi_exception_l10n.dart';
import '../domain/user_profile.dart';
import 'auth_state_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.user;
  bool _analyticsConsentGranted = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .signUp(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
            analyticsConsentGranted: _analyticsConsentGranted,
          );

      if (!mounted) return;

      if (result.requiresEmailConfirmation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cuenta creada. Revisa tu correo para confirmar el registro.',
            ),
          ),
        );
        context.go(RouteNames.loginPath);
        return;
      }

      final target = _selectedRole == UserRole.business
          ? RouteNames.businessProductsPath
          : RouteNames.homePath;
      context.go(target);
    } catch (error) {
      if (!mounted) return;
      final message = error is FudiException
          ? error.userMessage()
          : 'No pudimos crear tu cuenta. Intenta de nuevo.';
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
      appBar: AppBar(title: const Text('Crear cuenta')),
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
                      'Únete a Fudi',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu cuenta como consumidor o negocio.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu correo';
                        }
                        if (!value.contains('@')) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
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
                    DropdownButtonFormField<UserRole>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de cuenta',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: UserRole.user,
                          child: Text('Consumidor'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.business,
                          child: Text('Negocio'),
                        ),
                      ],
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _selectedRole = value);
                            },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _analyticsConsentGranted,
                      contentPadding: EdgeInsets.zero,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(
                                () => _analyticsConsentGranted = value ?? false,
                              );
                            },
                      title: const Text(
                        'Acepto analytics para mejorar la experiencia',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: Text(
                        isLoading ? 'Creando cuenta...' : 'Crear cuenta',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go(RouteNames.loginPath),
                      child: const Text('Ya tengo cuenta'),
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
