import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CityModel {
  final String name;
  final String province;
  final double latitude;
  final double longitude;

  const CityModel({
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
  });

  String get displayName => province.isNotEmpty ? '$name, $province' : name;
}

class CitySearchService {
  /// Daftar kota populer di Indonesia untuk akses cepat instan tanpa delay jaringan
  static const List<CityModel> popularCities = [
    CityModel(
      name: 'Jakarta',
      province: 'DKI Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    CityModel(
      name: 'Bandung',
      province: 'Jawa Barat',
      latitude: -6.9175,
      longitude: 107.6191,
    ),
    CityModel(
      name: 'Yogyakarta',
      province: 'DI Yogyakarta',
      latitude: -7.7956,
      longitude: 110.3695,
    ),
    CityModel(
      name: 'Surabaya',
      province: 'Jawa Timur',
      latitude: -7.2575,
      longitude: 112.7521,
    ),
    CityModel(
      name: 'Denpasar',
      province: 'Bali',
      latitude: -8.6500,
      longitude: 115.2167,
    ),
    CityModel(
      name: 'Semarang',
      province: 'Jawa Tengah',
      latitude: -6.9667,
      longitude: 110.4167,
    ),
    CityModel(
      name: 'Medan',
      province: 'Sumatera Utara',
      latitude: 3.5952,
      longitude: 98.6722,
    ),
    CityModel(
      name: 'Makassar',
      province: 'Sulawesi Selatan',
      latitude: -5.1477,
      longitude: 119.4327,
    ),
    CityModel(
      name: 'Labuan Bajo',
      province: 'Nusa Tenggara Timur',
      latitude: -8.4964,
      longitude: 119.8877,
    ),
    CityModel(
      name: 'Malang',
      province: 'Jawa Timur',
      latitude: -7.9797,
      longitude: 112.6304,
    ),
    CityModel(
      name: 'Surakarta (Solo)',
      province: 'Jawa Tengah',
      latitude: -7.5755,
      longitude: 110.8243,
    ),
    CityModel(
      name: 'Bogor',
      province: 'Jawa Barat',
      latitude: -6.5971,
      longitude: 106.8060,
    ),
  ];

  /// Mencari kota menggunakan filter lokal dan Open-Meteo Geocoding API
  static Future<List<CityModel>> search(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return popularCities;
    }

    // 1. Filter dari daftar populer lokal terlebih dahulu
    final localMatches = popularCities.where((c) {
      return c.name.toLowerCase().contains(cleanQuery) ||
          c.province.toLowerCase().contains(cleanQuery);
    }).toList();

    // Jika query pendek (< 3 huruf), gunakan hasil lokal untuk respons instan
    if (cleanQuery.length < 3) {
      return localMatches;
    }

    // 2. Jika query >= 3 huruf, panggil Open-Meteo Geocoding API
    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search'
        '?name=${Uri.encodeComponent(cleanQuery)}'
        '&count=8'
        '&language=id'
        '&format=json',
      );

      final res = await http.get(url).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final apiList = <CityModel>[];
          for (final item in results) {
            final name = item['name'] as String? ?? '';
            final admin1 = item['admin1'] as String? ?? '';
            final country = item['country'] as String? ?? '';
            final lat = (item['latitude'] as num?)?.toDouble() ?? 0.0;
            final lon = (item['longitude'] as num?)?.toDouble() ?? 0.0;

            final provinceName = admin1.isNotEmpty
                ? admin1
                : (country.isNotEmpty ? country : '');

            // Cegah duplikasi dengan hasil lokal yang sudah ada
            final isDuplicate = localMatches.any((m) =>
                m.name.toLowerCase() == name.toLowerCase() &&
                (m.latitude - lat).abs() < 0.1);

            if (!isDuplicate && name.isNotEmpty) {
              apiList.add(CityModel(
                name: name,
                province: provinceName,
                latitude: lat,
                longitude: lon,
              ));
            }
          }

          return [...localMatches, ...apiList];
        }
      }
    } catch (e) {
      debugPrint('Geocoding search error: $e');
    }

    return localMatches;
  }
}
