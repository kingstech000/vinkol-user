import 'package:flutter/foundation.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/models/app_state/view_model_state.dart';

class BaseViewModel extends ChangeNotifier {
  late final _logger = appLogger(runtimeType);
  AppLogger get logger => _logger;
  //======================================================
  //==================== STATE SECTION ===================
  //======================================================
  ViewModelState _state = const ViewModelState.idle();
  ViewModelState get state => _state;

  /// if state is busy
  bool get isBusy =>
      _state.maybeWhen<bool>(busy: () => true, orElse: () => false);

  /// if state is idle
  bool get isIdle =>
      _state.maybeWhen<bool>(idle: () => true, orElse: () => false);

  /// if state is error
  bool get isError =>
      _state.maybeWhen<bool>(error: (value) => true, orElse: () => false);

  ///get error
  String get getError => _state.maybeWhen<String>(
      error: (value) => value.message, orElse: () => "");

  // alter state
  changeState(ViewModelState newState) {
    _state = newState;
    // notify listeners if viewmodel is still active
    if (!isDisposed) notifyListeners();
  }

  //======================================================
  //==================== SECONDARY STATE SECTION ===================
  //======================================================
  ViewModelState _secondaryState = const ViewModelState.idle();
  ViewModelState get secondaryState => _secondaryState;

  /// if state is busy
  bool get isSecondaryBusy =>
      _secondaryState.maybeWhen<bool>(busy: () => true, orElse: () => false);

  /// if state is idle
  bool get isSecondaryIdle =>
      _secondaryState.maybeWhen<bool>(idle: () => true, orElse: () => false);

  /// if state is error
  bool get isSecondaryError => _secondaryState.maybeWhen<bool>(
      error: (value) => true, orElse: () => false);

  ///get error
  String get getSecondaryError => _secondaryState.maybeWhen<String>(
      error: (value) => value.message, orElse: () => "");

  // alter state
  changeSecondaryState(ViewModelState newState) {
    _secondaryState = newState;
    // notify listeners if viewmodel is still active
    if (!isDisposed) notifyListeners();
  }

  // void showSuccessDialog(String message) {
  //   locator<DialogService>().showDialog(
  //     autoDismiss: true,
  //     routeName: DialogRoutes.topInfoDialog,
  //     arguments: TopInfoDialogArg(
  //       type: TopInfoDialogType.success,
  //       message: message,
  //     ),
  //   );
  // }

  // void showErrorDialog(String message) {
  //   locator<DialogService>().showDialog(
  //     autoDismiss: true,
  //     routeName: DialogRoutes.topInfoDialog,
  //     arguments: TopInfoDialogArg(
  //       type: TopInfoDialogType.error,
  //       message: message,
  //     ),
  //   );
  // }

  // void showInfoDialog(String message) {
  //   locator<DialogService>().showDialog(
  //     routeName: DialogRoutes.topInfoDialog,
  //     arguments: TopInfoDialogArg(
  //       type: TopInfoDialogType.info,
  //       message: message,
  //     ),
  //   );
  // }

  //======================================================
  //==================== Disposed SECTION ================
  //======================================================
  bool _disposed = false;
  bool get isDisposed => _disposed;
  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }
}
