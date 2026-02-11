import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id, 
    name, 
    email, 
    profilePicture, 
    phone, 
    createdAt, 
    updatedAt
  ];

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// Parses the backend API response (UserRead: id, name, username, email, profile_image_url).
  factory UserModel.fromApiJson(Map<String, dynamic> json) {
    final id = json['id'];
    return UserModel(
      id: id != null ? id.toString() : '',
      name: (json['name'] ?? json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      profilePicture: json['profile_image_url'] as String?,
      phone: null,
      createdAt: null,
      updatedAt: null,
    );
  }
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
      
  // Factory constructor to convert UserEntity to UserModel
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      profilePicture: entity.profilePicture,
      phone: entity.phone,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

// Extension to convert UserModel to UserEntity
extension UserModelX on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      profilePicture: profilePicture,
      phone: phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
