// Drag-and-drop file import (Flutter web / desktop).
//
// Wraps a page body in a [DropTarget]. Dropped CSV files open a column-mapping
// preview dialog and then batch-import as transactions. Dropped images are
// forwarded to the Receipt Scanner confirm flow (OCR + parse).
//
// On non-web platforms the wrapper is a transparent pass-through — there is no
// desktop drag source on a phone, and we avoid pulling the native channel into
// mobile builds.

import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:csv/csv.dart';
import 'package:desktop_drop/desktop_drop.dart';
// Hide foundation's `Category` annotation so the domain `Category` entity
// resolves unambiguously; we still need `kIsWeb` from foundation.
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_receipt_scanner/receipt_scanner.dart' as receipt;
import 'package:pf_feat_transactions/transactions.dart' as transactions;

/// Wraps [child] so that files dragged onto it import into PocketFlow.
///
/// CSV (`.csv`) → column-mapping preview → batch import.
/// Images (`.jpg/.jpeg/.png/.webp`) → Receipt Scanner confirm flow.
class DropImportTarget extends ConsumerStatefulWidget {
  /// Creates a drop-import wrapper.
  const DropImportTarget({required this.child, super.key});

  /// The wrapped page body.
  final Widget child;

  @override
  ConsumerState<DropImportTarget> createState() => _DropImportTargetState();
}

class _DropImportTargetState extends ConsumerState<DropImportTarget> {
  bool _dragging = false;

