import 'package:ess/Ess_App/generated/assets.dart';
import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:ess/Ess_App/src/views/menu/menu_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MenuView extends StatelessWidget {
  const MenuView({Key? key}) : super(key: key);

  static BuildContext? _privateCtx;

  static close() {
    if (_privateCtx != null) {
      Navigator.of(_privateCtx!).pop();
    }
  }

  static open() {
    if (_privateCtx != null) {
      Scaffold.of(_privateCtx!).openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MenuViewModel>.reactive(
      builder: (context, model, child) {
        return SizedBox(
          width: context.screenSize().width * 0.82,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // ── Compact gradient header ───────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 12,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company logo
                      // Image(
                      //   image: AssetImage(Assets.imagesPremierlogo),
                      //   height: 28,
                      //   fit: BoxFit.contain,
                      // ),
                      const SizedBox(height: 12),

                      // Avatar + user info
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                "https://cdn.iconscout.com/icon/free/png-256/avatar-370-456322.png",
                                height: 42,
                                width: 42,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.currentUser?.userName.toString() ?? '',
                                  style: TextStyling.bold14
                                      .copyWith(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'ID: ${model.currentUser?.userId.toString() ?? ''}',
                                    style: TextStyling.text12.copyWith(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Menu items ─────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      children: model.menuItems.map((e) {
                        int index = model.menuItems
                            .indexWhere((element) => element.label == e.label)
                            .toInt();
                        final bool isExpanded = index == model.collapsedIndex;

                        return Column(
                          children: [
                            // Parent item
                            InkWell(
                              onTap: () => e.onPress(),
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? AppColors.primary.withOpacity(0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e.label,
                                        style: TextStyling.bold14.copyWith(
                                          fontSize: 13,
                                          color: isExpanded
                                              ? AppColors.primary
                                              : AppColors.black,
                                        ),
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.25 : 0.0,
                                      duration:
                                      const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: isExpanded
                                            ? AppColors.primary
                                            : AppColors.grey,
                                        size: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Children
                            AnimatedCrossFade(
                              firstChild:
                              const SizedBox(width: double.infinity),
                              secondChild: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 2, 0, 2),
                                child: Column(
                                  children: e.children
                                      ?.map(
                                        (en) => InkWell(
                                      onTap: () => en.onPress(),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                      child: Container(
                                        width: double.infinity,
                                        margin:
                                        const EdgeInsets.symmetric(
                                            vertical: 2),
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color:
                                                AppColors.secondary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                en.label,
                                                style: TextStyling
                                                    .text14
                                                    .copyWith(
                                                  fontSize: 12.5,
                                                  color:
                                                  AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                      .toList() ??
                                      [],
                                ),
                              ),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 220),
                            ),

                            // Thin divider
                            Divider(
                                height: 4,
                                thickness: 0.6,
                                color: AppColors.border),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Logout button ──────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: InkWell(
                    onTap: () => model.onLogout(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyling.bold14
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      viewModelBuilder: () => MenuViewModel(context),
      onModelReady: (model) => model.init(context),
    );
  }
}

class MenuChildTileModel {
  final String title;
  final Function onTap;

  MenuChildTileModel({required this.title, required this.onTap});
}

class MenuTile extends StatefulWidget {
  final String title;
  final Function onTap;
  final bool isParent;
  final int currentIndex;
  final int collapsedIndex;
  final List<MenuChildTileModel>? children;

  const MenuTile({
    Key? key,
    required this.title,
    required this.onTap,
    this.children,
    required this.isParent,
    required this.currentIndex,
    required this.collapsedIndex,
  }) : super(key: key);

  @override
  State<MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> {
  @override
  Widget build(BuildContext context) {
    final bool isExpanded = widget.currentIndex != widget.collapsedIndex;
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              widget.onTap();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyling.bold16.copyWith(color: AppColors.primary),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
        if (!isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Column(
              children: widget.children
                  ?.map((e) => InkWell(
                onTap: () => widget.onTap(),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyling.bold16.copyWith(
                            color: AppColors.primary
                                .withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ))
                  .toList() ??
                  [],
            ),
          )
      ],
    );
  }
}