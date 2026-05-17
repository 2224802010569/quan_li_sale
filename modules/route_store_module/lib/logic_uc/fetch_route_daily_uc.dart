import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/assignment_entity.dart';
import 'package:route_store_module/logic_data/assignment_data.dart';

final fetchRouteDailyUcProvider = Provider<FetchRouteDailyUc>((ref) {
  return FetchRouteDailyUc(ref.read(assignmentDataProvider));
});

// Giả sử có một provider lưu trữ trạng thái userId và date hiện tại
// Có thể lấy từ route_input
final currentUserIdProvider = StateProvider<String>((ref) => '');
final currentDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Riverpod AsyncValue provider để UI dễ consume
final dailyRouteProvider = FutureProvider<List<AssignmentEntity>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final date = ref.watch(currentDateProvider);
  
  if (userId.isEmpty) return [];
  
  final uc = ref.read(fetchRouteDailyUcProvider);
  return await uc.execute(userId, date);
});

class FetchRouteDailyUc {
  final AssignmentData _assignmentData;

  FetchRouteDailyUc(this._assignmentData);

  Future<List<AssignmentEntity>> execute(String userId, DateTime date) async {
    return await _assignmentData.getAssignmentsByUserAndDate(userId, date);
  }
}
