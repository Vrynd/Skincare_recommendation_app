# Revisi Struktur Tabel Database Sistem Rekomendasi Sunscreen

Dokumen ini berisi hasil evaluasi dan revisi struktur tabel database untuk prototipe sistem rekomendasi sunscreen berbasis *Rule-Based Scoring*. Struktur ini merupakan penyederhanaan dari rancangan tabel sebelumnya agar lebih sesuai dengan kebutuhan prototipe PI/SETIK, yaitu fokus pada fitur rekomendasi sunscreen, bukan fitur evaluasi produk lanjutan.

---

## 1. Tujuan Revisi Struktur Tabel

Revisi struktur tabel dilakukan untuk menyesuaikan database dengan konsep sistem terbaru. Sistem yang dikembangkan pada tahap prototipe berfokus pada proses rekomendasi produk sunscreen berdasarkan jenis kulit, masalah kulit, aktivitas, preferensi tekstur, riwayat alergi atau bahan yang dihindari, serta Indeks UV.

Pada rancangan sebelumnya, terdapat beberapa atribut yang lebih cocok untuk fitur evaluasi lanjutan, seperti `session_type`, `evaluated_product_id`, dan `evaluation_note`. Atribut tersebut belum dibutuhkan pada prototipe karena sistem hanya menjalankan satu jenis proses, yaitu rekomendasi produk.

Dengan demikian, revisi struktur tabel bertujuan untuk:

1. menyederhanakan struktur database;
2. menghapus atribut yang belum diperlukan pada prototipe;
3. menjaga konsistensi data dengan dataset sunscreen yang sudah dibersihkan;
4. mendukung proses *hard filter*, *scoring*, penalti, dan ranking;
5. mempersiapkan database agar lebih mudah diimplementasikan pada Supabase dan Edge Function.

---

## 2. Evaluasi Singkat terhadap Struktur Tabel Terbaru

Struktur tabel terbaru sudah sesuai untuk kebutuhan prototipe sistem rekomendasi sunscreen. Skema ini terdiri dari 12 tabel utama yang dikelompokkan menjadi data pengguna, data master, data relasi produk, dan data proses rekomendasi.

| Komponen | Status | Catatan |
|---|---|---|
| Enum pengguna dan produk | Sesuai | Sudah membatasi nilai agar konsisten. |
| Tabel `users` | Sesuai | Sudah mengikuti kebutuhan Supabase Auth. |
| Tabel `skin_types` | Sesuai | Mendukung lima jenis kulit standar. |
| Tabel `skin_concerns` | Sesuai | Mendukung empat masalah kulit yang telah disepakati. |
| Tabel `ingredients` | Sesuai dengan catatan | `uv_filter` tetap dipertahankan sebagai informasi produk dan validasi jenis sunscreen. |
| Tabel `products` | Sesuai | Sudah memuat atribut utama produk sunscreen. |
| Tabel relasi produk | Sesuai | Mendukung relasi banyak-ke-banyak antara produk, jenis kulit, masalah kulit, dan kandungan. |
| Tabel `recommendation_sessions` | Sesuai | Sudah fokus pada sesi rekomendasi, tanpa atribut evaluasi. |
| Tabel `recommendation_results` | Sesuai | Sudah menyimpan skor, kategori, dan ranking hasil rekomendasi. |

Kesimpulannya, struktur tabel terbaru sudah layak digunakan sebagai struktur database prototipe. Beberapa catatan perbaikan hanya bersifat penajaman istilah dan penjelasan akademik, bukan perubahan besar pada struktur.

---

## 3. Perubahan dari Struktur Lama ke Struktur Terbaru

| Bagian Lama | Masalah | Keputusan Revisi |
|---|---|---|
| `session_type` pada `recommendation_sessions` | Pada prototipe semua sesi hanya berjenis rekomendasi, sehingga nilainya akan selalu sama. | Dihapus dari struktur prototipe. |
| `evaluated_product_id` pada `recommendation_sessions` | Hanya dibutuhkan untuk fitur evaluasi sunscreen yang sudah dimiliki pengguna. | Dihapus dan dipindahkan ke pengembangan TA. |
| `evaluation_note` pada `recommendation_results` | Lebih sesuai untuk fitur evaluasi produk atau pelacakan lanjutan. | Dihapus dari prototipe. |
| `usage_time_preference` berisi `next_day` | Nilai `next_day` terlalu umum dan tidak menunjukkan waktu penggunaan. | Diganti menjadi `evening`. |
| `recommendation_category_enum` berisi `less_suitable` | Produk dengan skor di bawah 40 tidak ditampilkan dan tidak disimpan. | `less_suitable` dihapus. |
| `ingredient_category` tanpa/atau ragu pada `uv_filter` | UV filter tidak langsung digunakan sebagai skor, tetapi berguna untuk informasi produk dan validasi jenis sunscreen. | `uv_filter` tetap dipertahankan. |

