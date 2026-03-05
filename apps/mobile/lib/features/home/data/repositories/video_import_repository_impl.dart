import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/video_import_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/video_import_repository.dart';

class VideoImportRepositoryImpl implements VideoImportRepository {
  VideoImportRepositoryImpl(this._dataSource);

  final VideoImportRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, String>> importFromVideo(String url, String language) async {
    try {
      final jobId = await _dataSource.importFromVideo(url, language);
      return Right(jobId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getImportStatus(String jobId) async {
    try {
      final status = await _dataSource.getImportStatus(jobId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
