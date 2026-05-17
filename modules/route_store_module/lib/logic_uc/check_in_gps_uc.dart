import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final checkInGpsUcProvider = Provider<CheckInGpsUc>((ref) => CheckInGpsUc());

class CheckInGpsUc {
  static const double ALLOWED_DISTANCE_METERS = 200.0;

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    } 

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }

  bool isWithinRadius(double currentLat, double currentLng, double storeLat, double storeLng) {
    final distance = Distance().as(
      LengthUnit.Meter,
      LatLng(currentLat, currentLng),
      LatLng(storeLat, storeLng),
    );
    return distance <= ALLOWED_DISTANCE_METERS;
  }
}