---

## 4. Enum Final

Enum digunakan untuk menjaga konsistensi nilai data. Dengan enum, sistem tidak menerima nilai bebas yang dapat menyebabkan inkonsistensi saat proses rekomendasi.

### 4.1 `user_role`

```dbml
Enum user_role {
  user
  admin
}
```

Enum ini digunakan untuk membedakan pengguna biasa dan admin. Pengguna biasa mengakses fitur rekomendasi, sedangkan admin mengelola data produk, jenis kulit, masalah kulit, dan kandungan.

### 4.2 `sunscreen_type_enum`

```dbml
Enum sunscreen_type_enum {
  physical
  chemical
  hybrid
}
```

Enum ini digunakan untuk membedakan jenis sunscreen berdasarkan filter UV yang digunakan. Nilai ini penting untuk informasi produk dan dapat digunakan dalam penalti, misalnya *chemical sunscreen* untuk kulit sensitif.

### 4.3 `texture_type_enum`

```dbml
Enum texture_type_enum {
  gel
  cream
  lotion
  serum
  milk
  watery
  stick
  spray
  mist
}
```

Enum ini digunakan untuk menyimpan tekstur produk. Tekstur diperlukan karena menjadi salah satu komponen *scoring* dengan bobot 0–15.

### 4.4 `finish_type_enum`

```dbml
Enum finish_type_enum {
  matte
  dewy
  natural
  tone_up
}
```

Enum ini digunakan untuk menyimpan hasil akhir produk pada kulit. Nilai ini berguna dalam penalti, terutama untuk pengguna dengan kulit berminyak.

### 4.5 `activity_type_enum`

```dbml
Enum activity_type_enum {
  indoor
  outdoor_light
  outdoor_intense
  sport
  swim
}
```

Enum ini digunakan untuk menyimpan aktivitas pengguna. Aktivitas menjadi salah satu komponen *scoring* dengan bobot 0–25.

### 4.6 `usage_time_preference_enum`

```dbml
Enum usage_time_preference_enum {
  realtime
  morning
  afternoon
  evening
}
```

Enum ini digunakan untuk menentukan waktu penggunaan sunscreen. Nilai `realtime` digunakan saat pengguna mencari rekomendasi pada pagi sampai sore hari. Nilai `morning`, `afternoon`, dan `evening` digunakan ketika pengguna mencari rekomendasi pada malam hari dan sistem perlu mengambil prakiraan UV untuk esok hari.

### 4.7 `ingredient_category`

```dbml
Enum ingredient_category {
  active
  uv_filter
  avoid
}
```

Enum ini digunakan untuk mengelompokkan bahan produk. Kategori `active` digunakan untuk kandungan utama yang mendukung alasan rekomendasi, `uv_filter` digunakan untuk informasi filter UV dan validasi jenis sunscreen, sedangkan `avoid` digunakan untuk bahan yang perlu diperhatikan pada proses *hard filter* alergi.

### 4.8 `allergy_status_type`

```dbml
Enum allergy_status_type {
  none
  unknown_ingredient
  known_ingredient
}
```

Enum ini digunakan untuk menyimpan status riwayat alergi atau ketidakcocokan pengguna. Nilai ini menentukan apakah sistem perlu melakukan filter bahan yang dihindari.

### 4.9 `recommendation_category_enum`

```dbml
Enum recommendation_category_enum {
  highly_recommended
  recommended
  fairly_suitable
}
```

Enum ini digunakan untuk menyimpan kategori hasil rekomendasi. Kategori `less_suitable` tidak digunakan karena produk dengan skor di bawah 40 tidak ditampilkan dan tidak disimpan ke hasil rekomendasi.

| Rentang Skor | Kategori |
|---|---|
| 80–100 | `highly_recommended` |
| 60–79 | `recommended` |
| 40–59 | `fairly_suitable` |

---

## 5. Struktur Tabel Final

## 5.1 Tabel `users`

