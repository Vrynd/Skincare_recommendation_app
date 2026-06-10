# Transformasi Dataset Sunscreen Cleaned & Balanced ke Struktur Tabel

Dokumen ini digunakan sebagai panduan praktis untuk memindahkan data dari dataset **sunscreen cleaned & balanced 30 produk** ke tabel-tabel pada skema database prototipe sistem rekomendasi sunscreen.

Fokus dokumen ini adalah bagian yang diperlukan untuk pengisian tabel master dan tabel relasi, yaitu `products`, `skin_types`, `skin_concerns`, `ingredients`, `product_skin_types`, `product_skin_concerns`, dan `product_ingredients`.

> Catatan: data rekomendasi seperti `recommendation_sessions`, `recommendation_concerns`, `avoided_ingredients`, dan `recommendation_results` tidak diisi dari dataset awal. Tabel-tabel tersebut akan terisi ketika pengguna menjalankan fitur rekomendasi di aplikasi.

## 1. Ringkasan Distribusi Dataset

| Kategori | Saat Ini | Persentase | Target Ideal | Status |
|---|---|---|---|---|
| physical | 8 | 27% | 8-10 (25-30%) | Sesuai |
| chemical | 13 | 43% | 12-15 (40-50%) | Sesuai |
| hybrid | 9 | 30% | 8-10 (25-30%) | Sesuai |
| water resistant | 8 | 27% | 8-10 (25-30%) | Sesuai |
| non-comedogenic | 13 | 43% | 12-15 (40-50%) | Sesuai |

Distribusi di atas sudah mengikuti target yang disepakati, yaitu variasi *physical*, *chemical*, *hybrid*, *water resistant*, dan *non-comedogenic* agar data produk tidak terlalu berat pada satu jenis sunscreen saja.

## 2. Urutan Pengisian Data ke Database

Agar relasi tidak bermasalah, pengisian data disarankan dilakukan dengan urutan berikut:

1. Isi data master `skin_types`.
2. Isi data master `skin_concerns`.
3. Isi data master `ingredients`.
4. Isi data utama produk pada tabel `products`.
5. Isi relasi `product_skin_types`.
6. Isi relasi `product_skin_concerns`.
7. Isi relasi `product_ingredients`.

Tabel relasi sebaiknya diisi setelah tabel master selesai, karena tabel relasi membutuhkan ID dari tabel induk.

## 3. Data Master: `skin_types`

| skin_type_code | skin_type_name | description |
|---|---|---|
| normal | Normal | Kulit relatif seimbang, tidak terlalu berminyak atau kering. |
| oily | Berminyak | Kulit cenderung menghasilkan minyak berlebih. |
| dry | Kering | Kulit cenderung kering, kasar, atau kurang lembap. |
| combination | Kombinasi | Kulit memiliki area berminyak dan area normal/kering. |
| sensitive | Sensitif | Kulit mudah mengalami kemerahan, perih, atau iritasi. |

Label seperti `acne-prone`, `berjerawat`, `anak`, `keluarga`, atau `ibu hamil/menyusui` tidak dimasukkan sebagai jenis kulit karena tidak sesuai dengan standar input sistem.

## 4. Data Master: `skin_concerns`

| skin_concern_code | skin_concern_name | description |
|---|---|---|
| acne | Jerawat | Masalah kulit yang berkaitan dengan jerawat, komedo, atau kulit rentan berjerawat. |
| hyperpigmentation | Hiperpigmentasi/Noda Hitam/Kulit Kusam | Masalah kulit yang berkaitan dengan noda hitam, bekas jerawat, warna kulit tidak merata, atau kulit kusam. |
| sensitive_irritation | Sensitif/Iritasi | Masalah kulit yang berkaitan dengan kemerahan, iritasi, atau riwayat kulit mudah tidak cocok. |
| aging | Penuaan Dini | Masalah kulit yang berkaitan dengan tanda penuaan dini, seperti garis halus atau penurunan elastisitas kulit. |

Kulit kusam tidak dibuat sebagai kategori tersendiri. Pada dataset ini, kulit kusam dipetakan ke kategori `hyperpigmentation` karena berkaitan dengan tampilan kulit tidak merata, noda, atau kurang cerah.

## 5. Data Utama Produk: `products`

Kolom berikut dapat digunakan sebagai acuan pengisian tabel `products`. Kolom `is_active` diisi `true` untuk seluruh produk karena semua produk dalam dataset digunakan sebagai objek rekomendasi.

### Batch 1

