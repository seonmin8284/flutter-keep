import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter/material.dart';

/// Service to handle file sharing from other apps
class SharingService {
  static Stream<List<SharedMediaFile>>? _mediaStream;

  /// Initialize sharing streams
  static void initialize() {
    // 파일(이미지 등) 공유 스트림
    _mediaStream = ReceiveSharingIntent.instance.getMediaStream();
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        debugPrint('Received initial shared files: \\${value.length}');
        for (final file in value) {
          debugPrint('File: \\${file.path}, Type: \\${file.type}');
        }
      }
    });
  }

  /// Get the media stream for listening to shared files
  static Stream<List<SharedMediaFile>>? get mediaStream => _mediaStream;

  /// Dispose streams when no longer needed
  static void dispose() {
    _mediaStream = null;
  }
}
