import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/splash/view_model/splash_view_model.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/location_provider.dart';
import 'package:starter_codes/provider/user_location_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

const _pageInset = EdgeInsetsDirectional.symmetric(horizontal: 20);

const _hairline = AppColors.lightgrey;

class LocationSetupScreen extends ConsumerStatefulWidget {
  const LocationSetupScreen({super.key, this.onDone});

  /// Where to go once a location is set. Defaults to popping the screen.
  final VoidCallback? onDone;

  @override
  ConsumerState<LocationSetupScreen> createState() =>
      _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _searching = false;
  bool _locating = false;
  bool _manualMode = false;
  String? _error;
  List<Map<String, dynamic>> _predictions = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    // Rebuilt on every keystroke so the clear affordance tracks the field.
    setState(() {
      if (query.length < 3) _predictions = const [];
    });
    if (query.length < 3) return;
    // Places bills per keystroke otherwise.
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(query);
    });
  }

  void _clearQuery() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _predictions = const [];
      _error = null;
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      // Deliberately unfiltered: this is where the customer tells us which
      // country they are in, so restricting to the current one would make it
      // impossible to ever change.
      final results = await ref
          .read(locationControllerProvider)
          .searchPlaces(query, restrictToMarket: false);
      if (!mounted) return;
      setState(() => _predictions = results);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _predictions = const [];
        _error = 'Could not search right now. Check your connection.';
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _choosePrediction(Map<String, dynamic> prediction) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final controller = ref.read(locationControllerProvider);
      final resolved = await controller.fetchCoordinateFromPlaceId(
          LocationModel.fromPredictionMap(prediction));
      await _commit(resolved);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = 'Could not use that address. Try another.';
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final controller = ref.read(locationControllerProvider);
      final position =
          controller.currentLatLng ?? await controller.refreshCurrentLocation();
      if (position == null) {
        if (!mounted) return;
        setState(() {
          _locating = false;
          _error = 'Location is off. Turn it on, or search for your address.';
        });
        return;
      }
      final resolved = await controller.getAddressFromLatLng(position);
      if (resolved == null) {
        if (!mounted) return;
        setState(() {
          _locating = false;
          _error = 'Could not read your address. Try searching for it.';
        });
        return;
      }
      await _commit(resolved);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _error = 'Could not get your location. Try searching for it.';
      });
    }
  }

  void _enterManualMode() {
    setState(() {
      _manualMode = true;
      _error = null;
    });
  }

  void _leaveManualMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _manualMode = false;
      _predictions = const [];
      _error = null;
    });
  }

  /// Stores the location, which also adopts the market it sits in.
  Future<void> _commit(LocationModel location) async {
    await ref.read(userLocationProvider.notifier).setLocation(location);
    if (!mounted) return;
    setState(() {
      _locating = false;
      _searching = false;
    });
    if (widget.onDone != null) {
      widget.onDone!();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    await ref.read(splashViewModelProvider).initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        // The search step runs its separators to the screen edge, so it applies
        // the page margin row by row rather than taking it from here.
        child: _manualMode
            ? _buildSearch()
            : Padding(
                padding: _pageInset,
                child: _buildIntro(),
              ),
      ),
    );
  }

  Widget _buildIntro() {
    // The two actions sit on the bottom edge; only the copy and the
    // illustration above them scroll, and only when they have to — a short
    // viewport or a large text scale.
    return Column(
      children: [
        Expanded(child: SingleChildScrollView(child: _introContent())),
        if (_error != null) ...[
          AppText.caption(_error!, centered: true, color: AppColors.red),
          Gap.h12,
        ],
        AppButton(
          title: 'Use my current location',
          color: AppColors.primary,
          textColor: AppColors.white,
          outlineColor: AppColors.primary,
          loading: _locating,
          onTap: _locating ? null : _useCurrentLocation,
        ),
        Gap.h16,
        TextButton(
          onPressed: _locating ? null : _enterManualMode,
          child: AppText.body(
            'Select it manually',
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap.h24,
      ],
    );
  }

  Widget _introContent() {
    return Column(
      children: [
        Gap.h36,
        AppText.h2('Where are you?', centered: true),
        Gap.h8,
        AppText.body(
          'So we can show what we deliver near you',
          centered: true,
          color: AppColors.darkgrey,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 24),
          child: SvgPicture.asset(
            SvgAsset.locationIcon,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.h8,
        Padding(
          // Less start inset than the page margin: the icon button carries its
          // own 8pt of touch padding, and the glyph should line up with the
          // text below it, not the box around it.
          padding: const EdgeInsetsDirectional.only(start: 12, end: 20),
          child: Row(
            children: [
              IconButton(
                onPressed: _leaveManualMode,
                icon: const Icon(PhosphorIconsRegular.arrowLeft,
                    color: AppColors.black),
              ),
              Expanded(child: AppText.h2('Your location')),
            ],
          ),
        ),
        Gap.h8,
        Padding(
          padding: _pageInset,
          child: _searchField(),
        ),
        Gap.h8,
        _currentLocationAction(),
        if (_error != null) ...[
          Padding(
            padding: _pageInset,
            child: AppText.caption(_error!, color: AppColors.red),
          ),
          Gap.h12,
        ],
        // A fixed 2pt lane, filled or empty, so results do not jump a pixel
        // every time a search starts.
        SizedBox(
          height: 2,
          child: _searching
              ? const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                )
              : const Divider(height: 2, thickness: 1, color: _hairline),
        ),
        Expanded(
          child: _predictions.isEmpty ? _emptyState() : _resultList(),
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      cursorColor: AppColors.primary,
      textInputAction: TextInputAction.search,
      onChanged: _onQueryChanged,
      decoration: InputDecoration(
        hintText: 'Search for your address',
        hintStyle: const TextStyle(color: AppColors.darkgrey),
        prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass,
            color: AppColors.black),
        suffixIcon: _searchController.text.isEmpty ? null : _clearButton(),
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _clearButton() {
    // widthFactor 1 keeps the suffix as wide as the button rather than letting
    // it claim half the field.
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: InkWell(
          onTap: _clearQuery,
          customBorder: const CircleBorder(),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(4),
              child:
                  Icon(PhosphorIconsBold.x, size: 12, color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }

  /// The GPS route, offered here as well as on the intro — by the time someone
  /// is typing they have usually decided search is the faster path, but a bad
  /// first result sends them straight back to it.
  Widget _currentLocationAction() {
    return InkWell(
      onTap: _locating ? null : _useCurrentLocation,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: _locating
                  ? const CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary)
                  : const Icon(PhosphorIconsRegular.navigationArrow,
                      size: 20, color: AppColors.primary),
            ),
            Gap.w12,
            AppText.body(
              'Use your current location',
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: _pageInset,
        child: AppText.caption(
          _searchController.text.trim().length < 3
              ? 'Type at least three letters'
              : 'No matches',
          centered: true,
          color: AppColors.darkgrey,
        ),
      ),
    );
  }

  Widget _resultList() {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _predictions.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 1, color: _hairline),
      itemBuilder: (context, index) => _predictionRow(_predictions[index]),
    );
  }

  Widget _predictionRow(Map<String, dynamic> prediction) {
    final description = prediction['description']?.toString() ?? '';
    final structured = prediction['structured_formatting'];
    final secondary =
        structured is Map ? structured['secondary_text']?.toString() ?? '' : '';

    // Not a ListTile: an address is the whole point of the row, and ListTile
    // constrains its height enough to clip a long one. This grows to whatever
    // the address needs.
    return InkWell(
      onTap: _searching ? null : () => _choosePrediction(prediction),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              // Optically centres the pin on the first line of the address
              // rather than on the whole block.
              padding: EdgeInsetsDirectional.only(top: 2),
              child: Icon(PhosphorIconsFill.mapPin,
                  size: 20, color: AppColors.primary),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(
                    description,
                    overflow: TextOverflow.visible,
                  ),
                  if (secondary.isNotEmpty) ...[
                    Gap.h4,
                    AppText.caption(
                      secondary,
                      color: AppColors.darkgrey,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
