import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/fudi_exception_l10n.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/atoms/icons/fudi_google_icon.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
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
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);
    ref.read(authSessionNotifierProvider.notifier).clearAuthError();

    await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.hasError) {
      final error = authState.error;
      final message = error is FudiException
          ? error.userMessage()
          : 'No pudimos iniciar sesión. Intenta de nuevo.';
      setState(() => _errorMessage = message);
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: const TextStyle(
        color: FudiColors.mutedForeground,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FudiColors.borderSolid),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FudiColors.borderSolid),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FudiColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Future<void> _openForgotPasswordDialog() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final dialogFormKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          title: const Text(
            'Recuperar contraseña',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Te enviaremos un enlace seguro para restablecer el acceso a tu cuenta.',
                  style: TextStyle(
                    color: FudiColors.mutedForeground,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    hintText: 'tu@email.com',
                    prefixIcon: const Icon(
                      FudiIcons.mail,
                      size: 20,
                      color: FudiColors.mutedForeground,
                    ),
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
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: FudiColors.mutedForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FudiPressableScale(
              onTap: () async {
                if (!dialogFormKey.currentState!.validate()) return;

                try {
                  await ref
                      .read(authControllerProvider.notifier)
                      .sendPasswordResetEmail(
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
                      : 'No pudimos enviar el correo.';
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: FudiColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Enviar enlace',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  FudiPressableScale(
                    onTap: () => context.go(RouteNames.homePath),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FudiIcons.chevronLeft,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Iniciar sesión',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: FudiColors.borderSolid, height: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: FudiLogo(
                              variant: FudiLogoVariant.icon,
                              size: FudiLogoSize.lg,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bienvenido de vuelta',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Inicia sesión para rescatar comida y ahorrar',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: FudiColors.mutedForeground),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          Text(
                            'Correo electrónico',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'tu@email.com',
                              prefixIcon: const Icon(
                                FudiIcons.mail,
                                size: 20,
                                color: FudiColors.mutedForeground,
                              ),
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
                          const SizedBox(height: 20),

                          Text(
                            'Contraseña',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(
                                FudiIcons.lock,
                                size: 20,
                                color: FudiColors.mutedForeground,
                              ),
                              suffixIcon: FudiPressableScale(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? FudiIcons.eye
                                      : FudiIcons.eyeOff,
                                  size: 20,
                                  color: FudiColors.mutedForeground,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Ingresa tu contraseña'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          Align(
                            alignment: Alignment.centerRight,
                            child: FudiPressableScale(
                              onTap: isLoading
                                  ? null
                                  : _openForgotPasswordDialog,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: FudiColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer
                                    .withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  FudiPressableScale(
                                    onTap: () =>
                                        setState(() => _errorMessage = null),
                                    child: Icon(
                                      FudiIcons.x,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          FudiPressableScale(
                            onTap: isLoading ? null : _submit,
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: FudiColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: FudiColors.primaryForeground,
                                        ),
                                      )
                                    : const Text(
                                        'Iniciar sesión',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Row(
                            children: [
                              Expanded(
                                child: Divider(color: FudiColors.borderSolid),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o continuar con',
                                  style: TextStyle(
                                    color: FudiColors.mutedForeground,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: FudiColors.borderSolid),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: FudiPressableScale(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: FudiColors.borderSolid,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const FudiGoogleIcon(),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Google',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FudiPressableScale(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: FudiColors.borderSolid,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.apple,
                                          size: 20,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Apple',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          Text.rich(
                            TextSpan(
                              text: '¿No tienes una cuenta? ',
                              style: const TextStyle(
                                color: FudiColors.mutedForeground,
                              ),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () =>
                                        context.go(RouteNames.signupPath),
                                    child: const Text(
                                      'Regístrate gratis',
                                      style: TextStyle(
                                        color: FudiColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
