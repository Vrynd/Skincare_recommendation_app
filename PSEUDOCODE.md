# Revisi Pseudocode Supabase Edge Function: `get_sunscreen_recommendation`

Dokumen ini berisi revisi pseudocode untuk fungsi rekomendasi sunscreen berbasis *Rule-Based Scoring*. Revisi ini menyesuaikan rancangan sebelumnya dengan skema tabel prototipe terbaru, yaitu tanpa fitur evaluasi produk, tanpa `session_type`, tanpa `evaluated_product_id`, dan tanpa `evaluation_note`.

Revisi utama yang diterapkan:

1. Menambahkan `usage_time_preference` ke input.
2. Menambahkan `location_name` ke input.
3. Mengubah `resolve_uv_index(latitude, longitude)` menjadi `resolve_uv_index(latitude, longitude, usage_time_preference)`.
4. Menambahkan validasi `usage_time_preference` saat malam hari.
5. Menghapus logika `none_concern_id` karena masalah kulit wajib dipilih.
6. Menghapus kode `all` dari *scoring* jenis kulit.
7. Menyamakan kode jenis kulit dan masalah kulit dengan database.
8. Memperbaiki helper query agar parameter tidak sama dengan nama kolom.
9. Menambahkan fungsi `format_response()`.
10. Mengubah `save_recommendation()` agar mengembalikan `session_id` dan `recommendation_code`.
11. Menambahkan perbaikan opsional: `timezone=auto`, validasi koordinat, validasi duplikasi, `get_uv_risk_level()`, dan penyimpanan menggunakan transaksi database.

---

## 1. Overview

```text
Nama Function  : get_sunscreen_recommendation
Method         : POST
Input          : RecommendationRequest
Output         : RecommendationResponse
Dipanggil oleh : Flutter Mobile App
Database       : Supabase PostgreSQL
Runtime        : Supabase Edge Function
```

---

## 2. Standar Kode Data Master

Agar pseudocode konsisten dengan database dan aplikasi, kode yang digunakan dalam sistem sebaiknya memakai format internal berbahasa Inggris. Tampilan pada aplikasi tetap dapat menggunakan bahasa Indonesia.

### 2.1 Standar `skin_type_code`

| Tampilan UI | `skin_type_code` |
|---|---|
| Normal | `normal` |
| Berminyak | `oily` |
| Kering | `dry` |
| Kombinasi | `combination` |
| Sensitif | `sensitive` |

### 2.2 Standar `skin_concern_code`

| Tampilan UI | `skin_concern_code` |
|---|---|
| Jerawat | `acne` |
| Hiperpigmentasi | `hyperpigmentation` |
| Sensitif/Iritasi | `sensitive_irritation` |
| Penuaan Dini | `aging` |

### 2.3 Standar `ingredient_code`

Contoh kode bahan yang digunakan sistem:

| Nama Bahan | `ingredient_code` | Kategori |
|---|---|---|
| Niacinamide | `niacinamide` | `active` |
| Vitamin C | `vitamin_c` | `active` |
| Peptide | `peptide` | `active` |
| Tocopherol | `tocopherol` | `active` |
| Zinc Oxide | `zinc_oxide` | `uv_filter` |
| Titanium Dioxide | `titanium_dioxide` | `uv_filter` |
| Octocrylene | `octocrylene` | `uv_filter` / `avoid` |
| Oxybenzone | `oxybenzone` | `avoid` |
| Fragrance | `fragrance` | `avoid` |
| Alcohol Denat. | `alcohol_denat` | `avoid` |
| Essential Oil | `essential_oil` | `avoid` |

---

## 3. Struktur Input dan Output

### 3.1 Input

```text
RecommendationRequest {
  user_id                : UUID
  skin_type_id           : UUID
  skin_concern_ids       : UUID[]
  activity               : activity_type_enum
  texture_preference     : texture_type_enum | null
  allergy_status         : allergy_status_type
  avoided_ingredient_ids : UUID[]
  usage_time_preference  : usage_time_preference_enum | null
  location_name          : String | null
  latitude               : Float
  longitude              : Float
}
```

Catatan:

- `usage_time_preference` boleh kosong jika rekomendasi dilakukan pada pukul 06.00–17.59 karena sistem memakai UV *real-time*.
- `usage_time_preference` wajib diisi jika rekomendasi dilakukan pada pukul 18.00–05.59 karena sistem perlu mengambil prakiraan UV untuk besok pagi, siang, atau sore.
- Nilai `usage_time_preference` yang boleh dipilih pengguna saat malam hari adalah `morning`, `afternoon`, atau `evening`.
- Nilai `realtime` dihasilkan oleh sistem, bukan dipilih manual oleh pengguna.

### 3.2 Output

```text
RecommendationResponse {
  recommendation_session_id : UUID
  recommendation_code       : String
  uv_data {
    uv_index              : Float
    uv_risk_level         : String
    spf_minimum           : Integer
    pa_minimum            : String
    usage_time_preference : String
    is_forecast           : Boolean
  }
  results : RecommendationResult[]
}

RecommendationResult {
  rank_position             : Integer
  product_id                : UUID
  product_code              : String
  brand_name                : String
  product_name              : String
  bpom_number               : String
  spf                       : Integer
  pa_grade                  : String
  sunscreen_type            : String
  texture                   : String
  finish                    : String
  match_score               : Float
  recommendation_category   : String
}
```

---

## 4. Fungsi Utama

