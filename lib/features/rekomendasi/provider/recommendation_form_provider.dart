import 'package:flutter/material.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';
import 'package:recommendation_app/features/home/services/home_uv_service.dart';

class RecommendationFormProvider extends ChangeNotifier {
  // Mode Formulir: 0 = Rekomendasi Rutin, 1 = Proteksi Hari Ini
  int _selectedModeIndex = 0;

  SkinTypeModel? _selectedSkinType;
  List<SkinConcernModel> _selectedSkinProblems = [];
  String? _selectedActivity;
  String? _selectedTexture;
  String? _selectedFinish;
  String? _selectedUsageTime;
  bool _isConfirmed = false;

  // State Otomatis Lokasi & UV (bagian dari payload formulir)
  String? _locationName;
  double? _latitude;
  double? _longitude;
  double? _uvIndex;
  String? _uvRiskLevel;

  // State Lokasi Khusus / Kustom (Mode Hari Ini untuk Kota Lain)
  bool _isCustomLocation = false;
  String? _customLocationName;
  double? _customLatitude;
  double? _customLongitude;
  double? _customUvIndex;
  String? _customUvRiskLevel;
  bool _isLoadingCustomLocation = false;

  // Getters Mode Formulir
  int get selectedModeIndex => _selectedModeIndex;
  bool get isRoutineMode => _selectedModeIndex == 0;
  bool get isTodayMode => _selectedModeIndex == 1;

  // Getters Lokasi Kustom
  bool get isCustomLocation => _isCustomLocation;
  String? get customLocationName => _customLocationName;
  double? get customUvIndex => _customUvIndex;
  String? get customUvRiskLevel => _customUvRiskLevel;
  bool get isLoadingCustomLocation => _isLoadingCustomLocation;

  void setSelectedModeIndex(int index) {
    if (_selectedModeIndex != index) {
      _selectedModeIndex = index;
      _isConfirmed = false;
      notifyListeners();
    }
  }

  SkinTypeModel? get selectedSkinType => _selectedSkinType;
  List<SkinConcernModel> get selectedSkinProblems => _selectedSkinProblems;
  List<String> get selectedConcernIds => _selectedSkinProblems
      .where((p) => p.skinConcernId != 'none')
      .map((p) => p.skinConcernId)
      .toList();
  String? get selectedActivity => _selectedActivity;
  String? get selectedTexture => _selectedTexture;
  String? get selectedFinish => _selectedFinish;
  String? get selectedUsageTime => _selectedUsageTime;
  bool get isConfirmed => _isConfirmed;

  // Getters Lokasi & UV
  String? get locationName => _locationName;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  double? get uvIndex => _uvIndex;
  String? get uvRiskLevel => _uvRiskLevel;

  /// Memeriksa apakah waktu saat ini adalah malam hari (jam lokal perangkat >= 18 atau < 6)
  bool get isNight {
    final hour = DateTime.now().hour;
    return hour >= 18 || hour < 6;
  }

