import '../entity/user.dart';

class UserOutput {
  final String type;
  final User? user;
  final String? message;

  UserOutput._({required this.type, this.user, this.message});

  factory UserOutput.loginSuccess(User user) {
    return UserOutput._(type: 'LOGIN_SUCCESS', user: user);
  }

  factory UserOutput.loginFail(String message) {
    return UserOutput._(type: 'LOGIN_FAIL', message: message);
  }
}
