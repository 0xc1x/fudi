import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/fudi_exception_l10n.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_logo.dart';
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
      final error = authState.error!;
      final message = error is FudiException
          ? error.userMessage()
          : 'No pudimos iniciar sesión. Intenta de nuevo.';
      setState(() => _errorMessage = message);
    }
  }

  Future<void> _openForgotPasswordDialog() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
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
                      : 'No pudimos enviar el correo de recuperación.';
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(message)));
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
      backgroundColor: FudiColors.muted,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: FudiColors.background,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: FudiColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => context.go(RouteNames.homePath),
                      icon: const Icon(FudiIcons.chevronLeft, size: 20),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Iniciar sesión',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const FudiLogo(
                            variant: FudiLogoVariant.icon,
                            size: FudiLogoSize.lg,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bienvenido de vuelta',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Inicia sesión para rescatar comida y ahorrar',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: FudiColors.mutedForeground),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: FudiColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: FudiColors.borderSolid),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Correo electrónico',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          FudiIcons.mail,
                                          size: 20,
                                          color: FudiColors.mutedForeground,
                                        ),
                                        hintText: 'tu@email.com',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: FudiColors.borderSolid,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: FudiColors.borderSolid,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: FudiColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
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
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Contraseña',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          FudiIcons.lock,
                                          size: 20,
                                          color: FudiColors.mutedForeground,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                          icon: Icon(
                                            _obscurePassword
                                                ? FudiIcons.eye
                                                : FudiIcons.eyeOff,
                                            size: 20,
                                            color: FudiColors.mutedForeground,
                                          ),
                                        ),
                                        hintText: '••••••••',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: FudiColors.borderSolid,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: FudiColors.borderSolid,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: FudiColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingresa tu contraseña';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : _openForgotPasswordDialog,
                                    style: TextButton.styleFrom(
                                      foregroundColor: FudiColors.primary,
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      '¿Olvidaste tu contraseña?',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
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
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _errorMessage = null),
                                    icon: Icon(
                                      FudiIcons.x,
                                      size: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: FudiColors.primary,
                                foregroundColor: FudiColors.primaryForeground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: isLoading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: FudiColors.primaryForeground,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Iniciando sesión...'),
                                      ],
                                    )
                                  : const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
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
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: FudiColors.borderSolid),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: FudiColors.background,
                                    side: const BorderSide(
                                      color: FudiColors.borderSolid,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CustomPaint(
                                          painter: _GoogleIconPainter(),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Google'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: FudiColors.background,
                                    side: const BorderSide(
                                      color: FudiColors.borderSolid,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      const Text('Apple'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text.rich(
                            TextSpan(
                              text: '¿No tienes una cuenta? ',
                              style: TextStyle(
                                color: FudiColors.mutedForeground,
                              ),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () =>
                                        context.go(RouteNames.signupPath),
                                    child: Text(
                                      'Regístrate gratis',
                                      style: TextStyle(
                                        color: FudiColors.primary,
                                        fontWeight: FontWeight.w600,
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

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final paint4285F4 = Paint()..color = const Color(0xFF4285F4);
    final paint34A853 = Paint()..color = const Color(0xFF34A853);
    final paintFBBC05 = Paint()..color = const Color(0xFFFBBC05);
    final paintEA4335 = Paint()..color = const Color(0xFFEA4335);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -0.15,
      1.83,
      false,
      paint4285F4,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      1.68,
      1.46,
      false,
      paint34A853,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.14,
      1.57,
      false,
      paintFBBC05,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      4.71,
      1.46,
      false,
      paintEA4335,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