| product_code | brand_name | product_name | bpom_number | spf | pa_grade | sunscreen_type | texture | finish | is_water_resistant | is_very_water_resistant | is_non_comedogenic | is_oil_free | is_active |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| S001 | Wardah | UV Shield Aqua Fresh Sunscreen Serum SPF50 PA++++ | NA18231701024 | 50 | PA++++ | chemical | watery | natural | false | false | false | false | true |
| S002 | Azarine | Hydrasoothe Sunscreen Gel SPF45 PA++++ | NA18221701516 | 45 | PA++++ | chemical | gel | natural | false | false | false | true | true |
| S003 | Skin1004 | Madagascar Centella Hyalu-Cica Water-Fit Sun Serum SPF50+ PA++++ | NA26221700106 | 50+ | PA++++ | chemical | serum | dewy | false | false | false | false | true |
| S004 | Biore | UV Aqua Rich Watery Essence SPF50+ PA++++ | NA54211700001 | 50+ | PA++++ | chemical | watery | natural | true | true | false | false | true |
| S005 | Carasun | Healthy Matte UV Protector SPF50+ PA++++ | NA18231701370 | 50+ | PA++++ | chemical | lotion | matte | false | false | true | false | true |
| S006 | ERHA | Perfect Shield Active Light Sunscreen SPF50+ PA++++ | NA18231701684 | 50+ | PA++++ | chemical | cream | natural | true | false | false | false | true |
| S007 | Somethinc | Holyshield UV Watery Sunscreen Gel SPF50+ PA++++ | NA18251701984 | 50+ | PA++++ | chemical | gel | natural | false | false | true | false | true |
| S008 | Nivea | Sun Face Serum Extra Protect Oil Control SPF50+ PA+++ | NA49211700003 | 50+ | PA+++ | chemical | serum | matte | false | false | true | false | true |
| S009 | Wardah | UV Shield Light Matte Sun Stick SPF50 PA++++ | NA18201700048 | 50 | PA++++ | chemical | stick | matte | true | false | false | false | true |
| S010 | Banana Boat | Sport Ultra SPF50+ | NA49221700006 | 50+ | PA+++ | chemical | lotion | natural | true | true | false | false | true |

### Batch 2

| product_code | brand_name | product_name | bpom_number | spf | pa_grade | sunscreen_type | texture | finish | is_water_resistant | is_very_water_resistant | is_non_comedogenic | is_oil_free | is_active |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| S011 | Skintific | 5X Ceramide Serum Sunscreen SPF50 PA++++ | NA11241700021 | 50+ | PA++++ | hybrid | serum | natural | false | false | false | false | true |
| S012 | Skin Aqua | UV Moisture Milk SPF50+ PA+++ | NA18130103390 | 50+ | PA+++ | hybrid | milk | natural | false | false | true | false | true |
| S013 | Somethinc | Copy Paste Tinted Sunscreen SPF40 PA++++ | NA18230301046 | 40 | PA++++ | hybrid | cream | dewy | false | false | true | false | true |
| S014 | The Originote | Ceramella Sunscreen SPF50 PA+++ | NA18221701412 | 50 | PA+++ | hybrid | cream | natural | false | false | false | false | true |
| S015 | Skin Aqua | UV Whitening Milk SPF50 PA++++ | NA18201700547 | 50 | PA++++ | hybrid | milk | natural | false | false | true | false | true |
| S016 | Skin Aqua | UV Mild Milk SPF50 PA++++ | NA18201700548 | 50 | PA++++ | hybrid | milk | natural | false | false | true | false | true |
| S017 | Skin Aqua | UV Tone Up Essence Lavender SPF50+ PA++++ | NA18191705830 | 50+ | PA++++ | hybrid | cream | tone_up | false | false | false | false | true |
| S018 | Facetology | Triple Care Sunscreen Oily & Acne SPF40 PA+++ | NA18241703027 | 40 | PA+++ | hybrid | lotion | matte | false | false | true | false | true |
| S019 | Anessa | Perfect UV Sunscreen Skincare Milk SPF50+ PA++++ | NA22231700025 | 50+ | PA++++ | hybrid | milk | natural | true | true | false | false | true |
| S020 | Neutrogena | Ultra Sheer Dry-Touch Sunscreen SPF50+ | NA49191705125 | 50+ | PA+++ | chemical | cream | matte | true | true | true | false | true |

### Batch 3

| product_code | brand_name | product_name | bpom_number | spf | pa_grade | sunscreen_type | texture | finish | is_water_resistant | is_very_water_resistant | is_non_comedogenic | is_oil_free | is_active |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| S021 | Acnes | Derma Care Gentle Mineral Sunscreen SPF50+ PA++++ | NA18231206404 | 50+ | PA++++ | physical | cream | natural | false | false | true | false | true |
| S022 | Labore | Sensitive Skin Care BiomeProtect Physical Sunscreen SPF50+ PA++++ | NA18211700506 | 50+ | PA++++ | physical | cream | natural | true | false | false | false | true |
| S023 | Dew It | Kids Daily Play Lotion SPF30 PA+++ | NA18241702391 | 30 | PA+++ | physical | lotion | natural | false | false | false | false | true |
| S024 | Wardah | UV Shield Physical Sunscreen Serum SPF50+ PA++++ | NA18241700027 | 50+ | PA++++ | physical | watery | natural | false | false | false | false | true |
| S025 | Dear Me Beauty | Skin Barrier Physical Sunscreen SPF50 PA++++ | NA18221701396 | 50 | PA++++ | physical | cream | natural | false | false | true | false | true |
| S026 | Amaterasun | Physical Sunscreen SPF50+ PA++++ | NA18241700130 | 50+ | PA++++ | physical | cream | natural | false | false | false | false | true |
| S027 | Amaterasun | 100% Physical Soothing Sunscreen SPF50+ PA++++ | NA18251702033 | 50+ | PA++++ | physical | cream | natural | false | false | true | false | true |
| S028 | Amaterasun | Pore Blurring Sunscreen SPF50+ PA++++ | NA18251701323 | 50+ | PA++++ | physical | cream | matte | false | false | true | false | true |
| S029 | La Roche-Posay | Anthelios UVMune 400 Anti-Dark Spots Fluid SPF50+ PA++++ | NC14241700023 | 50+ | PA++++ | chemical | serum | dewy | true | false | false | false | true |
| S030 | Wardah | UV Shield Airy Smooth Sunscreen Serum SPF50 PA++++ | NA18231701023 | 50 | PA++++ | chemical | serum | matte | false | false | false | false | true |

