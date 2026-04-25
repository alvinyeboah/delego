import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/api/api_models.dart';
import '../auth/data/auth_repository.dart';
import '../delego_providers.dart';
import '../realtime/task_socket_service.dart';

class CommandCenterPage extends ConsumerStatefulWidget {
  const CommandCenterPage({super.key});

  @override
  ConsumerState<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends ConsumerState<CommandCenterPage> {
  bool _loadingTenants = false;
  bool _loadingAudit = false;
  List<Map<String, dynamic>> _tenants = const [];
  List<AuditLogDto> _audit = const [];
  JwtMeDto? _me;
  String? _deviceToken;
  List<DeviceTokenDto> _serverDeviceTokens = const [];
  bool _loadingDeviceTokens = false;
  String? _socketStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final session = ref.read(authSessionProvider);
    if (session == null) return;
    final token = await ref.read(deviceTokenServiceProvider).getOrCreateToken();
    if (mounted) setState(() => _deviceToken = token);
    await _refreshServerDeviceTokens();
    await _refreshMe();
    await _loadTenants();
    await _loadAudit();
    _refreshSocketLabel();
  }

  Future<void> _refreshMe() async {
    try {
      final me = await AuthRepository(ref.read(apiClientProvider)).me();
      if (mounted) setState(() => _me = me);
    } catch (_) {
      if (mounted) setState(() => _me = null);
    }
  }

  Future<void> _loadTenants() async {
    setState(() => _loadingTenants = true);
    try {
      final list = await ref.read(tenantRepositoryProvider).listTenants();
      if (mounted) setState(() => _tenants = list);
    } finally {
      if (mounted) setState(() => _loadingTenants = false);
    }
  }

  Future<void> _loadAudit() async {
    final session = ref.read(authSessionProvider);
    if (session == null) return;
    setState(() => _loadingAudit = true);
    try {
      final list = await ref.read(auditRepositoryProvider).listForTenant(session.tenantId);
      if (mounted) setState(() => _audit = list);
    } catch (_) {
      if (mounted) setState(() => _audit = const []);
    } finally {
      if (mounted) setState(() => _loadingAudit = false);
    }
  }

  Future<void> _refreshServerDeviceTokens() async {
    setState(() => _loadingDeviceTokens = true);
    try {
      final list = await ref.read(deviceTokenRepositoryProvider).list();
      if (mounted) setState(() => _serverDeviceTokens = list);
    } catch (_) {
      if (mounted) setState(() => _serverDeviceTokens = const []);
    } finally {
      if (mounted) setState(() => _loadingDeviceTokens = false);
    }
  }