Tabel `users` digunakan untuk menyimpan profil pengguna dan admin. Tabel ini mengikuti data pengguna dari Supabase Auth, sehingga `user_id` dapat disesuaikan dengan ID autentikasi Supabase.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `user_id` | UUID | PK | ID unik pengguna, mengikuti ID dari Supabase Auth. |
| 2 | `full_name` | VARCHAR(100) |  | Nama lengkap pengguna. |
| 3 | `email` | VARCHAR(150) | UNIQUE, NOT NULL | Email pengguna sebagai *alternate key*. |
| 4 | `avatar_url` | TEXT |  | URL foto profil pengguna. |
| 5 | `role` | `user_role` | NOT NULL | Peran pengguna, yaitu `user` atau `admin`. |
| 6 | `is_active` | BOOLEAN | NOT NULL | Status aktif akun pengguna. |
| 7 | `created_at` | TIMESTAMPTZ | NOT NULL | Waktu data dibuat. |
| 8 | `updated_at` | TIMESTAMPTZ | NOT NULL | Waktu data diperbarui. |

**Alasan tabel diperlukan:**  
Tabel ini diperlukan karena sistem memiliki pengguna dan admin. Pengguna menggunakan fitur rekomendasi, sedangkan admin mengelola data master dan produk.

---

## 5.2 Tabel `skin_types`

Tabel `skin_types` digunakan untuk menyimpan daftar jenis kulit yang menjadi input pengguna dan komponen *scoring*.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `skin_type_id` | UUID | PK | ID unik jenis kulit. |
| 2 | `skin_type_code` | VARCHAR(20) | UNIQUE, NOT NULL | Kode jenis kulit, misalnya `normal`, `oily`, `dry`, `combination`, `sensitive`. |
| 3 | `skin_type_name` | VARCHAR(50) | UNIQUE, NOT NULL | Nama jenis kulit yang ditampilkan ke pengguna. |
| 4 | `description` | TEXT |  | Deskripsi jenis kulit. |
| 5 | `created_at` | TIMESTAMPTZ | NOT NULL | Waktu data dibuat. |
| 6 | `updated_at` | TIMESTAMPTZ | NOT NULL | Waktu data diperbarui. |

**Alasan tabel diperlukan:**  
Jenis kulit merupakan input utama dalam sistem rekomendasi. Tabel ini dibuat terpisah agar pilihan jenis kulit konsisten dan tidak ditulis berulang pada tabel produk maupun sesi rekomendasi.

---

## 5.3 Tabel `skin_concerns`

Tabel `skin_concerns` digunakan untuk menyimpan daftar masalah kulit yang relevan untuk pemilihan sunscreen.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `skin_concern_id` | UUID | PK | ID unik masalah kulit. |
| 2 | `skin_concern_code` | VARCHAR(20) | UNIQUE, NOT NULL | Kode masalah kulit, misalnya `acne`, `hyperpigmentation`, `sensitive_irritation`, `aging`. |
| 3 | `skin_concern_name` | VARCHAR(100) | UNIQUE, NOT NULL | Nama masalah kulit yang ditampilkan ke pengguna. |
| 4 | `description` | TEXT |  | Deskripsi masalah kulit. |
| 5 | `created_at` | TIMESTAMPTZ | NOT NULL | Waktu data dibuat. |
| 6 | `updated_at` | TIMESTAMPTZ | NOT NULL | Waktu data diperbarui. |

**Alasan tabel diperlukan:**  
Masalah kulit menjadi salah satu dasar penilaian kecocokan produk. Tabel ini dibatasi pada empat kategori, yaitu jerawat, hiperpigmentasi, sensitif/iritasi, dan penuaan dini agar data lebih konsisten.

---

## 5.4 Tabel `ingredients`

Tabel `ingredients` digunakan untuk menyimpan bahan penting pada produk sunscreen.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `ingredient_id` | UUID | PK | ID unik bahan. |
| 2 | `ingredient_code` | VARCHAR(20) | UNIQUE, NOT NULL | Kode bahan, misalnya `niacinamide`, `zinc_oxide`, `fragrance`. |
| 3 | `ingredient_name` | VARCHAR(100) | UNIQUE, NOT NULL | Nama bahan. |
| 4 | `category` | `ingredient_category` | NOT NULL | Kategori bahan: `active`, `uv_filter`, atau `avoid`. |
| 5 | `created_at` | TIMESTAMPTZ | NOT NULL | Waktu data dibuat. |
| 6 | `updated_at` | TIMESTAMPTZ | NOT NULL | Waktu data diperbarui. |

