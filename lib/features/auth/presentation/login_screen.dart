import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/fudi_exception_l10n.dart';
import 'auth_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear previous error before new attempt
    setState(() => _errorMessage = null);
    ref.read(authSessionNotifierProvider).clearAuthError();

    try {
      await ref.read(authControllerProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // On success, clearAuthError was already called above.
      // GoRouter's refreshListenable will trigger the guard,
      // which will redirect to the correct default route.
      // NO imperative navigation here — let the guard handle it.
    } catch (error) {
      if (!mounted) return;
      final message = error is FudiException
          ? error.userMessage()
          : 'No pudimos iniciar sesión. Intenta de nuevo.';
      setState(() => _errorMessage = message);
    }
  }

  Future<void> _openForgotPasswordDialog() async {
    final emailController =
        TextEditingController(text: _emailController.text.trim());
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final config = ref.read(appConfigProvider);

        return AlertDialog(
          title: const Text('Recuperar contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Te enviaremos un enlace para restablecer tu contraseña.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
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
                if (!config.hasAuthResetRedirectUrl) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Aviso: AUTH_RESET_REDIRECT_URL no está configurado. Supabase usará su redirect por defecto.',
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(
                        email: emailController.text.trim(),
                      );

                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Si el correo existe, enviaremos un enlace de recuperación.',
                      ),
                    ),
                  );
                } catch (error) {
                  if (!dialogContext.mounted) return;
                  final message = error is FudiException
                      ? error.userMessage()
                      : 'No pudimos enviar el correo de recuperación.';
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: const Text('Enviar enlace'),
            ),
          ],
        );
      },
    );

    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
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
                      'Bienvenido a Fudi',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión para reservar y gestionar tus pedidos.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
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
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : _openForgotPasswordDialog,
                        child: const Text('Olvidaste tu contraseña'),
                      ),
                    ),
    const SizedBox(height: 8),
    FilledButton(
      onPressed: isLoading ? null : _submit,
      child: Text(isLoading ? 'Ingresando...' : 'Iniciar sesión'),
    ),
    if (_errorMessage != null) ...[
      const SizedBox(height: 12),
      MaterialBanner(
        content: Text(
          _errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        actions: [
          TextButton(
            onPressed: () => setState(() => _errorMessage = null),
            child: Text(
              'Cerrar',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: EdgeInsets.zero,
      ),
    ],
    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('o continúa con'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: null,
                      child: const Text('Google — próximamente'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: null,
                      child: const Text('Apple — próximamente'),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go(RouteNames.signupPath),
                      child: const Text('¿No tienes cuenta? Crear cuenta'),
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
