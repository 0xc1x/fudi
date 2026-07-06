import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/fudi_exception_l10n.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_theme.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/atoms/icons/fudi_google_icon.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
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
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  final UserRole _selectedRole = UserRole.user;
  final bool _analyticsConsentGranted = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
        ),
      );
      return;
    }

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

  InputDecoration _inputDecoration({
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();

    return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      filled: true,
      fillColor: themeExt?.mutedBackground ?? theme.colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: themeExt?.borderSolid ?? theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: themeExt?.borderSolid ?? theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final resolvedMutedForeground = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final resolvedBorderColor = themeExt?.borderSolid ?? theme.colorScheme.outline.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Clean Header Navigation
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
                        color: themeExt?.mutedBackground ?? theme.colorScheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FudiIcons.chevronLeft,
                        size: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Crear cuenta',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: resolvedBorderColor, height: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
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
                            'Únete a Fudi',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rescata comida deliciosa y ayuda al planeta',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: resolvedMutedForeground),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Form Block
                          Text(
                            'Nombre completo',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'Tu nombre y apellido',
                              prefixIcon: Icon(
                                FudiIcons.userCircle,
                                size: 20,
                                color: resolvedMutedForeground,
                              ),
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Ingresa tu nombre'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Correo electrónico',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'tu@email.com',
                              prefixIcon: Icon(
                                FudiIcons.mail,
                                size: 20,
                                color: resolvedMutedForeground,
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
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(
                              hintText: 'Mínimo 8 caracteres',
                              prefixIcon: Icon(
                                FudiIcons.lock,
                                size: 20,
                                color: resolvedMutedForeground,
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
                                  color: resolvedMutedForeground,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa una contraseña';
                              }
                              if (value.length < 8) {
                                return 'Mínimo 8 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Terms and Conditions Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: isLoading
                                      ? null
                                      : (value) => setState(
                                          () => _acceptedTerms = value ?? false,
                                        ),
                                  activeColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                          color: resolvedMutedForeground,
                                          height: 1.4,
                                        ),
                                    children: [
                                      const TextSpan(text: 'Acepto los '),
                                      TextSpan(
                                        text: 'Términos y Condiciones',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              context.go(RouteNames.termsPath),
                                      ),
                                      const TextSpan(text: ' y la '),
                                      TextSpan(
                                        text: 'Política de Privacidad',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => context.go(
                                            RouteNames.privacyPath,
                                          ),
                                      ),
                                      const TextSpan(text: ' de Fudi'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Main Action Button
                          FudiPressableScale(
                            onTap: (isLoading || !_acceptedTerms)
                                ? null
                                : _submit,
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: _acceptedTerms
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        'Crear cuenta',
                                        style: TextStyle(
                                          color: _acceptedTerms
                                              ? theme.colorScheme.onPrimary
                                              : resolvedMutedForeground,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Social Splitter
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: resolvedBorderColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o regístrate con',
                                  style: TextStyle(
                                    color: resolvedMutedForeground,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: resolvedBorderColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social Login Row
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
                                      color: themeExt?.cardBg ?? theme.cardTheme.color ?? theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: resolvedBorderColor,
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
                                            color: theme.colorScheme.onSurface,
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
                                      color: themeExt?.cardBg ?? theme.cardTheme.color ?? theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: resolvedBorderColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Icon(
                                            Icons.apple,
                                            size: 20,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Apple',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
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

                          // Login Redirect
                          Text.rich(
                            TextSpan(
                              text: '¿Ya tienes una cuenta? ',
                              style: TextStyle(
                                color: resolvedMutedForeground,
                              ),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () =>
                                        context.go(RouteNames.loginPath),
                                    child: Text(
                                      'Inicia sesión',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Benefits Section
                          Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? FudiColors.success.withValues(alpha: 0.08)
                                  : FudiColors.surfaceSuccess.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.brightness == Brightness.dark
                                    ? FudiColors.success.withValues(alpha: 0.15)
                                    : FudiColors.surfaceSuccess,
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Por qué unirte a Fudi?',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                          color: theme.brightness == Brightness.dark
                                              ? FudiColors.success
                                              : FudiColors.successDark,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                const _BenefitItem(
                                  text:
                                      'Ahorra hasta un 70% en comida deliciosa',
                                ),
                                const _BenefitItem(
                                  text:
                                      'Ayuda a reducir el desperdicio de alimentos',
                                ),
                                const _BenefitItem(
                                  text: 'Descubre nuevos restaurantes y cafés',
                                ),
                                const _BenefitItem(
                                  text:
                                      'Contribuye a un planeta más sostenible',
                                ),
                              ],
                            ),
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

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Icon(
              Icons.check_rounded,
              size: 18,
              color: isDark ? FudiColors.success : FudiColors.successDark,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? FudiColors.success : FudiColors.successDark,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
