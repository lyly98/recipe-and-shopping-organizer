import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, UserEntity>> execute({
    required String email,
    required String username,
    required String password,
  }) {
    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      return Future.value(
        const Left(
          InputFailure(message: 'Email, username, and password cannot be empty'),
        ),
      );
    }

    return _repository.register(email: email, username: username, password: password);
  }
}
