import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/error/fudi_exception.dart';
import '../../../core/error/fudi_exception_l10n.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_logo.dart';
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
        const SnackBar(content: Text('Debes aceptar los términos y condiciones')),
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
                    'Crear cuenta',
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
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const FudiLogo(variant: FudiLogoVariant.icon, size: FudiLogoSize.lg),
                          const SizedBox(height: 12),
                          Text(
                            'Únete a Fudi',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rescata comida deliciosa y ayuda al planeta',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: FudiColors.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
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
                                      'Nombre completo',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _fullNameController,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(FudiIcons.userCircle, size: 20, color: FudiColors.mutedForeground),
                                        hintText: 'Tu nombre',
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
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Ingresa tu nombre';
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
                                      'Correo electrónico',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(FudiIcons.mail, size: 20, color: FudiColors.mutedForeground),
                                        hintText: 'tu@email.com',
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
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Contraseña',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(FudiIcons.lock, size: 20, color: FudiColors.mutedForeground),
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                          icon: Icon(
                                            _obscurePassword ? FudiIcons.eye : FudiIcons.eyeOff,
                                            size: 20,
                                            color: FudiColors.mutedForeground,
                                          ),
                                        ),
                                        hintText: 'Mínimo 8 caracteres',
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
                                    const SizedBox(height: 4),
                                    Text(
                                      'La contraseña debe tener al menos 8 caracteres',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: FudiColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
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
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _acceptedTerms,
                                    onChanged: isLoading
                                        ? null
                                        : (value) => setState(() => _acceptedTerms = value ?? false),
                                    activeColor: FudiColors.primary,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: FudiColors.mutedForeground,
                                        height: 1.5,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Acepto los '),
                                        TextSpan(
                                          text: 'Términos y Condiciones',
                                          style: TextStyle(
                                            color: FudiColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const TextSpan(text: ' y la '),
                                        TextSpan(
                                          text: 'Política de Privacidad',
                                          style: TextStyle(
                                            color: FudiColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const TextSpan(text: ' de Fudi'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: (isLoading || !_acceptedTerms) ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: _acceptedTerms ? FudiColors.primary : FudiColors.muted,
                                foregroundColor: _acceptedTerms ? FudiColors.primaryForeground : FudiColors.mutedForeground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: _acceptedTerms ? 4 : 0,
                              ),
                              child: isLoading
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                        Text('Creando cuenta...'),
                                      ],
                                    )
                                  : const Text('Crear cuenta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Row(
                            children: [
                              Expanded(child: Divider(color: FudiColors.borderSolid)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o regístrate con',
                                  style: TextStyle(color: FudiColors.mutedForeground, fontSize: 13),
                                ),
                              ),
                              Expanded(child: Divider(color: FudiColors.borderSolid)),
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
                                    side: const BorderSide(color: FudiColors.borderSolid),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                                    side: const BorderSide(color: FudiColors.borderSolid),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.apple, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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
                              text: '¿Ya tienes una cuenta? ',
                              style: TextStyle(color: FudiColors.mutedForeground),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () => context.go(RouteNames.loginPath),
                                    child: Text(
                                      'Inicia sesión',
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
                          const SizedBox(height: 32),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Por qué unirte a Fudi?',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _BenefitItem(text: 'Ahorra hasta un 70% en comida deliciosa'),
                                _BenefitItem(text: 'Ayuda a reducir el desperdicio de alimentos'),
                                _BenefitItem(text: 'Descubre nuevos restaurantes y cafés'),
                                _BenefitItem(text: 'Contribuye a un planeta más sostenible'),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, size: 16, color: Color(0xFF15803D)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF15803D),
              ),
            ),
          ),
        ],
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
