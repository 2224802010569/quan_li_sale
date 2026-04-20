enum UserEventType { loginSuccess }

class UserEvent {
  final UserEventType type;
  final Map<String, dynamic>? data;

  UserEvent({required this.type, this.data});

  factory UserEvent.loginSuccess(Map<String, dynamic> data) {
    return UserEvent(type: UserEventType.loginSuccess, data: data);
  }
}
