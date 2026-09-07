/// The Vinkol component library. Import this rather than the individual files.
///
/// Every component here reads its colours, type, spacing, radii, elevation and motion from
/// `lib/core/design/` and holds no literals of its own. Each supports default, pressed and
/// disabled states and resolves for both light and dark, because Midnight treats light as a
/// full peer rather than a tint (D-07).
///
/// The shell states live here too: [VinkolStateView] for empty, error and offline, and
/// [VinkolSkeletonList] for a list whose shape is known before its data is.
///
/// The five signatures live here: the Line ([VinkolStopsRail], [VinkolProgressTrack]), the
/// Pod ([VinkolPod]), status as typography ([VinkolStatusChip]), flush numerics ([VinkolRow],
/// [VinkolRecordCard], [VinkolDataGrid]) and the saturated hero ([VinkolHeroCard]).
library;

export 'vinkol_auth_scaffold.dart';
export 'vinkol_data_grid.dart';
export 'vinkol_form_field.dart';
export 'vinkol_form_scaffold.dart';
export 'vinkol_hero_card.dart';
export 'vinkol_line.dart';
export 'vinkol_mark.dart';
export 'vinkol_otp_field.dart';
export 'vinkol_pod.dart';
export 'vinkol_row.dart';
export 'vinkol_shell.dart';
export 'vinkol_skeleton.dart';
export 'vinkol_states.dart';
export 'vinkol_status_chip.dart';
export 'vinkol_surface.dart';