  static const Set<String> _imageExts = <String>{
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  @override
  Widget build(BuildContext context) {
    // No drag source on touch platforms — pass through untouched.
    if (!kIsWeb) {
      return widget.child;
    }

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (DropDoneDetails details) async {
        setState(() => _dragging = false);
        await _handleDrop(details.files);
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_dragging)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  child: Center(
                    child: Icon(
                      Icons.file_download_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleDrop(List<XFile> files) async {
    for (final XFile f in files) {
      final String lower = f.name.toLowerCase();
      if (lower.endsWith('.csv')) {
        final String content = utf8.decode(await f.readAsBytes());
        if (!mounted) {
          return;
        }
        await _importCsv(content);
      } else if (_imageExts.any(lower.endsWith)) {
        final Uint8List bytes = await f.readAsBytes();
        if (!mounted) {
          return;
        }
        await _forwardToReceiptScanner(f.path, bytes);
      }
    }
  }

  Future<void> _importCsv(String content) async {
    final List<List<dynamic>> rows =
        const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
            .convert(content);
    if (rows.isEmpty) {
      return;
    }
    final List<String> header =
        rows.first.map((dynamic c) => c.toString()).toList();
    final List<List<String>> dataRows = rows
        .skip(1)
        .map((List<dynamic> r) => r.map((dynamic c) => c.toString()).toList())
        .where((List<String> r) => r.any((String c) => c.trim().isNotEmpty))
        .toList();

    final _CsvMapping? mapping = await showDialog<_CsvMapping>(
      context: context,
      builder: (BuildContext ctx) => _CsvPreviewDialog(
        header: header,
        sampleRows: dataRows.take(5).toList(),
        rowCount: dataRows.length,
      ),
    );
    if (mapping == null || !mounted) {
      return;
    }

    await _batchImport(dataRows, mapping);
  }

  Future<void> _batchImport(
    List<List<String>> dataRows,
    _CsvMapping mapping,
  ) async {
    final TransactionsRepository repo =
        ref.read(transactions.transactionsRepositoryProvider);
    final Ulid userId = ref.read(transactions.currentUserIdProvider);
    final Currency currency = ref.read(transactions.defaultCurrencyProvider);
    final List<Account> accounts =
        ref.read(transactions.accountsStreamProvider).valueOrNull ??
            <Account>[];
    final List<Category> categories =
        ref.read(transactions.categoriesStreamProvider).valueOrNull ??
            <Category>[];
    if (accounts.isEmpty) {
      return;
    }
    final Ulid accountId = accounts.first.id;
    final Map<String, Ulid> catByName = <String, Ulid>{
      for (final Category c in categories) c.name.toLowerCase(): c.id,
    };

    int imported = 0;
    final DateTime now = DateTime.now().toUtc();
    for (final List<String> row in dataRows) {
      final BigInt? minor = _parseAmountMinor(
        _cell(row, mapping.amount),
        currency,
      );
      if (minor == null) {
        continue;
      }
      final DateTime occurred = _parseDate(_cell(row, mapping.date)) ?? now;
      final String? merchant =
          mapping.merchant == null ? null : _cell(row, mapping.merchant!);
      final String? catName =
          mapping.category == null ? null : _cell(row, mapping.category!);
      final Ulid? categoryId =
          catName == null ? null : catByName[catName.toLowerCase()];

      await repo.upsert(
        Transaction(
          id: Ulid.now(),
          userId: userId,
          accountId: accountId,
          type: minor.isNegative
              ? TransactionType.expense
              : TransactionType.income,
          amount: Money(minor.abs(), currency),
          occurredAt: occurred,
          createdAt: now,
          updatedAt: now,
          source: 'import_csv',
          attachmentIds: const <Ulid>[],
          tagIds: const <Ulid>[],
          categoryId: categoryId,
          description:
              (merchant != null && merchant.isNotEmpty) ? merchant : null,
        ),
      );
      imported++;
    }

    if (!mounted) {
      return;
    }
    context.showPfSnack(AppL10n.of(context).importDone(imported));
  }

  Future<void> _forwardToReceiptScanner(
    String path,
    Uint8List bytes,
  ) async {
    final receipt.ReceiptParser parser =
        ref.read(receipt.receiptParserProvider);
    final Currency currency = ref.read(receipt.receiptCurrencyProvider);

    String text = '';
    try {
      // OCR is only available on native platforms; on web the engine throws,
      // so the confirm page opens with an empty (user-editable) form.
      text = await ref.read(receipt.ocrEngineProvider).recognizeText(path);
    } catch (_) {
      text = '';
    }
    final receipt.ParsedReceipt parsed = parser.parse(text, currency: currency);

    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => receipt.ReceiptConfirmPage(
          receipt: parsed,
          imagePath: path,
          onSave: (receipt.ParsedReceipt edited) => _saveFromReceipt(edited),
        ),
      ),
    );
  }

  Future<void> _saveFromReceipt(receipt.ParsedReceipt edited) async {
    final TransactionsRepository repo =
        ref.read(transactions.transactionsRepositoryProvider);
    final Ulid userId = ref.read(transactions.currentUserIdProvider);
    final List<Account> accounts =
        ref.read(transactions.accountsStreamProvider).valueOrNull ??
            <Account>[];
    if (accounts.isEmpty || edited.totalMinor == 0) {
      return;
    }
    final DateTime now = DateTime.now().toUtc();
    await repo.upsert(
      Transaction(
        id: Ulid.now(),
        userId: userId,
        accountId: accounts.first.id,
        type: TransactionType.expense,
        amount: Money(BigInt.from(edited.totalMinor), edited.currency),
        occurredAt: edited.occurredAt,
        createdAt: now,
        updatedAt: now,
        source: 'receipt',
        attachmentIds: const <Ulid>[],
        tagIds: const <Ulid>[],
        description: edited.merchant,
      ),
    );
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }
}

String _cell(List<String> row, int index) =>
    index >= 0 && index < row.length ? row[index].trim() : '';

/// Parses a CSV amount cell into signed minor units, or null if unparseable.
BigInt? _parseAmountMinor(String raw, Currency currency) {
  if (raw.isEmpty) {
    return null;
  }
  // Strip currency symbols / spaces; tolerate comma decimals.
  final String cleaned =
      raw.replaceAll(RegExp(r'[^0-9,.\-]'), '').replaceAll(',', '.');
  final double? value = double.tryParse(cleaned);
  if (value == null) {
    return null;
  }
  final int scale = _pow10(currency.minorUnit);
  return BigInt.from((value * scale).round());
}

int _pow10(int n) {
  int r = 1;
  for (int i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

/// Best-effort date parse: ISO-8601 first, then dd.MM.yyyy / dd/MM/yyyy.
DateTime? _parseDate(String raw) {
  if (raw.isEmpty) {
    return null;
  }
  final DateTime? iso = DateTime.tryParse(raw);
  if (iso != null) {
    return iso.toUtc();
  }
  final Match? m =
      RegExp(r'(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})').firstMatch(raw);
  if (m != null) {
    final int day = int.parse(m.group(1)!);
    final int month = int.parse(m.group(2)!);
    int year = int.parse(m.group(3)!);
    if (year < 100) {
      year += 2000;
    }
    return DateTime.utc(year, month, day);
  }
  return null;
}

/// Resolved column indices for a CSV import.
class _CsvMapping {
  const _CsvMapping({
    required this.date,
    required this.amount,
    this.merchant,
    this.category,
  });

  final int date;
  final int amount;
  final int? merchant;
  final int? category;
}

/// Column-mapping preview shown before a CSV batch import.
class _CsvPreviewDialog extends StatefulWidget {
  const _CsvPreviewDialog({
    required this.header,
    required this.sampleRows,
    required this.rowCount,
  });

  final List<String> header;
  final List<List<String>> sampleRows;
  final int rowCount;

  @override
  State<_CsvPreviewDialog> createState() => _CsvPreviewDialogState();
}

class _CsvPreviewDialogState extends State<_CsvPreviewDialog> {
  int _date = 0;
  int _amount = 0;
  int? _merchant;
  int? _category;

  @override
  void initState() {
    super.initState();
    // Heuristic auto-mapping from header names.
    for (int i = 0; i < widget.header.length; i++) {
      final String h = widget.header[i].toLowerCase();
      if (h.contains('date') || h.contains('дата') || h.contains('күн')) {
        _date = i;
      } else if (h.contains('amount') ||
          h.contains('sum') ||
          h.contains('сумма') ||
          h.contains('сома')) {
        _amount = i;
      } else if (h.contains('merchant') ||
          h.contains('note') ||
          h.contains('продавец') ||
          h.contains('сатушы')) {
        _merchant = i;
      } else if (h.contains('categ') ||
          h.contains('катег') ||
          h.contains('санат')) {
        _category = i;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    return AlertDialog(
      title: Text(l10n.importPreviewTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ColumnDropdown(
              label: l10n.importColumnDate,
              header: widget.header,
              value: _date,
              onChanged: (int? v) => setState(() => _date = v ?? _date),
            ),
            _ColumnDropdown(
              label: l10n.importColumnAmount,
              header: widget.header,
              value: _amount,
              onChanged: (int? v) => setState(() => _amount = v ?? _amount),
            ),
            _ColumnDropdown(
              label: l10n.importColumnMerchant,
              header: widget.header,
              value: _merchant,
              nullable: true,
              onChanged: (int? v) => setState(() => _merchant = v),
            ),
            _ColumnDropdown(
              label: l10n.importColumnCategory,
              header: widget.header,
              value: _category,
              nullable: true,
              onChanged: (int? v) => setState(() => _category = v),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _CsvMapping(
              date: _date,
              amount: _amount,
              merchant: _merchant,
              category: _category,
            ),
          ),
          child: Text(l10n.importConfirm(widget.rowCount)),
        ),
      ],
    );
  }
}

class _ColumnDropdown extends StatelessWidget {
  const _ColumnDropdown({
    required this.label,
    required this.header,
    required this.value,
    required this.onChanged,
    this.nullable = false,
  });

  final String label;
  final List<String> header;
  final int? value;
  final bool nullable;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          SizedBox(width: 96, child: Text(label)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<int?>(
              isExpanded: true,
              value: value,
              items: <DropdownMenuItem<int?>>[
                if (nullable)
                  const DropdownMenuItem<int?>(
                    child: Text('—'),
                  ),
                for (int i = 0; i < header.length; i++)
                  DropdownMenuItem<int?>(
                    value: i,
                    child: Text(
                      header[i].isEmpty ? 'Column ${i + 1}' : header[i],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