**Alasan tabel diperlukan:**  
Tabel ini diperlukan untuk menyimpan bahan yang relevan terhadap sistem, bukan seluruh komposisi produk. Data bahan digunakan untuk mendukung alasan rekomendasi, identifikasi filter UV, validasi jenis sunscreen, dan *hard filter* bahan yang dihindari.

**Catatan penting:**  
Kolom `category` tidak berarti satu bahan hanya memiliki satu fungsi secara mutlak. Dalam implementasi prototipe, satu bahan disimpan berdasarkan fungsi yang paling relevan untuk sistem. Jika bahan seperti `octocrylene` dianggap sebagai UV filter sekaligus bahan perhatian, sistem dapat menggunakan pendekatan kode bahan yang sama dengan perlakuan khusus pada logika rekomendasi, atau membuat entri kategori yang disesuaikan sesuai kebutuhan implementasi.

---

## 5.5 Tabel `products`

Tabel `products` digunakan untuk menyimpan data utama produk sunscreen yang menjadi objek rekomendasi.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `product_id` | UUID | PK | ID unik produk. |
| 2 | `product_code` | VARCHAR(20) | UNIQUE, NOT NULL | Kode produk, misalnya S001. |
| 3 | `brand_name` | VARCHAR(100) | NOT NULL | Nama merek produk. |
| 4 | `product_name` | VARCHAR(150) | NOT NULL | Nama lengkap produk. |
| 5 | `bpom_number` | VARCHAR(50) | UNIQUE, NOT NULL | Nomor registrasi BPOM. |
| 6 | `spf` | INTEGER | NOT NULL | Nilai SPF produk. |
| 7 | `pa_grade` | VARCHAR(10) | NOT NULL | Nilai PA produk, misalnya PA+++ atau PA++++. |
| 8 | `sunscreen_type` | `sunscreen_type_enum` | NOT NULL | Jenis sunscreen: `physical`, `chemical`, atau `hybrid`. |
| 9 | `texture` | `texture_type_enum` | NOT NULL | Tekstur produk. |
| 10 | `finish` | `finish_type_enum` | NOT NULL | Hasil akhir produk pada kulit. |
| 11 | `is_water_resistant` | BOOLEAN | NOT NULL | Menandai apakah produk tahan air. |
| 12 | `is_very_water_resistant` | BOOLEAN | NOT NULL | Menandai apakah produk sangat tahan air. |
| 13 | `is_non_comedogenic` | BOOLEAN | NOT NULL | Menandai klaim tidak menyumbat pori. |
| 14 | `is_oil_free` | BOOLEAN | NOT NULL | Menandai klaim bebas minyak. |
| 15 | `is_active` | BOOLEAN | NOT NULL | Menandai apakah produk masih digunakan dalam sistem. |
| 16 | `created_at` | TIMESTAMPTZ | NOT NULL | Waktu data dibuat. |
| 17 | `updated_at` | TIMESTAMPTZ | NOT NULL | Waktu data diperbarui. |

**Alasan tabel diperlukan:**  
Tabel ini menjadi pusat data produk sunscreen. Atribut SPF, PA, jenis sunscreen, tekstur, hasil akhir, ketahanan air, non-comedogenic, dan oil-free digunakan dalam proses *hard filter*, *scoring*, penalti, dan penentuan ranking rekomendasi.

---

## 5.6 Tabel `product_skin_types`

Tabel `product_skin_types` digunakan untuk menghubungkan produk sunscreen dengan jenis kulit yang sesuai.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `product_id` | UUID | PK, FK | Mengacu ke tabel `products`. |
| 2 | `skin_type_id` | UUID | PK, FK | Mengacu ke tabel `skin_types`. |

**Alasan tabel diperlukan:**  
Satu produk dapat cocok untuk lebih dari satu jenis kulit, dan satu jenis kulit dapat dimiliki oleh banyak produk. Oleh karena itu, relasinya bersifat banyak-ke-banyak. Tabel ini digunakan untuk menghitung skor komponen jenis kulit.

---

## 5.7 Tabel `product_skin_concerns`

Tabel `product_skin_concerns` digunakan untuk menghubungkan produk sunscreen dengan masalah kulit yang ditargetkan.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `product_id` | UUID | PK, FK | Mengacu ke tabel `products`. |
| 2 | `skin_concern_id` | UUID | PK, FK | Mengacu ke tabel `skin_concerns`. |

