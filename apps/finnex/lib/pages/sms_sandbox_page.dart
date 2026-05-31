// SMS Sandbox page — F-03 parser exercised on Web for testing.
//
// Lets you paste an SMS / push body and see how the Kaspi / Halyk / Freedom
// parsers interpret it (amount, type, merchant, external_ref). Useful while
// the Android NotificationListenerService is being developed in parallel.

import 'package:flutter/material.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_sms_parser/fnx_sms_parser.dart';

class SmsSandboxPage extends StatefulWidget {
  const SmsSandboxPage({super.key});

  @override
  State<SmsSandboxPage> createState() => _SmsSandboxPageState();
}

class _SmsSandboxPageState extends State<SmsSandboxPage> {
  final TextEditingController _input = TextEditingController(
    text: 'Оплата на сумму 1 234.56 ₸ в KASPI MAGAZIN.',
  );
  ParserRegistry get _registry => ParserRegistry.kazakhstan();
  ParsedTransaction? _last;
  String? _bankUsed;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _parse() {
    setState(() {
      _last = null;
      _bankUsed = null;
      _error = null;
    });
    try {
      for (final BankNotificationParser p in _registry.parsers) {
        final ParsedTransaction? r = p.tryParse(_input.text);
        if (r != null) {
          setState(() {
            _last = r;
            _bankUsed = p.bankCode;
          });
          return;
        }
      }
      setState(() => _error = 'Ни один парсер не распознал текст.');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        title: const Text('SMS Sandbox'),
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: <Widget>[
          const Text(
            'Вставьте SMS или push-уведомление от Kaspi / Halyk / Freedom Bank — '
            'парсер извлечёт сумму, тип операции и мерчанта.',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A8A93)),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _input,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFFF2F2F3)),
              decoration: const InputDecoration(
                hintText: 'Halyk Bank: Покупка 2 500 KZT в SMARTPOINT.',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF5C5C66)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _parse,
            icon: const Icon(Icons.bolt),
            label: const Text('Разобрать'),
          ),
          const SizedBox(height: 24),
          if (_error != null)
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFFF453A)),
              ),
            ),
          if (_last != null) ...<Widget>[
            const Text(
              'РЕЗУЛЬТАТ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 3,
                color: Color(0xFF8A8A93),
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _row('Банк', _bankUsed ?? '—'),
                  _row(
                    'Сумма',
                    '${(_last!.amountMinor / 100).toStringAsFixed(2)} ${_last!.currency}',
                  ),
                  _row('Тип', _last!.type),
                  _row('Мерчант', _last!.merchant ?? '—'),
                  _row('Дата', _last!.occurredAt.toIso8601String()),
                  _row('External ref (sha-1 cut)',
                      _last!.externalRef.substring(0, 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Text(
            'Готовые примеры:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A8A93),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _sample(
                'Kaspi: оплата',
                'Оплата на сумму 1 234.56 ₸ в KASPI MAGAZIN.',
              ),
              _sample(
                'Kaspi: поступление',
                'Поступление 5 000 ₸. Доступно: 12 345 ₸. Сообщение: От Айгуль К.',
              ),
              _sample('Halyk', 'Halyk Bank: Покупка 2 500 KZT в SMARTPOINT.'),
              _sample(
                'Freedom',
                'Freedom Bank: На счёт 7 000 KZT от ИВАНОВ И.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 160,
            child: Text(
              k,
              style: const TextStyle(
                color: Color(0xFF8A8A93),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                color: Color(0xFFF2F2F3),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sample(String label, String text) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() => _input.text = text);
        _parse();
      },
    );
  }
}
