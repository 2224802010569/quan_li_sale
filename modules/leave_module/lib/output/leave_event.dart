/// leave_event.dart
/// Event pattern chuẩn — giống UserEvent trong user_module.
/// LeaveScreen sẽ gọi callback onEvent(LeaveEvent) thay vì LeaveOutput.

enum LeaveEventType { submitted, approved, rejected, close }

class LeaveEvent {
  final LeaveEventType type;
  final Map<String, dynamic>? data;

  LeaveEvent({required this.type, this.data});

  factory LeaveEvent.submitted() => LeaveEvent(type: LeaveEventType.submitted);
  factory LeaveEvent.approved() => LeaveEvent(type: LeaveEventType.approved);
  factory LeaveEvent.rejected() => LeaveEvent(type: LeaveEventType.rejected);
  factory LeaveEvent.close() => LeaveEvent(type: LeaveEventType.close);
}