**Alasan tabel diperlukan:**  
Satu produk dapat relevan untuk lebih dari satu masalah kulit. Tabel ini digunakan untuk mendukung *scoring* komponen masalah kulit.

---

## 5.8 Tabel `product_ingredients`

Tabel `product_ingredients` digunakan untuk menghubungkan produk sunscreen dengan bahan penting yang dimiliki produk.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `product_id` | UUID | PK, FK | Mengacu ke tabel `products`. |
| 2 | `ingredient_id` | UUID | PK, FK | Mengacu ke tabel `ingredients`. |

**Alasan tabel diperlukan:**  
Tabel ini digunakan untuk menyimpan kandungan penting produk secara relasional. Data ini mendukung alasan rekomendasi, validasi jenis sunscreen, dan proses *hard filter* bahan yang dihindari. Sistem tidak menyimpan seluruh komposisi produk agar database tidak membengkak.

---

## 5.9 Tabel `recommendation_sessions`

Tabel `recommendation_sessions` digunakan untuk menyimpan data utama setiap sesi rekomendasi.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `recommendation_session_id` | UUID | PK | ID unik sesi rekomendasi. |
| 2 | `recommendation_code` | VARCHAR(30) | UNIQUE, NOT NULL | Kode sesi rekomendasi sebagai *alternate key*. |
| 3 | `user_id` | UUID | FK, NOT NULL | Mengacu ke tabel `users`. |
| 4 | `skin_type_id` | UUID | FK, NOT NULL | Jenis kulit pengguna. |
| 5 | `activity` | `activity_type_enum` | NOT NULL | Aktivitas pengguna. |
| 6 | `texture_preference` | `texture_type_enum` |  | Preferensi tekstur produk. |
| 7 | `allergy_status` | `allergy_status_type` | NOT NULL | Status riwayat alergi atau ketidakcocokan. |
| 8 | `usage_time_preference` | `usage_time_preference_enum` | NOT NULL | Waktu penggunaan sunscreen. |
| 9 | `location_name` | VARCHAR(150) |  | Nama lokasi pengguna. |
| 10 | `latitude` | NUMERIC(10,7) |  | Latitude lokasi pengguna. |
| 11 | `longitude` | NUMERIC(10,7) |  | Longitude lokasi pengguna. |
| 12 | `uv_index` | NUMERIC(4,2) |  | Nilai Indeks UV yang digunakan sistem. |
| 13 | `created_at` | TIMESTAMPTZ | NOT NULL | Waktu sesi dibuat. |

**Alasan tabel diperlukan:**  
Tabel ini menyimpan input utama pengguna dalam satu sesi rekomendasi. Data pada tabel ini digunakan sebagai dasar proses rekomendasi, termasuk jenis kulit, aktivitas, preferensi tekstur, status alergi, lokasi, dan Indeks UV.

**Catatan:**  
Atribut `session_type` dan `evaluated_product_id` tidak digunakan pada prototipe karena sistem belum memiliki fitur evaluasi sunscreen yang sudah dimiliki pengguna. Keduanya dapat ditambahkan pada tahap pengembangan TA.

---

## 5.10 Tabel `recommendation_concerns`

Tabel `recommendation_concerns` digunakan untuk menyimpan masalah kulit yang dipilih pengguna dalam satu sesi rekomendasi.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `recommendation_session_id` | UUID | PK, FK | Mengacu ke tabel `recommendation_sessions`. |
| 2 | `skin_concern_id` | UUID | PK, FK | Mengacu ke tabel `skin_concerns`. |

**Alasan tabel diperlukan:**  
Pengguna dapat memilih lebih dari satu masalah kulit dalam satu sesi. Tabel ini memungkinkan data masalah kulit disimpan secara relasional dan tetap konsisten.

---

## 5.11 Tabel `avoided_ingredients`

Tabel `avoided_ingredients` digunakan untuk menyimpan bahan yang dihindari pengguna pada satu sesi rekomendasi.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `recommendation_session_id` | UUID | PK, FK | Mengacu ke tabel `recommendation_sessions`. |
| 2 | `ingredient_id` | UUID | PK, FK | Mengacu ke tabel `ingredients`. |

**Alasan tabel diperlukan:**  
Tabel ini mendukung proses *hard filter* bahan yang dihindari. Jika pengguna mengetahui bahan yang menyebabkan ketidakcocokan, sistem dapat menyaring produk yang mengandung bahan tersebut.

---

## 5.12 Tabel `recommendation_results`