## 6. Data Master Ingredients: `ingredients`

Tabel berikut berisi daftar kandungan unik yang muncul pada dataset. Kode bahan (`ingredient_code`) dibuat dari nama bahan dengan format huruf kecil dan garis bawah agar lebih mudah digunakan pada kode program.

> Catatan penting: beberapa bahan memiliki fungsi ganda, misalnya sebagai `uv_filter` sekaligus bahan perhatian. Karena struktur tabel `ingredients` hanya memiliki satu kolom `category`, dokumen ini menggunakan kategori utama. Bahan yang berfungsi ganda tetap dapat digunakan pada proses filter alergi karena `avoided_ingredients` mereferensikan `ingredient_id`, bukan hanya kategori.

| ingredient_code | ingredient_name | category | catatan |
|---|---|---|---|
| 5x_ceramide | 5X Ceramide | active |  |
| alcohol | Alcohol | avoid |  |
| alcohol_denat | Alcohol Denat. | avoid |  |
| allantoin | Allantoin | active |  |
| aloe_vera | Aloe Vera | active |  |
| aquafused_technology | Aquafused Technology | active |  |
| arginine | Arginine | active |  |
| avobenzone | Avobenzone | uv_filter |  |
| avotriplex_technology | Avotriplex Technology | active |  |
| benzophenone_3 | Benzophenone-3 | uv_filter | fungsi ganda: avoid, uv_filter |
| bera_mineral | Bera Mineral | active |  |
| betaine | Betaine | active |  |
| bisabolol | Bisabolol | active |  |
| centella | Centella | active |  |
| centella_asiatica | Centella Asiatica | active |  |
| ceramide | Ceramide | active |  |
| ceramide_np | Ceramide NP | active |  |
| chemical_uv_filters | Chemical UV Filters | avoid |  |
| collagen | Collagen | active |  |
| dhhb | DHHB | uv_filter |  |
| dmdm_hydantoin | DMDM Hydantoin | avoid |  |
| diethylhexyl_butamido_triazone | Diethylhexyl Butamido Triazone | uv_filter |  |
| ethylhexyl_methoxycinnamate | Ethylhexyl Methoxycinnamate | uv_filter |  |
| ethylhexyl_salicylate | Ethylhexyl Salicylate | uv_filter |  |
| ethylhexyl_triazone | Ethylhexyl Triazone | uv_filter |  |
| fermented_ingredient | Fermented Ingredient | active |  |
| fine_strobe_pearl | Fine Strobe Pearl | active |  |
| flavour | Flavour | avoid |  |
| fragrance | Fragrance | avoid |  |
| geranium_oil | Geranium Oil | avoid |  |
| glycerin | Glycerin | active |  |
| green_tea | Green Tea | active |  |
| green_tea_extract | Green Tea Extract | active |  |
| heartleaf_extract | Heartleaf Extract | active |  |
| homosalate | Homosalate | uv_filter | fungsi ganda: avoid, uv_filter |
| hyaluronic_acid | Hyaluronic Acid | active |  |
| improved_hyaluronic_acid | Improved Hyaluronic Acid | active |  |
| intelligent_dna_guardian | Intelligent DNA Guardian | active |  |
| kaolin | Kaolin | active |  |
| l_carnitine | L-Carnitine | active |  |
| licorice_extract | Licorice Extract | active |  |
| mbbt | MBBT | uv_filter |  |
| melasyl | Melasyl | active |  |
| methylparaben | Methylparaben | avoid |  |
| mexoryl_400 | Mexoryl 400 | uv_filter | fungsi ganda: active, uv_filter |
| mexoryl_sx | Mexoryl SX | uv_filter |  |
| microbiome_technology | Microbiome Technology | active |  |
| mineral_filter_white_cast | Mineral Filter/White Cast | avoid |  |
| mugwort | Mugwort | active |  |
| niacinamide | Niacinamide | active | fungsi ganda: active, avoid |
| oat_extract | Oat Extract | active |  |
| octocrylene | Octocrylene | uv_filter | fungsi ganda: avoid, uv_filter |
| panthenol | Panthenol | active |  |
| paraben | Paraben | avoid |  |
| peptide_complex | Peptide Complex | active |  |
| phenoxyethanol | Phenoxyethanol | avoid |  |
| pigment_tint | Pigment/Tint | avoid |  |
| pigment_tone_up_ingredients | Pigment/Tone-Up Ingredients | avoid |  |
| propylparaben | Propylparaben | avoid |  |
| resveratrol | Resveratrol | active |  |
| retinol | Retinol | avoid |  |
| rice_extract | Rice Extract | active |  |
| royal_jelly_extract | Royal Jelly Extract | active |  |
| salicylic_acid | Salicylic Acid | active | fungsi ganda: active, avoid |
| sebum_absorber | Sebum Absorber | active |  |
| silica | Silica | active |  |
| skinboostdna | SkinBoostDNA | active |  |
| sunflower_sprout | Sunflower Sprout | active |  |
| tara_spinosa | Tara Spinosa | active |  |
| thermal_water | Thermal Water | active |  |
| tinosorb_m | Tinosorb M | uv_filter |  |
| tinosorb_s | Tinosorb S | uv_filter |  |
| titanium_dioxide | Titanium Dioxide | uv_filter | fungsi ganda: avoid, uv_filter |
| tocopherol | Tocopherol | active |  |
| tocopheryl_acetate | Tocopheryl Acetate | active |  |
| tranexamic_acid | Tranexamic Acid | active |  |
| trehalose | Trehalose | active |  |
| tremella | Tremella | active |  |
| uvinul_t_150 | Uvinul T 150 | uv_filter |  |
| vitamin_c | Vitamin C | active |  |
| vitamin_e | Vitamin E | active |  |
| zinc_oxide | Zinc Oxide | uv_filter |  |
| t_butyl_alcohol | t-Butyl Alcohol | avoid |  |

