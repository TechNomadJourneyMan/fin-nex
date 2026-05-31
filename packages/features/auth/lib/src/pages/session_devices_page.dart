// Session devices page — list of active devices with revoke action.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

/// In-memory device record for the placeholder list.
class _Device {
  _Device({
    required this.id,
    required this.name,
    required this.lastSeen,
    required this.current,
  });
  final String id;
  final String name;
  final DateTime lastSeen;
  final bool current;
}

/// Lists active sessions with a revoke action.
class SessionDevicesPage extends ConsumerStatefulWidget {
  /// Default constructor.
  const SessionDevicesPage({super.key});

  @override
  ConsumerState<SessionDevicesPage> createState() =>
      _SessionDevicesPageState();
}

class _SessionDevicesPageState extends ConsumerState<SessionDevicesPage> {
  // TODO(F-AUTH-WEB): wire to DevicesService from fnx_data_api once available.
  final List<_Device> _devices = <_Device>[
    _Device(
      id: 'cur',
      name: 'This device',
      lastSeen: DateTime.now(),
      current: true,
    ),
    _Device(
      id: 'iphone',
      name: 'iPhone 15',
      lastSeen: DateTime.now().subtract(const Duration(hours: 3)),
      current: false,
    ),
    _Device(
      id: 'web',
      name: 'Chrome on macOS',
      lastSeen: DateTime.now().subtract(const Duration(days: 2)),
      current: false,
    ),
  ];

  void _revoke(_Device d) {
    setState(() => _devices.removeWhere((x) => x.id == d.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _devices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final d = _devices[i];
          return FnxCard(
            child: ListTile(
              key: ValueKey<String>('devices.row.${d.id}'),
              leading: Icon(
                d.current ? Icons.devices_other : Icons.smartphone_outlined,
              ),
              title: Text(d.name),
              subtitle: Text(
                '${d.lastSeen.toLocal()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: d.current
                  ? null
                  : TextButton(
                      key: ValueKey<String>('devices.revoke.${d.id}'),
                      onPressed: () => _revoke(d),
                      child: Text(l10n.commonDelete),
                    ),
            ),
          );
        },
      ),
    );
  }
}
