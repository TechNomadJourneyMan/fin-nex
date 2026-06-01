// Offline Google Fonts loader for tests.
//
// `flutter test` installs an HttpClient that fails every request, so
// `GoogleFonts` (used by PfTypography for Inter / JetBrains Mono) cannot fetch
// fonts and floods the test with "Failed to load font" exceptions. We sidestep
// that by replacing the google_fonts top-level [httpClient] with a fake that
// serves the matching .ttf from `test/fonts/`. Each font file is named after
// its sha256 (which is also the last path segment of the gstatic URL
// google_fonts requests), so the package's hash check passes.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as gf_base;

/// Installs the offline font client and stubs path_provider. Call once in
/// `main()` after the test binding is initialized.
void installOfflineGoogleFonts() {
  gf_base.httpClient = _LocalFontClient();
  _stubPathProvider();
}

void _stubPathProvider() {
  final Directory tmp = Directory.systemTemp.createTempSync('pf_fonts_');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async => tmp.path,
  );
}

class _LocalFontClient extends http.BaseClient {
  static final Directory _fontsDir =
      Directory('${Directory.current.path}/test/fonts');

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // The URL's last path segment is the sha256-named font file.
    final String name = request.url.pathSegments.last; // e.g. <hash>.ttf
    final File f = File('${_fontsDir.path}/$name');
    if (await f.exists()) {
      final Uint8List bytes = await f.readAsBytes();
      return http.StreamedResponse(
        Stream<List<int>>.value(bytes),
        200,
        contentLength: bytes.length,
        request: request,
      );
    }
    // Unknown font → 404 so google_fonts records it (and our test filter
    // treats it as ignorable noise).
    return http.StreamedResponse(
      const Stream<List<int>>.empty(),
      404,
      request: request,
    );
  }
}
