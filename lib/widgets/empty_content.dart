import 'package:flutter/material.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_states.dart';

/// The legacy empty-state widget, re-pointed at [VinkolStateView] (decision D-03).
///
/// The old version was one 120pt brand-tinted circle, an 80pt icon and a line of grey text,
/// used identically everywhere, with **no action**. That is a dead end: it tells a user the
/// screen is empty, which they can see, and offers nothing to do about it.
///
/// The API is kept so existing call sites compile, but it is deliberately narrow now:
/// [title] and [action] have no defaults worth guessing, so a caller that has not decided
/// what this particular emptiness means gets a compile error rather than a generic screen.
/// Prefer constructing [VinkolStateView.empty] directly in new code.
@Deprecated(
  'Use VinkolStateView.empty, which requires its own copy and an action. '
  'EmptyContent exists only to keep older call sites compiling.',
)
class EmptyContent extends StatelessWidget {
  const EmptyContent({
    super.key,
    required this.title,
    required this.contentText,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String contentText;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return VinkolStateView.empty(
      icon: icon,
      title: title,
      message: contentText,
      action: VinkolStateAction(label: actionLabel, onPressed: onAction),
    );
  }
}