  /// Mengatur pilihan tipe kulit
  void setSelectedSkinType(SkinTypeModel? value) {
    _selectedSkinType = value;
    // Reset selected texture if it's not valid for the new skin type
    if (_selectedTexture != null && !dynamicTextures.contains(_selectedTexture)) {
      _selectedTexture = null;
    }
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan masalah-masalah kulit (multi-selection, maksimal 2)
  void toggleSkinProblem(SkinConcernModel value) {
    if (_selectedSkinProblems.contains(value)) {
      _selectedSkinProblems.remove(value);
    } else {
      if (_selectedSkinProblems.length < 2) {
        _selectedSkinProblems.add(value);
      }
    }
    _isConfirmed = false;
    notifyListeners();
  }

  void setSelectedSkinProblems(List<SkinConcernModel> values) {
    if (values.length <= 2) {
      _selectedSkinProblems = values;
      _isConfirmed = false;
      notifyListeners();
    }
  }

  /// Mengatur pilihan aktivitas harian
  void setSelectedActivity(String? value) {
    _selectedActivity = value;
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan preferensi tekstur
  void setSelectedTexture(String? value) {
    _selectedTexture = value;
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan hasil akhir (finish preference)
  void setSelectedFinish(String? value) {
    _selectedFinish = value;
    _isConfirmed = false;
    notifyListeners();
  }

  /// Mengatur pilihan waktu penggunaan skincare
  void setSelectedUsageTime(String? value) {
    _selectedUsageTime = value;
    _isConfirmed = false;
    notifyListeners();
  }

  // Logika alergi ditiadakan di UI karena sudah di-handle otomatis oleh Safety Auto-Filter di backend

  /// Mengubah status konfirmasi data formulir
  void setIsConfirmed(bool value) {
    _isConfirmed = value;
    notifyListeners();
  }

  /// Mengatur lokasi khusus (kota tujuan lain) untuk Mode Hari Ini
  Future<void> setCustomLocation({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    _isCustomLocation = true;
    _customLocationName = name;
    _customLatitude = latitude;
    _customLongitude = longitude;
    _locationName = name;
    _latitude = latitude;
    _longitude = longitude;
    _isConfirmed = false;
    _isLoadingCustomLocation = true;
    notifyListeners();

    try {
      final uvData = await HomeUVService().fetchUVData(latitude, longitude);
      if (uvData != null) {
        _customUvIndex = uvData.uvIndex;
        _uvIndex = uvData.uvIndex;
        _customUvRiskLevel = switch (uvData.riskLevel) {
          UVRiskLevel.low => 'low',
          UVRiskLevel.moderate => 'moderate',
          UVRiskLevel.high => 'high',
          UVRiskLevel.veryHigh => 'very_high',
          UVRiskLevel.extreme => 'extreme',
        };
        _uvRiskLevel = _customUvRiskLevel;
      }
    } catch (e) {
      debugPrint('Error fetching UV for custom location: $e');
    } finally {
      _isLoadingCustomLocation = false;
      notifyListeners();
    }
  }

  /// Mengembalikan pilihan lokasi ke GPS saat ini
  void resetToGpsLocation(HomeLocationProvider locationProvider) {
    _isCustomLocation = false;
    _customLocationName = null;
    _customLatitude = null;
    _customLongitude = null;
    _customUvIndex = null;
    _customUvRiskLevel = null;
    _isLoadingCustomLocation = false;
    updateLocationAndUv(locationProvider);
    _isConfirmed = false;
    notifyListeners();
  }

  /// Menyalin dan memetakan data lokasi dan UV dari HomeLocationProvider ke dalam state formulir
  void updateLocationAndUv(HomeLocationProvider locationProvider) {
    if (_isCustomLocation && _customLatitude != null && _customLongitude != null) {
      _locationName = _customLocationName;
      _latitude = _customLatitude;
      _longitude = _customLongitude;
      _uvIndex = _customUvIndex ?? locationProvider.uvIndex;
      _uvRiskLevel = _customUvRiskLevel ?? 'moderate';
      notifyListeners();
      return;
    }

    final position = locationProvider.currentPosition;
    final address = locationProvider.readableAddress;

    // Set ke null jika statusnya masih berupa placeholder pencarian awal atau gagal
    final isSearching =
        address == 'Mencari lokasi...' || address == 'Gagal memuat lokasi';
    _locationName = isSearching
        ? (isRoutineMode ? 'Indonesia (Rutin Harian)' : null)
        : address;

    // Koordinat fallback default tropis jika di mode rutin dan GPS belum tersedia
    _latitude = position?.latitude ?? (isRoutineMode ? -6.2088 : null);
    _longitude = position?.longitude ?? (isRoutineMode ? 106.8456 : null);
    _uvIndex = locationProvider.uvIndex;

    // Memetakan tingkat risiko UV dari enum model ke string enum database
    _uvRiskLevel = switch (locationProvider.uvRiskLevel) {
      UVRiskLevel.low => 'low',
      UVRiskLevel.moderate => 'moderate',
      UVRiskLevel.high => 'high',
      UVRiskLevel.veryHigh => 'very_high',
      UVRiskLevel.extreme => 'extreme',
    };

    notifyListeners();
  }

  /// Melakukan pembersihan/reset seluruh data pilihan pada formulir ke kondisi semula
  void resetForm() {
    _selectedSkinType = null;
    _selectedSkinProblems = [];
    _selectedActivity = null;
    _selectedTexture = null;
    _selectedFinish = null;
    _selectedUsageTime = null;
    _isConfirmed = false;

    // Bersihkan juga data lokasi & UV
    _locationName = null;
    _latitude = null;
    _longitude = null;
    _uvIndex = null;
    _uvRiskLevel = null;
    _isCustomLocation = false;
    _customLocationName = null;
    _customLatitude = null;
    _customLongitude = null;
    _customUvIndex = null;
    _customUvRiskLevel = null;
    _isLoadingCustomLocation = false;

    notifyListeners();
  }

  /// Mendapatkan list tekstur secara dinamis berdasarkan jenis kulit yang dipilih
  List<String> get dynamicTextures {
    if (_selectedSkinType == null) {
      return [];
    }
    final code = _selectedSkinType!.skinTypeCode.toLowerCase();
    if (code == 'oily' || code == 'combination') {
      return ['Gel', 'Watery', 'Serum', 'Stick'];
    } else if (code == 'dry') {
      return ['Cream', 'Lotion', 'Milk', 'Stick'];
    } else if (code == 'sensitive') {
      return ['Gel', 'Cream', 'Lotion', 'Milk'];
    } else {
      // normal
      return ['Gel', 'Cream', 'Lotion', 'Serum'];
    }
  }

  /// Mendapatkan penjelasan tekstur yang sedang dipilih untuk ditampilkan sebagai banner di UI
  String? get selectedTextureDescription {
    if (_selectedTexture == null) return null;
    return switch (_selectedTexture) {
      'Gel' =>
        'Tekstur gel sangat ringan, berbahan dasar air, cepat meresap tanpa meninggalkan rasa lengket. Sangat cocok untuk kulit berminyak atau berjerawat karena meminimalisir penyumbatan pori-pori.',
      'Watery' =>
        'Tekstur watery cair seperti air, memberikan sensasi dingin dan hidrasi instan yang menyegarkan saat diaplikasikan. Ringan dan nyaman digunakan sehari-hari.',
      'Serum' =>
        'Tekstur serum cenderung cair-kental, diperkaya dengan konsentrasi bahan aktif tinggi untuk merawat kulit sekaligus melindunginya dari sinar UV.',
      'Cream' =>
        'Tekstur cream lebih pekat, kaya akan pelembap, dan sangat baik untuk menjaga hidrasi kulit kering. Memberikan perlindungan ekstra agar kulit tidak mudah terkelupas.',
      'Lotion' =>
        'Tekstur lotion memiliki keenceran sedang, mudah diratakan, dan memberikan kelembapan seimbang. Nyaman untuk tipe kulit kombinasi maupun normal.',
      'Milk' =>
        'Tekstur milk berwujud emulsi cair yang selembut susu, memberikan kelembapan sedang tanpa terasa berat, cocok untuk kulit sensitif atau kering.',
      'Stick' =>
        'Tekstur stick padat, praktis digunakan langsung pada wajah, dan ideal untuk re-apply di luar ruangan tanpa menyentuh wajah dengan tangan.',
      'Spray' || 'Mist' =>
        'Tekstur spray/mist berupa partikel air halus yang disemprotkan ke wajah, sangat praktis untuk re-apply sunscreen di atas makeup.',
      _ => null,
    };
  }

  /// Mendapatkan penjelasan hasil akhir yang sedang dipilih untuk ditampilkan sebagai banner di UI
  String? get selectedFinishDescription {
    if (_selectedFinish == null) return null;
    return switch (_selectedFinish) {
      'Matte' =>
        'Hasil akhir bebas kilap yang mengontrol minyak berlebih, membuat wajah tampak segar sepanjang hari. Sangat cocok untuk kulit berminyak.',
      'Dewy' || 'Dewy / Glowy' =>
        'Hasil akhir berkilau sehat yang memberikan efek kulit lembap, kenyal, dan tampak bercahaya alami. Sangat cocok untuk kulit kering.',
      'Natural' || 'Natural / Satin' =>
        'Hasil akhir seimbang yang meniru kilau alami kulit sehat, tidak terlalu mengkilap dan tidak terlalu kering. Sangat ideal untuk kulit normal atau kombinasi.',
      'Tone-Up' =>
        'Hasil akhir mencerahkan seketika (tone-up) secara natural untuk membantu menyamarkan warna kulit yang kusam dan memberikan efek segar.',
      _ => null,
    };
  }

  /// Memetakan aktivitas ke nilai database
  String get mappedActivity => switch (_selectedActivity) {
    'Di Dalam Ruangan' || 'Dalam Ruangan (Indoor)' => 'indoor',
    'Di Luar Ruangan' || 'Luar Ruangan Ringan' => 'outdoor_light',
    'Luar Ruangan Intens' => 'outdoor_intense',
    'Olahraga' || 'Olahraga / Sport' => 'sport',
    'Berenang' || 'Berenang / Aktivitas Air' => 'swim',
    _ => 'indoor',
  };

  /// Memetakan tekstur ke nilai database (Mode Hari Ini tidak menggunakan preferensi tekstur)
  String? get mappedTexture {
    if (isTodayMode) return null;
    return switch (_selectedTexture) {
      'Gel' => 'gel',
      'Cream' => 'cream',
      'Lotion' => 'lotion',
      'Serum' => 'serum',
      'Milk' => 'milk',
      'Watery' => 'watery',
      'Stick' => 'stick',
      'Spray' => 'spray',
      'Mist' => 'mist',
      _ => null,
    };
  }

  /// Memetakan hasil akhir ke format enum database
  String? get mappedFinish => switch (_selectedFinish) {
    'Matte' => 'matte',
    'Dewy' || 'Dewy / Glowy' => 'dewy',
    'Natural' || 'Natural / Satin' => 'natural',
    'Tone-Up' => 'tone_up',
    _ => null,
  };

  /// Memetakan label waktu penggunaan ke format enum database Supabase
  String get mappedUsageTime {
    if (isRoutineMode) return 'realtime';
    if (!isNight) return 'realtime';
    return switch (_selectedUsageTime) {
      'Pagi Hari' => 'morning',
      'Siang Hari' => 'afternoon',
      'Malam Hari' => 'evening',
      _ => 'morning',
    };
  }

  /// Memetakan label riwayat alergi ke format enum database Supabase (selalu 'none' karena di-handle otomatis di backend)
  String get mappedAllergyStatus => 'none';

  bool get isFormValid {
    // Mode Rekomendasi Produk: Jenis Kulit, Aktivitas, Tekstur, Finish
    if (isRoutineMode) {
      return _selectedSkinType != null &&
          _selectedActivity != null &&
          _selectedTexture != null &&
          _selectedFinish != null;
    }

    // Mode Hari Ini: Aktivitas, Jenis Kulit, Finish (Tekstur tidak digunakan)
    final todayValid = _selectedActivity != null &&
        _selectedSkinType != null &&
        _selectedFinish != null;

    if (!todayValid) return false;

    // Mode Hari Ini pada malam hari: memerlukan pilihan waktu penggunaan esok hari
    if (isNight && _selectedUsageTime == null) {
      return false;
    }

    return true;
  }
}
