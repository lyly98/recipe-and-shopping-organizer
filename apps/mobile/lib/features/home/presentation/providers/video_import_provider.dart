import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/video_import_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/video_import_providers.dart';

// ---------------------------------------------------------------------------
// State classes
// ---------------------------------------------------------------------------

abstract class VideoImportState {
  const VideoImportState();
}

class VideoImportIdle extends VideoImportState {
  const VideoImportIdle();
}

class VideoImportSubmitting extends VideoImportState {
  const VideoImportSubmitting();
}

class VideoImportPolling extends VideoImportState {
  const VideoImportPolling(this.jobId);
  final String jobId;
}

class VideoImportDone extends VideoImportState {
  const VideoImportDone(this.recipeData);
  final Map<String, dynamic> recipeData;
}

class VideoImportError extends VideoImportState {
  const VideoImportError(this.message);
  final String message;
}

// ---------------------------------------------------------------------------
// Notifier (Riverpod 3 — Notifier<T>)
// ---------------------------------------------------------------------------

class VideoImportNotifier extends Notifier<VideoImportState> {
  Timer? _pollingTimer;

  @override
  VideoImportState build() {
    ref.onDispose(() => _pollingTimer?.cancel());
    return const VideoImportIdle();
  }

  VideoImportRepository get _repository =>
      ref.read(videoImportRepositoryProvider);

  Future<void> submitJob(String url, String language) async {
    state = const VideoImportSubmitting();

    final result = await _repository.importFromVideo(url, language);

    result.fold(
      (failure) => state = VideoImportError(failure.message),
      (jobId) {
        state = VideoImportPolling(jobId);
        _startPolling(jobId);
      },
    );
  }

  void _startPolling(String jobId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkStatus(jobId),
    );
  }

  Future<void> _checkStatus(String jobId) async {
    final result = await _repository.getImportStatus(jobId);

    result.fold(
      (failure) {
        _pollingTimer?.cancel();
        state = VideoImportError(failure.message);
      },
      (statusMap) {
        final status = statusMap['status'] as String?;
        if (status == 'done') {
          _pollingTimer?.cancel();
          final recipeData = statusMap['recipe_data'];
          state = VideoImportDone(
            recipeData is Map<String, dynamic>
                ? recipeData
                : Map<String, dynamic>.from(recipeData as Map? ?? {}),
          );
        } else if (status == 'error') {
          _pollingTimer?.cancel();
          state = VideoImportError(
            statusMap['error_message'] as String? ?? 'Une erreur est survenue',
          );
        }
        // "pending" → keep polling
      },
    );
  }

  void reset() {
    _pollingTimer?.cancel();
    state = const VideoImportIdle();
  }
}

// ---------------------------------------------------------------------------
// Provider (auto-dispose so state resets when modal is closed)
// ---------------------------------------------------------------------------

final videoImportProvider =
    NotifierProvider.autoDispose<VideoImportNotifier, VideoImportState>(
  VideoImportNotifier.new,
);
