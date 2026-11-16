/// Status tingkat interaksi antar dua obat
enum InteractionLevel {
  none,      // Tidak ada interaksi
  caution,   // Perlu perhatian
  moderate,  // Interaksi sedang
}

/// Model hasil cek interaksi obat
class DrugInteraction {
  final String medicine1Id;
  final String medicine2Id;
  final InteractionLevel level;
  final String description;
  final String recommendation;

  const DrugInteraction({
    required this.medicine1Id,
    required this.medicine2Id,
    required this.level,
    required this.description,
    required this.recommendation,
  });
}

/// Dummy data interaksi obat (simulasi edukasi).
/// Struktur pasangan obat disimpan sebagai ID.
/// Lookup dilakukan dua arah (A+B == B+A).
const List<DrugInteraction> dummyInteractions = [
  DrugInteraction(
    medicine1Id: 'med-001', // Paracetamol
    medicine2Id: 'med-007', // Vitamin C
    level: InteractionLevel.none,
    description:
        'Berdasarkan data simulasi, tidak ada interaksi signifikan antara Paracetamol dan Vitamin C pada dosis normal.',
    recommendation:
        'Kedua obat dapat dikonsumsi bersamaan. Tetap ikuti petunjuk penggunaan masing-masing.',
  ),
  DrugInteraction(
    medicine1Id: 'med-001', // Paracetamol
    medicine2Id: 'med-020', // Bodrex Migra (mengandung paracetamol)
    level: InteractionLevel.moderate,
    description:
        'Paracetamol dan Bodrex Migra keduanya mengandung paracetamol. Penggunaan bersamaan dapat meningkatkan dosis paracetamol secara tidak sengaja dan berpotensi menyebabkan kerusakan hati.',
    recommendation:
        'TIDAK disarankan untuk menggunakan kedua obat secara bersamaan. Pilih salah satu saja. Konsultasikan dengan apoteker.',
  ),
  DrugInteraction(
    medicine1Id: 'med-001', // Paracetamol
    medicine2Id: 'med-002', // Ibuprofen
    level: InteractionLevel.caution,
    description:
        'Kombinasi paracetamol dan ibuprofen dapat digunakan pada beberapa kondisi nyeri berat, namun perlu perhatian khusus pada dosis total dan kondisi ginjal.',
    recommendation:
        'Gunakan hanya di bawah pengawasan dokter atau apoteker. Jangan melebihi dosis masing-masing obat.',
  ),
  DrugInteraction(
    medicine1Id: 'med-014', // Amoxicillin
    medicine2Id: 'med-010', // Zinc
    level: InteractionLevel.caution,
    description:
        'Zinc dapat mengurangi penyerapan amoxicillin jika diminum bersamaan. Berdasarkan data simulasi, ada potensi penurunan efektivitas antibiotik.',
    recommendation:
        'Berikan jarak minimal 2 jam antara konsumsi amoxicillin dan zinc.',
  ),
  DrugInteraction(
    medicine1Id: 'med-016', // CTM
    medicine2Id: 'med-005', // Decolgen (mengandung CTM)
    level: InteractionLevel.moderate,
    description:
        'CTM dan Decolgen sama-sama mengandung Chlorpheniramine Maleate. Kombinasi ini dapat menyebabkan efek sedasi berlebihan dan overdosis antihistamin.',
    recommendation:
        'Jangan gunakan keduanya secara bersamaan. Konsultasikan dengan apoteker untuk pilihan yang tepat.',
  ),
  DrugInteraction(
    medicine1Id: 'med-003', // OBH Combi
    medicine2Id: 'med-004', // Woods Antitusive
    level: InteractionLevel.moderate,
    description:
        'OBH Combi mengandung ekspektoran sementara Woods mengandung antitusif (penekan batuk). Keduanya bekerja berlawanan dan tidak boleh dikombinasikan.',
    recommendation:
        'Pilih salah satu: OBH Combi untuk batuk berdahak, atau Woods untuk batuk kering. Jangan dikombinasikan.',
  ),
  DrugInteraction(
    medicine1Id: 'med-011', // Omega-3
    medicine2Id: 'med-007', // Vitamin C
    level: InteractionLevel.none,
    description:
        'Berdasarkan data simulasi, tidak ada interaksi yang relevan antara Omega-3 dan Vitamin C. Keduanya bahkan dapat saling mendukung kesehatan.',
    recommendation:
        'Dapat dikonsumsi bersamaan. Vitamin C dapat mendukung antioksidan sementara Omega-3 mendukung kesehatan jantung.',
  ),
  DrugInteraction(
    medicine1Id: 'med-002', // Ibuprofen
    medicine2Id: 'med-013', // Antasida
    level: InteractionLevel.caution,
    description:
        'Antasida dapat mengurangi penyerapan ibuprofen jika diminum bersamaan. Namun, ibuprofen memang dianjurkan diminum bersama makanan atau antasida untuk melindungi lambung.',
    recommendation:
        'Berikan jarak 1–2 jam antara konsumsi keduanya, atau gunakan sesuai petunjuk dokter.',
  ),
];

/// Mencari interaksi antara dua obat berdasarkan ID (dua arah).
DrugInteraction? findInteraction(String id1, String id2) {
  for (final interaction in dummyInteractions) {
    if ((interaction.medicine1Id == id1 && interaction.medicine2Id == id2) ||
        (interaction.medicine1Id == id2 && interaction.medicine2Id == id1)) {
      return interaction;
    }
  }
  return null; // Tidak ada dalam database simulasi
}
