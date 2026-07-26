import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/api_keys.dart';
import '../core/api_client.dart';

class OlaRoutingService {
  /// Fetches the route from Ola Maps Routing API and returns a list of coordinates
  static Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    try {
      final String url = 'https://api.olamaps.io/routing/v1/directions';
      final Uri uri = Uri.parse(url).replace(queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'api_key': ApiKeys.olaMapsKey,
      });

      final response = await ApiClient.post(
        uri,
        headers: {
          'X-Request-Id': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'SUCCESS' && data['routes'] != null && data['routes'].isNotEmpty) {
          final pointsString = data['routes'][0]['overview_polyline'];
          if (pointsString != null) {
             return _decodePolyline(pointsString);
          }
        }
      }
    } catch (e) {
      print('OlaRoutingService error: $e');
    }
    
    // Fallback to straight line if API fails
    return [origin, destination];
  }

  /// Decodes the encoded polyline string from the Ola Maps response
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
