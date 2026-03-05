import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';

abstract class VideoImportRepository {
  /// Submits a video URL for transcription. Returns the job ID on success.
  Future<Either<Failure, String>> importFromVideo(String url, String language);

  /// Polls job status. Returns a status map on success.
  Future<Either<Failure, Map<String, dynamic>>> getImportStatus(String jobId);
}