### 6.1 Bahan dengan Fungsi Ganda

| ingredient_name | kategori_di_dataset | kategori_disarankan |
|---|---|---|
| Benzophenone-3 | avoid, uv_filter | uv_filter |
| Homosalate | avoid, uv_filter | uv_filter |
| Mexoryl 400 | active, uv_filter | uv_filter |
| Niacinamide | active, avoid | active |
| Octocrylene | avoid, uv_filter | uv_filter |
| Salicylic Acid | active, avoid | active |
| Titanium Dioxide | avoid, uv_filter | uv_filter |
## 7. Relasi Produk dan Jenis Kulit: `product_skin_types`

Tabel ini menunjukkan pemetaan ringkas antara `product_code` dan `skin_type_code`. Saat memasukkan ke database, `product_code` digunakan untuk mencari `product_id`, sedangkan `skin_type_code` digunakan untuk mencari `skin_type_id`.

| product_code | skin_type_codes |
|---|---|
| S001 | normal; dry; combination |
| S002 | normal; oily; combination |
| S003 | normal; dry; combination; sensitive |
| S004 | normal; oily; combination |
| S005 | oily; combination |
| S006 | normal; oily; combination |
| S007 | normal; oily; combination |
| S008 | oily; combination |
| S009 | normal; oily; combination |
| S010 | normal; oily; combination |
| S011 | normal; dry; combination; sensitive |
| S012 | normal; oily; dry; combination; sensitive |
| S013 | normal; dry; combination |
| S014 | normal; dry; combination; sensitive |
| S015 | normal; oily; dry; combination; sensitive |
| S016 | normal; dry; sensitive |
| S017 | normal; dry; combination |
| S018 | oily; combination |
| S019 | normal; oily; combination |
| S020 | normal; oily; combination |
| S021 | normal; sensitive |
| S022 | normal; sensitive |
| S023 | normal; dry; sensitive |
| S024 | normal; sensitive |
| S025 | normal; dry; sensitive |
| S026 | normal; sensitive |
| S027 | normal; sensitive |
| S028 | normal; oily; combination |
| S029 | normal; sensitive |
| S030 | normal; oily; combination |

### 7.1 Format Relasi Baris per Baris

| product_code | skin_type_code |
|---|---|
| S001 | normal |
| S001 | dry |
| S001 | combination |
| S002 | normal |
| S002 | oily |
| S002 | combination |
| S003 | normal |
| S003 | dry |
| S003 | combination |
| S003 | sensitive |
| S004 | normal |
| S004 | oily |
| S004 | combination |
| S005 | oily |
| S005 | combination |
| S006 | normal |
| S006 | oily |
| S006 | combination |
| S007 | normal |
| S007 | oily |
| S007 | combination |
| S008 | oily |
| S008 | combination |
| S009 | normal |
| S009 | oily |
| S009 | combination |
| S010 | normal |
| S010 | oily |
| S010 | combination |
| S011 | normal |
| S011 | dry |
| S011 | combination |
| S011 | sensitive |
| S012 | normal |
| S012 | oily |
| S012 | dry |
| S012 | combination |
| S012 | sensitive |
| S013 | normal |
| S013 | dry |
| S013 | combination |
| S014 | normal |
| S014 | dry |
| S014 | combination |
| S014 | sensitive |
| S015 | normal |
| S015 | oily |
| S015 | dry |
| S015 | combination |
| S015 | sensitive |
| S016 | normal |
| S016 | dry |
| S016 | sensitive |
| S017 | normal |
| S017 | dry |
| S017 | combination |
| S018 | oily |
| S018 | combination |
| S019 | normal |
| S019 | oily |
| S019 | combination |
| S020 | normal |
| S020 | oily |
| S020 | combination |
| S021 | normal |
| S021 | sensitive |
| S022 | normal |
| S022 | sensitive |
| S023 | normal |
| S023 | dry |
| S023 | sensitive |
| S024 | normal |
| S024 | sensitive |
| S025 | normal |
| S025 | dry |
| S025 | sensitive |
| S026 | normal |
| S026 | sensitive |
| S027 | normal |
| S027 | sensitive |
| S028 | normal |
| S028 | oily |
| S028 | combination |
| S029 | normal |
| S029 | sensitive |
| S030 | normal |
| S030 | oily |
| S030 | combination |
## 8. Relasi Produk dan Masalah Kulit: `product_skin_concerns`

Tabel ini menunjukkan pemetaan antara `product_code` dan `skin_concern_code`. Masalah kulit sudah dibatasi pada empat kategori utama yang disepakati.