```text
FUNCTION get_sunscreen_recommendation(request):

  // ─────────────────────────────────────
  // TAHAP 1: VALIDASI INPUT
  // ─────────────────────────────────────
  validation = validate_input(request)
  IF validation.is_error THEN
    RETURN error(validation.message)
  END IF

  // ─────────────────────────────────────
  // TAHAP 2: TENTUKAN UV INDEX
  // ─────────────────────────────────────
  uv_result = resolve_uv_index(
    request.latitude,
    request.longitude,
    request.usage_time_preference
  )

  IF uv_result.is_error THEN
    RETURN error("Gagal mengambil data indeks UV")
  END IF

  spf_minimum = get_spf_minimum(uv_result.uv_index)
  pa_minimum  = get_pa_minimum(uv_result.uv_index)

  // ─────────────────────────────────────
  // TAHAP 3: AMBIL SEMUA PRODUK AKTIF
  // ─────────────────────────────────────
  products = fetch_active_products()

  IF products IS EMPTY THEN
    RETURN error("Tidak ada produk tersedia")
  END IF

  // ─────────────────────────────────────
  // TAHAP 4: HARD FILTER
  // ─────────────────────────────────────
  filtered = apply_hard_filter(
    products,
    request.allergy_status,
    request.avoided_ingredient_ids,
    spf_minimum,
    pa_minimum
  )

  IF filtered IS EMPTY THEN
    RETURN error(
      "Tidak ada produk yang memenuhi kriteria perlindungan UV dan riwayat alergi saat ini"
    )
  END IF

  // ─────────────────────────────────────
  // TAHAP 5: SCORING
  // ─────────────────────────────────────
  scored = calculate_scores(
    filtered,
    request.skin_type_id,
    request.skin_concern_ids,
    request.activity,
    request.texture_preference
  )

  // ─────────────────────────────────────
  // TAHAP 6: PENALTY
  // ─────────────────────────────────────
  penalized = apply_penalty(
    scored,
    request.skin_type_id,
    request.activity
  )

  // ─────────────────────────────────────
  // TAHAP 7: RANKING & KATEGORISASI
  // ─────────────────────────────────────
  ranked = rank_and_categorize(penalized)

  IF ranked IS EMPTY THEN
    RETURN error("Tidak ada produk yang cukup sesuai dengan kondisi pengguna")
  END IF

  // ─────────────────────────────────────
  // TAHAP 8: SIMPAN KE DATABASE
  // ─────────────────────────────────────
  session_data = save_recommendation(
    request,
    uv_result,
    spf_minimum,
    pa_minimum,
    ranked
  )

  // ─────────────────────────────────────
  // TAHAP 9: RETURN RESPONSE
  // ─────────────────────────────────────
  RETURN format_response(
    session_data,
    uv_result,
    spf_minimum,
    pa_minimum,
    ranked
  )

END FUNCTION
```

---

## 5. Tahap 1 — Validasi Input

```text
FUNCTION validate_input(request):

  // ─────────────────────────────────────
  // Cek field wajib
  // ─────────────────────────────────────
  IF request.user_id IS EMPTY THEN
    RETURN error("user_id wajib diisi")
  END IF

  IF NOT is_valid_uuid(request.user_id) THEN
    RETURN error("Format user_id tidak valid")
  END IF

  IF request.skin_type_id IS EMPTY THEN
    RETURN error("Jenis kulit wajib dipilih")
  END IF

  IF NOT is_valid_uuid(request.skin_type_id) THEN
    RETURN error("Format skin_type_id tidak valid")
  END IF

  IF request.skin_concern_ids IS EMPTY THEN
    RETURN error("Masalah kulit wajib dipilih")
  END IF

  IF LEN(request.skin_concern_ids) > 4 THEN
    RETURN error("Maksimal masalah kulit yang dipilih adalah 4 kategori")
  END IF

  IF HAS_DUPLICATE(request.skin_concern_ids) THEN
    RETURN error("Masalah kulit tidak boleh duplikat")
  END IF

  FOR EACH concern_id IN request.skin_concern_ids:
    IF NOT is_valid_uuid(concern_id) THEN
      RETURN error("Format skin_concern_id tidak valid")
    END IF
  END FOR

  IF request.activity IS EMPTY THEN
    RETURN error("Aktivitas harian wajib dipilih")
  END IF

  IF request.activity NOT IN activity_type_enum THEN
    RETURN error("Nilai aktivitas tidak valid")
  END IF

  IF request.texture_preference IS NOT NULL AND
     request.texture_preference NOT IN texture_type_enum THEN
    RETURN error("Nilai preferensi tekstur tidak valid")
  END IF

  IF request.allergy_status IS EMPTY THEN
    RETURN error("Status alergi wajib diisi")
  END IF

  IF request.allergy_status NOT IN allergy_status_type THEN
    RETURN error("Nilai status alergi tidak valid")
  END IF

  IF request.allergy_status == "known_ingredient" AND
     request.avoided_ingredient_ids IS EMPTY THEN
    RETURN error(
      "Bahan yang dihindari wajib dipilih jika status alergi diketahui"
    )
  END IF

  IF request.avoided_ingredient_ids IS NOT EMPTY THEN
    IF HAS_DUPLICATE(request.avoided_ingredient_ids) THEN
      RETURN error("Bahan yang dihindari tidak boleh duplikat")
    END IF

    FOR EACH ingredient_id IN request.avoided_ingredient_ids:
      IF NOT is_valid_uuid(ingredient_id) THEN
        RETURN error("Format avoided_ingredient_id tidak valid")
      END IF
    END FOR
  END IF

  IF request.latitude IS EMPTY OR request.longitude IS EMPTY THEN
    RETURN error("Lokasi tidak dapat diakses")
  END IF

  IF request.latitude < -90 OR request.latitude > 90 THEN
    RETURN error("Latitude tidak valid")
  END IF

  IF request.longitude < -180 OR request.longitude > 180 THEN
    RETURN error("Longitude tidak valid")
  END IF

  // ─────────────────────────────────────
  // Validasi waktu penggunaan sunscreen
  // ─────────────────────────────────────
  current_hour = GET_CURRENT_LOCAL_HOUR(
    request.latitude,
    request.longitude
  )

  IF current_hour >= 18 OR current_hour < 6 THEN
    IF request.usage_time_preference IS EMPTY THEN
      RETURN error("Waktu penggunaan sunscreen wajib dipilih")
    END IF

    IF request.usage_time_preference NOT IN ["morning", "afternoon", "evening"] THEN
      RETURN error("Waktu penggunaan sunscreen tidak valid")
    END IF
  END IF

  IF current_hour >= 6 AND current_hour < 18 THEN
    IF request.usage_time_preference IS NOT NULL AND
       request.usage_time_preference NOT IN ["realtime", "morning", "afternoon", "evening"] THEN
      RETURN error("Waktu penggunaan sunscreen tidak valid")
    END IF
  END IF

  RETURN success

END FUNCTION
```

