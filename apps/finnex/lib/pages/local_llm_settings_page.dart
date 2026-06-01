// Local LLM settings + playground (on-device Gemma).
//
// Surfaces the [LocalLlmService] state from a Riverpod provider:
//   * install state + a "Скачать Gemma" button bound to downloadProgress
//   * a playground textfield that runs infer() and shows the response
//   * a size estimate + privacy note (data never leaves the device)
//
// On Web the injected service is the no-op stub: download() throws
// UnsupportedError, which we render as a friendly "unavailable" banner.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_local_llm/pf_local_llm.dart';

import '../providers.dart' show localLlmServiceProvider;

class LocalLlmSettingsPage extends ConsumerStatefulWidget {
  const LocalLlmSettingsPage({super.key});

  @override
  ConsumerState<LocalLlmSettingsPage> createState() =>
      _LocalLlmSettingsPageState();
}

class _LocalLlmSettingsPageState extends ConsumerState<LocalLlmSettingsPage> {
  final TextEditingController _prompt = TextEditingController(
    text: 'Сколько примерно я трачу на кофе в месяц? Дай совет.',
  );

  bool _installed = false;
  bool _downloading = false;
  double _progress = 0;
  String? _downloadError;

  bool _inferring = false;
  String? _response;
  String? _inferError;

  @override
  void initState() {
    super.initState();
    _refreshInstalled();
  }

  LocalLlmService get _llm => ref.read(localLlmServiceProvider);

  Future<void> _refreshInstalled() async {
    final bool ok = await _llm.isInstalled();
    if (mounted) setState(() => _installed = ok);
  }

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _downloadError = null;
      _progress = 0;
    });
    final sub = _llm.downloadProgress.listen((LlmDownloadProgress p) {
      if (!mounted) return;
      setState(() {
        _progress = p.progress;
        if (p.error != null) _downloadError = p.error.toString();
      });
    });
    try {
      await _llm.download();
      await _refreshInstalled();
    } catch (e) {
      if (mounted) setState(() => _downloadError = e.toString());
    } finally {
      await sub.cancel();
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _run() async {
    setState(() {
      _inferring = true;
      _inferError = null;
      _response = null;
    });
    try {
      final String out = await _llm.infer(_prompt.text);
      if (mounted) setState(() => _response = out);
    } catch (e) {
      if (mounted) setState(() => _inferError = e.toString());
    } finally {
      if (mounted) setState(() => _inferring = false);
    }
  }

  String get _sizeEstimate {
    final int bytes = _llm.approxModelSizeBytes;
    if (bytes <= 0) return 'недоступно';
    final double gb = bytes / (1024 * 1024 * 1024);
    return '≈ ${gb.toStringAsFixed(1)} ГБ';
  }

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        title: const Text('Локальная модель'),
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: <Widget>[
          const Text(
            'Pocket Flow может запускать ИИ-модель Gemma прямо на устройстве — '
            'для распознавания чеков, разбора уведомлений банков и подсказок.',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A8A93)),
          ),
          const SizedBox(height: 16),

          // Model card --------------------------------------------------
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.memory,
                      size: 20,
                      color: Color(0xFFE5E5EA),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _llm.modelId,
                        style: const TextStyle(
                          color: Color(0xFFF2F2F3),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _StatusPill(installed: _installed),
                  ],
                ),
                const SizedBox(height: 12),
                _kv('Размер', _sizeEstimate),
                _kv('Статус', _installed ? 'Установлена' : 'Не установлена'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Download ----------------------------------------------------
          if (!_installed) ...<Widget>[
            FilledButton.icon(
              onPressed: _downloading ? null : _download,
              icon: const Icon(Icons.download),
              label: Text(_downloading ? 'Загрузка…' : 'Скачать Gemma'),
            ),
            if (_downloading) ...<Widget>[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress,
                  minHeight: 6,
                  backgroundColor: const Color(0x14FFFFFF),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFE5E5EA),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(_progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A8A93),
                ),
              ),
            ],
            if (_downloadError != null) ...<Widget>[
              const SizedBox(height: 12),
              _ErrorCard(message: _downloadError!),
            ],
          ],

          const SizedBox(height: 24),

          // Playground --------------------------------------------------
          const Text(
            'ПЕСОЧНИЦА',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
              color: Color(0xFF8A8A93),
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _prompt,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFFF2F2F3)),
              decoration: const InputDecoration(
                hintText: 'Введите запрос для модели…',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF5C5C66)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: (!_installed || _inferring) ? null : _run,
            icon: _inferring
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bolt),
            label: Text(_inferring ? 'Думаю…' : 'Запустить'),
          ),
          if (!_installed)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Сначала скачайте модель, чтобы запускать запросы.',
                style: TextStyle(fontSize: 12, color: Color(0xFF5C5C66)),
              ),
            ),
          if (_inferError != null) ...<Widget>[
            const SizedBox(height: 12),
            _ErrorCard(message: _inferError!),
          ],
          if (_response != null) ...<Widget>[
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Text(
                _response!,
                style: const TextStyle(
                  color: Color(0xFFF2F2F3),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Privacy note ------------------------------------------------
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Color(0xFF24A148),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Локальная модель — данные никогда не '
                              'покидают устройство.\n',
                          style: TextStyle(
                            color: Color(0xFFF2F2F3),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Размер загрузки $_kSizeHint. Модель Gemma '
                              'распространяется по условиям Google Gemma '
                              'Terms of Use.',
                          style: TextStyle(
                            color: Color(0xFF8A8A93),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(
              k,
              style: const TextStyle(color: Color(0xFF8A8A93), fontSize: 12),
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
}

/// Static size hint shown in the privacy note (matches the int4 variant).
const String _kSizeHint = '≈ 1.5 ГБ';

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.installed});
  final bool installed;

  @override
  Widget build(BuildContext context) {
    final Color c =
        installed ? const Color(0xFF24A148) : const Color(0xFF5C5C66);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        installed ? 'Готова' : 'Нет',
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 18, color: Color(0xFFFF453A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFF453A),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
