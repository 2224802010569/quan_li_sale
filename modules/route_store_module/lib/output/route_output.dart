import 'package:route_store_module/entity/assignment_entity.dart';

class RouteOutput {
  final Function(AssignmentEntity assignment)? onVisitCompleted;
  final Function(List<AssignmentEntity> allAssignments)? onRouteFinished;

  RouteOutput({
    this.onVisitCompleted,
    this.onRouteFinished,
  });
}