  Future<void> _registerDeviceTokenOnServer() async {
    final messenger = ScaffoldMessenger.of(context);
    final token = _deviceToken ?? await ref.read(deviceTokenServiceProvider).getOrCreateToken();
    if (!context.mounted) return;
    setState(() => _deviceToken = token);
    try {
      await ref.read(deviceTokenRepositoryProvider).register(
            token: token,
            platform: kIsWeb ? 'flutter-web' : 'flutter-${defaultTargetPlatform.name}',
          );
      if (!context.mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('This device is registered for notifications')));
      await _refreshServerDeviceTokens();
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Register failed: $e')));
    }
  }

  void _refreshSocketLabel() {
    final c = ref.read(taskSocketServiceProvider).connected;
    if (mounted) setState(() => _socketStatus = c ? 'connected' : 'disconnected');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Text('Command center', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Your profile, organizations, audit history, analytics, and live updates for the task board.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        _sectionTitle(context, 'Profile & identity'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signed in as ${session?.email ?? '—'}', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 6),
                Text('User id: ${session?.userId ?? '—'}', style: Theme.of(context).textTheme.bodySmall),
                Text('Tenant id: ${session?.tenantId ?? '—'}', style: Theme.of(context).textTheme.bodySmall),
                Text('Default workspace: ${session?.defaultWorkspaceId ?? '—'}', style: Theme.of(context).textTheme.bodySmall),
                if (_me != null) ...[
                  const SizedBox(height: 8),
                  Text('Account id: ${_me!.sub}', style: Theme.of(context).textTheme.labelSmall),
                  Text('Email: ${_me!.email}', style: Theme.of(context).textTheme.labelSmall),
                  Text('Organization scope: ${_me!.tenantId}', style: Theme.of(context).textTheme.labelSmall),
                ],
                const SizedBox(height: 8),
                Text('Push device id (for notifications when enabled):', style: Theme.of(context).textTheme.labelMedium),
                SelectableText(_deviceToken ?? '—', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  _loadingDeviceTokens
                      ? 'Loading server registrations…'
                      : 'Server registrations for this user: ${_serverDeviceTokens.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: _refreshMe,
                      child: const Text('Refresh profile'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () async {
                        await ref.read(deviceTokenServiceProvider).resetToken();
                        final t = await ref.read(deviceTokenServiceProvider).getOrCreateToken();
                        if (mounted) setState(() => _deviceToken = t);
                      },
                      child: const Text('Rotate token'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _registerDeviceTokenOnServer,
                      child: const Text('Register on server'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loadingDeviceTokens ? null : _refreshServerDeviceTokens,
                  child: const Text('Refresh registrations'),
                ),
                const SizedBox(height: 16),
                Text('Live updates: ${_socketStatus ?? '—'}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton(
                      onPressed: session?.defaultWorkspaceId == null
                          ? null
                          : () {
                              ref.read(taskSocketServiceProvider).connect(
                                    workspaceId: session!.defaultWorkspaceId!,
                                    token: session.accessToken,
                                  );
                              Future.delayed(const Duration(milliseconds: 400), _refreshSocketLabel);
                            },
                      child: const Text('Connect'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        ref.read(taskSocketServiceProvider).dispose();
                        setState(() => _socketStatus = 'disconnected');
                      },
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle(context, 'Tenant & workspaces'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _loadingTenants
                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._tenants.map((t) => _tenantBlock(context, t)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.tonal(onPressed: _loadTenants, child: const Text('Reload')),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => _promptCreateOrg(context),
                            child: const Text('New organization'),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle(context, 'Audit trail'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _loadingAudit
                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_audit.isEmpty) const Text('No audit entries yet'),
                      ..._audit.take(25).map(
                            (a) => ListTile(
                              dense: true,
                              title: Text('${a.action} · ${a.resource}'),
                              subtitle: Text(a.createdAtIso),
                            ),
                          ),
                      TextButton(onPressed: _loadAudit, child: const Text('Reload audit')),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle(context, 'Analytics'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send a structured event for reporting (event name and JSON details). Your team uses this for dashboards and trends.',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: session == null ? null : () => _openAnalyticsDialog(context, session.tenantId),
                  child: const Text('Send analytics event…'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _tenantBlock(BuildContext context, Map<String, dynamic> tenant) {
    final id = tenant['id'] as String? ?? '';
    final name = tenant['name'] as String? ?? '';
    final orgs = (tenant['organizations'] as List<dynamic>?) ?? const [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$name ($id)', style: Theme.of(context).textTheme.titleSmall),
          ...orgs.map((raw) {
            final o = Map<String, dynamic>.from(raw as Map);
            final oid = o['id'] as String? ?? '';
            final oname = o['name'] as String? ?? '';
            final wss = (o['workspaces'] as List<dynamic>?) ?? const [];
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Org: $oname ($oid)', style: Theme.of(context).textTheme.bodySmall),
                  ...wss.map((w) {
                    final wm = Map<String, dynamic>.from(w as Map);
                    return Padding(
                      padding: const EdgeInsets.only(left: 12, top: 2),
                      child: Text('Workspace: ${wm['name']} (${wm['id']})', style: Theme.of(context).textTheme.labelSmall),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _promptCreateWorkspace(context, oid),
                      child: const Text('Add workspace here'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _promptCreateOrg(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(authSessionProvider);
    if (session == null) return;
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New organization'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    try {
      final org = await ref.read(tenantRepositoryProvider).createOrganization(
            tenantId: session.tenantId,
            name: nameCtrl.text.trim(),
          );
      await _loadTenants();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Organization ${org.id} created at ${org.createdAtIso}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _promptCreateWorkspace(BuildContext context, String organizationId) async {
    final messenger = ScaffoldMessenger.of(context);
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New workspace'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    try {
      final ws = await ref.read(tenantRepositoryProvider).createWorkspace(
            organizationId: organizationId,
            name: nameCtrl.text.trim(),
          );
      await _loadTenants();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Workspace ${ws.id} created at ${ws.createdAtIso}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _openAnalyticsDialog(BuildContext context, String tenantId) async {
    final messenger = ScaffoldMessenger.of(context);
    final eventType = TextEditingController();
    final payloadJson = TextEditingController(text: '{}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send analytics event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventType,
                decoration: const InputDecoration(labelText: 'Event name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: payloadJson,
                decoration: const InputDecoration(labelText: 'Details (JSON)'),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Publish')),
        ],
      ),
    );
    if (ok != true) return;
    if (eventType.text.trim().isEmpty) {
      if (!context.mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Event name is required')));
      return;
    }
    late final Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(payloadJson.text.trim());
      if (decoded is! Map) {
        throw const FormatException('payload must be a JSON object');
      }
      payload = Map<String, dynamic>.from(decoded);
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Invalid JSON: $e')));
      return;
    }
    try {
      final row = await ref.read(analyticsRepositoryProvider).publish(
            tenantId: tenantId,
            eventType: eventType.text.trim(),
            payload: payload,
          );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Event sent · ref ${row.id}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