| product_code | skin_concern_codes |
|---|---|
| S001 | hyperpigmentation; aging; sensitive_irritation |
| S002 | acne; sensitive_irritation; aging |
| S003 | sensitive_irritation; hyperpigmentation; aging |
| S004 | aging; hyperpigmentation |
| S005 | acne; aging |
| S006 | aging; hyperpigmentation |
| S007 | aging; sensitive_irritation |
| S008 | acne; aging |
| S009 | aging; hyperpigmentation |
| S010 | aging |
| S011 | sensitive_irritation; aging |
| S012 | aging |
| S013 | hyperpigmentation; aging |
| S014 | sensitive_irritation; aging; hyperpigmentation |
| S015 | hyperpigmentation; aging |
| S016 | sensitive_irritation; aging |
| S017 | hyperpigmentation; aging |
| S018 | acne; sensitive_irritation |
| S019 | aging; hyperpigmentation |
| S020 | acne; aging |
| S021 | acne; sensitive_irritation; aging |
| S022 | sensitive_irritation; aging |
| S023 | sensitive_irritation; aging |
| S024 | sensitive_irritation; aging |
| S025 | acne; sensitive_irritation; aging |
| S026 | sensitive_irritation; aging |
| S027 | acne; sensitive_irritation; aging |
| S028 | acne; aging |
| S029 | hyperpigmentation; aging |
| S030 | aging; hyperpigmentation |

### 8.1 Format Relasi Baris per Baris

| product_code | skin_concern_code |
|---|---|
| S001 | hyperpigmentation |
| S001 | aging |
| S001 | sensitive_irritation |
| S002 | acne |
| S002 | sensitive_irritation |
| S002 | aging |
| S003 | sensitive_irritation |
| S003 | hyperpigmentation |
| S003 | aging |
| S004 | aging |
| S004 | hyperpigmentation |
| S005 | acne |
| S005 | aging |
| S006 | aging |
| S006 | hyperpigmentation |
| S007 | aging |
| S007 | sensitive_irritation |
| S008 | acne |
| S008 | aging |
| S009 | aging |
| S009 | hyperpigmentation |
| S010 | aging |
| S011 | sensitive_irritation |
| S011 | aging |
| S012 | aging |
| S013 | hyperpigmentation |
| S013 | aging |
| S014 | sensitive_irritation |
| S014 | aging |
| S014 | hyperpigmentation |
| S015 | hyperpigmentation |
| S015 | aging |
| S016 | sensitive_irritation |
| S016 | aging |
| S017 | hyperpigmentation |
| S017 | aging |
| S018 | acne |
| S018 | sensitive_irritation |
| S019 | aging |
| S019 | hyperpigmentation |
| S020 | acne |
| S020 | aging |
| S021 | acne |
| S021 | sensitive_irritation |
| S021 | aging |
| S022 | sensitive_irritation |
| S022 | aging |
| S023 | sensitive_irritation |
| S023 | aging |
| S024 | sensitive_irritation |
| S024 | aging |
| S025 | acne |
| S025 | sensitive_irritation |
| S025 | aging |
| S026 | sensitive_irritation |
| S026 | aging |
| S027 | acne |
| S027 | sensitive_irritation |
| S027 | aging |
| S028 | acne |
| S028 | aging |
| S029 | hyperpigmentation |
| S029 | aging |
| S030 | aging |
| S030 | hyperpigmentation |
## 9. Relasi Produk dan Kandungan: `product_ingredients`

Tabel ini berisi ringkasan kandungan per produk. Bagian `active` berisi kandungan utama, `uv_filter` berisi filter UV representatif, dan `avoid` berisi bahan yang perlu diperhatikan. Dataset tidak menyimpan seluruh komposisi produk agar database tidak membengkak.

