import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    print('===== LOCATION STEP 1 ====='); print('===== LOCATION STEP 1 ====='); bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); print('===== LOCATION STEP 1 OK ====='); print('===== LOCATION STEP 1 OK =====');
    if (!serviceEnabled) { print('===== LOCATION BLOCKED: SERVICE DISABLED ====='); return null; }

    print('===== LOCATION STEP 2 ====='); print('===== LOCATION STEP 2 ====='); LocationPermission permission = await Geolocator.checkPermission(); print('===== LOCATION STEP 2 OK: ' + permission.toString() + ' ====='); print('===== LOCATION STEP 2 OK: ' + permission.toString() + ' =====');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) { print('===== LOCATION BLOCKED: PERMISSION DENIED ====='); return null; }
    }
    if (permission == LocationPermission.deniedForever) { print('===== LOCATION BLOCKED: PERMISSION DENIED FOREVER ====='); return null; }

    print('===== LOCATION STEP 3 ====='); print('===== LOCATION STEP 3 ====='); final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    print('===== LOCATION DEBUG =====');
    print('LATITUDE: ${position.latitude}');
    print('LONGITUDE: ${position.longitude}');
    print('ACCURACY: ${position.accuracy}');
    print('===== FIM LOCATION DEBUG =====');

    return position;
  }
}



