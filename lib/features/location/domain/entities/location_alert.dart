import 'package:equatable/equatable.dart';

enum LocationType { supermarket, restaurant, mall, pharmacy, fuel }

final class LocationAlert extends Equatable {
  final String       placeName;
  final LocationType type;
  final double       latitude;
  final double       longitude;
  final DateTime     detectedAt;

  const LocationAlert({
    required this.placeName,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.detectedAt,
  });

  String get suggestedCategory => switch (type) {
    LocationType.supermarket => 'food',
    LocationType.restaurant  => 'restaurants',
    LocationType.mall        => 'shopping',
    LocationType.pharmacy    => 'health',
    LocationType.fuel        => 'transport',
  };

  String get alertMessage => switch (type) {
    LocationType.supermarket => 'دخلت $placeName — تريد تسجيل مصروف بقالة؟',
    LocationType.restaurant  => 'أنت في $placeName — تريد تسجيل وجبة؟',
    LocationType.mall        => 'دخلت $placeName — انتبه من التسوق الزائد!',
    LocationType.pharmacy    => 'في صيدلية — تريد تسجيل مصروف صحة؟',
    LocationType.fuel        => 'عند محطة وقود — تريد تسجيل مصروف وقود؟',
  };

  @override
  List<Object?> get props => [placeName, type, latitude, longitude];
}
