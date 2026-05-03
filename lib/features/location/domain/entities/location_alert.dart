import '../../../../core/constants/app_strings.dart';
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
    LocationType.supermarket => '${AppStrings.alertSuperPre}$placeName${AppStrings.alertSuperSuf}',
    LocationType.restaurant  => '${AppStrings.alertRestPre}$placeName${AppStrings.alertRestSuf}',
    LocationType.mall        => '${AppStrings.alertMallPre}$placeName${AppStrings.alertMallSuf}',
    LocationType.pharmacy    => AppStrings.alertPharmacy,
    LocationType.fuel        => AppStrings.alertFuel,
  };

  @override
  List<Object?> get props => [placeName, type, latitude, longitude];
}
