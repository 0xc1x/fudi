import 'package:flutter/material.dart';

import 'fudi_colors.dart';
import 'fudi_pressable_scale.dart';
import 'fudi_spacing.dart';
import 'fudi_surface_card.dart';
import 'fudi_typography.dart';
import 'atoms/icons/fudi_icons.dart';

/// Reusable contact chip for chat, email, call actions.
class FudiContactChip extends StatelessWidget {
  const FudiContactChip({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? FudiColorsDark.background : FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(color: isDark ? FudiColorsDark.borderSolid : FudiColors.borderSolid),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: FudiColors.primary),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              label,
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal list of contact actions (Chat, Email, Llamar).
class FudiQuickContact extends StatelessWidget {
  const FudiQuickContact({
    this.onChatTap,
    this.onEmailTap,
    this.onCallTap,
    super.key,
  });

  final VoidCallback? onChatTap;
  final VoidCallback? onEmailTap;
  final VoidCallback? onCallTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FudiContactChip(
            icon: FudiIcons.messageSquare,
            label: 'Chat',
            onTap: onChatTap ?? () {},
          ),
        ),
        const SizedBox(width: FudiSpacing.md),
        Expanded(
          child: FudiContactChip(
            icon: FudiIcons.mail,
            label: 'Email',
            onTap: onEmailTap ?? () {},
          ),
        ),
        const SizedBox(width: FudiSpacing.md),
        Expanded(
          child: FudiContactChip(
            icon: FudiIcons.phone,
            label: 'Llamar',
            onTap: onCallTap ?? () {},
          ),
        ),
      ],
    );
  }
}

/// Data class for FAQ item.
class FudiFAQData {
  const FudiFAQData({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  final String id;
  final String question;
  final String answer;
  final String category;
}

/// Data class for Help Category item.
class FudiHelpCategory {
  const FudiHelpCategory({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTap;
}

/// Section displaying help categories in a clean list card.
class FudiCategoriesSection extends StatelessWidget {
  const FudiCategoriesSection({
    required this.categories,
    this.title = 'Categorías',
    super.key,
  });

  final String title;
  final List<FudiHelpCategory> categories;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            child: Text(title, style: FudiTypography.labelSmall),
          ),
          Divider(height: 1, color: isDark ? FudiColorsDark.borderSolid : FudiColors.borderSolid),
          ...categories.map((cat) => _FudiCategoryRow(category: cat, isDark: isDark)),
        ],
      ),
    );
  }
}

class _FudiCategoryRow extends StatelessWidget {
  const _FudiCategoryRow({required this.category, required this.isDark});
  final FudiHelpCategory category;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: category.onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, size: 20, color: category.iconColor),
            ),
            const SizedBox(width: FudiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: FudiTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(category.subtitle, style: FudiTypography.bodySmall),
                ],
              ),
            ),
            Icon(
              FudiIcons.chevronRight,
              size: 20,
              color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section containing expansion FAQ tiles.
class FudiFAQSection extends StatelessWidget {
  const FudiFAQSection({
    required this.items,
    required this.expandedId,
    required this.onToggle,
    this.title = 'Preguntas frecuentes',
    super.key,
  });

  final String title;
  final List<FudiFAQData> items;
  final String? expandedId;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            child: Text(title, style: FudiTypography.labelSmall),
          ),
          Divider(height: 1, color: isDark ? FudiColorsDark.borderSolid : FudiColors.borderSolid),
          ...items.map(
            (faq) => _FudiFAQRow(
              faq: faq,
              isExpanded: expandedId == faq.id,
              onToggle: () => onToggle(faq.id),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _FudiFAQRow extends StatelessWidget {
  const _FudiFAQRow({
    required this.faq,
    required this.isExpanded,
    required this.onToggle,
    required this.isDark,
  });

  final FudiFAQData faq;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              FudiIcons.helpCircle,
              size: 20,
              color: FudiColors.primary,
            ),
            const SizedBox(width: FudiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faq.question,
                    style: FudiTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: FudiSpacing.sm),
                    Text(
                      faq.answer,
                      style: FudiTypography.bodySmall.copyWith(
                        color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                FudiIcons.chevronRight,
                size: 20,
                color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Call-to-action support contact card.
class FudiContactSupportCard extends StatelessWidget {
  const FudiContactSupportCard({
    this.title = '¿No encuentras lo que buscas?',
    this.subtitle = 'Nuestro equipo de soporte está disponible para ayudarte',
    this.buttonText = 'Contactar soporte',
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FudiColors.primary,
            FudiColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: isDark ? FudiColorsDark.shadow : FudiColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FudiTypography.labelSmall.copyWith(color: FudiColors.primaryForeground),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            subtitle,
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.primaryForeground.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FudiPressableScale(
              onTap: onTap ?? () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
                decoration: BoxDecoration(
                  color: FudiColors.primaryForeground,
                  borderRadius: BorderRadius.circular(FudiRadius.md),
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: FudiColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen detail page for help categories.
class HelpCategoryDetailPage extends StatelessWidget {
  const HelpCategoryDetailPage({
    required this.title,
    required this.sections,
    super.key,
  });

  final String title;
  final List<HelpSection> sections;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: isDark ? FudiColorsDark.shadow : FudiColors.shadow,
        leading: Padding(
          padding: const EdgeInsets.only(left: FudiSpacing.sm),
          child: IconButton(
            icon: const Icon(FudiIcons.chevronLeft, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(title, style: FudiTypography.h4),
      ),
      body: ListView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        children: [
          for (final section in sections) ...[
            FudiSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(FudiSpacing.lg),
                    child: Text(
                      section.title,
                      style: FudiTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (section.items.isNotEmpty)
                    Divider(height: 1, color: isDark ? FudiColorsDark.borderSolid : FudiColors.borderSolid),
                  for (final item in section.items)
                    HelpItemRow(item: item),
                ],
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
          ],
        ],
      ),
    );
  }
}

class HelpSection {
  const HelpSection({required this.title, this.items = const []});
  final String title;
  final List<HelpItem> items;
}

class HelpItem {
  const HelpItem({required this.title, required this.description});
  final String title;
  final String description;
}

class HelpItemRow extends StatelessWidget {
  const HelpItemRow({required this.item, super.key});
  final HelpItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.lg,
        vertical: FudiSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? FudiColorsDark.foreground : FudiColors.foreground,
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            item.description,
            style: FudiTypography.bodySmall.copyWith(
              color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple layout showing support hours schedule info.
class FudiScheduleInfo extends StatelessWidget {
  const FudiScheduleInfo({
    this.title = 'Horario de atención',
    this.weekdayHours = 'Lunes a Viernes: 8:00 - 20:00',
    this.weekendHours = 'Sábados: 9:00 - 18:00',
    super.key,
  });

  final String title;
  final String weekdayHours;
  final String weekendHours;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: FudiTypography.bodySmall),
        const SizedBox(height: FudiSpacing.xs),
        Text(
          weekdayHours,
          style: FudiTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          weekendHours,
          style: FudiTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