---

## 6. Tahap 2 — Tentukan UV Index

```text
FUNCTION resolve_uv_index(latitude, longitude, usage_time_preference):

  current_hour = GET_CURRENT_LOCAL_HOUR(latitude, longitude)

  // ─────────────────────────────────────
  // SIANG HARI: Ambil UV Index real-time
  // ─────────────────────────────────────
  IF current_hour >= 6 AND current_hour < 18 THEN

    uv_index = fetch_realtime_uv(latitude, longitude)

    RETURN {
      uv_index              : uv_index,
      usage_time_preference : "realtime",
      is_forecast           : false
    }

  // ─────────────────────────────────────
  // MALAM HARI: Ambil prakiraan UV besok
  // ─────────────────────────────────────
  ELSE

    hour_range = get_hour_range(usage_time_preference)

    IF hour_range IS EMPTY THEN
      RETURN error("Waktu penggunaan sunscreen tidak valid")
    END IF

    uv_index = fetch_forecast_uv(
      latitude,
      longitude,
      hour_range
    )

    RETURN {
      uv_index              : uv_index,
      usage_time_preference : usage_time_preference,
      is_forecast           : true
    }

  END IF

END FUNCTION
```

### 6.1 Ambil UV Real-Time

```text
FUNCTION fetch_realtime_uv(latitude, longitude):

  response = HTTP_GET(
    "https://api.open-meteo.com/v1/forecast",
    {
      latitude      : latitude,
      longitude     : longitude,
      hourly        : "uv_index",
      forecast_days : 1,
      timezone      : "auto"
    }
  )

  IF response IS ERROR THEN
    RETURN error("Gagal mengambil data UV real-time")
  END IF

  current_hour = GET_CURRENT_LOCAL_HOUR(latitude, longitude)

  RETURN response.hourly.uv_index[current_hour]

END FUNCTION
```

### 6.2 Ambil UV Forecast

```text
FUNCTION fetch_forecast_uv(latitude, longitude, hour_range):

  response = HTTP_GET(
    "https://api.open-meteo.com/v1/forecast",
    {
      latitude      : latitude,
      longitude     : longitude,
      hourly        : "uv_index",
      forecast_days : 2,
      timezone      : "auto"
    }
  )

  IF response IS ERROR THEN
    RETURN error("Gagal mengambil data prakiraan UV")
  END IF

  // Ambil data UV besok.
  // Jika data hourly dimulai dari jam 00.00 hari ini,
  // maka data besok berada pada indeks 24 sampai 47.
  tomorrow_uv = response.hourly.uv_index[24..47]

  uv_values = []

  FOR EACH hour IN hour_range:
    uv_values.APPEND(tomorrow_uv[hour])
  END FOR

  RETURN MAX(uv_values)

END FUNCTION
```

### 6.3 Rentang Waktu Penggunaan

```text
FUNCTION get_hour_range(usage_time_preference):

  IF usage_time_preference == "morning" THEN
    // 06.00–10.00
    RETURN [6, 7, 8, 9]

  ELSE IF usage_time_preference == "afternoon" THEN
    // 10.00–14.00
    RETURN [10, 11, 12, 13]

  ELSE IF usage_time_preference == "evening" THEN
    // 14.00–18.00
    RETURN [14, 15, 16, 17]

  ELSE
    RETURN []
  END IF

END FUNCTION
```

### 6.4 Tentukan SPF Minimum

```text
FUNCTION get_spf_minimum(uv_index):

  IF uv_index <= 2 THEN
    RETURN 15
  ELSE IF uv_index <= 5 THEN
    RETURN 30
  ELSE IF uv_index <= 7 THEN
    RETURN 50
  ELSE
    RETURN 50
  END IF

END FUNCTION
```

Catatan: Untuk UV Index 8 ke atas, sistem tetap menggunakan nilai numerik `50` karena kolom `spf` bertipe integer. Produk SPF50+ dapat disimpan sebagai `spf = 50` dan ditandai dari nama produk atau catatan produk jika diperlukan.

### 6.5 Tentukan PA Minimum

```text
FUNCTION get_pa_minimum(uv_index):

  IF uv_index <= 2 THEN
    RETURN "PA+"
  ELSE IF uv_index <= 5 THEN
    RETURN "PA++"
  ELSE IF uv_index <= 10 THEN
    RETURN "PA+++"
  ELSE
    RETURN "PA++++"
  END IF

END FUNCTION
```

### 6.6 Kategori Risiko UV

