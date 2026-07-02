import 'package:flutter/material.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_type_model.dart';
import 'package:recommendation_app/features/rekomendasi/models/skin_concern_model.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/models/uv_risk_level.dart';

class RecommendationFormProvider extends ChangeNotifier {
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

  /// Menyalin dan memetakan data lokasi dan UV dari HomeLocationProvider ke dalam state formulir
  void updateLocationAndUv(HomeLocationProvider locationProvider) {
    final position = locationProvider.currentPosition;
    final address = locationProvider.readableAddress;

    // Set ke null jika statusnya masih berupa placeholder pencarian awal atau gagal
    final isSearching =
        address == 'Mencari lokasi...' || address == 'Gagal memuat lokasi';
    _locationName = isSearching ? null : address;

    _latitude = position?.latitude;
    _longitude = position?.longitude;
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
        'Hasil akhir bebas kilap yang mengontrol minyak berlebih, membuat wajah tampak bebas minyak sepanjang hari. Sangat cocok untuk kulit berminyak.',
      'Dewy / Glowy' =>
        'Hasil akhir berkilau sehat (dewy/glowy) yang memberikan efek kulit lembap, kenyal, dan tampak basah alami. Sangat cocok untuk kulit kering.',
      'Natural / Satin' =>
        'Hasil akhir seimbang yang meniru kilau alami kulit sehat, tidak terlalu mengkilap dan tidak terlalu kering. Sangat ideal untuk kulit normal atau kombinasi.',
      'Tone-Up' =>
        'Hasil akhir mencerahkan seketika (tone-up) secara natural untuk membantu menyamarkan warna kulit yang kusam dan memberikan efek segar.',
      _ => null,
    };
  }

  /// Memetakan aktivitas ke nilai database
  String get mappedActivity => switch (_selectedActivity) {
    'Dalam Ruangan (Indoor)' => 'indoor',
    'Luar Ruangan Ringan' => 'outdoor_light',
    'Luar Ruangan Intens' => 'outdoor_intense',
    'Olahraga / Sport' => 'sport',
    'Berenang / Aktivitas Air' => 'swim',
    _ => 'indoor',
  };

  /// Memetakan tekstur ke nilai database
  String? get mappedTexture => switch (_selectedTexture) {
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

  /// Memetakan hasil akhir ke format enum database
  String? get mappedFinish => switch (_selectedFinish) {
    'Matte' => 'matte',
    'Dewy / Glowy' => 'dewy',
    'Natural / Satin' => 'natural',
    'Tone-Up' => 'tone_up',
    _ => null,
  };

  /// Memetakan label waktu penggunaan ke format enum database Supabase
  String get mappedUsageTime {
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
    final requiresUsageTime = isNight;
    final hasInvalidUsageTime = requiresUsageTime && _selectedUsageTime == null;

    return _selectedSkinType != null &&
        _selectedActivity != null &&
        _selectedTexture != null &&
        _selectedFinish != null &&
        !hasInvalidUsageTime;
  }
}
