import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TenantStatus {
  active,
  pending,
  inactive;

  // Helper to get a user-friendly title
  String get displayTitle {
    switch (this) {
      case TenantStatus.active:
        return 'Active';
      case TenantStatus.pending:
        return 'Pending';
      case TenantStatus.inactive:
        return 'Inactive';
    }
  }

  // Helper to get a color associated with the status
  Color get color {
    switch (this) {
      case TenantStatus.active:
        return Colors.green; // Or use theme.colorScheme.primary
      case TenantStatus.pending:
        return Colors.orange; // Or use theme.colorScheme.secondary
      case TenantStatus.inactive:
        return Colors.grey; // Or use theme.disabledColor
    }
  }
}

class Tenant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String unitNumber;
  final DateTime leaseStart;
  final DateTime leaseEnd;
  final double monthlyRent;
  final TenantStatus status;
  final String? profileImage;
  final Map<String, dynamic>? documents;
  final DateTime joinedDate;

  Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.unitNumber,
    required this.leaseStart,
    required this.leaseEnd,
    required this.monthlyRent,
    required this.status,
    this.profileImage,
    this.documents,
    required this.joinedDate,
  });

  String get formattedLeaseStart => DateFormat('MMM d, y').format(leaseStart);
  String get formattedLeaseEnd => DateFormat('MMM d, y').format(leaseEnd);
  String get formattedJoinedDate => DateFormat('MMM d, y').format(joinedDate);
  String get formattedMonthlyRent => NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  ).format(monthlyRent);

  bool get isLeaseExpiringSoon {
    final daysRemaining = leaseEnd.difference(DateTime.now()).inDays;
    return daysRemaining <= 30 && daysRemaining > 0;
  }

  // Factory constructor to create a Tenant from a Firestore document
  factory Tenant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tenant(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      unitNumber: data['unitNumber'] ?? '',
      monthlyRent: (data['monthlyRent'] as num?)?.toDouble() ?? 0.0,
      leaseStart: (data['leaseStart'] as Timestamp?)?.toDate() ?? DateTime.now(), // Corrected field name
      leaseEnd: (data['leaseEnd'] as Timestamp?)?.toDate() ?? DateTime.now(), // Corrected field name
      status: TenantStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == (data['status'] as String?)?.toLowerCase(), // More robust status parsing
        orElse: () => TenantStatus.pending, // Default if status is missing or invalid
      ),
      profileImage: data['profileImage'] as String?,
      documents: data['documents'] as Map<String, dynamic>?,
      joinedDate: (data['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now(), // Use joinedDate field
    );
  }

  // Method to convert a Tenant instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'unitNumber': unitNumber,
      'monthlyRent': monthlyRent,
      'leaseStart': Timestamp.fromDate(leaseStart), // Corrected field name
      'leaseEnd': Timestamp.fromDate(leaseEnd), // Corrected field name
      'status': status.toString().split('.').last,
      'profileImage': profileImage,
      'documents': documents,
      'joinedDate': Timestamp.fromDate(joinedDate),
      // Use FieldValue.serverTimestamp() only when creating, not updating
      // 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Existing factory constructor (keep if needed for other purposes)
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      unitNumber: json['unitNumber'] as String,
      leaseStart: DateTime.parse(json['leaseStart'] as String),
      leaseEnd: DateTime.parse(json['leaseEnd'] as String),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      status: TenantStatus.values.firstWhere(
        (e) => e.toString() == 'TenantStatus.${json['status']}',
      ),
      profileImage: json['profileImage'] as String?,
      documents: json['documents'] as Map<String, dynamic>?,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'unitNumber': unitNumber,
      'leaseStart': leaseStart.toIso8601String(),
      'leaseEnd': leaseEnd.toIso8601String(),
      'monthlyRent': monthlyRent,
      'status': status.toString().split('.').last,
      'profileImage': profileImage,
      'documents': documents,
      'joinedDate': joinedDate.toIso8601String(),
    };
  }
}