```text
FUNCTION get_uv_risk_level(uv_index):

  IF uv_index <= 2 THEN
    RETURN "low"
  ELSE IF uv_index <= 5 THEN
    RETURN "moderate"
  ELSE IF uv_index <= 7 THEN
    RETURN "high"
  ELSE IF uv_index <= 10 THEN
    RETURN "very_high"
  ELSE
    RETURN "extreme"
  END IF

END FUNCTION
```

### 6.7 Perbandingan PA Grade

```text
FUNCTION compare_pa_grade(product_pa, minimum_pa):

  pa_scale = {
    "PA+"    : 1,
    "PA++"   : 2,
    "PA+++"  : 3,
    "PA++++" : 4
  }

  product_value = pa_scale[product_pa] OR 0
  minimum_value = pa_scale[minimum_pa] OR 0

  RETURN product_value >= minimum_value

END FUNCTION
```

---

## 7. Tahap 3 — Ambil Produk Aktif

Untuk prototipe 30 produk, query gabungan masih dapat digunakan. Jika data bertambah besar, proses pengambilan relasi dapat dipisahkan menjadi beberapa query agar lebih efisien.

```text
FUNCTION fetch_active_products():

  products = DB_QUERY(
    SELECT
      p.*,
      ARRAY_AGG(DISTINCT pst.skin_type_id)
        FILTER (WHERE pst.skin_type_id IS NOT NULL)
        AS skin_type_ids,
      ARRAY_AGG(DISTINCT psc.skin_concern_id)
        FILTER (WHERE psc.skin_concern_id IS NOT NULL)
        AS skin_concern_ids,
      ARRAY_AGG(DISTINCT pi.ingredient_id)
        FILTER (WHERE pi.ingredient_id IS NOT NULL)
        AS ingredient_ids
    FROM products p
    LEFT JOIN product_skin_types pst
      ON p.product_id = pst.product_id
    LEFT JOIN product_skin_concerns psc
      ON p.product_id = psc.product_id
    LEFT JOIN product_ingredients pi
      ON p.product_id = pi.product_id
    WHERE p.is_active = true
    GROUP BY p.product_id
  )

  RETURN products

END FUNCTION
```

---

## 8. Tahap 4 — Hard Filter

```text
FUNCTION apply_hard_filter(
  products,
  allergy_status,
  avoided_ingredient_ids,
  spf_minimum,
  pa_minimum
):

  filtered = []

  FOR EACH product IN products:

    // ─────────────────────────────────────
    // FILTER 1: RIWAYAT ALERGI
    // ─────────────────────────────────────
    pass_allergy = true

    IF allergy_status == "none" THEN
      pass_allergy = true

    ELSE IF allergy_status == "unknown_ingredient" THEN

      // Pendekatan kehati-hatian untuk pengguna yang pernah tidak cocok
      // tetapi tidak mengetahui bahan penyebabnya.
      auto_avoid = GET_IDS_BY_CODES([
        "oxybenzone",
        "fragrance"
      ])

      FOR EACH avoid_id IN auto_avoid:
        IF avoid_id IN product.ingredient_ids THEN
          pass_allergy = false
          BREAK
        END IF
      END FOR

    ELSE IF allergy_status == "known_ingredient" THEN

      FOR EACH avoid_id IN avoided_ingredient_ids:
        IF avoid_id IN product.ingredient_ids THEN
          pass_allergy = false
          BREAK
        END IF
      END FOR

    END IF

    IF NOT pass_allergy THEN
      CONTINUE
    END IF

    // ─────────────────────────────────────
    // FILTER 2: SPF DAN PA MINIMUM
    // ─────────────────────────────────────
    IF product.spf < spf_minimum THEN
      CONTINUE
    END IF

    IF NOT compare_pa_grade(product.pa_grade, pa_minimum) THEN
      CONTINUE
    END IF

    filtered.APPEND(product)

  END FOR

  RETURN filtered

END FUNCTION
```

---

## 9. Tahap 5 — Scoring

```text
FUNCTION calculate_scores(
  products,
  skin_type_id,
  skin_concern_ids,
  activity,
  texture_preference
):

  scored = []

  FOR EACH product IN products:

    score_a = score_skin_type(
      product.skin_type_ids,
      skin_type_id
    )

    score_b = score_skin_concern(
      product,
      skin_concern_ids
    )

    score_c = score_activity(
      product,
      activity
    )

    score_d = score_texture(
      product.texture,
      texture_preference
    )

    total = score_a + score_b + score_c + score_d

    scored.APPEND({
      product : product,
      score_a : score_a,
      score_b : score_b,
      score_c : score_c,
      score_d : score_d,
      total   : total
    })

  END FOR

  RETURN scored

END FUNCTION
```

### 9.1 Scoring A — Jenis Kulit (0–30)

```text
FUNCTION score_skin_type(product_skin_type_ids, user_skin_type_id):

  similarity = {
    "oily": {
      "oily"        : 30,
      "combination" : 20,
      "normal"      : 10,
      "dry"         : 5,
      "sensitive"   : 0
    },
    "dry": {
      "dry"         : 30,
      "normal"      : 20,
      "combination" : 10,
      "oily"        : 5,
      "sensitive"   : 5
    },
    "normal": {
      "normal"      : 30,
      "combination" : 15,
      "dry"         : 10,
      "oily"        : 10,
      "sensitive"   : 5
    },
    "combination": {
      "combination" : 30,
      "oily"        : 20,
      "normal"      : 10,
      "dry"         : 5,
      "sensitive"   : 0
    },
    "sensitive": {
      "sensitive"   : 30,
      "normal"      : 10,
      "dry"         : 10,
      "oily"        : 0,
      "combination" : 0
    }
  }

  user_skin_code = get_skin_type_code(user_skin_type_id)
  max_score = 0

  FOR EACH product_skin_type_id IN product_skin_type_ids:

    product_skin_code = get_skin_type_code(product_skin_type_id)

    IF user_skin_code IN similarity AND
       product_skin_code IN similarity[user_skin_code] THEN
      score = similarity[user_skin_code][product_skin_code]
    ELSE
      score = 0
    END IF

    IF score > max_score THEN
      max_score = score
    END IF

  END FOR

  RETURN max_score

END FUNCTION
```

