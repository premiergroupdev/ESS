import 'dart:convert';
import 'package:http/http.dart' as http;

const String kGoogleApiKey = 'AIzaSyAOR_DLUdVhP4yYkRwRoe8My-oi7Pr-sJc';

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion({required this.placeId, required this.description});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);
}

class GooglePlacesService {
  static const String _autocompleteUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
  static const String _distanceMatrixUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';

  /// Suggestions for [input]. Pass the same [sessionToken] for every call
  /// belonging to one "search" (first keystroke through to a place being
  /// picked) — Google bills autocomplete + the following details call
  /// together at a lower combined rate when a session token is used.
  Future<List<PlaceSuggestion>> autocomplete(String input, {String? sessionToken}) async {
    if (input.trim().isEmpty) return [];

    final uri = Uri.parse(_autocompleteUrl).replace(queryParameters: {
      'input': input,
      'key': kGoogleApiKey,
      if (sessionToken != null) 'sessiontoken': sessionToken,
      // Biases results to Pakistan since that's where these trips happen.
      // Remove/change if that's not a safe assumption.
      'components': 'country:pk',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    if (data['status'] != 'OK') return [];

    final predictions = data['predictions'] as List<dynamic>;
    return predictions.map((p) => PlaceSuggestion.fromJson(p)).toList();
  }

  /// Resolves a place_id to lat/lng.
  Future<LatLng?> getPlaceLatLng(String placeId, {String? sessionToken}) async {
    final uri = Uri.parse(_detailsUrl).replace(queryParameters: {
      'place_id': placeId,
      'fields': 'geometry',
      'key': kGoogleApiKey,
      if (sessionToken != null) 'sessiontoken': sessionToken,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data['status'] != 'OK') return null;

    final location = data['result']['geometry']['location'];
    return LatLng((location['lat'] as num).toDouble(), (location['lng'] as num).toDouble());
  }

  /// Driving distance in kilometers between two points via the Distance
  /// Matrix API. Returns null if no route could be resolved.
  Future<double?> drivingDistanceKm(LatLng origin, LatLng destination) async {
    final uri = Uri.parse(_distanceMatrixUrl).replace(queryParameters: {
      'origins': '${origin.lat},${origin.lng}',
      'destinations': '${destination.lat},${destination.lng}',
      'mode': 'driving',
      'units': 'metric',
      'key': kGoogleApiKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data['status'] != 'OK') return null;

    final element = data['rows'][0]['elements'][0];
    if (element['status'] != 'OK') return null;

    final meters = element['distance']['value'] as num;
    return meters / 1000.0;
  }
}