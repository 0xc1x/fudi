import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: FudiColors.muted.withValues(alpha: 0.5),
            child: FudiPressableScale(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: FudiColors.foreground,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const FudiLogo(),
        centerTitle: false,
      ),
      body: const SingleChildScrollView(
        child: Column(children: [_Hero(), _Mission(), _Values(), _Stats()]),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FudiColors.secondary.withValues(alpha: 0.3),
            FudiColors.secondary.withValues(alpha: 0.1),
            FudiColors.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 80 : 48,
        horizontal: FudiSpacing.xl,
      ),
      child: Column(
        children: [
          Text(
            'Nuestra Misión',
            textAlign: TextAlign.center,
            style: FudiTypography.h1.copyWith(fontSize: isWide ? 48 : 28),
          ),
          const SizedBox(height: 24),
          Text(
            'En Fudi, creemos que la buena comida no debería desperdiciarse. Estamos construyendo el marketplace de excedentes más grande de Latinoamérica.',
            textAlign: TextAlign.center,
            style: FudiTypography.bodyLarge.copyWith(
              color: FudiColors.mutedForeground,
              fontSize: isWide ? 20 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _Mission extends StatelessWidget {
  const _Mission();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 100 : 48,
        horizontal: FudiSpacing.xl,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: isWide
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Por qué existimos?',
                            style: TextStyle(
                              fontSize: isWide ? 32 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Cada año, un tercio de toda la comida producida en el mundo se desperdicia. Esto no solo es un problema social y económico, sino también una de las principales causas del cambio climático.',
                            style: FudiTypography.bodyLarge.copyWith(
                              color: FudiColors.mutedForeground,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Fudi nace para conectar a los comercios que tienen excedentes diarios con usuarios que quieren disfrutar de comida de calidad a un precio reducido, reduciendo juntos el impacto ambiental.',
                            style: FudiTypography.bodyLarge.copyWith(
                              color: FudiColors.mutedForeground,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 80),
                    Expanded(
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: FudiColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Center(
                          child: Text('🌍', style: TextStyle(fontSize: 120)),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const Text(
                      '¿Por qué existimos?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cada año, un tercio de toda la comida producida en el mundo se desperdicia. Esto no solo es un problema social y económico, sino también una de las principales causas del cambio climático.',
                      textAlign: TextAlign.center,
                      style: FudiTypography.bodyLarge.copyWith(
                        color: FudiColors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Fudi nace para conectar a los comercios que tienen excedentes diarios con usuarios que quieren disfrutar de comida de calidad a un precio reducido, reduciendo juntos el impacto ambiental.',
                      textAlign: TextAlign.center,
                      style: FudiTypography.bodyLarge.copyWith(
                        color: FudiColors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FudiColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Center(
                        child: Text('🌍', style: TextStyle(fontSize: 80)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Values extends StatelessWidget {
  const _Values();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 100 : 48,
        horizontal: FudiSpacing.xl,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Nuestros Valores',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isWide ? 32 : 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: isWide ? 64 : 32),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 3 : 1,
                mainAxisSpacing: isWide ? 32 : 16,
                crossAxisSpacing: isWide ? 32 : 0,
                childAspectRatio: isWide ? 0.8 : 2.5,
                children: const [
                  _ValueCard(
                    icon: Icons.eco_outlined,
                    title: 'Sostenibilidad',
                    description:
                        'Cada acción que tomamos busca reducir el impacto ambiental y promover un consumo responsable.',
                  ),
                  _ValueCard(
                    icon: Icons.favorite_border,
                    title: 'Comunidad',
                    description:
                        'Creamos vínculos fuertes entre comercios y vecinos, fortaleciendo la economía local.',
                  ),
                  _ValueCard(
                    icon: Icons.lightbulb_outline,
                    title: 'Innovación',
                    description:
                        'Usamos la tecnología para resolver problemas complejos de logística y desperdicio.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: EdgeInsets.all(isWide ? 32 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FudiColors.muted.withValues(alpha: 0.5)),
      ),
      child: isWide
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FudiColors.secondary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: FudiColors.primary, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FudiColors.secondary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: FudiColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWide ? 100 : 48, horizontal: FudiSpacing.xl),
      child: Column(
        children: [
          Text(
            'Nuestro impacto hasta hoy',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isWide ? 32 : 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: isWide ? 64 : 32),
          isWide
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(value: '500k+', label: 'Comidas rescatadas'),
                    _StatItem(value: '2k+', label: 'Comercios aliados'),
                    _StatItem(value: '100k+', label: 'Usuarios activos'),
                    _StatItem(value: '1.2M', label: 'kg de CO2 ahorrados'),
                  ],
                )
              : const Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 24,
                  spacing: 32,
                  children: [
                    _StatItem(value: '500k+', label: 'Comidas rescatadas'),
                    _StatItem(value: '2k+', label: 'Comercios aliados'),
                    _StatItem(value: '100k+', label: 'Usuarios activos'),
                    _StatItem(value: '1.2M', label: 'kg de CO2 ahorrados'),
                  ],
                ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isWide ? 48 : 32,
            fontWeight: FontWeight.bold,
            color: FudiColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: FudiTypography.bodyMedium.copyWith(
            color: FudiColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