Catatan: Kode `all` dihapus. Jika produk cocok untuk semua jenis kulit, produk tersebut disimpan pada tabel `product_skin_types` dengan lima relasi: `normal`, `oily`, `dry`, `combination`, dan `sensitive`.

### 9.2 Scoring B — Masalah Kulit (0–30)

```text
FUNCTION score_skin_concern(product, skin_concern_ids):

  concern_scores = []

  FOR EACH concern_id IN skin_concern_ids:

    concern_code = get_concern_code(concern_id)

    IF concern_code == "acne" THEN
      score = score_acne(product)

    ELSE IF concern_code == "hyperpigmentation" THEN
      score = score_hyperpigmentation(product)

    ELSE IF concern_code == "sensitive_irritation" THEN
      score = score_sensitive_irritation(product)

    ELSE IF concern_code == "aging" THEN
      score = score_aging(product)

    ELSE
      score = 0
    END IF

    concern_scores.APPEND(score)

  END FOR

  average = SUM(concern_scores) / LEN(concern_scores)
  RETURN ROUND_UP(average)

END FUNCTION
```

### 9.3 Scoring Jerawat

```text
FUNCTION score_acne(product):

  IF product.is_non_comedogenic AND product.is_oil_free THEN
    RETURN 30
  ELSE IF product.is_non_comedogenic THEN
    RETURN 20
  ELSE IF product.is_oil_free THEN
    RETURN 15
  ELSE
    RETURN 0
  END IF

END FUNCTION
```

### 9.4 Scoring Hiperpigmentasi

```text
FUNCTION score_hyperpigmentation(product):

  has_brightening = has_ingredient(
    product.ingredient_ids,
    ["niacinamide", "vitamin_c"]
  )

  pa = pa_to_number(product.pa_grade)

  IF pa >= 4 AND has_brightening THEN
    RETURN 30
  ELSE IF pa >= 3 AND has_brightening THEN
    RETURN 25
  ELSE IF pa >= 4 THEN
    RETURN 20
  ELSE IF pa >= 3 THEN
    RETURN 15
  ELSE
    RETURN 0
  END IF

END FUNCTION
```

### 9.5 Scoring Sensitif/Iritasi

```text
FUNCTION score_sensitive_irritation(product):

  is_physical = product.sunscreen_type == "physical"
  is_hybrid   = product.sunscreen_type == "hybrid"

  fragrance_free = NOT has_ingredient(
    product.ingredient_ids,
    ["fragrance"]
  )

  alcohol_free = NOT has_ingredient(
    product.ingredient_ids,
    ["alcohol_denat", "ethanol"]
  )

  essential_oil_free = NOT has_ingredient(
    product.ingredient_ids,
    ["essential_oil"]
  )

  IF is_physical AND fragrance_free AND alcohol_free AND essential_oil_free THEN
    RETURN 30
  ELSE IF is_physical AND fragrance_free AND alcohol_free THEN
    RETURN 25
  ELSE IF is_physical THEN
    RETURN 20
  ELSE IF is_hybrid AND fragrance_free AND alcohol_free THEN
    RETURN 15
  ELSE
    RETURN 0
  END IF

END FUNCTION
```

### 9.6 Scoring Penuaan Dini

```text
FUNCTION score_aging(product):

  has_antioxidant = has_ingredient(
    product.ingredient_ids,
    ["vitamin_c", "peptide", "tocopherol"]
  )

  pa = pa_to_number(product.pa_grade)

  IF pa >= 4 AND has_antioxidant THEN
    RETURN 30
  ELSE IF pa >= 4 THEN
    RETURN 20
  ELSE IF pa >= 3 AND has_antioxidant THEN
    RETURN 15
  ELSE IF pa >= 3 THEN
    RETURN 10
  ELSE
    RETURN 0
  END IF

END FUNCTION
```

### 9.7 Scoring C — Aktivitas Harian (0–25)

```text
FUNCTION score_activity(product, activity):

  IF activity == "indoor" THEN

    IF product.texture IN ["gel", "serum", "watery", "mist"] THEN
      RETURN 25
    ELSE IF product.texture IN ["lotion", "milk"] THEN
      RETURN 20
    ELSE IF product.texture == "cream" THEN
      RETURN 15
    ELSE
      RETURN 10
    END IF

  ELSE IF activity == "outdoor_light" THEN

    IF product.is_water_resistant THEN
      RETURN 25
    ELSE IF product.texture IN ["gel", "lotion", "serum", "watery"] THEN
      RETURN 20
    ELSE
      RETURN 15
    END IF

  ELSE IF activity == "outdoor_intense" THEN

    IF product.is_water_resistant AND
       product.texture IN ["gel", "serum", "lotion", "watery"] THEN
      RETURN 25
    ELSE IF product.is_water_resistant THEN
      RETURN 20
    ELSE
      RETURN 0
    END IF

  ELSE IF activity == "sport" THEN

    IF product.is_water_resistant AND
       product.texture IN ["gel", "serum", "watery"] THEN
      RETURN 25
    ELSE IF product.is_water_resistant AND
            product.texture IN ["lotion", "milk"] THEN
      RETURN 18
    ELSE IF product.is_water_resistant THEN
      RETURN 10
    ELSE
      RETURN 0
    END IF

  ELSE IF activity == "swim" THEN

    IF product.is_very_water_resistant THEN
      RETURN 25
    ELSE IF product.is_water_resistant THEN
      RETURN 10
    ELSE
      RETURN 0
    END IF

  ELSE
    RETURN 0
  END IF

END FUNCTION
```

