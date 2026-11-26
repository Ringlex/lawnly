import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lawnly/core/fpdarts.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';

enum LocationFailure { serviceDisabled, permissionDenied, notFound, network }

class LocationRepository {
  const LocationRepository({required http.Client client}) : _client = client;

  final http.Client _client;

  static const _geocodingHost = 'geocoding-api.open-meteo.com';

  TaskEither<LocationFailure, LawnLocation> current() =>
      tryCatchE<LocationFailure, LawnLocation>(() async {
        if (!await Geolocator.isLocationServiceEnabled()) {
          return left(LocationFailure.serviceDisabled);
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return left(LocationFailure.permissionDenied);
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
        );
        return right(LawnLocation(latitude: position.latitude, longitude: position.longitude));
      }, (_, _) => LocationFailure.serviceDisabled);

  TaskEither<LocationFailure, LawnLocation> search(String query) =>
      tryCatchE<LocationFailure, LawnLocation>(() async {
        final uri = Uri.https(_geocodingHost, '/v1/search', {
          'name': query.trim(),
          'count': '1',
          'language': 'pl',
          'format': 'json',
        });
        final response = await _client.get(uri);
        if (response.statusCode != 200) {
          return left(LocationFailure.network);
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final results = body['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return left(LocationFailure.notFound);
        }

        final place = results.first as Map<String, dynamic>;
        return right(
          LawnLocation(
            latitude: (place['latitude'] as num).toDouble(),
            longitude: (place['longitude'] as num).toDouble(),
            label: place['name'] as String,
          ),
        );
      }, (_, _) => LocationFailure.network);
}