Tabel `recommendation_results` digunakan untuk menyimpan hasil produk yang direkomendasikan oleh sistem.

| No | Atribut | Tipe Data | Kunci | Keterangan |
|---:|---|---|---|---|
| 1 | `recommendation_result_id` | UUID | PK | ID unik hasil rekomendasi. |
| 2 | `recommendation_session_id` | UUID | FK, NOT NULL | Mengacu ke tabel `recommendation_sessions`. |
| 3 | `product_id` | UUID | FK, NOT NULL | Mengacu ke tabel `products`. |
| 4 | `match_score` | NUMERIC(5,2) | NOT NULL | Skor akhir kecocokan produk. |
| 5 | `recommendation_category` | `recommendation_category_enum` | NOT NULL | Kategori rekomendasi. |
| 6 | `rank_position` | INTEGER | NOT NULL | Posisi ranking produk dalam hasil rekomendasi. |
| 7 | `created_at` | TIMESTAMPTZ | NOT NULL | Waktu hasil rekomendasi dibuat. |

**Alasan tabel diperlukan:**  
Tabel ini menyimpan output dari proses *Rule-Based Scoring*. Produk yang masuk ke tabel ini hanya produk dengan skor akhir minimal 40, kemudian dikategorikan menjadi sangat direkomendasikan, direkomendasikan, atau cukup sesuai.

**Catatan:**  
Atribut `evaluation_note` tidak digunakan pada prototipe karena catatan evaluasi lebih sesuai untuk fitur evaluasi produk atau *efficacy tracker* pada pengembangan lanjutan.

---

## 6. Relasi Antar Tabel

| Tabel Asal | Relasi | Tabel Tujuan | Keterangan |
|---|---|---|---|
| `users` | 1 : N | `recommendation_sessions` | Satu pengguna dapat memiliki banyak sesi rekomendasi. |
| `skin_types` | 1 : N | `recommendation_sessions` | Satu jenis kulit dapat digunakan pada banyak sesi rekomendasi. |
| `products` | M : N | `skin_types` | Melalui tabel `product_skin_types`. |
| `products` | M : N | `skin_concerns` | Melalui tabel `product_skin_concerns`. |
| `products` | M : N | `ingredients` | Melalui tabel `product_ingredients`. |
| `recommendation_sessions` | M : N | `skin_concerns` | Melalui tabel `recommendation_concerns`. |
| `recommendation_sessions` | M : N | `ingredients` | Melalui tabel `avoided_ingredients`. |
| `recommendation_sessions` | 1 : N | `recommendation_results` | Satu sesi menghasilkan beberapa rekomendasi produk. |
| `products` | 1 : N | `recommendation_results` | Satu produk dapat muncul pada banyak hasil rekomendasi. |

---

## 7. DBML Struktur Final