### 9.8 Scoring D — Tekstur (0–15)

```text
FUNCTION score_texture(product_texture, texture_preference):

  IF texture_preference IS NULL THEN
    RETURN 10
  END IF

  texture_match = {
    "gel"    : {"gel":15, "serum":10, "watery":8, "lotion":5, "milk":3, "mist":3, "cream":0, "stick":0, "spray":0},
    "cream"  : {"cream":15, "lotion":10, "milk":8, "serum":5, "gel":3, "watery":3, "mist":0, "stick":0, "spray":0},
    "lotion" : {"lotion":15, "milk":12, "cream":8, "gel":8, "serum":8, "watery":5, "mist":3, "stick":0, "spray":0},
    "serum"  : {"serum":15, "gel":10, "watery":8, "lotion":5, "milk":3, "mist":3, "cream":0, "stick":0, "spray":0},
    "milk"   : {"milk":15, "lotion":12, "cream":8, "serum":5, "gel":3, "watery":3, "mist":0, "stick":0, "spray":0},
    "watery" : {"watery":15, "gel":12, "serum":10, "mist":8, "lotion":5, "milk":3, "cream":0, "stick":0, "spray":0},
    "stick"  : {"stick":15, "spray":10, "lotion":5, "gel":3, "serum":3, "watery":3, "cream":0, "milk":0, "mist":0},
    "spray"  : {"spray":15, "stick":10, "mist":8, "lotion":5, "gel":3, "watery":3, "cream":0, "milk":0, "serum":0},
    "mist"   : {"mist":15, "spray":10, "watery":8, "gel":5, "serum":5, "lotion":3, "cream":0, "milk":0, "stick":0}
  }

  IF texture_preference IN texture_match AND
     product_texture IN texture_match[texture_preference] THEN
    RETURN texture_match[texture_preference][product_texture]
  END IF

  RETURN 0

END FUNCTION
```

---

## 10. Tahap 6 — Penalty System

```text
FUNCTION apply_penalty(scored_products, skin_type_id, activity):

  penalized = []

  FOR EACH item IN scored_products:

    product   = item.product
    penalty   = 0
    skin_code = get_skin_type_code(skin_type_id)

    // Chemical murni untuk kulit sensitif
    IF skin_code == "sensitive" AND
       product.sunscreen_type == "chemical" THEN
      penalty += 10
    END IF

    // Tidak water resistant untuk aktivitas berat
    IF activity == "outdoor_intense" AND
       NOT product.is_water_resistant THEN
      penalty += 8
    END IF

    IF activity == "sport" AND
       NOT product.is_water_resistant THEN
      penalty += 8
    END IF

    IF activity == "swim" AND
       NOT product.is_very_water_resistant THEN
      penalty += 10
    END IF

    // Tekstur berat untuk kulit berminyak
    IF skin_code == "oily" AND
       product.texture == "cream" THEN
      penalty += 5
    END IF

    // Finish dewy untuk kulit berminyak
    IF skin_code == "oily" AND
       product.finish == "dewy" THEN
      penalty += 3
    END IF

    // Finish tone-up untuk kulit berminyak
    IF skin_code == "oily" AND
       product.finish == "tone_up" THEN
      penalty += 3
    END IF

    final_score = MAX(0, item.total - penalty)

    penalized.APPEND({
      product     : product,
      score_a     : item.score_a,
      score_b     : item.score_b,
      score_c     : item.score_c,
      score_d     : item.score_d,
      total_raw   : item.total,
      penalty     : penalty,
      final_score : final_score
    })

  END FOR

  RETURN penalized

END FUNCTION
```

Catatan: Penalti *water resistant* tetap dipertahankan untuk prototipe karena sistem perlu lebih ketat pada aktivitas luar ruangan intensif, olahraga, dan berenang.

---

## 11. Tahap 7 — Ranking dan Kategorisasi

```text
FUNCTION rank_and_categorize(penalized_products):

  qualified = FILTER(
    penalized_products,
    WHERE final_score >= 40
  )

  IF qualified IS EMPTY THEN
    RETURN []
  END IF

  sorted = SORT_DESCENDING(qualified, BY: final_score)

  top5 = sorted[0..4]

  ranked = []

  FOR i, item IN ENUMERATE(top5):

    IF item.final_score >= 80 THEN
      category = "highly_recommended"
    ELSE IF item.final_score >= 60 THEN
      category = "recommended"
    ELSE
      category = "fairly_suitable"
    END IF

    ranked.APPEND({
      ...item,
      rank_position           : i + 1,
      recommendation_category : category
    })

  END FOR

  RETURN ranked

END FUNCTION
```

---

## 12. Tahap 8 — Simpan ke Database

Penyimpanan sebaiknya dilakukan dalam transaksi agar data tidak terpotong. Jika salah satu proses insert gagal, semua proses insert dibatalkan.

