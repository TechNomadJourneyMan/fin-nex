// Microphone permission gateway.
//
// Wraps `permission_handler` behind an interface so the controller can be
// driven by a fake in tests (the real plugin needs a platform channel).

import 'package:permission_handler/permission_handler.dart';

/// Outcome of a microphone permission request.
enum MicPermissionStatus {
  /// User granted access.
  granted,

  /// User denied this time (may be asked again).
  denied,

  /// User permanently denied; only Settings can re-enable.
  permanentlyDenied,
}

/// Requests and inspects microphone permission.
abstract class MicrophonePermission {
  /// Ensures permission, prompting the OS dialog if needed.
  Future<MicPermissionStatus> ensure();

  /// Opens the OS app settings page (for the permanently-denied path).
  Future<bool> openSettings();
}

/// Default [MicrophonePermission] backed by `permission_handler`.
class PermissionHandlerMicrophonePermission implements MicrophonePermission {
  /// Const constructor.
  const PermissionHandlerMicrophonePermission();

  @override
  Future<MicPermissionStatus> ensure() async {
    final status = await Permission.microphone.request();
    if (status.isGranted || status.isLimited) {
      return MicPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MicPermissionStatus.permanentlyDenied;
    }
    return MicPermissionStatus.denied;
  }

  @override
  Future<bool> openSettings() => openAppSettings();
}
