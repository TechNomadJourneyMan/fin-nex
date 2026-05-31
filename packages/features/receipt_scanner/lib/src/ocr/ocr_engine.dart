import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Abstraction over the on-device OCR backend.
///
/// Lets the camera page depend on an interface (so it can be faked in tests)
/// while the production implementation wraps ML Kit text recognition.
abstract class OcrEngine {
  /// Runs OCR on the image at [imagePath] and returns the recognized text.
  Future<String> recognizeText(String imagePath);

  /// Releases any native resources.
  Future<void> dispose();
}

/// ML Kit-backed [OcrEngine] using on-device text recognition.
///
/// The Latin script recognizer also covers Cyrillic glyphs well enough for
/// Kazakhstan receipts; if accuracy proves insufficient, swap the
/// [TextRecognitionScript] passed to the constructor.
class MlKitOcrEngine implements OcrEngine {
  /// Creates an engine for the given [script] (defaults to Latin).
  MlKitOcrEngine({TextRecognitionScript script = TextRecognitionScript.latin})
      : _recognizer = TextRecognizer(script: script);

  final TextRecognizer _recognizer;

  @override
  Future<String> recognizeText(String imagePath) async {
    final InputImage input = InputImage.fromFilePath(imagePath);
    final RecognizedText recognized = await _recognizer.processImage(input);
    return recognized.text;
  }

  @override
  Future<void> dispose() => _recognizer.close();
}
