import '../entity/user.dart';

class LoginOutput {
  final String from;
  final String to;
  final String view;
  final Map<String, dynamic>? data;

  LoginOutput({
    required this.from,
    required this.to,
    required this.view,
    this.data,
  });

  factory LoginOutput.loginSuccess(User user) {
    return LoginOutput(
      from: 'USER',
      to: 'ROUTE_STORE',
      view: 'HOME',
      data: {'userId': user.id, 'role': user.role, 'token': user.token},
    );
  }
}