```dbml
Enum user_role {
  user
  admin
}

Enum sunscreen_type_enum {
  physical
  chemical
  hybrid
}

Enum texture_type_enum {
  gel
  cream
  lotion
  serum
  milk
  watery
  stick
  spray
  mist
}

Enum finish_type_enum {
  matte
  dewy
  natural
  tone_up
}

Enum activity_type_enum {
  indoor
  outdoor_light
  outdoor_intense
  sport
  swim
}

Enum usage_time_preference_enum {
  realtime
  morning
  afternoon
  evening
}

Enum ingredient_category {
  active
  uv_filter
  avoid
}

Enum allergy_status_type {
  none
  unknown_ingredient
  known_ingredient
}

Enum recommendation_category_enum {
  highly_recommended
  recommended
  fairly_suitable
}

Table users {
  user_id uuid [pk, note: 'Mengikuti id dari Supabase Auth']
  full_name varchar(100)
  email varchar(150) [unique, not null, note: 'Alternate key']
  avatar_url text
  role user_role [not null, default: 'user']
  is_active boolean [not null, default: true]
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  Note: 'Tabel untuk menyimpan data profil pengguna dan admin sistem.'
}

Table skin_types {
  skin_type_id uuid [pk, default: `gen_random_uuid()`]
  skin_type_code varchar(20) [unique, not null, note: 'Alternate key']
  skin_type_name varchar(50) [not null, unique]
  description text
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  Note: 'Tabel untuk menyimpan daftar jenis kulit yang digunakan sebagai komponen scoring dan pilihan input pengguna.'
}

Table skin_concerns {
  skin_concern_id uuid [pk, default: `gen_random_uuid()`]
  skin_concern_code varchar(20) [unique, not null, note: 'Alternate key']
  skin_concern_name varchar(100) [not null, unique]
  description text
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  Note: 'Tabel untuk menyimpan daftar masalah kulit yang relevan untuk pemilihan sunscreen, dibatasi pada jerawat, hiperpigmentasi, sensitif/iritasi, dan penuaan dini.'
}

Table ingredients {
  ingredient_id uuid [pk, default: `gen_random_uuid()`]
  ingredient_code varchar(20) [unique, not null, note: 'Alternate key']
  ingredient_name varchar(100) [not null, unique]
  category ingredient_category [not null]
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  Note: 'Tabel untuk menyimpan daftar kandungan produk sunscreen. Kategori active untuk kandungan utama, uv_filter untuk filter UV sebagai informasi produk, dan avoid untuk bahan yang perlu dihindari pada hard filter alergi.'
}

Table products {
  product_id uuid [pk, default: `gen_random_uuid()`]
  product_code varchar(20) [unique, not null, note: 'Alternate key']
  brand_name varchar(100) [not null]
  product_name varchar(150) [not null]
  bpom_number varchar(50) [unique, not null]
  spf integer [not null]
  pa_grade varchar(10) [not null]
  sunscreen_type sunscreen_type_enum [not null]
  texture texture_type_enum [not null]
  finish finish_type_enum [not null]
  is_water_resistant boolean [not null, default: false]
  is_very_water_resistant boolean [not null, default: false]
  is_non_comedogenic boolean [not null, default: false]
  is_oil_free boolean [not null, default: false]
  is_active boolean [not null, default: true]
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  Note: 'Tabel untuk menyimpan data utama produk sunscreen yang menjadi objek rekomendasi dalam sistem.'
}

Table product_skin_types {
  product_id uuid [not null]
  skin_type_id uuid [not null]

  indexes {
    (product_id, skin_type_id) [pk]
  }

  Note: 'Tabel relasi many-to-many antara produk sunscreen dan jenis kulit yang sesuai. Digunakan untuk scoring komponen jenis kulit.'
}

Table product_skin_concerns {
  product_id uuid [not null]
  skin_concern_id uuid [not null]

  indexes {
    (product_id, skin_concern_id) [pk]
  }

  Note: 'Tabel relasi many-to-many antara produk sunscreen dan masalah kulit yang ditargetkan. Digunakan untuk scoring komponen masalah kulit.'
}

Table product_ingredients {
  product_id uuid [not null]
  ingredient_id uuid [not null]

  indexes {
    (product_id, ingredient_id) [pk]
  }

  Note: 'Tabel relasi many-to-many antara produk sunscreen dan kandungan yang dimiliki. Digunakan untuk informasi produk, validasi jenis sunscreen, dan hard filter bahan yang dihindari.'
}

Table recommendation_sessions {
  recommendation_session_id uuid [pk, default: `gen_random_uuid()`]
  recommendation_code varchar(30) [unique, not null, note: 'Alternate key']
  user_id uuid [not null]
  skin_type_id uuid [not null]
  activity activity_type_enum [not null]
  texture_preference texture_type_enum
  allergy_status allergy_status_type [not null, default: 'none']
  usage_time_preference usage_time_preference_enum [not null]
  location_name varchar(150)
  latitude numeric(10,7)
  longitude numeric(10,7)
  uv_index numeric(4,2)
  created_at timestamptz [not null, default: `now()`]

  Note: 'Tabel untuk menyimpan data utama setiap sesi rekomendasi. Menyimpan kondisi kulit, aktivitas, preferensi tekstur, indeks UV, dan lokasi pengguna saat rekomendasi dibuat.'
}

Table recommendation_concerns {
  recommendation_session_id uuid [not null]
  skin_concern_id uuid [not null]

  indexes {
    (recommendation_session_id, skin_concern_id) [pk]
  }

  Note: 'Tabel relasi untuk menyimpan masalah kulit yang dipilih pengguna pada satu sesi rekomendasi. Memungkinkan pengguna memilih lebih dari satu masalah kulit.'
}

Table avoided_ingredients {
  recommendation_session_id uuid [not null]
  ingredient_id uuid [not null]

  indexes {
    (recommendation_session_id, ingredient_id) [pk]
  }

  Note: 'Tabel relasi untuk menyimpan bahan yang dihindari pengguna pada satu sesi rekomendasi. Digunakan sebagai hard filter untuk menyaring produk yang mengandung bahan tersebut.'
}

Table recommendation_results {
  recommendation_result_id uuid [pk, default: `gen_random_uuid()`]
  recommendation_session_id uuid [not null]
  product_id uuid [not null]
  match_score numeric(5,2) [not null, default: 0]
  recommendation_category recommendation_category_enum [not null]
  rank_position integer [not null]
  created_at timestamptz [not null, default: `now()`]

  indexes {
    (recommendation_session_id, product_id) [unique]
  }

  Note: 'Tabel untuk menyimpan hasil produk yang direkomendasikan beserta skor akhir Rule-Based Scoring, kategori rekomendasi, dan posisi ranking.'
}

Ref: product_skin_types.product_id > products.product_id [delete: cascade, update: cascade]
Ref: product_skin_types.skin_type_id > skin_types.skin_type_id [delete: cascade, update: cascade]

Ref: product_skin_concerns.product_id > products.product_id [delete: cascade, update: cascade]
Ref: product_skin_concerns.skin_concern_id > skin_concerns.skin_concern_id [delete: cascade, update: cascade]

Ref: product_ingredients.product_id > products.product_id [delete: cascade, update: cascade]
Ref: product_ingredients.ingredient_id > ingredients.ingredient_id [delete: cascade, update: cascade]

Ref: recommendation_sessions.user_id > users.user_id [delete: cascade, update: cascade]
Ref: recommendation_sessions.skin_type_id > skin_types.skin_type_id [delete: restrict, update: cascade]

Ref: recommendation_concerns.recommendation_session_id > recommendation_sessions.recommendation_session_id [delete: cascade, update: cascade]
Ref: recommendation_concerns.skin_concern_id > skin_concerns.skin_concern_id [delete: restrict, update: cascade]

Ref: avoided_ingredients.recommendation_session_id > recommendation_sessions.recommendation_session_id [delete: cascade, update: cascade]
Ref: avoided_ingredients.ingredient_id > ingredients.ingredient_id [delete: restrict, update: cascade]

Ref: recommendation_results.recommendation_session_id > recommendation_sessions.recommendation_session_id [delete: cascade, update: cascade]
Ref: recommendation_results.product_id > products.product_id [delete: restrict, update: cascade]
```

