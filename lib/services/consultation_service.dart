import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/consultation.dart';

/// Service terpadu untuk Validasi Resep & Chat Konsultasi Apoteker.
/// Sinkron dengan Cloud Firestore ('prescriptions' & 'consultations') + in-memory state.
class ConsultationService extends ChangeNotifier {
  static final ConsultationService _instance = ConsultationService._internal();
  factory ConsultationService() => _instance;

  final List<PrescriptionRequest> _prescriptions = [];
  final List<ConsultationThread> _threads = [];

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _prescriptionsRef =>
      _firestore.collection('prescriptions');
  CollectionReference<Map<String, dynamic>> get _consultationsRef =>
      _firestore.collection('consultations');

  ConsultationService._internal() {
    _seedInitialData();
    initFirestoreSync();
  }

  void _seedInitialData() {
    final now = DateTime.now();
    _prescriptions.addAll([
      PrescriptionRequest(
        id: 'RSP-2026-001',
        userId: 'dev-001',
        userName: 'User ApoteKita',
        doctorName: 'dr. Hendra Wijaya, Sp.PD',
        clinicName: 'Klinik Pratama Sehat',
        notes: 'Demam 2 hari disertai batuk berdahak. Mohon validasi Paracetamol & OBH Combi.',
        requestedMedicineIds: ['med-001', 'med-003'],
        approvedMedicineIds: ['med-001', 'med-003'],
        status: PrescriptionStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      PrescriptionRequest(
        id: 'RSP-2026-002',
        userId: 'dev-001',
        userName: 'User ApoteKita',
        doctorName: 'dr. Clara Kusuma',
        clinicName: 'RS Mitra Keluarga',
        notes: 'Keluhan maag & nyeri ulu hati setelah makan pedas.',
        requestedMedicineIds: ['med-007'],
        approvedMedicineIds: ['med-007'],
        pharmacistNote: 'Diminum 30 menit sebelum makan, kunyah hingga halus.',
        validatedBy: 'apt. Siti Rahma, S.Farm.',
        status: PrescriptionStatus.approved,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    _threads.add(
      ConsultationThread(
        id: 'CHAT-001',
        userId: 'dev-001',
        userName: 'User ApoteKita',
        topic: 'Aturan minum Paracetamol & Vitamin C',
        updatedAt: now.subtract(const Duration(minutes: 25)),
        messages: [
          ChatMessage(
            id: 'msg-1',
            senderId: 'dev-001',
            senderName: 'User ApoteKita',
            senderRole: 'user',
            text: 'Selamat pagi Kak Apoteker, apakah Paracetamol boleh diminum bersamaan dengan Vitamin C setelah makan?',
            sentAt: now.subtract(const Duration(minutes: 30)),
          ),
          ChatMessage(
            id: 'msg-2',
            senderId: 'staff-apoteker-01',
            senderName: 'apt. Siti Rahma, S.Farm.',
            senderRole: 'apoteker',
            text: 'Selamat pagi! Boleh sekali, Paracetamol dan Vitamin C aman dikonsumsi bersamaan sesudah makan. Pastikan minum air putih yang cukup ya.',
            sentAt: now.subtract(const Duration(minutes: 25)),
          ),
        ],
      ),
    );
  }

  Future<void> initFirestoreSync() async {
    try {
      final presSnap = await _prescriptionsRef.get();
      if (presSnap.docs.isNotEmpty) {
        for (final doc in presSnap.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          final item = PrescriptionRequest.fromMap(data);
          final idx = _prescriptions.indexWhere((p) => p.id == item.id);
          if (idx != -1) {
            _prescriptions[idx] = item;
          } else {
            _prescriptions.add(item);
          }
        }
        _prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      final chatSnap = await _consultationsRef.get();
      if (chatSnap.docs.isNotEmpty) {
        for (final doc in chatSnap.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          final thread = ConsultationThread.fromMap(data);
          final idx = _threads.indexWhere((t) => t.id == thread.id);
          if (idx != -1) {
            _threads[idx] = thread;
          } else {
            _threads.add(thread);
          }
        }
        _threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ConsultationService Firestore sync notice: $e');
    }
  }

  // ─── Prescriptions ──────────────────────────────────────────────────────────
  List<PrescriptionRequest> get prescriptions =>
      List.unmodifiable(_prescriptions);

  List<PrescriptionRequest> getPrescriptionsForUser(String userId) {
    return _prescriptions
        .where((p) => p.userId == userId || userId == 'dev-001')
        .toList();
  }

  int get pendingPrescriptionCount => _prescriptions
      .where((p) => p.status == PrescriptionStatus.pending)
      .length;

  Future<PrescriptionRequest> submitPrescription({
    required String userId,
    required String userName,
    required String doctorName,
    required String clinicName,
    required String notes,
    required List<String> requestedMedicineIds,
  }) async {
    final now = DateTime.now();
    final id =
        'RSP-${now.year}-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

    final req = PrescriptionRequest(
      id: id,
      userId: userId,
      userName: userName,
      doctorName: doctorName.trim(),
      clinicName: clinicName.trim(),
      notes: notes.trim(),
      requestedMedicineIds: requestedMedicineIds,
      approvedMedicineIds: List<String>.from(requestedMedicineIds),
      status: PrescriptionStatus.pending,
      createdAt: now,
    );

    _prescriptions.insert(0, req);
    notifyListeners();

    try {
      await _prescriptionsRef.doc(req.id).set(req.toMap());
    } catch (e) {
      debugPrint('Failed to save prescription to Firestore: $e');
    }

    return req;
  }

  Future<void> validatePrescription({
    required String id,
    required PrescriptionStatus status,
    required List<String> approvedMedicineIds,
    required String pharmacistNote,
    required String pharmacistName,
  }) async {
    final idx = _prescriptions.indexWhere((p) => p.id == id);
    if (idx == -1) return;

    final item = _prescriptions[idx];
    item.status = status;
    item.approvedMedicineIds = approvedMedicineIds;
    item.pharmacistNote = pharmacistNote.trim();
    item.validatedBy = pharmacistName;
    notifyListeners();

    try {
      await _prescriptionsRef.doc(id).set(item.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update prescription in Firestore: $e');
    }
  }

  Future<void> markPrescriptionOrdered(String id) async {
    final idx = _prescriptions.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    _prescriptions[idx].isOrdered = true;
    notifyListeners();

    try {
      await _prescriptionsRef.doc(id).set(
        {'isOrdered': true},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Failed to mark prescription ordered: $e');
    }
  }

  // ─── Consultations (Chat) ───────────────────────────────────────────────────
  List<ConsultationThread> get threads => List.unmodifiable(_threads);

  List<ConsultationThread> getThreadsForUser(String userId) {
    return _threads
        .where((t) => t.userId == userId || userId == 'dev-001')
        .toList();
  }

  int get activeThreadCount => _threads.where((t) => !t.isResolved).length;

  ConsultationThread? getThreadById(String id) {
    try {
      return _threads.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ConsultationThread> createThread({
    required String userId,
    required String userName,
    required String topic,
    required String firstMessage,
  }) async {
    final now = DateTime.now();
    final id = 'CHAT-${(now.millisecondsSinceEpoch % 100000)}';
    final msg = ChatMessage(
      id: 'msg-${now.millisecondsSinceEpoch}',
      senderId: userId,
      senderName: userName,
      senderRole: 'user',
      text: firstMessage.trim(),
      sentAt: now,
    );
    final thread = ConsultationThread(
      id: id,
      userId: userId,
      userName: userName,
      topic: topic.trim(),
      updatedAt: now,
      messages: [msg],
    );
    _threads.insert(0, thread);
    notifyListeners();

    try {
      await _consultationsRef.doc(thread.id).set(thread.toMap());
    } catch (e) {
      debugPrint('Failed to save consultation thread: $e');
    }

    return thread;
  }

  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    final idx = _threads.indexWhere((t) => t.id == threadId);
    if (idx == -1) return;

    final now = DateTime.now();
    final msg = ChatMessage(
      id: 'msg-${now.millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text.trim(),
      sentAt: now,
    );

    final thread = _threads[idx];
    thread.messages.add(msg);
    thread.updatedAt = now;
    if (senderRole == 'user') {
      thread.isResolved = false;
    }
    _threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();

    try {
      await _consultationsRef
          .doc(threadId)
          .set(thread.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update consultation messages: $e');
    }
  }

  Future<void> toggleThreadResolved(String threadId, bool resolved) async {
    final idx = _threads.indexWhere((t) => t.id == threadId);
    if (idx == -1) return;
    _threads[idx].isResolved = resolved;
    notifyListeners();

    try {
      await _consultationsRef.doc(threadId).set(
        {'isResolved': resolved},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Failed to update thread resolved state: $e');
    }
  }
}
