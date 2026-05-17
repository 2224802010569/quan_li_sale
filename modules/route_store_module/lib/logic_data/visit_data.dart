import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

final visitDataProvider = Provider<VisitData>((ref) => VisitData());

class VisitData {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Ghi nhận checkin
  Future<void> recordVisit({
    required String userId,
    required int storeId,
    required double lat,
    required double lng,
    required String photoUrl,
    required DateTime visitTime,
  }) async {
    await _supabase.from('visits').insert({
      'user_id': userId,
      'store_id': storeId,
      'latitude': lat,
      'longitude': lng,
      'photo_url': photoUrl,
      'visit_time': visitTime.toIso8601String(),
      'status': 'visited'
    });
  }

  // Upload ảnh lên storage/visits/{user_id}/{date}/
  Future<String> uploadVisitPhoto(String userId, File photoFile) async {
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final ext = p.extension(photoFile.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final path = '$userId/$dateStr/$fileName';

    await _supabase.storage.from('visits').upload(path, photoFile);
    
    final publicUrl = _supabase.storage.from('visits').getPublicUrl(path);
    return publicUrl;
  }
}
