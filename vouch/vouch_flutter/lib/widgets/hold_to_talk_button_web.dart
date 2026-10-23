import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../app/theme.dart';

enum _HoldState { idle, listening, verifying, error }

Widget buildHoldToTalkButton(
  BuildContext context, {
  required Future<void> Function(Uint8List audioBytes, String mimeType) onRecorded,
  required bool enabled,
}) {
  return _HoldToTalkButtonWeb(onRecorded: onRecorded, enabled: enabled);
}

class _HoldToTalkButtonWeb extends StatefulWidget {
  const _HoldToTalkButtonWeb({required this.onRecorded, required this.enabled});

  final Future<void> Function(Uint8List audioBytes, String mimeType) onRecorded;
  final bool enabled;

  @override
  State<_HoldToTalkButtonWeb> createState() => _HoldToTalkButtonWebState();
}

class _HoldToTalkButtonWebState extends State<_HoldToTalkButtonWeb> {
  _HoldState _state = _HoldState.idle;
  String? _errorMessage;
  web.MediaStream? _stream;
  web.MediaRecorder? _recorder;
  final List<web.Blob> _chunks = [];

  static const _mimeType = 'audio/webm;codecs=opus';

  Future<void> _startRecording() async {
    if (!widget.enabled || _state == _HoldState.listening) return;
    try {
      _stream ??= await web.window.navigator.mediaDevices
          .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
          .toDart;
      final mimeType = web.MediaRecorder.isTypeSupported(_mimeType) ? _mimeType : 'audio/webm';
      _chunks.clear();
      final recorder = web.MediaRecorder(_stream!, web.MediaRecorderOptions(mimeType: mimeType));
      recorder.ondataavailable = ((web.Event event) {
        final blobEvent = event as web.BlobEvent;
        _chunks.add(blobEvent.data);
      }).toJS;
      _recorder = recorder;
      recorder.start();
      setState(() {
        _state = _HoldState.listening;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _state = _HoldState.error;
        _errorMessage = 'Microphone unavailable: $e';
      });
      _resetToIdleAfterDelay();
    }
  }

  Future<void> _stopRecording() async {
    final recorder = _recorder;
    if (recorder == null || _state != _HoldState.listening) return;
    setState(() => _state = _HoldState.verifying);

    final done = Completer<void>();
    recorder.onstop = ((web.Event _) => done.complete()).toJS;
    recorder.stop();
    await done.future;

    try {
      final blob = _chunks.isEmpty
          ? web.Blob(<web.BlobPart>[].toJS)
          : web.Blob(_chunks.map((c) => c as web.BlobPart).toList().toJS);
      final buffer = await blob.arrayBuffer().toDart;
      final bytes = buffer.toDart.asUint8List();
      await widget.onRecorded(bytes, recorder.mimeType.isNotEmpty ? recorder.mimeType : _mimeType);
      if (!mounted) return;
      setState(() => _state = _HoldState.idle);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _HoldState.error;
        _errorMessage = '$e';
      });
      _resetToIdleAfterDelay();
    }
  }

  void _resetToIdleAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _state == _HoldState.error) {
        setState(() {
          _state = _HoldState.idle;
          _errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    for (final track in (_stream?.getTracks().toDart ?? const [])) {
      track.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final label = switch (_state) {
      _HoldState.idle => 'Hold to talk',
      _HoldState.listening => 'Listening…',
      _HoldState.verifying => 'Verifying…',
      _HoldState.error => _errorMessage ?? 'Error',
    };
    final color = switch (_state) {
      _HoldState.idle => c.textSecondary,
      _HoldState.listening => c.success,
      _HoldState.verifying => c.textSecondary,
      _HoldState.error => c.errorText,
    };
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _startRecording() : null,
      onTapUp: widget.enabled ? (_) => _stopRecording() : null,
      onTapCancel: widget.enabled ? () => _stopRecording() : null,
      child: Container(
        key: const Key('hold-to-talk-button'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_state == _HoldState.verifying)
              SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
              )
            else
              Icon(Icons.mic, color: color, size: 16),
            const SizedBox(width: 8),
            Flexible(child: Text(label, style: TextStyle(color: color))),
          ],
        ),
      ),
    );
  }
}
