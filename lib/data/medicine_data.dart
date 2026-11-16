import '../models/medicine.dart';

/// Dummy data obat untuk testing UI Phase 2.
/// Nanti mudah diganti dengan panggilan REST API di MedicineService.
const List<Medicine> dummyMedicines = [
  // ─── Obat Demam ─────────────────────────────────────────────────────────────
  Medicine(
    id: 'med-001',
    name: 'Paracetamol 500 mg',
    category: MedicineCategory.obatDemam,
    price: 5000,
    stock: 150,
    imageIcon: 'medication',
    description:
        'Paracetamol adalah obat analgesik dan antipiretik yang digunakan untuk meredakan nyeri ringan hingga sedang dan menurunkan demam. Merupakan salah satu obat yang paling umum dan aman digunakan.',
    indication:
        'Demam, sakit kepala, nyeri otot, nyeri gigi, nyeri haid, nyeri punggung.',
    ingredients: 'Paracetamol 500 mg',
    dosage:
        'Dewasa & anak >12 tahun: 1–2 tablet, 3–4 kali sehari. Jarak antar dosis minimal 4 jam. Tidak lebih dari 8 tablet per hari.',
    sideEffects:
        'Umumnya ditoleransi dengan baik. Jarang terjadi: reaksi alergi, ruam kulit, kerusakan hati (pada dosis berlebih).',
    warning:
        'Jangan melebihi dosis yang dianjurkan. Hindari penggunaan bersama alkohol. Hati-hati pada pasien dengan gangguan hati atau ginjal. Konsultasikan dengan dokter jika demam >3 hari.',
    keywords: ['paracetamol', 'demam', 'panas', 'sakit kepala', 'nyeri'],
  ),

  Medicine(
    id: 'med-002',
    name: 'Ibuprofen 400 mg',
    category: MedicineCategory.obatDemam,
    price: 8000,
    stock: 80,
    imageIcon: 'medication_liquid',
    description:
        'Ibuprofen adalah obat anti-inflamasi nonsteroid (NSAID) yang digunakan untuk meredakan nyeri, peradangan, dan demam. Bekerja dengan menghambat enzim siklooksigenase (COX).',
    indication:
        'Nyeri ringan hingga sedang, demam, nyeri sendi, nyeri otot, sakit kepala, nyeri gigi.',
    ingredients: 'Ibuprofen 400 mg',
    dosage:
        'Dewasa: 1 tablet 3 kali sehari setelah makan. Anak 6–12 tahun: sesuai petunjuk dokter.',
    sideEffects:
        'Gangguan saluran cerna (mual, nyeri perut), pusing, sakit kepala. Jarang: tukak lambung, reaksi alergi.',
    warning:
        'Diminum bersama makanan untuk mengurangi iritasi lambung. Tidak dianjurkan untuk ibu hamil trimester 3. Hindari jika memiliki riwayat tukak lambung.',
    keywords: ['ibuprofen', 'demam', 'nyeri', 'radang', 'NSAID'],
  ),

  // ─── Obat Batuk ─────────────────────────────────────────────────────────────
  Medicine(
    id: 'med-003',
    name: 'OBH Combi Batuk Berdahak',
    category: MedicineCategory.obatBatuk,
    price: 22000,
    stock: 60,
    imageIcon: 'local_pharmacy',
    description:
        'OBH Combi adalah obat batuk kombinasi yang mengandung ekspektoran untuk mengencerkan dahak dan memudahkan pengeluarannya dari saluran napas.',
    indication: 'Batuk berdahak, batuk produktif, bronkitis ringan.',
    ingredients:
        'Guaifenesin 100 mg, Bromhexine HCl 4 mg, Chlorpheniramine Maleate 1 mg per 5 ml.',
    dosage:
        'Dewasa: 10 ml (2 sendok takar), 3 kali sehari. Anak 6–12 tahun: 5 ml, 3 kali sehari.',
    sideEffects:
        'Mengantuk, mulut kering, gangguan saluran cerna ringan. Jangan mengemudi setelah minum obat ini.',
    warning:
        'Mengandung antihistamin yang dapat menyebabkan kantuk. Hati-hati pada penderita hipertensi, glaukoma, dan hipertrofi prostat.',
    keywords: ['batuk', 'dahak', 'ekspektoran', 'OBH', 'bronkitis'],
  ),

  Medicine(
    id: 'med-004',
    name: 'Woods Antitusive Syrup',
    category: MedicineCategory.obatBatuk,
    price: 28000,
    stock: 45,
    imageIcon: 'local_pharmacy',
    description:
        'Obat batuk kering yang bekerja menekan refleks batuk. Cocok untuk batuk tidak berdahak yang mengganggu aktivitas dan tidur.',
    indication: 'Batuk kering, batuk tidak produktif, batuk akibat iritasi.',
    ingredients: 'Dextromethorphan HBr 10 mg, Diphenhydramine HCl 12.5 mg per 5 ml.',
    dosage:
        'Dewasa: 10 ml, 3–4 kali sehari. Anak 6–12 tahun: 5 ml, 3–4 kali sehari.',
    sideEffects: 'Kantuk, pusing, mulut kering, konstipasi.',
    warning:
        'Tidak untuk batuk berdahak. Dapat menyebabkan kantuk berat. Hindari alkohol.',
    keywords: ['batuk kering', 'antitusive', 'woods', 'batuk'],
  ),

  // ─── Obat Flu ────────────────────────────────────────────────────────────────
  Medicine(
    id: 'med-005',
    name: 'Decolgen Flu & Batuk',
    category: MedicineCategory.obatFlu,
    price: 15000,
    stock: 100,
    imageIcon: 'medical_services',
    description:
        'Decolgen adalah obat kombinasi untuk mengatasi gejala flu seperti pilek, hidung tersumbat, bersin, demam, dan sakit kepala secara bersamaan.',
    indication:
        'Flu, pilek, hidung tersumbat, bersin, sakit kepala akibat flu, demam ringan.',
    ingredients:
        'Paracetamol 500 mg, Pseudoephedrine HCl 30 mg, Chlorpheniramine Maleate 2 mg.',
    dosage: 'Dewasa: 1 tablet, 3 kali sehari.',
    sideEffects: 'Kantuk, mulut kering, palpitasi, insomnia, pusing.',
    warning:
        'Tidak untuk penderita hipertensi, penyakit jantung, diabetes, atau hipertiroid. Tidak untuk ibu hamil dan menyusui tanpa konsultasi dokter.',
    keywords: ['flu', 'pilek', 'hidung tersumbat', 'bersin', 'decolgen'],
  ),

  Medicine(
    id: 'med-006',
    name: 'Rhinofed Tablet',
    category: MedicineCategory.obatFlu,
    price: 12000,
    stock: 75,
    imageIcon: 'medical_services',
    description:
        'Rhinofed mengandung pseudoefedrin sebagai dekongestan dan triprolidine sebagai antihistamin untuk mengatasi gejala alergi dan flu.',
    indication:
        'Rinitis alergi, sinusitis, hidung tersumbat, bersin-bersin, mata berair.',
    ingredients: 'Triprolidine HCl 2.5 mg, Pseudoephedrine HCl 60 mg.',
    dosage: 'Dewasa: 1 tablet, 3 kali sehari.',
    sideEffects: 'Kantuk, mulut kering, pusing, jantung berdebar.',
    warning:
        'Hindari mengemudi. Tidak untuk penderita hipertensi berat. Konsultasikan dengan dokter.',
    keywords: ['flu', 'alergi', 'rhinitis', 'bersin', 'rhinofed'],
  ),

  // ─── Vitamin ─────────────────────────────────────────────────────────────────
  Medicine(
    id: 'med-007',
    name: 'Vitamin C 1000 mg',
    category: MedicineCategory.vitamin,
    price: 25000,
    stock: 200,
    imageIcon: 'health_and_safety',
    description:
        'Vitamin C (asam askorbat) adalah antioksidan penting yang berperan dalam pembentukan kolagen, meningkatkan daya tahan tubuh, dan membantu penyerapan zat besi.',
    indication:
        'Suplemen vitamin C, mencegah dan mengatasi kekurangan vitamin C (skorbut), meningkatkan imunitas.',
    ingredients: 'Ascorbic Acid (Vitamin C) 1000 mg.',
    dosage:
        'Dewasa: 1 tablet per hari setelah makan, atau sesuai petunjuk dokter.',
    sideEffects:
        'Dosis tinggi dapat menyebabkan diare, mual, kram perut, nyeri kepala.',
    warning:
        'Dosis >2000 mg/hari tidak dianjurkan. Hati-hati pada pasien batu ginjal.',
    keywords: ['vitamin C', 'imunitas', 'antioksidan', 'asam askorbat'],
  ),

  Medicine(
    id: 'med-008',
    name: 'Vitamin D3 1000 IU',
    category: MedicineCategory.vitamin,
    price: 35000,
    stock: 120,
    imageIcon: 'health_and_safety',
    description:
        'Vitamin D3 (cholecalciferol) penting untuk kesehatan tulang, gigi, dan sistem imun. Membantu penyerapan kalsium dan fosfor dari makanan.',
    indication:
        'Kekurangan vitamin D, pencegahan osteoporosis, meningkatkan imunitas, kesehatan tulang dan gigi.',
    ingredients: 'Cholecalciferol (Vitamin D3) 1000 IU.',
    dosage: 'Dewasa: 1 kapsul per hari bersama makanan berlemak.',
    sideEffects:
        'Jarang terjadi pada dosis normal. Dosis berlebih: mual, lemah, nyeri tulang.',
    warning:
        'Jangan melebihi dosis anjuran. Konsultasikan dengan dokter jika memiliki gangguan ginjal.',
    keywords: ['vitamin D', 'tulang', 'kalsium', 'imunitas', 'cholecalciferol'],
  ),

  Medicine(
    id: 'med-009',
    name: 'Vitamin B Kompleks',
    category: MedicineCategory.vitamin,
    price: 18000,
    stock: 160,
    imageIcon: 'health_and_safety',
    description:
        'Kombinasi vitamin B yang esensial untuk metabolisme energi, fungsi saraf, pembentukan sel darah merah, dan kesehatan kulit.',
    indication:
        'Kekurangan vitamin B, kelelahan, neurologi perifer, mendukung metabolisme energi.',
    ingredients:
        'Vitamin B1 (Thiamine) 100 mg, B2 (Riboflavin) 5 mg, B3 (Niacinamide) 50 mg, B5 10 mg, B6 10 mg, B12 5 mcg.',
    dosage: 'Dewasa: 1 tablet per hari setelah makan.',
    sideEffects:
        'Urin berwarna kuning (dari B2), jarang gangguan lambung ringan.',
    warning: 'Aman untuk penggunaan jangka panjang pada dosis yang dianjurkan.',
    keywords: ['vitamin B', 'energi', 'saraf', 'B kompleks'],
  ),

  // ─── Suplemen ─────────────────────────────────────────────────────────────────
  Medicine(
    id: 'med-010',
    name: 'Zinc 10 mg',
    category: MedicineCategory.suplemen,
    price: 30000,
    stock: 90,
    imageIcon: 'spa',
    description:
        'Zinc (seng) adalah mineral esensial yang berperan dalam imunitas, penyembuhan luka, pertumbuhan, dan metabolisme. Penting untuk produksi hormon dan enzim.',
    indication:
        'Kekurangan zinc, mendukung imunitas, membantu penyembuhan luka, mendukung pertumbuhan anak.',
    ingredients: 'Zinc Sulfate setara Zinc Elemental 10 mg.',
    dosage: 'Dewasa: 1 tablet per hari setelah makan.',
    sideEffects: 'Mual, gangguan pencernaan (terutama jika diminum saat perut kosong).',
    warning:
        'Tidak melebihi 40 mg zinc elemental per hari untuk dewasa. Hindari bersamaan dengan antibiotik tetrasiklin.',
    keywords: ['zinc', 'seng', 'imunitas', 'mineral', 'suplemen'],
  ),

  Medicine(
    id: 'med-011',
    name: 'Omega-3 Fish Oil 1000 mg',
    category: MedicineCategory.suplemen,
    price: 85000,
    stock: 50,
    imageIcon: 'spa',
    description:
        'Suplemen minyak ikan kaya asam lemak omega-3 (EPA dan DHA) yang mendukung kesehatan jantung, otak, dan mengurangi peradangan.',
    indication:
        'Suplemen omega-3, mendukung kesehatan jantung dan otak, mengurangi trigliserida.',
    ingredients:
        'Fish Oil 1000 mg mengandung EPA 180 mg dan DHA 120 mg.',
    dosage: 'Dewasa: 1–3 kapsul per hari setelah makan.',
    sideEffects: 'Rasa amis setelah konsumsi, mual ringan, diare pada dosis tinggi.',
    warning:
        'Hati-hati pada pasien yang menggunakan antikoagulan. Simpan di tempat sejuk.',
    keywords: ['omega-3', 'fish oil', 'jantung', 'otak', 'EPA', 'DHA'],
  ),

  Medicine(
    id: 'med-012',
    name: 'Madu Multivitamin Anak',
    category: MedicineCategory.suplemen,
    price: 45000,
    stock: 70,
    imageIcon: 'child_care',
    description:
        'Suplemen multivitamin berbasis madu untuk anak yang membantu memenuhi kebutuhan vitamin dan mineral harian untuk mendukung pertumbuhan optimal.',
    indication:
        'Suplemen vitamin harian anak, mendukung pertumbuhan, meningkatkan nafsu makan.',
    ingredients:
        'Madu, Vitamin A 1500 IU, Vitamin C 30 mg, Vitamin D 200 IU, Zinc 5 mg, Vitamin B kompleks.',
    dosage: 'Anak 2–6 tahun: 5 ml 1 kali sehari. Anak 6–12 tahun: 10 ml 1 kali sehari.',
    sideEffects: 'Sangat jarang, kadang gangguan lambung ringan.',
    warning:
        'Tidak untuk bayi <1 tahun (mengandung madu). Simpan di tempat sejuk dan kering.',
    keywords: ['multivitamin', 'anak', 'madu', 'suplemen', 'pertumbuhan'],
  ),

  // ─── Obat Bebas ──────────────────────────────────────────────────────────────
  Medicine(
    id: 'med-013',
    name: 'Antasida Tablet',
    category: MedicineCategory.obatPencernaan,
    price: 8000,
    stock: 130,
    imageIcon: 'local_pharmacy',
    description:
        'Antasida menetralkan asam lambung berlebih untuk meredakan nyeri ulu hati, kembung, dan maag secara cepat.',
    indication:
        'Maag, nyeri ulu hati, kembung, mual akibat asam lambung berlebih.',
    ingredients: 'Aluminium Hydroxide 200 mg, Magnesium Hydroxide 200 mg, Simethicone 20 mg.',
    dosage:
        'Dewasa: 1–2 tablet, 3–4 kali sehari (setelah makan dan menjelang tidur). Kunyah sebelum ditelan.',
    sideEffects: 'Konstipasi (akibat aluminium), diare (akibat magnesium), jarang terjadi.',
    warning:
        'Tidak untuk digunakan >2 minggu tanpa pengawasan dokter. Dapat mengganggu penyerapan beberapa obat lain.',
    keywords: ['antasida', 'maag', 'lambung', 'kembung', 'asam lambung'],
  ),

  Medicine(
    id: 'med-014',
    name: 'Amoxicillin 500 mg',
    category: MedicineCategory.obatBebasTerbatas,
    price: 15000,
    stock: 40,
    imageIcon: 'medication',
    description:
        'Amoxicillin adalah antibiotik golongan penisilin yang digunakan untuk mengobati berbagai infeksi bakteri. Harus digunakan sesuai resep dokter.',
    indication:
        'Infeksi saluran pernapasan, infeksi telinga, infeksi saluran kemih, infeksi kulit akibat bakteri sensitif.',
    ingredients: 'Amoxicillin Trihydrate setara Amoxicillin 500 mg.',
    dosage:
        'Dewasa: 500 mg setiap 8 jam (3 kali sehari) selama 5–10 hari atau sesuai petunjuk dokter. Harus habis.',
    sideEffects:
        'Diare, mual, ruam kulit, reaksi alergi (hingga anafilaksis pada kasus tertentu).',
    warning:
        'HARUS SESUAI RESEP DOKTER. Beri tahu dokter jika ada riwayat alergi penisilin. Selesaikan seluruh kursus antibiotik.',
    keywords: ['amoxicillin', 'antibiotik', 'infeksi', 'bakteri', 'penisilin'],
  ),

  Medicine(
    id: 'med-015',
    name: 'Loperamide 2 mg',
    category: MedicineCategory.obatPencernaan,
    price: 12000,
    stock: 85,
    imageIcon: 'local_pharmacy',
    description:
        'Loperamide mengurangi gerakan usus berlebihan sehingga membantu mengatasi diare akut. Bekerja secara lokal di usus.',
    indication: 'Diare akut non-spesifik, diare perjalanan.',
    ingredients: 'Loperamide HCl 2 mg.',
    dosage:
        'Dewasa: Awal 2 tablet, lanjut 1 tablet setelah tiap BAB cair. Maksimal 8 tablet per hari.',
    sideEffects: 'Konstipasi, mual, pusing, mulut kering.',
    warning:
        'Tidak untuk diare berdarah atau diare akibat infeksi bakteri berat. Segera konsultasikan dokter jika diare >48 jam.',
    keywords: ['loperamide', 'diare', 'mencret', 'BAB cair'],
  ),

  // ─── Obat Bebas Terbatas ──────────────────────────────────────────────────────
  Medicine(
    id: 'med-016',
    name: 'CTM (Chlorpheniramine) 4 mg',
    category: MedicineCategory.obatBebasTerbatas,
    price: 5000,
    stock: 200,
    imageIcon: 'medication',
    description:
        'CTM adalah antihistamin generasi pertama yang digunakan untuk mengatasi reaksi alergi. Merupakan salah satu obat alergi paling terjangkau.',
    indication:
        'Alergi, rhinitis alergi, urtikaria (biduran), gatal akibat alergi, konjungtivitis alergi.',
    ingredients: 'Chlorpheniramine Maleate 4 mg.',
    dosage: 'Dewasa: 1 tablet, 3 kali sehari. Anak 6–12 tahun: ½ tablet, 3 kali sehari.',
    sideEffects: 'Kantuk (efek utama), mulut kering, penglihatan kabur, konstipasi.',
    warning:
        'Sangat mengantuk — hindari mengemudi. Tidak untuk pengidap glaukoma, BPH. Hati-hati pada lansia.',
    keywords: ['CTM', 'alergi', 'antihistamin', 'gatal', 'biduran'],
  ),

  Medicine(
    id: 'med-017',
    name: 'Cetirizine 10 mg',
    category: MedicineCategory.obatBebasTerbatas,
    price: 18000,
    stock: 95,
    imageIcon: 'medication',
    description:
        'Cetirizine adalah antihistamin generasi kedua yang lebih selektif dengan efek kantuk yang minimal dibandingkan generasi pertama.',
    indication:
        'Rhinitis alergi musiman dan tahunan, urtikaria kronik, gatal akibat alergi.',
    ingredients: 'Cetirizine Dihydrochloride 10 mg.',
    dosage: 'Dewasa & anak >12 tahun: 1 tablet per hari, malam hari.',
    sideEffects: 'Kantuk ringan, mulut kering, sakit kepala, kelelahan.',
    warning:
        'Kurangi dosis pada gangguan ginjal. Meskipun efek kantuk minimal, tetap hati-hati saat mengemudi.',
    keywords: ['cetirizine', 'alergi', 'antihistamin', 'rhinitis', 'biduran'],
  ),

  // ─── Perawatan Kulit ──────────────────────────────────────────────────────────
  Medicine(
    id: 'med-018',
    name: 'Hydrocortisone Cream 1%',
    category: MedicineCategory.perawatanKulit,
    price: 12000,
    stock: 65,
    imageIcon: 'spa',
    description:
        'Krim hydrocortisone adalah kortikosteroid topikal ringan yang efektif untuk mengurangi peradangan dan gatal pada kulit.',
    indication:
        'Dermatitis kontak, eksim ringan, gatal akibat gigitan serangga, ruam kulit ringan.',
    ingredients: 'Hydrocortisone Acetate 1%.',
    dosage: 'Oleskan tipis pada area yang terkena, 2–3 kali sehari. Tidak untuk jangka panjang.',
    sideEffects: 'Penipisan kulit, striae (jika digunakan lama), kulit kering.',
    warning:
        'Tidak untuk digunakan di wajah, lipatan kulit, atau area yang luas tanpa pengawasan dokter. Tidak untuk infeksi jamur atau bakteri.',
    keywords: ['hydrocortisone', 'krim', 'eksim', 'gatal', 'dermatitis', 'kulit'],
  ),

  Medicine(
    id: 'med-019',
    name: 'Betamethasone Cream',
    category: MedicineCategory.perawatanKulit,
    price: 20000,
    stock: 0,
    imageIcon: 'spa',
    description:
        'Betamethasone adalah kortikosteroid topikal potensi sedang-tinggi yang digunakan untuk kondisi kulit inflamasi yang lebih berat.',
    indication:
        'Psoriasis, eksim berat, dermatitis atopik, lichen planus.',
    ingredients: 'Betamethasone Valerate 0.1%.',
    dosage:
        'Oleskan tipis 1–2 kali sehari pada area yang terkena. Tidak lebih dari 4 minggu.',
    sideEffects: 'Penipisan kulit, telangiectasia, striae, infeksi sekunder.',
    warning:
        'HARUS SESUAI PENGAWASAN DOKTER. Tidak untuk wajah. Hindari penggunaan jangka panjang. Stok saat ini habis.',
    keywords: ['betamethasone', 'krim', 'kulit', 'psoriasis', 'eksim'],
  ),

  Medicine(
    id: 'med-020',
    name: 'Bodrex Migra',
    category: MedicineCategory.obatBebas,
    price: 10000,
    stock: 110,
    imageIcon: 'medication',
    description:
        'Bodrex Migra adalah obat pereda sakit kepala dan migrain yang mengandung kombinasi paracetamol dan kafein untuk efek yang lebih cepat.',
    indication:
        'Sakit kepala, migrain, sakit kepala tegang.',
    ingredients: 'Paracetamol 500 mg, Caffeine 65 mg.',
    dosage: 'Dewasa: 1–2 tablet saat nyeri muncul. Maksimal 8 tablet per hari.',
    sideEffects:
        'Insomnia (akibat kafein), jantung berdebar, gelisah, sakit perut.',
    warning:
        'Tidak untuk pengidap gangguan jantung. Hindari penggunaan bersama minuman berkafein.',
    keywords: ['bodrex', 'migrain', 'sakit kepala', 'kafein', 'paracetamol'],
  ),
];
