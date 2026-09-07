/// Pieces shared by the profile section: the avatar, the grouped surface, the destructive
/// row and the FAQ disclosure.
///
/// Everything a plain [VinkolRow] can already say is said with one — these exist only for the
/// three things it cannot: a destructive row, a row that expands, and an identity block.
library;

import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// The identity disc: the prototype's `.av`.
///
/// Initials on a quiet surface rather than a brand-filled circle. Midnight allows one
/// saturated object per screen and on Profile there is no live thing to spend it on, so the
/// avatar stays neutral (D-07).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.file,
    this.size = 56,
  });

  final String initials;

  /// The stored avatar, when the user has one.
  final String? imageUrl;

  /// A freshly picked image, before it has been uploaded. Wins over [imageUrl].
  final ImageProvider<Object>? file;

  final double size;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final ImageProvider<Object>? image = file ??
        ((imageUrl != null && imageUrl!.isNotEmpty)
            ? NetworkImage(imageUrl!)
            : null);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: v.surfaceAlt,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: v.borderSubtle)),
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      child: image != null
          ? null
          : Text(
              initials,
              style: VinkolType.h3.copyWith(
                color: v.textSecondary,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// Initials from whatever of a name is present. Falls back to the first letter of the email,
/// then to a dash — never to an empty circle, which reads as a failed image.
String profileInitials({String? first, String? last, String? email}) {
  final a = (first ?? '').trim();
  final b = (last ?? '').trim();
  if (a.isNotEmpty && b.isNotEmpty) return '${a[0]}${b[0]}'.toUpperCase();
  if (a.isNotEmpty) return a[0].toUpperCase();
  if (b.isNotEmpty) return b[0].toUpperCase();
  final e = (email ?? '').trim();
  if (e.isNotEmpty) return e[0].toUpperCase();
  return '–';
}

/// A bordered surface holding arbitrary rows, hairline-separated.
///
/// [VinkolRowGroup] does the same for a list of [VinkolRow]s; this is its sibling for the
/// rows that are not one — a switch row, a disclosure, a destructive action.
class ProfileGroup extends StatelessWidget {
  const ProfileGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brLg,
        border: VinkolElevation.hairline(v),
        boxShadow: VinkolElevation.e1(v),
      ),
      child: ClipRRect(
        borderRadius: VinkolRadius.brLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) Container(height: 1, color: v.borderSubtle),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// A row whose action destroys something.
///
/// The danger colour is carried by the icon well *and* the title, and the row still says in
/// words what will happen — colour is never the only signal (D-05).
class ProfileDangerRow extends StatefulWidget {
  const ProfileDangerRow({
    super.key,
    required this.icon,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  State<ProfileDangerRow> createState() => _ProfileDangerRowState();
}

class _ProfileDangerRowState extends State<ProfileDangerRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _pressed ? v.surfaceAlt : Colors.transparent,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: VinkolSpace.lg,
            vertical: 14,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v.dangerGround,
                  borderRadius: VinkolRadius.brSm,
                ),
                child: Icon(widget.icon, size: 19, color: v.danger),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: VinkolType.h4.copyWith(color: v.danger),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.meta,
                      style: VinkolType.bodyS.copyWith(color: v.textTertiary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VinkolSpace.sm),
              Icon(Icons.chevron_right, size: 16, color: v.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// One question in the FAQ.
///
/// A disclosure rather than a separate screen: an answer is two sentences, and pushing a
/// route for two sentences costs the reader the list they were scanning. The chevron rotates
/// so the open state carries shape, and the whole header is one 44pt target.
class ProfileFaqItem extends StatefulWidget {
  const ProfileFaqItem({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<ProfileFaqItem> createState() => _ProfileFaqItemState();
}

class _ProfileFaqItemState extends State<ProfileFaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final duration = VinkolMotion.respecting(context, VinkolMotion.fast);

    return Semantics(
      button: true,
      expanded: _open,
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        behavior: HitTestBehavior.opaque,
        child: AnimatedSize(
          duration: duration,
          curve: VinkolMotion.standard,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: VinkolSpace.lg,
              vertical: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.question,
                        style: VinkolType.h4.copyWith(color: v.textPrimary),
                      ),
                    ),
                    const SizedBox(width: VinkolSpace.md),
                    AnimatedRotation(
                      duration: duration,
                      curve: VinkolMotion.standard,
                      turns: _open ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: v.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (_open) ...<Widget>[
                  const SizedBox(height: VinkolSpace.sm),
                  Text(
                    widget.answer,
                    style: VinkolType.bodyS.copyWith(color: v.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens an external link, and says so when it cannot.
///
/// Every contact channel and legal document lives on the web; a tap that silently does
/// nothing is the failure mode worth spending a line of code on.
Future<void> profileLaunch(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = context.l10n.supportLinkFailed;
  try {
    final opened =
        await launchUrlString(url, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