---

## 8. Catatan Implementasi

1. Gunakan kode internal berbahasa Inggris untuk `skin_type_code`, `skin_concern_code`, dan `ingredient_code`, sedangkan tampilan UI dapat tetap menggunakan bahasa Indonesia.
2. Produk yang cocok untuk semua jenis kulit tidak perlu memakai kode `all`. Simpan produk tersebut ke semua jenis kulit melalui tabel `product_skin_types`.
3. Produk dengan skor akhir di bawah 40 tidak perlu disimpan ke tabel `recommendation_results`.
4. Kategori `uv_filter` tetap dipertahankan untuk mendukung informasi produk dan validasi jenis sunscreen.
5. Tabel relasi tidak menggunakan kolom ID terpisah karena kombinasi dua foreign key sudah cukup menjadi primary key.
6. Data `session_type`, `evaluated_product_id`, dan `evaluation_note` dapat ditambahkan kembali pada tahap pengembangan TA jika fitur evaluasi sunscreen sudah diimplementasikan.
7. Jika ingin menampilkan alasan rekomendasi yang lebih rinci pada masa depan, dapat ditambahkan tabel terpisah seperti `recommendation_reason_details`, tetapi tidak diperlukan pada prototipe.

---

## 9. Kesimpulan

Struktur tabel terbaru sudah sesuai untuk prototipe sistem rekomendasi sunscreen berbasis *Rule-Based Scoring*. Skema ini lebih sederhana dibandingkan rancangan lama karena hanya memuat fitur rekomendasi, tanpa fitur evaluasi produk lanjutan. Meskipun lebih ringkas, struktur ini tetap mendukung seluruh kebutuhan utama sistem, yaitu input jenis kulit, masalah kulit, aktivitas, preferensi tekstur, riwayat alergi, Indeks UV, filter SPF/PA, filter bahan yang dihindari, perhitungan skor, penalti, ranking, dan penyimpanan hasil rekomendasi.

Dengan struktur ini, sistem dapat dikembangkan secara lebih terarah untuk kebutuhan prototipe. Pada tahap pengembangan TA, fitur evaluasi sunscreen yang sudah dimiliki pengguna dapat ditambahkan kembali dengan menambahkan atribut atau tabel tambahan tanpa perlu mengubah struktur inti secara besar-besaran.
