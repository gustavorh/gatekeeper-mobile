import 'package:equatable/equatable.dart';

/// Represents user authentication credentials
class AuthCredentials extends Equatable {
  final String rut;
  final String password;

  const AuthCredentials({required this.rut, required this.password});

  /// Clean the RUT format (remove dots and dashes)
  String get cleanRut => rut.replaceAll(RegExp(r'[.-]'), '');

  /// Format RUT for display (add dots and dash)
  String get formattedRut {
    final cleanedRut = cleanRut;
    if (cleanedRut.length < 2) return cleanedRut;

    final body = cleanedRut.substring(0, cleanedRut.length - 1);
    final dv = cleanedRut.substring(cleanedRut.length - 1);

    if (body.length <= 3) {
      return '$body-$dv';
    } else if (body.length <= 6) {
      return '${body.substring(0, body.length - 3)}.${body.substring(body.length - 3)}-$dv';
    } else {
      return '${body.substring(0, body.length - 6)}.${body.substring(body.length - 6, body.length - 3)}.${body.substring(body.length - 3)}-$dv';
    }
  }

  /// Validate if the RUT format is correct
  bool get isValidRut {
    final cleanedRut = cleanRut;
    if (cleanedRut.length < 8 || cleanedRut.length > 9) return false;

    // Check if it's numeric except for the last character (which can be 'k' or 'K')
    final body = cleanedRut.substring(0, cleanedRut.length - 1);
    final dv = cleanedRut.substring(cleanedRut.length - 1);

    if (!RegExp(r'^\d+$').hasMatch(body)) return false;
    if (!RegExp(r'^[\dkK]$').hasMatch(dv)) return false;

    return true;
  }

  /// Validate if password meets minimum requirements
  bool get isValidPassword => password.length >= 6;

  /// Check if both RUT and password are valid
  bool get isValid => isValidRut && isValidPassword;

  /// Create credentials with cleaned RUT
  AuthCredentials withCleanRut() {
    return AuthCredentials(rut: cleanRut, password: password);
  }

  @override
  List<Object?> get props => [rut, password];

  @override
  String toString() => 'AuthCredentials(rut: $formattedRut)'; // Don't expose password
}
