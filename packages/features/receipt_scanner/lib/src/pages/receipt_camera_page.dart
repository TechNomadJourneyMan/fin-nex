import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../parsing/parsed_receipt.dart';
import '../providers.dart';

/// Live camera preview with tap-to-capture receipt scanning.
///
/// On capture it: takes a photo, runs on-device OCR via the [OcrEngine]
/// provider, pipes the raw text through the [ReceiptParser], and invokes
/// [onScanned] with the parsed result and the captured image path so the
/// caller can route to the confirm page.
class ReceiptCameraPage extends ConsumerStatefulWidget {
  /// Creates the camera page.
  ///
  /// [onScanned] receives the parsed receipt plus the captured photo path.
  /// [cameras] may be injected for tests; defaults to [availableCameras].
  const ReceiptCameraPage({
    required this.onScanned,
    super.key,
    this.cameras,
  });

  /// Called once a photo has been captured and parsed.
  final void Function(ParsedReceipt receipt, String imagePath) onScanned;

  /// Optional injected camera list (testing). When null, queried at runtime.
  final List<CameraDescription>? cameras;

  @override
  ConsumerState<ReceiptCameraPage> createState() => _ReceiptCameraPageState();
}

class _ReceiptCameraPageState extends ConsumerState<ReceiptCameraPage> {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final List<CameraDescription> cameras =
          widget.cameras ?? await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Камера недоступна');
        return;
      }
      final CameraDescription back = cameras.firstWhere(
        (CameraDescription c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final CameraController controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _error = e.description ?? 'Ошибка камеры');
      }
    }
  }

  Future<void> _capture() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final XFile shot = await controller.takePicture();
      final String text =
          await ref.read(ocrEngineProvider).recognizeText(shot.path);
      final ParsedReceipt parsed = ref.read(receiptParserProvider).parse(
            text,
            currency: ref.read(receiptCurrencyProvider),
          );
      if (!mounted) {
        return;
      }
      widget.onScanned(parsed, shot.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось распознать чек: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _capturing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Сканировать чек'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final CameraController? controller = _controller;
          if (controller == null ||
              snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CameraPreview(controller),
              const _ReceiptFrameOverlay(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: _CaptureButton(
                    busy: _capturing,
                    onTap: _capture,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Simple framing guide rectangle drawn over the preview.
class _ReceiptFrameOverlay extends StatelessWidget {
  const _ReceiptFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round shutter button with a busy spinner.
class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: busy
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : const Icon(Icons.document_scanner, size: 32),
      ),
    );
  }
}
