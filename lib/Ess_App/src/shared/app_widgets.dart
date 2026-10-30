import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:flutter/material.dart';

/// Reusable building blocks for the revamped screens. Use these for the
/// remaining modules (Loan, Capex, Education Aid, QMS ...) so every screen
/// shares one visual language.

/// White rounded card with the standard soft shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;
  final bool shadow;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.color,
    this.radius = 18,
    this.shadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: br,
        boxShadow: shadow ? AppColors.softShadow : null,
        border: Border.all(color: AppColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: br,
        child: InkWell(
          borderRadius: br,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// "Title ........ See all" row used above every section.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    Key? key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyling.section)),
          if (actionLabel != null)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: TextStyling.bold14
                          .copyWith(color: AppColors.primaryLight),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.primaryLight),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum StatusTone { success, warning, danger, info, neutral }

/// Small pill for statuses (Approved / Pending / Rejected ...).
class StatusChip extends StatelessWidget {
  final String label;
  final StatusTone tone;
  final Color? color; // optional override (e.g. a colour coming from the API)

  const StatusChip({
    Key? key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.color,
  }) : super(key: key);

  /// Maps free-text status strings to a tone.
  factory StatusChip.fromText(String label) {
    final s = label.toLowerCase();
    StatusTone tone = StatusTone.neutral;
    if (s.contains('approv') || s.contains('present') || s.contains('complete')) {
      tone = StatusTone.success;
    } else if (s.contains('pend') || s.contains('late') || s.contains('wait')) {
      tone = StatusTone.warning;
    } else if (s.contains('reject') || s.contains('absent') || s.contains('declin')) {
      tone = StatusTone.danger;
    } else if (s.contains('leave') || s.contains('visit') || s.contains('process')) {
      tone = StatusTone.info;
    }
    return StatusChip(label: label, tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    Color fg;
    Color bg;
    switch (tone) {
      case StatusTone.success:
        fg = AppColors.success;
        bg = AppColors.successSoft;
        break;
      case StatusTone.warning:
        fg = const Color(0xFFB45309);
        bg = AppColors.warningSoft;
        break;
      case StatusTone.danger:
        fg = AppColors.danger;
        bg = AppColors.dangerSoft;
        break;
      case StatusTone.info:
        fg = AppColors.info;
        bg = AppColors.infoSoft;
        break;
      case StatusTone.neutral:
        fg = AppColors.inkSoft;
        bg = AppColors.surfaceMuted;
        break;
    }
    if (color != null) {
      fg = color!;
      bg = color!.withOpacity(0.12);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyling.caption
            .copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}

/// Tinted rounded square holding an icon.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconTile({
    Key? key,
    required this.icon,
    this.color = AppColors.primary,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

/// Friendly empty state.
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const EmptyState({
    Key? key,
    this.title = 'Nothing here yet',
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyling.section, textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: TextStyling.body, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Label / value pair for detail screens.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text(label, style: TextStyling.caption)),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyling.bold14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Navy gradient page header for list/detail screens that want more presence
/// than [GeneralAppBar].
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;

  const GradientHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBack = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          18, MediaQuery.of(context).padding.top + 12, 18, 22),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyling.title.copyWith(color: Colors.white)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyling.caption
                        .copyWith(color: Colors.white.withOpacity(0.75)),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Standard "details" dialog used by list screens (leave, visits, ...).
/// [rows] are label/value pairs; [footer] is an optional extra widget.
Future<void> showDetailDialog(
    BuildContext context, {
      required String title,
      String? status,
      Color? statusColor,
      required List<MapEntry<String, String>> rows,
      Widget? footer,
    }) {
  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: TextStyling.title)),
                if (status != null)
                  StatusChip(label: status, color: statusColor),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final r in rows)
                      InfoRow(label: r.key, value: r.value),
                    if (footer != null) ...[
                      const SizedBox(height: 8),
                      footer,
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Three small count tiles (e.g. Sick / Casual / Annual).
class CountTiles extends StatelessWidget {
  final List<MapEntry<String, String>> items;
  const CountTiles({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(items[i].value, style: TextStyling.extraBold22
                      .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(items[i].key, style: TextStyling.caption),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Horizontal legend row (use with TitleWidget pills).
class LegendRow extends StatelessWidget {
  final List<Widget> children;
  const LegendRow({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Wrap(spacing: 8, runSpacing: 8, children: children),
    );
  }
}
