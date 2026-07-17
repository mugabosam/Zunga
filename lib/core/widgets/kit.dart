import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Shared widget kit — one system for all 22 screens.

class ZCard extends StatelessWidget {
  const ZCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 24),
    this.padding = EdgeInsets.zero,
    this.radius = ZTokens.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ZTokens.surface,
        border: Border.all(color: ZTokens.line),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key, this.topPadding = 20});

  final String text;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 10),
      child: Text(text.toUpperCase(), style: ZText.groupLabel),
    );
  }
}

class AvatarBox extends StatelessWidget {
  const AvatarBox(
    this.initials, {
    super.key,
    this.size = 42,
    this.dark = false,
    this.accent = false,
  });

  final String initials;
  final double size;
  final bool dark;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? ZTokens.ink : ZTokens.bg,
        border: dark ? null : Border.all(color: ZTokens.line),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.31,
          fontWeight: FontWeight.w600,
          color: dark
              ? Colors.white
              : accent
                  ? ZTokens.accent
                  : ZTokens.ink2,
        ),
      ),
    );
  }
}

/// List row with a leading icon box, title/subtitle and a chevron —
/// the `.bill` row of the design system.
class BillRow extends StatelessWidget {
  const BillRow({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.dueText,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final String? dueText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            leading ??
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: ZTokens.bg,
                    border: Border.all(color: ZTokens.line),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 20, color: ZTokens.ink),
                ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: ZText.rowTitle, overflow: TextOverflow.ellipsis),
                  if (subtitle != null || dueText != null)
                    Text.rich(
                      TextSpan(children: [
                        if (subtitle != null)
                          TextSpan(text: subtitle, style: ZText.rowSub),
                        if (dueText != null)
                          TextSpan(
                            text: dueText,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: ZTokens.accent,
                            ),
                          ),
                      ]),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            trailing ??
                (showChevron
                    ? const Icon(Icons.chevron_right,
                        size: 20, color: ZTokens.ink3)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// A bordered group of rows separated by soft hairlines (`.bill-group`).
class RowGroup extends StatelessWidget {
  const RowGroup({super.key, required this.children, this.margin});

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return ZCard(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

enum PillKind { ok, wait, connect }

class StatusPill extends StatelessWidget {
  const StatusPill(this.text, {super.key, this.kind = PillKind.ok});

  final String text;
  final PillKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (kind) {
      PillKind.ok => (ZTokens.accentTint, ZTokens.accent, Colors.transparent),
      PillKind.wait => (ZTokens.bg, ZTokens.ink3, ZTokens.line),
      PillKind.connect => (ZTokens.ink, Colors.white, Colors.transparent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(ZTokens.radiusPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.33,
          color: fg,
        ),
      ),
    );
  }
}

/// Transaction row (`.tx`): avatar, name, sub, signed amount.
class TxRow extends StatelessWidget {
  const TxRow({
    super.key,
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.amountRwf,
    this.incoming = false,
  });

  final String initials;
  final String title;
  final String subtitle;
  final String amountRwf;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          AvatarBox(initials),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: ZText.rowTitle, overflow: TextOverflow.ellipsis),
                Text(subtitle,
                    style: ZText.rowSub, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            '${incoming ? '+' : '−'}$amountRwf',
            style: ZText.num14.copyWith(
              color: incoming ? ZTokens.accent : ZTokens.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Accent-tinted banner used for verified names and eKash routing.
class AccentBanner extends StatelessWidget {
  const AccentBanner({
    super.key,
    this.hint,
    required this.title,
    this.subtitle,
    this.margin = const EdgeInsets.fromLTRB(24, 16, 24, 0),
  });

  final String? hint;
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ZTokens.accentTint,
        border: Border.all(color: ZTokens.accentBorder),
        borderRadius: BorderRadius.circular(ZTokens.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: ZTokens.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      hint!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.58,
                        color: ZTokens.accent,
                      ),
                    ),
                  ),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                        fontSize: 12.5, color: ZTokens.ink2, height: 1.5),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small informational note with a leading icon (`.rail-note` / `.note`).
class RailNote extends StatelessWidget {
  const RailNote(
    this.text, {
    super.key,
    this.icon = Icons.info_outline,
    this.iconColor = ZTokens.accent,
    this.margin = const EdgeInsets.fromLTRB(24, 14, 24, 0),
  });

  final String text;
  final IconData icon;
  final Color iconColor;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 12.5, color: ZTokens.ink2, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-option segmented control (`.seg`).
class SegControl extends StatelessWidget {
  const SegControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ZTokens.surface,
        border: Border.all(color: ZTokens.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == selected ? ZTokens.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    options[i],
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: i == selected ? Colors.white : ZTokens.ink3,
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

/// Numeric keypad (`.keypad`). Emits digits and backspace; when
/// [onClear] is given the bottom-left key becomes `clear`.
class ZKeypad extends StatelessWidget {
  const ZKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onClear,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return Expanded(
        child: InkWell(
          onTap: onTap ?? () => onDigit(label),
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 60,
            child: Center(
              child: child ??
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.w500),
                  ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 6, 32, 18),
      child: Column(
        children: [
          Row(children: [key('1'), key('2'), key('3')]),
          Row(children: [key('4'), key('5'), key('6')]),
          Row(children: [key('7'), key('8'), key('9')]),
          Row(children: [
            onClear != null
                ? key(
                    'clear',
                    onTap: onClear,
                    child: const Text(
                      'clear',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ZTokens.accent),
                    ),
                  )
                : key('·', onTap: () {}),
            key('0'),
            key(
              '⌫',
              onTap: onBackspace,
              child: const Icon(Icons.backspace_outlined, size: 24),
            ),
          ]),
        ],
      ),
    );
  }
}

/// PIN progress dots (`.pins`).
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled, this.total = 4});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? ZTokens.ink : Colors.transparent,
              border: Border.all(
                color: i < filled ? ZTokens.ink : ZTokens.line,
                width: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

/// Thin progress bar (`.prog`).
class ZProgress extends StatelessWidget {
  const ZProgress(this.value, {super.key});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: ZTokens.lineSoft,
        valueColor: const AlwaysStoppedAnimation(ZTokens.accent),
      ),
    );
  }
}

/// RWF amount formatter with thousands separators.
String rwf(num amount) {
  final s = amount.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
