import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/logic_data/visit_data.dart';

final uploadVisitPhotoUcProvider = Provider<UploadVisitPhotoUc>((ref) {
  return UploadVisitPhotoUc(ref.read(visitDataProvider));
});

class UploadVisitPhotoUc {
  final VisitData _visitData;

  UploadVisitPhotoUc(this._visitData);

  Future<String> execute(String userId, File photoFile) async {
    return await _visitData.uploadVisitPhoto(userId, photoFile);
  }
}
