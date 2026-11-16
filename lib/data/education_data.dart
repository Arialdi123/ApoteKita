/// Model artikel edukasi obat
class EducationArticle {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String content;
  final String datePublished;
  final String iconName; // nama icon untuk representasi visual

  const EducationArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.datePublished,
    required this.iconName,
  });
}

const List<EducationArticle> dummyArticles = [
  EducationArticle(
    id: 'art-001',
    title: 'Cara Menggunakan Obat dengan Benar',
    category: 'Panduan Obat',
    datePublished: '15 September 2026',
    iconName: 'medication',
    summary:
        'Mengetahui cara minum obat yang benar sangat penting untuk memastikan efektivitas pengobatan dan menghindari efek samping yang tidak diinginkan.',
    content: '''
Menggunakan obat dengan benar adalah kunci keberhasilan terapi. Banyak orang tidak menyadari bahwa cara minum obat yang salah dapat mengurangi efektivitasnya atau bahkan menimbulkan risiko.

**1. Baca Label dan Petunjuk**

Selalu baca label obat sebelum mengonsumsinya. Perhatikan:
- Nama obat dan kandungannya
- Dosis yang dianjurkan
- Waktu dan cara penggunaan
- Kontraindikasi dan peringatan
- Tanggal kedaluwarsa

**2. Ikuti Dosis yang Dianjurkan**

Jangan menambah atau mengurangi dosis tanpa saran dokter atau apoteker. Dosis berlebihan dapat berbahaya, sementara dosis kurang dapat membuat pengobatan tidak efektif.

**3. Perhatikan Waktu Minum Obat**

- "Sebelum makan" berarti 30 menit sebelum makan
- "Bersama makanan" berarti langsung saat atau setelah makan
- "Setelah makan" berarti 30–60 menit setelah makan

**4. Gunakan Air Putih**

Minumlah obat dengan segelas penuh air putih (minimal 200 ml) kecuali ada petunjuk lain. Hindari minum obat dengan teh, kopi, susu, atau jus jeruk karena dapat mempengaruhi penyerapan.

**5. Jangan Menghancurkan Sembarang Obat**

Tidak semua obat boleh dikunyah, dihancurkan, atau dibuka kapsulnya. Tablet salut enteric dan extended-release dirancang khusus untuk larut di bagian tertentu saluran cerna.

**6. Selesaikan Antibiotik**

Jika mendapat antibiotik, selalu selesaikan seluruh kursus pengobatan meskipun sudah merasa membaik. Menghentikan antibiotik lebih awal dapat menyebabkan resistensi bakteri.

**7. Simpan dengan Benar**

Simpan obat di tempat yang sesuai — biasanya sejuk, kering, dan terhindar dari cahaya langsung. Jauhkan dari jangkauan anak-anak.

Selalu konsultasikan dengan dokter atau apoteker jika ada pertanyaan tentang penggunaan obat Anda.
''',
  ),

  EducationArticle(
    id: 'art-002',
    title: 'Mengenal Obat Bebas dan Obat Bebas Terbatas',
    category: 'Jenis Obat',
    datePublished: '12 September 2026',
    iconName: 'local_pharmacy',
    summary:
        'Tahukah Anda perbedaan antara obat bebas dan obat bebas terbatas? Memahami perbedaan ini membantu Anda memilih obat yang tepat dan aman.',
    content: '''
Di Indonesia, obat diklasifikasikan berdasarkan tingkat pengawasan dan keamanannya. Dua kategori yang paling umum dijumpai adalah Obat Bebas dan Obat Bebas Terbatas.

**Obat Bebas (Lingkaran Hijau)**

Obat bebas adalah obat yang dapat dibeli tanpa resep dokter dan relatif aman untuk digunakan secara mandiri. Ditandai dengan logo lingkaran hijau pada kemasan.

Contoh: Paracetamol, Vitamin C, Antasida, Minyak Kayu Putih

Karakteristik:
- Efek samping minimal pada dosis normal
- Risiko penyalahgunaan rendah
- Tersedia di apotek, minimarket, dan warung

**Obat Bebas Terbatas (Lingkaran Biru)**

Obat bebas terbatas dapat dibeli tanpa resep dokter, namun memiliki tanda peringatan khusus. Ditandai dengan logo lingkaran biru pada kemasan.

Contoh: CTM (antihistamin), Pseudoefedrin, beberapa obat batuk

Karakteristik:
- Memiliki potensi efek samping yang lebih signifikan
- Harus memperhatikan peringatan pada kemasan
- Tersedia hanya di apotek

**Tanda Peringatan Obat Bebas Terbatas**

Terdapat 6 peringatan (P1–P6):
- P.1: Awas! Obat keras. Bacalah aturan pakainya.
- P.2: Awas! Obat keras. Hanya untuk kumur, jangan ditelan.
- Dan seterusnya sesuai cara penggunaan.

**Obat Keras dan Psikotropika**

Di luar obat bebas dan bebas terbatas, terdapat obat keras (harus resep dokter) dan psikotropika/narkotika yang memiliki pengawasan lebih ketat.

Selalu beli obat dari apotek resmi dan konsultasikan dengan apoteker jika ragu.
''',
  ),

  EducationArticle(
    id: 'art-003',
    title: 'Tips Menyimpan Obat yang Benar di Rumah',
    category: 'Panduan Obat',
    datePublished: '8 September 2026',
    iconName: 'home',
    summary:
        'Penyimpanan obat yang tidak tepat dapat mengurangi efektivitasnya atau bahkan membuatnya berbahaya. Pelajari cara menyimpan obat yang benar.',
    content: '''
Menyimpan obat dengan benar sama pentingnya dengan mengonsumsinya dengan benar. Kondisi penyimpanan yang tidak tepat dapat mengubah komposisi kimia obat dan mengurangi efektivitasnya.

**Prinsip Umum Penyimpanan Obat**

1. **Suhu ruangan (15–25°C):** Sebagian besar obat disimpan pada suhu ruangan yang sejuk
2. **Terhindar dari cahaya langsung:** Sinar UV dapat merusak banyak senyawa obat
3. **Tempat kering:** Kelembaban dapat mempercepat degradasi obat
4. **Terpisah dari jangkauan anak:** Gunakan laci atau lemari dengan kunci

**Kamar Mandi Bukan Tempat Ideal**

Meskipun banyak orang menyimpan obat di kotak P3K di kamar mandi, ini sebenarnya tidak ideal karena kamar mandi memiliki suhu dan kelembaban yang berubah-ubah.

**Obat yang Perlu Disimpan di Kulkas**

- Insulin dan beberapa produk biologis
- Suppositoria
- Beberapa sirup antibiotik yang sudah dilarutkan
- Tetes mata tertentu

Perhatikan: kulkas tidak sama dengan freezer. Obat tidak boleh dibekukan kecuali ada petunjuk khusus.

**Membuang Obat Kedaluwarsa**

Jangan membuang obat ke toilet atau wastafel. Cara yang benar:
1. Campurkan dengan bahan tidak menarik (ampas kopi, tanah)
2. Masukkan dalam wadah tertutup
3. Buang ke tempat sampah rumah tangga

Atau kembalikan ke apotek yang menerima pengembalian obat kedaluwarsa.

**Periksa Obat di Rumah Secara Berkala**

Setidaknya 2 kali setahun, periksa semua obat di rumah Anda:
- Cek tanggal kedaluwarsa
- Periksa perubahan warna, bau, atau tekstur
- Buang obat yang rusak meskipun belum kedaluwarsa
''',
  ),

  EducationArticle(
    id: 'art-004',
    title: 'Vitamin dan Suplemen: Manfaat dan Penggunaan yang Tepat',
    category: 'Suplemen',
    datePublished: '5 September 2026',
    iconName: 'health_and_safety',
    summary:
        'Vitamin dan suplemen bukan pengganti pola makan sehat. Pelajari kapan dan bagaimana menggunakannya dengan tepat untuk mendukung kesehatan.',
    content: '''
Vitamin dan suplemen semakin populer, namun banyak orang menggunakannya tanpa pemahaman yang cukup. Mari kita bahas fakta dan mitos seputar suplemen.

**Apakah Semua Orang Perlu Suplemen?**

Tidak. Orang yang mengonsumsi makanan beragam dan bergizi seimbang umumnya tidak memerlukan suplemen tambahan. Suplemen ditujukan untuk:
- Orang dengan defisiensi nutrisi yang terkonfirmasi
- Kondisi khusus (kehamilan, menyusui, lansia)
- Diet sangat terbatas (vegetarian ketat)
- Pemulihan dari penyakit tertentu

**Vitamin yang Larut Air vs. Larut Lemak**

*Larut Air (B kompleks, Vitamin C):*
- Tidak disimpan dalam tubuh dalam jumlah besar
- Kelebihan dikeluarkan melalui urin
- Perlu dikonsumsi rutin

*Larut Lemak (A, D, E, K):*
- Disimpan dalam jaringan lemak dan hati
- Dapat beracun jika berlebihan
- Tidak perlu dikonsumsi setiap hari

**Waktu Terbaik Minum Suplemen**

- Vitamin B dan C: Pagi hari (memberi energi)
- Vitamin D, E, K: Bersama makanan berlemak (meningkatkan penyerapan)
- Zinc dan zat besi: Tidak bersamaan (saling menghambat penyerapan)
- Kalsium dan zat besi: Berikan jarak konsumsi

**Tips Memilih Suplemen**

1. Cari produk dengan label BPOM yang jelas
2. Pilih merek dengan reputasi baik
3. Jangan tergiur klaim berlebihan
4. Konsultasikan dengan dokter atau apoteker
5. Lebih tidak selalu lebih baik — ikuti dosis anjuran

Ingat: makanan alami tetap menjadi sumber nutrisi terbaik.
''',
  ),

  EducationArticle(
    id: 'art-005',
    title: 'Mengenal Efek Samping Obat dan Cara Mengatasinya',
    category: 'Keamanan Obat',
    datePublished: '1 September 2026',
    iconName: 'warning',
    summary:
        'Setiap obat memiliki potensi efek samping. Pelajari cara mengenali, mencegah, dan merespons efek samping obat dengan tepat.',
    content: '''
Efek samping adalah respons tubuh yang tidak diinginkan terhadap suatu obat pada dosis normal. Memahami efek samping membantu Anda menggunakan obat dengan lebih aman.

**Jenis-jenis Efek Samping**

1. **Efek samping umum:** Terjadi pada banyak pengguna, biasanya ringan (mengantuk, mual, mulut kering)

2. **Efek samping jarang:** Terjadi pada <1% pengguna

3. **Efek samping serius:** Reaksi alergi berat (anafilaksis), kerusakan organ

**Faktor yang Mempengaruhi Efek Samping**

- Usia (anak-anak dan lansia lebih sensitif)
- Kondisi kesehatan yang sudah ada
- Dosis dan lama penggunaan
- Interaksi dengan obat lain
- Faktor genetik

**Gejala yang Harus Segera Ditindaklanjuti**

Segera hentikan obat dan cari bantuan medis jika mengalami:
- Sesak napas atau mengi
- Pembengkakan wajah, bibir, atau tenggorokan
- Ruam kulit yang menyebar cepat
- Detak jantung tidak teratur
- Kulit atau mata menguning (jaundice)
- Urin berwarna sangat gelap

**Cara Mengurangi Risiko Efek Samping**

1. Informasikan semua obat yang sedang dikonsumsi kepada dokter/apoteker
2. Beritahu riwayat alergi obat
3. Baca petunjuk penggunaan dengan seksama
4. Mulai dengan dosis terendah yang efektif
5. Jangan menghentikan obat secara mendadak (terutama kortikosteroid dan beberapa psikiatri)

**Melaporkan Efek Samping**

Di Indonesia, efek samping obat dapat dilaporkan ke BPOM melalui sistem e-MESO (electronic Monitoring of Adverse Drug Reactions).
''',
  ),

  EducationArticle(
    id: 'art-006',
    title: 'Antibiotik: Penggunaan yang Tepat untuk Mencegah Resistensi',
    category: 'Keamanan Obat',
    datePublished: '25 Agustus 2026',
    iconName: 'biotech',
    summary:
        'Resistensi antibiotik menjadi ancaman kesehatan global. Pelajari cara menggunakan antibiotik dengan benar untuk mencegah resistensi.',
    content: '''
Resistensi antibiotik (antimicrobial resistance/AMR) adalah kondisi di mana bakteri berkembang kemampuan untuk bertahan dari efek antibiotik. WHO menyebutnya sebagai salah satu ancaman kesehatan terbesar abad ini.

**Mengapa Resistensi Terjadi?**

Resistensi terjadi karena:
1. Penggunaan antibiotik yang tidak tepat (untuk infeksi virus)
2. Tidak menyelesaikan kursus antibiotik
3. Penggunaan antibiotik tanpa resep dokter
4. Penggunaan berlebihan di sektor peternakan

**Antibiotik Tidak Efektif untuk Virus**

Ini adalah kesalahpahaman paling umum. Antibiotik HANYA membunuh bakteri, bukan virus. Flu, pilek, COVID-19, dan sebagian besar batuk disebabkan oleh virus — tidak akan merespons antibiotik.

**Prinsip 5 Tepat Antibiotik**

1. **Tepat Indikasi:** Hanya untuk infeksi bakteri yang terkonfirmasi
2. **Tepat Obat:** Sesuai jenis bakteri penyebab infeksi
3. **Tepat Dosis:** Sesuai berat badan dan kondisi pasien
4. **Tepat Waktu:** Interval antar dosis yang benar
5. **Tepat Lama:** Selesaikan seluruh durasi pengobatan

**Dampak Resistensi Antibiotik**

- Infeksi yang sebelumnya mudah diobati menjadi berbahaya
- Diperlukan antibiotik yang lebih kuat dengan efek samping lebih besar
- Biaya pengobatan meningkat drastis
- Angka kematian akibat infeksi meningkat

**Yang Bisa Anda Lakukan**

- Gunakan antibiotik HANYA dengan resep dokter
- Selesaikan seluruh kursus meskipun sudah membaik
- Jangan berbagi antibiotik dengan orang lain
- Jangan menyimpan antibiotik untuk digunakan sendiri kemudian
''',
  ),

  EducationArticle(
    id: 'art-007',
    title: 'Interaksi Obat: Apa yang Perlu Anda Ketahui',
    category: 'Keamanan Obat',
    datePublished: '20 Agustus 2026',
    iconName: 'compare_arrows',
    summary:
        'Dua obat yang aman secara individual bisa berbahaya jika dikombinasikan. Pelajari dasar-dasar interaksi obat untuk keamanan Anda.',
    content: '''
Interaksi obat terjadi ketika satu obat mempengaruhi cara kerja obat lain. Ini bisa menyebabkan salah satu obat menjadi kurang efektif, lebih kuat dari yang seharusnya, atau menimbulkan efek yang tidak diharapkan.

**Jenis-jenis Interaksi Obat**

1. **Interaksi Farmakokinetik:** Satu obat mempengaruhi penyerapan, distribusi, metabolisme, atau ekskresi obat lain

2. **Interaksi Farmakodinamik:** Kedua obat bekerja pada target yang sama atau berinteraksi langsung

3. **Interaksi Fisikokimia:** Dua obat bereaksi secara kimia jika dicampur (relevan untuk injeksi IV)

**Contoh Interaksi yang Sering Terjadi**

- Warfarin + Aspirin → Risiko perdarahan meningkat
- Statin + Grapefruit → Peningkatan kadar statin, risiko kerusakan otot
- MAOI + Antidepresan lain → Sindrom serotonin yang berbahaya
- Antasida + Antibiotik tertentu → Penyerapan antibiotik berkurang

**Makanan yang Berinteraksi dengan Obat**

- Grapefruit (jeruk bali): Menghambat enzim metabolisme banyak obat
- Susu: Mengurangi penyerapan antibiotik tertentu
- Makanan tinggi vitamin K: Dapat mengurangi efek warfarin
- Alkohol: Berinteraksi dengan banyak obat (antihistamin, acetaminophen, dll.)

**Cara Menghindari Interaksi Berbahaya**

1. Selalu informasikan SEMUA obat yang dikonsumsi kepada dokter/apoteker
2. Termasuk obat bebas, suplemen, dan herbal
3. Gunakan satu apotek yang sama agar riwayat obat terpantau
4. Baca petunjuk interaksi di kemasan obat
5. Jangan ragu bertanya kepada apoteker

Ingat: fitur "Cek Interaksi" di ApoteKita ini hanya untuk tujuan edukasi dan bukan pengganti konsultasi profesional.
''',
  ),

  EducationArticle(
    id: 'art-008',
    title: 'Pentingnya Konsultasi dengan Apoteker',
    category: 'Edukasi Kesehatan',
    datePublished: '15 Agustus 2026',
    iconName: 'support_agent',
    summary:
        'Apoteker bukan hanya penjual obat. Mereka adalah tenaga kesehatan profesional yang dapat membantu Anda menggunakan obat dengan aman dan efektif.',
    content: '''
Apoteker adalah tenaga kesehatan yang memiliki keahlian khusus dalam obat-obatan. Sayangnya, peran apoteker sering diremehkan, padahal mereka dapat memberikan kontribusi besar dalam keamanan pengobatan Anda.

**Apa yang Bisa Dilakukan Apoteker?**

1. **Memeriksa kesesuaian resep:** Dosis, frekuensi, dan kesesuaian dengan kondisi pasien

2. **Mendeteksi interaksi obat:** Jika Anda mengonsumsi beberapa obat sekaligus

3. **Memberikan informasi penggunaan:** Cara minum, waktu, dan hal yang perlu dihindari

4. **Memberikan saran obat bebas:** Merekomendasikan obat yang tepat untuk gejala ringan

5. **Monitoring terapi:** Memantau efektivitas dan keamanan pengobatan jangka panjang

**Kapan Harus Bertanya kepada Apoteker?**

- Saat menerima resep baru, terutama jika sudah ada obat lain yang dikonsumsi
- Ketika ada gejala baru setelah mulai obat
- Jika mengalami efek samping yang mengganggu
- Saat membeli obat bebas untuk memastikan pilihan yang tepat
- Ketika ingin memilih suplemen atau vitamin

**Tips Berkonsultasi dengan Apoteker**

1. Bawa semua obat yang sedang dikonsumsi (termasuk suplemen)
2. Informasikan kondisi kesehatan yang dimiliki
3. Beritahu riwayat alergi obat
4. Jangan ragu bertanya sampai benar-benar paham
5. Minta penjelasan ulang jika ada yang kurang jelas

ApoteKita hadir untuk mendekatkan Anda dengan layanan apoteker terpercaya. Konsultasikan kebutuhan obat Anda melalui fitur Konsultasi di aplikasi kami.
''',
  ),
];
