/// Public API for the FinNex OCR receipt-scanning feature module.
library fnx_feat_receipt_scanner;

// Parsing (pure Dart)
export 'src/parsing/parsed_receipt.dart';
export 'src/parsing/receipt_parser.dart';

// Providers
export 'src/providers.dart';

// Pages
export 'src/pages/receipt_camera_page.dart';
export 'src/pages/receipt_confirm_page.dart';
