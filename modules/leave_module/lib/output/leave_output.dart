/// leave_output.dart

import '../entity/leave_request_entity.dart';

typedef OnLeaveSubmitted = void Function(LeaveRequestEntity leave);
typedef OnLeaveApproved = void Function(LeaveRequestEntity leave);
typedef OnClose = void Function();

class LeaveOutput {
  final OnLeaveSubmitted? onLeaveSubmitted;
  final OnLeaveApproved? onLeaveApproved;
  final OnClose? onClose;

  const LeaveOutput({
    this.onLeaveSubmitted,
    this.onLeaveApproved,
    this.onClose,
  });
}
