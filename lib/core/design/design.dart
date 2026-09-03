/// Vinkol design system. Import this rather than the individual token files.
///
/// Rules live in `.claude/skills/vinkol-design-system/SKILL.md`; the token values and their
/// verified contrast ratios live in `.claude/design/04-tokens.md`.
///
/// This directory is the only place in `lib/` allowed to hold color literals, raw radii or
/// shadow definitions. Everywhere else reads tokens.
library;

export 'vinkol_color.dart';
export 'vinkol_motion.dart';
export 'vinkol_space.dart';
export 'vinkol_theme.dart';
export 'vinkol_type.dart';