| product_code | active | uv_filter | avoid |
|---|---|---|---|
| S001 | Bisabolol; Allantoin; Aquafused Technology | Ethylhexyl Methoxycinnamate; Avobenzone; Octocrylene; Tinosorb S | Homosalate; Octocrylene; Fragrance |
| S002 | Aloe Vera; Green Tea; Resveratrol | Ethylhexyl Methoxycinnamate; Avobenzone; Octocrylene | Octocrylene; Phenoxyethanol |
| S003 | Centella Asiatica; Hyaluronic Acid; Niacinamide | DHHB; Ethylhexyl Triazone; MBBT; Diethylhexyl Butamido Triazone | Niacinamide; t-Butyl Alcohol |
| S004 | Hyaluronic Acid; Royal Jelly Extract; Glycerin | Ethylhexyl Methoxycinnamate; Ethylhexyl Triazone; DHHB; Tinosorb S | Alcohol; Fragrance |
| S005 | Rice Extract; Trehalose; Kaolin | Avobenzone; Ethylhexyl Methoxycinnamate; Octocrylene | Octocrylene; DMDM Hydantoin; Phenoxyethanol |
| S006 | Tocopheryl Acetate; Arginine; Panthenol | DHHB; Ethylhexyl Salicylate; MBBT; Ethylhexyl Triazone | Chemical UV Filters; Phenoxyethanol |
| S007 | Sunflower Sprout; Tara Spinosa; Allantoin | Ethylhexyl Methoxycinnamate; Avobenzone; Octocrylene | Octocrylene; Phenoxyethanol; Flavour |
| S008 | L-Carnitine; Licorice Extract; Tocopheryl Acetate | Homosalate; Avobenzone; Ethylhexyl Salicylate; Octocrylene | Alcohol Denat.; Homosalate; Octocrylene |
| S009 | Vitamin E; Sebum Absorber | Octocrylene; Homosalate; Tinosorb S; Avobenzone | Octocrylene; Homosalate; Fragrance |
| S010 | Avotriplex Technology; Aloe Vera; Tocopheryl Acetate | Octocrylene; Benzophenone-3; Avobenzone | Benzophenone-3; Octocrylene; Fragrance |
| S011 | 5X Ceramide; Hyaluronic Acid; Centella Asiatica | Tinosorb S; Tinosorb M | Phenoxyethanol; Chemical UV Filters |
| S012 | Improved Hyaluronic Acid; Collagen | Zinc Oxide; Ethylhexyl Methoxycinnamate; DHHB | Methylparaben; Propylparaben |
| S013 | Hyaluronic Acid; Betaine; Allantoin | Titanium Dioxide; Ethylhexyl Methoxycinnamate | Titanium Dioxide; Pigment/Tint; Phenoxyethanol |
| S014 | Ceramide; Tremella; Niacinamide | Ethylhexyl Methoxycinnamate; Octocrylene; Tinosorb S; Zinc Oxide | Octocrylene; Phenoxyethanol; Retinol |
| S015 | Improved Hyaluronic Acid; Tranexamic Acid | Zinc Oxide; Ethylhexyl Methoxycinnamate; DHHB | Paraben; Chemical UV Filters |
| S016 | Improved Hyaluronic Acid; Vitamin E; Allantoin | Zinc Oxide; Ethylhexyl Methoxycinnamate; DHHB | Paraben; Chemical UV Filters |
| S017 | Hyaluronic Acid; Vitamin C; Fine Strobe Pearl | Zinc Oxide; Ethylhexyl Methoxycinnamate; DHHB | Pigment/Tone-Up Ingredients; Fragrance |
| S018 | Mugwort; Centella Asiatica; Salicylic Acid | Titanium Dioxide; Ethylhexyl Methoxycinnamate; Avobenzone; Tinosorb S | Salicylic Acid; Octocrylene; Phenoxyethanol |
| S019 | Glycerin; Green Tea Extract; Hyaluronic Acid | Zinc Oxide; Octocrylene; Ethylhexyl Salicylate; Titanium Dioxide | Alcohol; Octocrylene; Fragrance |
| S020 | Tocopheryl Acetate; Silica | Homosalate; Benzophenone-3; Octocrylene; Avobenzone | Benzophenone-3; Octocrylene; Fragrance |
| S021 | Allantoin; Panthenol; Glycerin | Zinc Oxide; Titanium Dioxide | Mineral Filter/White Cast |
| S022 | Microbiome Technology; Panthenol; Bisabolol | Zinc Oxide; Titanium Dioxide | Mineral Filter/White Cast |
| S023 | Aloe Vera; Oat Extract; Panthenol | Zinc Oxide; Titanium Dioxide | Geranium Oil; Phenoxyethanol |
| S024 | Bisabolol; Oat Extract; Green Tea | Zinc Oxide | Mineral Filter/White Cast |
| S025 | Ceramide; Aloe Vera; Fermented Ingredient | Zinc Oxide; Titanium Dioxide | Mineral Filter/White Cast |
| S026 | Heartleaf Extract; Intelligent DNA Guardian; Tocopherol | Zinc Oxide | Mineral Filter/White Cast |
| S027 | Niacinamide; Panthenol; Ceramide NP | Zinc Oxide | Mineral Filter/White Cast |
| S028 | Peptide Complex; Hyaluronic Acid; Panthenol | Zinc Oxide | Phenoxyethanol; Mineral Filter/White Cast |
| S029 | Mexoryl 400; Melasyl; Thermal Water | Mexoryl 400; Mexoryl SX; Uvinul T 150; Tinosorb S | Alcohol Denat.; Fragrance |
| S030 | Centella; Bera Mineral; SkinBoostDNA | Ethylhexyl Methoxycinnamate; Octocrylene; Avobenzone | Octocrylene; Fragrance; Phenoxyethanol |

### 9.1 Format Relasi Baris per Baris

Format berikut lebih dekat dengan struktur tabel `product_ingredients`. Saat input ke database, `product_code` digunakan untuk mencari `product_id`, sedangkan `ingredient_code` digunakan untuk mencari `ingredient_id`.

