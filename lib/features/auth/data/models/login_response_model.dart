import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'login_response_model.g.dart';

/// Data model for login API response
@JsonSerializable()
class LoginResponseModel {
  final String? token;
  final UserModel? user;
  final String? message;
  final bool? success;

  const LoginResponseModel({this.token, this.user, this.message, this.success});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
