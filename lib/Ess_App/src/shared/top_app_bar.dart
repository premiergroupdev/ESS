import 'package:badges/badges.dart' as badges;
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:flutter/material.dart';

import '../views/notification/notification.dart';

/// Rounded square icon button used by every app bar.
class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool onDark;

  const AppBarIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.onDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onDark ? Colors.white.withOpacity(0.14) : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onDark
                  ? Colors.white.withOpacity(0.18)
                  : AppColors.border.withOpacity(0.8),
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: onDark ? AppColors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Notification bell that listens to [NotiCount] (null-safe).
class NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  final bool onDark;

  const NotificationBell({Key? key, required this.onTap, this.onDark = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: NotiCount.count,
      builder: (context, value, child) {
        final count = value ?? 0;
        return badges.Badge(
          position: badges.BadgePosition.topEnd(top: -6, end: -4),
          showBadge: count > 0,
          badgeContent: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: AppColors.danger,
            padding: EdgeInsets.all(5),
          ),
          child: AppBarIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: onTap,
            onDark: onDark,
          ),
        );
      },
    );
  }
}

/// Large navy greeting bar. Signature unchanged.
class HomeAppBar extends StatelessWidget {
  final String name;
  final Function onMenuTap;
  final Function onNotificationTap;

  const HomeAppBar(
      {Key? key,
        required this.name,
        required this.onMenuTap,
        required this.onNotificationTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          18, MediaQuery.of(context).padding.top + 12, 18, 18),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Row(
        children: [
          AppBarIconButton(
            icon: Icons.menu_rounded,
            onDark: true,
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalam o alaikum',
                  style: TextStyling.caption
                      .copyWith(color: Colors.white.withOpacity(0.75)),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyling.title.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          AppBarIconButton(
            icon: Icons.access_time_rounded,
            onDark: true,
            onTap: () => onNotificationTap(),
          ),
        ],
      ),
    );
  }
}

/// Back button + centred title + notification bell. Signature unchanged.
class GeneralAppBar extends StatelessWidget {
  final String title;
  final Function onMenuTap;
  final Function onNotificationTap;

  const GeneralAppBar({
    Key? key,
    required this.title,
    required this.onMenuTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 14, left: 18, right: 18),
      margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
      child: Row(
        children: [
          AppBarIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyling.title.copyWith(
                  color: AppColors.primary,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          NotificationBell(
            onTap: () async {
              NavService.notification();
              onNotificationTap();
            },
          ),
        ],
      ),
    );
  }
}

/// Back button + centred title, no bell. Signature unchanged.
class notiAppBar extends StatelessWidget {
  final String title;
  final Function onMenuTap;
  final Function onNotificationTap;

  const notiAppBar({
    Key? key,
    required this.title,
    required this.onMenuTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 14, left: 18, right: 18),
      margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
      child: Row(
        children: [
          AppBarIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyling.title.copyWith(
                  color: AppColors.primary,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          // Keeps the title optically centred.
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

/// Back button + left-aligned title. Signature unchanged.
class AppBarwidget extends StatelessWidget {
  final String title;
  final Function onMenuTap;
  final Function onNotificationTap;

  const AppBarwidget(
      {Key? key,
        required this.title,
        required this.onMenuTap,
        required this.onNotificationTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 14, left: 18, right: 18),
      margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
      child: Row(
        children: [
          AppBarIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyling.title.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
