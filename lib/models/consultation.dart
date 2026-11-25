import 'package:flutter/material.dart';
import '../app/theme.dart';

enum PrescriptionStatus {
  pending,
  approved,
  rejected,
}

extension PrescriptionStatusExtension on PrescriptionStatus {
  String get label {
    switch (this) {
      case PrescriptionStatus.pending:
        return 'Menunggu Validasi';
      case PrescriptionStatus.approved:
        return 'Disetujui Apoteker';
      case PrescriptionStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case PrescriptionStatus.pending:
        return const Color(0xFFFF9800);
      case PrescriptionStatus.approved:
        return AppColors.green;
      case PrescriptionStatus.rejected:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case PrescriptionStatus.pending:
        return Icons.hourglass_top_rounded;
      case PrescriptionStatus.approved:
        return Icons.verified_rounded;
      case PrescriptionStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

class PrescriptionRequest {
  final String id;
  final String userId;
  final String userName;
  final String doctorName;
  final String clinicName;
  final String notes;
  final List<String> requestedMedicineIds;
  List<String> approvedMedicineIds;
  String pharmacistNote;
  String? validatedBy;
  PrescriptionStatus status;
  final DateTime createdAt;
  bool isOrdered;

  PrescriptionRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.doctorName,
    required this.clinicName,
    required this.notes,
    this.requestedMedicineIds = const [],
    List<String>? approvedMedicineIds,
    this.pharmacistNote = '',
    this.validatedBy,
    this.status = PrescriptionStatus.pending,
    required this.createdAt,
    this.isOrdered = false,
  }) : approvedMedicineIds = approvedMedicineIds ?? List<String>.from(requestedMedicineIds);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'doctorName': doctorName,
      'clinicName': clinicName,
      'notes': notes,
      'requestedMedicineIds': requestedMedicineIds,
      'approvedMedicineIds': approvedMedicineIds,
      'pharmacistNote': pharmacistNote,
      'validatedBy': validatedBy,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'isOrdered': isOrdered,
    };
  }

  factory PrescriptionRequest.fromMap(Map<String, dynamic> map) {
    return PrescriptionRequest(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Pengguna',
      doctorName: map['doctorName'] ?? '',
      clinicName: map['clinicName'] ?? '',
      notes: map['notes'] ?? '',
      requestedMedicineIds: List<String>.from(map['requestedMedicineIds'] ?? []),
      approvedMedicineIds: List<String>.from(map['approvedMedicineIds'] ?? []),
      pharmacistNote: map['pharmacistNote'] ?? '',
      validatedBy: map['validatedBy'],
      status: PrescriptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PrescriptionStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isOrdered: map['isOrdered'] == true,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? 'user',
      text: map['text'] ?? '',
      sentAt: map['sentAt'] != null
          ? DateTime.tryParse(map['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ConsultationThread {
  final String id;
  final String userId;
  final String userName;
  final String topic;
  bool isResolved;
  DateTime updatedAt;
  final List<ChatMessage> messages;

  ConsultationThread({
    required this.id,
    required this.userId,
    required this.userName,
    required this.topic,
    this.isResolved = false,
    required this.updatedAt,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'topic': topic,
      'isResolved': isResolved,
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory ConsultationThread.fromMap(Map<String, dynamic> map) {
    return ConsultationThread(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Pengguna',
      topic: map['topic'] ?? 'Konsultasi Obat',
      isResolved: map['isResolved'] == true,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      messages: (map['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m)))
              .toList() ??
          [],
    );
  }
}
