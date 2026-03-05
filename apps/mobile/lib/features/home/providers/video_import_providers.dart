import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/video_import_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/repositories/video_import_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/video_import_repository.dart';

final videoImportDataSourceProvider =
    Provider<VideoImportRemoteDataSource>((ref) {
  return VideoImportRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final videoImportRepositoryProvider = Provider<VideoImportRepository>((ref) {
  return VideoImportRepositoryImpl(ref.watch(videoImportDataSourceProvider));
});
