import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';

/// 36×36 bordered back button (`.topbar .back`).
class ZBackButton extends StatelessWidget {
  const ZBackButton({super.key, this.icon = Icons.arrow_back_ios_new, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => context.pop(),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: ZTokens.surface,
          borderRadius: BorderRadius.circular(13),
          boxShadow: ZTokens.shadowSoft,
        ),
        child: Icon(icon, size: 16, color: ZTokens.ink),
      ),
    );
  }
}

PreferredSizeWidget zAppBar(
  BuildContext context, {
  required String title,
  bool showBack = true,
  Widget? trailing,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    leadingWidth: 60,
    leading: showBack
        ? const Padding(
            padding: EdgeInsets.only(left: 24),
            child: Center(child: ZBackButton()),
          )
        : null,
    title: Text(title),
    actions: [
      if (trailing != null)
        Padding(padding: const EdgeInsets.only(right: 24), child: trailing),
      if (trailing == null && showBack) const SizedBox(width: 60),
    ],
  );
}

/// Big page title used on tab roots (`Activity`, `Pay`, `Profile`).
class PageTitleBar extends StatelessWidget {
  const PageTitleBar(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: ZText.pageTitle),
          ?trailing,
        ],
      ),
    );
  }
}
