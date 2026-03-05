import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';

abstract class VideoImportRemoteDataSource {
  /// Submits a video URL for transcription. Returns the arq job ID.
  Future<String> importFromVideo(String url, String language);

  /// Polls the status of a transcription job. Returns a status map with keys:
  /// - status: "pending" | "done" | "error"
  /// - recipe_data: Map<String, dynamic>? (present when status == "done")
  /// - error_message: String? (present when status == "error")
  Future<Map<String, dynamic>> getImportStatus(String jobId);
}

class VideoImportRemoteDataSourceImpl implements VideoImportRemoteDataSource {
  VideoImportRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<String> importFromVideo(String url, String language) async {
    final result = await _apiClient.post(
      '/api/v1/recipes/import-from-video',
      data: {'url': url, 'language': language},
    );
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) {
        final map = data as Map<String, dynamic>?;
        final jobId = map?['job_id'] as String?;
        if (jobId == null || jobId.isEmpty) {
          throw ServerException(message: 'No job_id in server response');
        }
        return jobId;
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getImportStatus(String jobId) async {
    final result = await _apiClient.get('/api/v1/recipes/import-status/$jobId');
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }
}