| product_code | ingredient_code | dataset_category | is_key_ingredient |
|---|---|---|---|
| S001 | bisabolol | active | true |
| S001 | allantoin | active | true |
| S001 | aquafused_technology | active | true |
| S001 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S001 | avobenzone | uv_filter | false |
| S001 | octocrylene | uv_filter | false |
| S001 | tinosorb_s | uv_filter | false |
| S001 | homosalate | avoid | false |
| S001 | octocrylene | avoid | false |
| S001 | fragrance | avoid | false |
| S002 | aloe_vera | active | true |
| S002 | green_tea | active | true |
| S002 | resveratrol | active | true |
| S002 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S002 | avobenzone | uv_filter | false |
| S002 | octocrylene | uv_filter | false |
| S002 | octocrylene | avoid | false |
| S002 | phenoxyethanol | avoid | false |
| S003 | centella_asiatica | active | true |
| S003 | hyaluronic_acid | active | true |
| S003 | niacinamide | active | true |
| S003 | dhhb | uv_filter | false |
| S003 | ethylhexyl_triazone | uv_filter | false |
| S003 | mbbt | uv_filter | false |
| S003 | diethylhexyl_butamido_triazone | uv_filter | false |
| S003 | niacinamide | avoid | false |
| S003 | t_butyl_alcohol | avoid | false |
| S004 | hyaluronic_acid | active | true |
| S004 | royal_jelly_extract | active | true |
| S004 | glycerin | active | true |
| S004 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S004 | ethylhexyl_triazone | uv_filter | false |
| S004 | dhhb | uv_filter | false |
| S004 | tinosorb_s | uv_filter | false |
| S004 | alcohol | avoid | false |
| S004 | fragrance | avoid | false |
| S005 | rice_extract | active | true |
| S005 | trehalose | active | true |
| S005 | kaolin | active | true |
| S005 | avobenzone | uv_filter | false |
| S005 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S005 | octocrylene | uv_filter | false |
| S005 | octocrylene | avoid | false |
| S005 | dmdm_hydantoin | avoid | false |
| S005 | phenoxyethanol | avoid | false |
| S006 | tocopheryl_acetate | active | true |
| S006 | arginine | active | true |
| S006 | panthenol | active | true |
| S006 | dhhb | uv_filter | false |
| S006 | ethylhexyl_salicylate | uv_filter | false |
| S006 | mbbt | uv_filter | false |
| S006 | ethylhexyl_triazone | uv_filter | false |
| S006 | chemical_uv_filters | avoid | false |
| S006 | phenoxyethanol | avoid | false |
| S007 | sunflower_sprout | active | true |
| S007 | tara_spinosa | active | true |
| S007 | allantoin | active | true |
| S007 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S007 | avobenzone | uv_filter | false |
| S007 | octocrylene | uv_filter | false |
| S007 | octocrylene | avoid | false |
| S007 | phenoxyethanol | avoid | false |
| S007 | flavour | avoid | false |
| S008 | l_carnitine | active | true |
| S008 | licorice_extract | active | true |
| S008 | tocopheryl_acetate | active | true |
| S008 | homosalate | uv_filter | false |
| S008 | avobenzone | uv_filter | false |
| S008 | ethylhexyl_salicylate | uv_filter | false |
| S008 | octocrylene | uv_filter | false |
| S008 | alcohol_denat | avoid | false |
| S008 | homosalate | avoid | false |
| S008 | octocrylene | avoid | false |
| S009 | vitamin_e | active | true |
| S009 | sebum_absorber | active | true |
| S009 | octocrylene | uv_filter | false |
| S009 | homosalate | uv_filter | false |
| S009 | tinosorb_s | uv_filter | false |
| S009 | avobenzone | uv_filter | false |
| S009 | octocrylene | avoid | false |
| S009 | homosalate | avoid | false |
| S009 | fragrance | avoid | false |
| S010 | avotriplex_technology | active | true |
| S010 | aloe_vera | active | true |
| S010 | tocopheryl_acetate | active | true |
| S010 | octocrylene | uv_filter | false |
| S010 | benzophenone_3 | uv_filter | false |
| S010 | avobenzone | uv_filter | false |
| S010 | benzophenone_3 | avoid | false |
| S010 | octocrylene | avoid | false |
| S010 | fragrance | avoid | false |
| S011 | 5x_ceramide | active | true |
| S011 | hyaluronic_acid | active | true |
| S011 | centella_asiatica | active | true |
| S011 | tinosorb_s | uv_filter | false |
| S011 | tinosorb_m | uv_filter | false |
| S011 | phenoxyethanol | avoid | false |
| S011 | chemical_uv_filters | avoid | false |
| S012 | improved_hyaluronic_acid | active | true |
| S012 | collagen | active | true |
| S012 | zinc_oxide | uv_filter | false |
| S012 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S012 | dhhb | uv_filter | false |
| S012 | methylparaben | avoid | false |
| S012 | propylparaben | avoid | false |
| S013 | hyaluronic_acid | active | true |
| S013 | betaine | active | true |
| S013 | allantoin | active | true |
| S013 | titanium_dioxide | uv_filter | false |
| S013 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S013 | titanium_dioxide | avoid | false |
| S013 | pigment_tint | avoid | false |
| S013 | phenoxyethanol | avoid | false |
| S014 | ceramide | active | true |
| S014 | tremella | active | true |
| S014 | niacinamide | active | true |
| S014 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S014 | octocrylene | uv_filter | false |
| S014 | tinosorb_s | uv_filter | false |
| S014 | zinc_oxide | uv_filter | false |
| S014 | octocrylene | avoid | false |
| S014 | phenoxyethanol | avoid | false |
| S014 | retinol | avoid | false |
| S015 | improved_hyaluronic_acid | active | true |
| S015 | tranexamic_acid | active | true |
| S015 | zinc_oxide | uv_filter | false |
| S015 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S015 | dhhb | uv_filter | false |
| S015 | paraben | avoid | false |
| S015 | chemical_uv_filters | avoid | false |
| S016 | improved_hyaluronic_acid | active | true |
| S016 | vitamin_e | active | true |
| S016 | allantoin | active | true |
| S016 | zinc_oxide | uv_filter | false |
| S016 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S016 | dhhb | uv_filter | false |
| S016 | paraben | avoid | false |
| S016 | chemical_uv_filters | avoid | false |
| S017 | hyaluronic_acid | active | true |
| S017 | vitamin_c | active | true |
| S017 | fine_strobe_pearl | active | true |
| S017 | zinc_oxide | uv_filter | false |
| S017 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S017 | dhhb | uv_filter | false |
| S017 | pigment_tone_up_ingredients | avoid | false |
| S017 | fragrance | avoid | false |
| S018 | mugwort | active | true |
| S018 | centella_asiatica | active | true |
| S018 | salicylic_acid | active | true |
| S018 | titanium_dioxide | uv_filter | false |
| S018 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S018 | avobenzone | uv_filter | false |
| S018 | tinosorb_s | uv_filter | false |
| S018 | salicylic_acid | avoid | false |
| S018 | octocrylene | avoid | false |
| S018 | phenoxyethanol | avoid | false |
| S019 | glycerin | active | true |
| S019 | green_tea_extract | active | true |
| S019 | hyaluronic_acid | active | true |
| S019 | zinc_oxide | uv_filter | false |
| S019 | octocrylene | uv_filter | false |
| S019 | ethylhexyl_salicylate | uv_filter | false |
| S019 | titanium_dioxide | uv_filter | false |
| S019 | alcohol | avoid | false |
| S019 | octocrylene | avoid | false |
| S019 | fragrance | avoid | false |
| S020 | tocopheryl_acetate | active | true |
| S020 | silica | active | true |
| S020 | homosalate | uv_filter | false |
| S020 | benzophenone_3 | uv_filter | false |
| S020 | octocrylene | uv_filter | false |
| S020 | avobenzone | uv_filter | false |
| S020 | benzophenone_3 | avoid | false |
| S020 | octocrylene | avoid | false |
| S020 | fragrance | avoid | false |
| S021 | allantoin | active | true |
| S021 | panthenol | active | true |
| S021 | glycerin | active | true |
| S021 | zinc_oxide | uv_filter | false |
| S021 | titanium_dioxide | uv_filter | false |
| S021 | mineral_filter_white_cast | avoid | false |
| S022 | microbiome_technology | active | true |
| S022 | panthenol | active | true |
| S022 | bisabolol | active | true |
| S022 | zinc_oxide | uv_filter | false |
| S022 | titanium_dioxide | uv_filter | false |
| S022 | mineral_filter_white_cast | avoid | false |
| S023 | aloe_vera | active | true |
| S023 | oat_extract | active | true |
| S023 | panthenol | active | true |
| S023 | zinc_oxide | uv_filter | false |
| S023 | titanium_dioxide | uv_filter | false |
| S023 | geranium_oil | avoid | false |
| S023 | phenoxyethanol | avoid | false |
| S024 | bisabolol | active | true |
| S024 | oat_extract | active | true |
| S024 | green_tea | active | true |
| S024 | zinc_oxide | uv_filter | false |
| S024 | mineral_filter_white_cast | avoid | false |
| S025 | ceramide | active | true |
| S025 | aloe_vera | active | true |
| S025 | fermented_ingredient | active | true |
| S025 | zinc_oxide | uv_filter | false |
| S025 | titanium_dioxide | uv_filter | false |
| S025 | mineral_filter_white_cast | avoid | false |
| S026 | heartleaf_extract | active | true |
| S026 | intelligent_dna_guardian | active | true |
| S026 | tocopherol | active | true |
| S026 | zinc_oxide | uv_filter | false |
| S026 | mineral_filter_white_cast | avoid | false |
| S027 | niacinamide | active | true |
| S027 | panthenol | active | true |
| S027 | ceramide_np | active | true |
| S027 | zinc_oxide | uv_filter | false |
| S027 | mineral_filter_white_cast | avoid | false |
| S028 | peptide_complex | active | true |
| S028 | hyaluronic_acid | active | true |
| S028 | panthenol | active | true |
| S028 | zinc_oxide | uv_filter | false |
| S028 | phenoxyethanol | avoid | false |
| S028 | mineral_filter_white_cast | avoid | false |
| S029 | mexoryl_400 | active | true |
| S029 | melasyl | active | true |
| S029 | thermal_water | active | true |
| S029 | mexoryl_400 | uv_filter | false |
| S029 | mexoryl_sx | uv_filter | false |
| S029 | uvinul_t_150 | uv_filter | false |
| S029 | tinosorb_s | uv_filter | false |
| S029 | alcohol_denat | avoid | false |
| S029 | fragrance | avoid | false |
| S030 | centella | active | true |
| S030 | bera_mineral | active | true |
| S030 | skinboostdna | active | true |
| S030 | ethylhexyl_methoxycinnamate | uv_filter | false |
| S030 | octocrylene | uv_filter | false |
| S030 | avobenzone | uv_filter | false |
| S030 | octocrylene | avoid | false |
| S030 | fragrance | avoid | false |
| S030 | phenoxyethanol | avoid | false |
## 10. Catatan Mapping ke Tabel Rekomendasi

Dataset ini **tidak langsung mengisi** tabel berikut:

- `recommendation_sessions`
- `recommendation_concerns`
- `avoided_ingredients`
- `recommendation_results`

Tabel tersebut akan terisi ketika pengguna mengisi form rekomendasi pada aplikasi. Dengan demikian, dataset awal hanya digunakan sebagai data produk dan data master untuk proses *Rule-Based Scoring*.

## 11. Catatan Validasi Dataset

| Validasi | Hasil |
|---|---|
| Jumlah produk | 30 |
| Physical | 8 |
| Chemical | 13 |
| Hybrid | 9 |
| Water resistant | 8 |
| Non-comedogenic | 13 |
| Jenis kulit di luar standar | 0 |
| Masalah kulit di luar standar | 0 |
| Baris product_ingredients | 239 |
## 12. Kesimpulan

Dataset ini sudah dapat digunakan sebagai data awal sistem rekomendasi sunscreen karena kategori jenis kulit, masalah kulit, jenis sunscreen, tekstur, hasil akhir, dan kandungan sudah distandarkan. Produk juga sudah dibagi ke dalam 30 data yang seimbang, sehingga proses *hard filter*, *scoring*, dan ranking dapat berjalan lebih konsisten.
