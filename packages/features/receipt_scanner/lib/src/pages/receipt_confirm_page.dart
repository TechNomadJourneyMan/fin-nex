import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fnx_domain/fnx_domain.dart';

import '../parsing/parsed_receipt.dart';

/// Review-and-edit screen shown after a receipt is scanned.
///
/// Displays the captured photo plus every parsed field (total, merchant,
/// date, line items) as editable inputs, and invokes [onSave] with the
/// corrected [ParsedReceipt] when the user confirms.
class ReceiptConfirmPage extends StatefulWidget {
  /// Creates the confirm page.
  const ReceiptConfirmPage({
    required this.receipt,
    required this.onSave,
    super.key,
    this.imagePath,
  });

  /// Parser output to pre-fill the form.
  final ParsedReceipt receipt;

  /// Path to the captured photo (shown as a preview). Optional for tests.
  final String? imagePath;

  /// Called with the edited receipt when the user taps Save.
  final void Function(ParsedReceipt edited) onSave;

  @override
  State<ReceiptConfirmPage> createState() => _ReceiptConfirmPageState();
}

class _ReceiptConfirmPageState extends State<ReceiptConfirmPage> {
  late final TextEditingController _merchantCtrl;
  late final TextEditingController _totalCtrl;
  late DateTime _occurredAt;
  late Currency _currency;
  late List<ReceiptLineItem> _items;

  @override
  void initState() {
    super.initState();
    final ParsedReceipt r = widget.receipt;
    _merchantCtrl = TextEditingController(text: r.merchant ?? '');
    _totalCtrl =
        TextEditingController(text: _minorToMajorString(r.totalMinor, r.currency));
    _occurredAt = r.occurredAt;
    _currency = r.currency;
    _items = List<ReceiptLineItem>.from(r.lineItems);
  }

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  String _minorToMajorString(int minor, Currency currency) {
    final int scale = _pow10(currency.minorUnit);
    if (currency.minorUnit == 0) {
      return minor.toString();
    }
    final int whole = minor ~/ scale;
    final int frac = (minor % scale).abs();
    return '$whole.${frac.toString().padLeft(currency.minorUnit, '0')}';
  }

  int _majorStringToMinor(String text, Currency currency) {
    final String cleaned = text.replaceAll(',', '.').trim();
    final List<String> parts = cleaned.split('.');
    final int scale = _pow10(currency.minorUnit);
    final int whole = int.tryParse(parts.first) ?? 0;
    int frac = 0;
    if (parts.length > 1 && currency.minorUnit > 0) {
      final String fracStr =
          parts[1].padRight(currency.minorUnit, '0').substring(0, currency.minorUnit);
      frac = int.tryParse(fracStr) ?? 0;
    }
    return whole * scale + frac;
  }

  int _pow10(int n) {
    int v = 1;
    for (int i = 0; i < n; i++) {
      v *= 10;
    }
    return v;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _occurredAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _occurredAt.hour,
          _occurredAt.minute,
        );
      });
    }
  }

  void _handleSave() {
    final String merchant = _merchantCtrl.text.trim();
    final ParsedReceipt edited = ParsedReceipt(
      totalMinor: _majorStringToMinor(_totalCtrl.text, _currency),
      currency: _currency,
      merchant: merchant.isEmpty ? null : merchant,
      occurredAt: _occurredAt,
      lineItems: _items,
      rawText: widget.receipt.rawText,
    );
    widget.onSave(edited);
  }

  @override
  Widget build(BuildContext context) {
    final String dateLabel =
        '${_occurredAt.year}-${_two(_occurredAt.month)}-${_two(_occurredAt.day)}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтвердите чек'),
        actions: <Widget>[
          TextButton(
            onPressed: _handleSave,
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (widget.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(height: 200),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _merchantCtrl,
            decoration: const InputDecoration(
              labelText: 'Магазин',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _totalCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Итого',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<Currency>(
                value: _currency,
                onChanged: (Currency? c) {
                  if (c != null) {
                    setState(() => _currency = c);
                  }
                },
                items: Currency.values
                    .map(
                      (Currency c) => DropdownMenuItem<Currency>(
                        value: c,
                        child: Text(c.code),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Дата'),
            subtitle: Text(dateLabel),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          const Divider(height: 32),
          Text(
            'Позиции',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < _items.length; i++)
            _LineItemTile(
              item: _items[i],
              currency: _currency,
              onChanged: (ReceiptLineItem updated) {
                setState(() => _items[i] = updated);
              },
              onDelete: () {
                setState(() => _items.removeAt(i));
              },
            ),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Позиции не распознаны'),
            ),
        ],
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

/// Editable row for a single parsed line item.
class _LineItemTile extends StatelessWidget {
  const _LineItemTile({
    required this.item,
    required this.currency,
    required this.onChanged,
    required this.onDelete,
  });

  final ReceiptLineItem item;
  final Currency currency;
  final void Function(ReceiptLineItem) onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: item.name,
              decoration: const InputDecoration(labelText: 'Название'),
              onChanged: (String v) => onChanged(
                ReceiptLineItem(
                  name: v,
                  quantity: item.quantity,
                  priceMinor: item.priceMinor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: TextFormField(
              initialValue: item.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Кол-во'),
              onChanged: (String v) => onChanged(
                ReceiptLineItem(
                  name: item.name,
                  quantity: int.tryParse(v) ?? 1,
                  priceMinor: item.priceMinor,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