```text
FUNCTION save_recommendation(
  request,
  uv_result,
  spf_minimum,
  pa_minimum,
  ranked
):

  session_id = GEN_UUID()
  recommendation_code = GEN_CODE("REC")

  BEGIN_TRANSACTION()

  TRY:

    DB_INSERT(
      recommendation_sessions,
      {
        recommendation_session_id : session_id,
        recommendation_code       : recommendation_code,
        user_id                   : request.user_id,
        skin_type_id              : request.skin_type_id,
        activity                  : request.activity,
        texture_preference        : request.texture_preference,
        allergy_status            : request.allergy_status,
        usage_time_preference     : uv_result.usage_time_preference,
        location_name             : request.location_name,
        latitude                  : request.latitude,
        longitude                 : request.longitude,
        uv_index                  : uv_result.uv_index,
        created_at                : NOW()
      }
    )

    FOR EACH concern_id IN request.skin_concern_ids:
      DB_INSERT(
        recommendation_concerns,
        {
          recommendation_session_id : session_id,
          skin_concern_id           : concern_id
        }
      )
    END FOR

    IF request.allergy_status == "unknown_ingredient" THEN

      auto_avoid = GET_IDS_BY_CODES([
        "oxybenzone",
        "fragrance"
      ])

      FOR EACH auto_id IN auto_avoid:
        DB_INSERT(
          avoided_ingredients,
          {
            recommendation_session_id : session_id,
            ingredient_id             : auto_id
          }
        )
      END FOR

    ELSE IF request.allergy_status == "known_ingredient" THEN

      FOR EACH ingredient_id IN request.avoided_ingredient_ids:
        DB_INSERT(
          avoided_ingredients,
          {
            recommendation_session_id : session_id,
            ingredient_id             : ingredient_id
          }
        )
      END FOR

    END IF

    FOR EACH item IN ranked:
      DB_INSERT(
        recommendation_results,
        {
          recommendation_result_id  : GEN_UUID(),
          recommendation_session_id : session_id,
          product_id                : item.product.product_id,
          match_score               : item.final_score,
          recommendation_category   : item.recommendation_category,
          rank_position             : item.rank_position,
          created_at                : NOW()
        }
      )
    END FOR

    COMMIT_TRANSACTION()

    RETURN {
      session_id          : session_id,
      recommendation_code : recommendation_code
    }

  CATCH error:

    ROLLBACK_TRANSACTION()
    RETURN error("Gagal menyimpan hasil rekomendasi")

  END TRY

END FUNCTION
```

---

## 13. Tahap 9 — Format Response

```text
FUNCTION format_response(
  session_data,
  uv_result,
  spf_minimum,
  pa_minimum,
  ranked
):

  results = []

  FOR EACH item IN ranked:

    results.APPEND({
      rank_position             : item.rank_position,
      product_id                : item.product.product_id,
      product_code              : item.product.product_code,
      brand_name                : item.product.brand_name,
      product_name              : item.product.product_name,
      bpom_number               : item.product.bpom_number,
      spf                       : item.product.spf,
      pa_grade                  : item.product.pa_grade,
      sunscreen_type            : item.product.sunscreen_type,
      texture                   : item.product.texture,
      finish                    : item.product.finish,
      match_score               : item.final_score,
      recommendation_category   : item.recommendation_category
    })

  END FOR

  RETURN {
    recommendation_session_id : session_data.session_id,
    recommendation_code       : session_data.recommendation_code,
    uv_data: {
      uv_index              : uv_result.uv_index,
      uv_risk_level         : get_uv_risk_level(uv_result.uv_index),
      spf_minimum           : spf_minimum,
      pa_minimum            : pa_minimum,
      usage_time_preference : uv_result.usage_time_preference,
      is_forecast           : uv_result.is_forecast
    },
    results: results
  }

END FUNCTION
```

---

## 14. Fungsi Helper

### 14.1 Cek Kandungan Produk

```text
FUNCTION has_ingredient(product_ingredient_ids, ingredient_codes):

  ingredient_ids = GET_IDS_BY_CODES(ingredient_codes)

  FOR EACH id IN ingredient_ids:
    IF id IN product_ingredient_ids THEN
      RETURN true
    END IF
  END FOR

  RETURN false

END FUNCTION
```

### 14.2 Ambil ID Bahan Berdasarkan Kode

```text
FUNCTION GET_IDS_BY_CODES(ingredient_codes):

  IF ingredient_codes IS EMPTY THEN
    RETURN []
  END IF

  rows = DB_QUERY(
    SELECT ingredient_id
    FROM ingredients
    WHERE ingredient_code IN ingredient_codes
  )

  RETURN rows.ingredient_id

END FUNCTION
```

### 14.3 Konversi PA Grade ke Angka

```text
FUNCTION pa_to_number(pa_grade):

  map = {
    "PA+"    : 1,
    "PA++"   : 2,
    "PA+++"  : 3,
    "PA++++" : 4
  }

  RETURN map[pa_grade] OR 0

END FUNCTION
```

### 14.4 Ambil Kode Jenis Kulit

```text
FUNCTION get_skin_type_code(input_skin_type_id):

  row = DB_QUERY(
    SELECT skin_type_code
    FROM skin_types
    WHERE skin_type_id = input_skin_type_id
  )

  RETURN row.skin_type_code

END FUNCTION
```

### 14.5 Ambil Kode Masalah Kulit

```text
FUNCTION get_concern_code(input_skin_concern_id):

  row = DB_QUERY(
    SELECT skin_concern_code
    FROM skin_concerns
    WHERE skin_concern_id = input_skin_concern_id
  )

  RETURN row.skin_concern_code

END FUNCTION
```

### 14.6 Generate Kode Sesi

```text
FUNCTION GEN_CODE(prefix):

  timestamp = FORMAT(NOW(), "YYYYMMDDHHMMSS")
  random    = RANDOM_STRING(4)

  RETURN prefix + "-" + timestamp + "-" + random

  // Contoh: REC-20260610102030-A3B2

END FUNCTION
```

### 14.7 Validasi UUID

```text
FUNCTION is_valid_uuid(value):

  pattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"

  RETURN MATCH_REGEX(value, pattern)

END FUNCTION
```

### 14.8 Cek Duplikasi Array

