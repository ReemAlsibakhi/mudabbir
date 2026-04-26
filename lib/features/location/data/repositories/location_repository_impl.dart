import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/location_alert.dart';

final class LocationRepositoryImpl {
  static const _tag = 'LocationRepo';

  // ── Request permission ────────────────────────────────
  Future<Result<bool>> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled)
        return const Fail(PermissionFailure('GPS غير مفعّل على الجهاز'));

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          return const Fail(PermissionFailure('تم رفض إذن الموقع'));
      }

      if (permission == LocationPermission.deniedForever)
        return const Fail(
            PermissionFailure('الإذن مرفوض بشكل دائم — افتح الإعدادات'));

      return const Success(true);
    } catch (e, st) {
      AppLogger.error(_tag, 'requestPermission', e, st);
      return Fail(UnexpectedFailure(e.toString()));
    }
  }

  // ── Get current position ──────────────────────────────
  // geolocator ^12: getCurrentPosition accepts desiredAccuracy only
  // timeLimit was removed in ^10+ — use timeout on the Future instead
  Future<Result<Position>> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('انتهت مهلة تحديد الموقع'),
      );
      return Success(position);
    } catch (e, st) {
      AppLogger.error(_tag, 'getCurrentPosition', e, st);
      return Fail(UnexpectedFailure(e.toString()));
    }
  }

  // ── Reverse geocode ───────────────────────────────────
  Future<Result<String>> getPlaceName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty)
        return const Fail(NotFoundFailure('لم يتم تحديد المكان'));

      final place = placemarks.first;
      final name  = place.name?.isNotEmpty == true
          ? place.name!
          : place.street ?? place.locality ?? 'موقع غير معروف';
      return Success(name);
    } catch (e) {
      AppLogger.error(_tag, 'getPlaceName', e);
      return const Fail(UnexpectedFailure('خطأ في تحديد المكان'));
    }
  }

  // ── Detect type from place name ───────────────────────
  LocationType detectType(String placeName) {
    final n = placeName.toLowerCase();
    if (n.contains('carrefour') || n.contains('لولو') ||
        n.contains('hypermarket') || n.contains('بقالة') ||
        n.contains('panda')       || n.contains('danube'))
      return LocationType.supermarket;
    if (n.contains('restaurant')  || n.contains('مطعم') ||
        n.contains('kfc')         || n.contains('mcdonalds') ||
        n.contains('cafe')        || n.contains('كافيه'))
      return LocationType.restaurant;
    if (n.contains('mall')        || n.contains('مول') ||
        n.contains('plaza'))
      return LocationType.mall;
    if (n.contains('pharmacy')    || n.contains('صيدلية') ||
        n.contains('nahdi')       || n.contains('النهدي'))
      return LocationType.pharmacy;
    if (n.contains('petro')       || n.contains('محطة') ||
        n.contains('aramco')      || n.contains('shell'))
      return LocationType.fuel;
    return LocationType.mall;
  }
}
