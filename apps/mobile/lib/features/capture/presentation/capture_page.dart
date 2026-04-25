import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../app.dart';
import '../../delego_providers.dart';

String _deviceKindLabel() {
  if (kIsWeb) return 'Web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.iOS => 'iOS',
    TargetPlatform.macOS => 'macOS',
    TargetPlatform.windows => 'Windows',
    TargetPlatform.linux => 'Linux',
    _ => 'Mobile',
  };
}

class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({super.key});

  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage> {
  final _picker = ImagePicker();
  final _storageKeyCtrl = TextEditingController();
  XFile? _picked;
  String? _ocrPreview;
  bool _busy = false;

  @override
  void dispose() {
    _storageKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Field capture', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Take or choose a photo, upload it, then save a capture. You can run text recognition on the image when your team has it turned on.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _storageKeyCtrl,
          decoration: const InputDecoration(
            labelText: 'Photo reference',
            hintText: 'Upload below, or paste a reference from your team',
          ),
        ),
        if (_ocrPreview != null) ...[
          const SizedBox(height: 12),
          Text('Last recognition result', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          SelectableText(_ocrPreview!, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _busy ? null : _pickImage,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(_picked == null ? 'Pick image' : 'Picked: ${_picked!.name}'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: _busy || _picked == null ? null : _uploadPicked,
          child: Text(_busy ? 'Working…' : 'Upload photo'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? 'Submitting…' : 'Save capture'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _busy ? null : _runOcr,
          child: const Text('Run text recognition'),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _busy ? null : _enqueueOffline,
          child: const Text('Save for later (offline)'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (x == null) {
      setState(() => _picked = null);
      return;
    }
    setState(() {
      _picked = x;
      _ocrPreview = null;
    });
    if (!kIsWeb && x.path.isNotEmpty) {
      _storageKeyCtrl.text = x.path;
    }
  }

  Future<void> _uploadPicked() async {
    final x = _picked;
    if (x == null) return;
    setState(() => _busy = true);
    try {
      final media = ref.read(mediaRepositoryProvider);
      final up = kIsWeb
          ? await media.uploadBytes(bytes: await x.readAsBytes(), filename: x.name)
          : await media.uploadFile(filePath: x.path, filename: x.name);
      if (mounted) {
        setState(() => _storageKeyCtrl.text = up.storageKey);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded (${up.sizeBytes} bytes) → key set')),
        );
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      // Demo-safe fallback when upload endpoint is unavailable in deployed API.
      if (code == 404) {
        final fallback = 'demo-upload/${DateTime.now().millisecondsSinceEpoch}-${x.name}';
        if (mounted) {
          setState(() => _storageKeyCtrl.text = fallback);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload service unavailable; using demo capture reference.')),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${e.message ?? e}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _requireStorageKey() {
    final k = _storageKeyCtrl.text.trim();
    if (k.isEmpty) {
      throw StateError('imageStorageKey is required');
    }
    return k;
  }

  Future<void> _submit() async {
    final session = ref.read(authSessionProvider);
    final wid = session?.defaultWorkspaceId;
    if (session == null || wid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No workspace')));
      return;
    }
    late final String storageKey;
    try {
      storageKey = _requireStorageKey();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a photo reference — upload a file first, or paste one from your team.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      double? lat;
      double? lng;
      if (!kIsWeb) {
        final perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
          final p = await Geolocator.getCurrentPosition();
          lat = p.latitude;
          lng = p.longitude;
        }
      }
      final repo = ref.read(captureRepositoryProvider);
      final created = await repo.createSession(
        workspaceId: wid,
        imageStorageKey: storageKey,
        createdById: session.userId,
        latitude: lat,
        longitude: lng,
        deviceModel: _deviceKindLabel(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CaptureSession created: ${created.id}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Capture failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runOcr() async {
    late final String storageKey;
    try {
      storageKey = _requireStorageKey();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set a photo reference first — upload above, or paste a valid reference.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(captureRepositoryProvider);
      final body = await repo.runWorkerPipeline(storageKey: storageKey);
      if (mounted) {
        setState(() => _ocrPreview = const JsonEncoder.withIndent('  ').convert(body));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pipeline completed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pipeline failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enqueueOffline() async {
    final session = ref.read(authSessionProvider);
    final wid = session?.defaultWorkspaceId;
    if (session == null || wid == null) return;
    late final String storageKey;
    try {
      storageKey = _requireStorageKey();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a photo reference before saving offline.')),
      );
      return;
    }
    final uuid = const Uuid().v4();
    final payload = jsonEncode({
      'op': 'capture.session',
      'workspaceId': wid,
      'createdById': session.userId,
      'imageStorageKey': storageKey,
    });
    await ref.read(syncQueueRepositoryProvider).enqueue(id: uuid, payload: payload);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Queued ($uuid)')));
    }
  }
}
