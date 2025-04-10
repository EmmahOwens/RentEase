import 'package:intl/intl.dart';

enum TenantStatus {
  active,
  pending,
  inactive,
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