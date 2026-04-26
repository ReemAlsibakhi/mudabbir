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
        return const Fail(PermissionFailure('الإذن مرفوض بشكل دائم — افتح الإعدادات'));

      return const Success(true);
    } catch (e, st) {
      AppLogger.error(_tag, 'requestPermission error', e, st);
      return Fail(UnexpectedFailure(e.toString()));
    }
  }

  // ── Get current position ──────────────────────────────
  Future<Result<Position>> getCurrentPosition() async {
    try {
      // geolocator ^12: use desiredAccuracy directly (no locationSettings wrapper)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit:       const Duration(seconds: 10),
      );
      return Success(position);
    } catch (e, st) {
      AppLogger.error(_tag, 'getCurrentPosition error', e, st);
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
      AppLogger.error(_tag, 'getPlaceName error', e);
      return const Fail(UnexpectedFailure('خطأ في تحديد المكان'));
    }
  }

  // ── Detect location type from place name ─────────────
  LocationType detectType(String placeName) {
    final name = placeName.toLowerCase();
    if (name.contains('carrefour') || name.contains('لولو') ||
        name.contains('hypermarket') || name.contains('بقالة') ||
        name.contains('supermarket') || name.contains('danube') ||
        name.contains('panda'))
      return LocationType.supermarket;
    if (name.contains('restaurant') || name.contains('مطعم') ||
        name.contains('kfc') || name.contains('mcdonalds') ||
        name.contains('cafe') || name.contains('كافيه'))
      return LocationType.restaurant;
    if (name.contains('mall') || name.contains('مول') ||
        name.contains('plaza') || name.contains('plaza'))
      return LocationType.mall;
    if (name.contains('pharmacy') || name.contains('صيدلية') ||
        name.contains('nahdi') || name.contains('النهدي'))
      return LocationType.pharmacy;
    if (name.contains('petro') || name.contains('aramco') ||
        name.contains('محطة') || name.contains('shell'))
      return LocationType.fuel;
    return LocationType.mall;
  }
}