```text
FUNCTION HAS_DUPLICATE(array):

  unique_values = UNIQUE(array)

  RETURN LEN(unique_values) != LEN(array)

END FUNCTION
```

### 14.9 Ambil Jam Lokal

```text
FUNCTION GET_CURRENT_LOCAL_HOUR(latitude, longitude):

  // Opsi 1:
  // Gunakan timezone=auto dari Open-Meteo dan sesuaikan waktu lokal dari respons API.

  // Opsi 2:
  // Flutter mengirim local_datetime pengguna ke Edge Function.

  // Untuk pseudocode ini, fungsi mengembalikan jam lokal lokasi pengguna.
  RETURN LOCAL_HOUR_BY_COORDINATE(latitude, longitude)

END FUNCTION
```

---

## 15. Ringkasan Alur Final

```text
REQUEST MASUK
      ↓
TAHAP 1: VALIDASI INPUT
→ Cek field wajib
→ Cek format UUID
→ Cek enum valid
→ Cek duplikasi input array
→ Cek koordinat latitude dan longitude
→ Cek konsistensi allergy_status
→ Jika malam, usage_time_preference wajib diisi
      ↓
TAHAP 2: RESOLVE UV INDEX
→ Siang (06.00–17.59): UV real-time
→ Malam (18.00–05.59): prakiraan UV besok
→ morning   = 06.00–10.00
→ afternoon = 10.00–14.00
→ evening   = 14.00–18.00
→ Tentukan SPF minimum
→ Tentukan PA minimum
→ Tentukan UV risk level
      ↓
TAHAP 3: FETCH PRODUK AKTIF
→ Ambil produk aktif
→ Ambil relasi jenis kulit
→ Ambil relasi masalah kulit
→ Ambil relasi ingredient
      ↓
TAHAP 4: HARD FILTER
→ Filter alergi:
  none    = tidak ada filter alergi
  unknown = filter bahan perhatian umum, yaitu oxybenzone dan fragrance
  known   = filter bahan yang dipilih pengguna
→ Filter UV:
  SPF < minimum = gugur
  PA < minimum  = gugur
      ↓
TAHAP 5: SCORING
→ Jenis kulit   = 0–30
→ Masalah kulit = 0–30
→ Aktivitas     = 0–25
→ Tekstur       = 0–15
→ Total maksimal = 100
      ↓
TAHAP 6: PENALTY
→ Chemical untuk kulit sensitif = -10
→ Tidak water resistant untuk outdoor intense = -8
→ Tidak water resistant untuk sport = -8
→ Tidak very water resistant untuk swim = -10
→ Cream untuk kulit berminyak = -5
→ Dewy untuk kulit berminyak = -3
→ Tone-up untuk kulit berminyak = -3
→ Final score = MAX(0, total - penalty)
      ↓
TAHAP 7: RANKING
→ Filter final_score < 40
→ Urutkan berdasarkan final_score tertinggi
→ Ambil Top 5 produk
→ Kategorikan:
  80–100 = highly_recommended
  60–79  = recommended
  40–59  = fairly_suitable
      ↓
TAHAP 8: SIMPAN KE DATABASE
→ recommendation_sessions
→ recommendation_concerns
→ avoided_ingredients
→ recommendation_results
→ Gunakan transaksi database
      ↓
TAHAP 9: RESPONSE
→ Return recommendation_session_id
→ Return recommendation_code
→ Return uv_data
→ Return Top 5 recommendation results
```

---

## 16. Catatan Implementasi untuk Supabase Edge Function

1. Gunakan `service_role_key` hanya di server Edge Function, bukan di aplikasi Flutter.
2. Gunakan `anon_key` hanya untuk sisi aplikasi jika dibutuhkan.
3. Simpan proses insert sesi, concern, avoided ingredients, dan results dalam transaksi database.
4. Hindari melakukan banyak query berulang untuk mengambil kode jenis kulit, masalah kulit, dan ingredient. Pada implementasi nyata, data master dapat diambil sekali lalu disimpan sebagai map di memori function selama proses request.
5. Pastikan semua data master memiliki kode standar, seperti `oily`, `acne`, `niacinamide`, dan `fragrance`.
6. Pastikan produk dengan klaim “untuk semua jenis kulit” disimpan sebagai lima relasi di `product_skin_types`, bukan memakai kode `all`.
7. Produk dengan skor di bawah 40 tidak disimpan ke `recommendation_results`.
8. Kolom `uv_filter` tetap disimpan dalam tabel `ingredients` dan `product_ingredients`, tetapi tidak wajib memengaruhi skor secara langsung.

---

## 17. Catatan Akademik

Pseudocode ini menggunakan pendekatan *Rule-Based Scoring* dengan dua tahap utama, yaitu *hard filter* dan pemberian skor. *Hard filter* digunakan untuk menyaring produk yang tidak memenuhi syarat minimum, seperti SPF/PA berdasarkan Indeks UV dan bahan yang dihindari pengguna. Produk yang lolos kemudian dihitung skornya berdasarkan jenis kulit, masalah kulit, aktivitas, dan preferensi tekstur. Setelah itu, sistem menerapkan penalti untuk kondisi tertentu, seperti penggunaan *chemical sunscreen* pada kulit sensitif atau produk yang tidak tahan air pada aktivitas berat.

Dengan rancangan ini, sistem dapat menghasilkan rekomendasi yang lebih personal, kontekstual, dan aman digunakan sebagai alat bantu pemilihan sunscreen. Sistem tidak dimaksudkan sebagai diagnosis medis, melainkan sebagai pendukung keputusan berdasarkan data yang dimasukkan pengguna dan data produk yang tersedia dalam sistem.
