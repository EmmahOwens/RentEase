import 'package:intl/intl.dart';

enum PaymentStatus { pending, processing, completed, failed }
enum PaymentMethod { card, mtnMoney, airtelMoney }

class Payment {
  final String id;
  final String userId;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime date;
  final String? description;
  final String? propertyId; // Optional: Link payment to a property
  final String? tenantId; // Optional: Link payment to a tenant
  final String? landlordId; // Optional: Link payment to a landlord

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
    this.description,
    this.propertyId,
    this.tenantId,
    this.landlordId,
  });

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String get formattedDate {
    return DateFormat('MMM d, y').format(date);
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['method']}',
      ),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
<<<<<<< HEAD
=======
      propertyId: json['propertyId'] as String?,
      tenantId: json['tenantId'] as String?,
      landlordId: json['landlordId'] as String?,
>>>>>>> 5964a33 (This might be the time I actually deploy this to Firebase.)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'date': date.toIso8601String(),
      'description': description,
      'propertyId': propertyId,
      'tenantId': tenantId,
      'landlordId': landlordId,
    };
  }
}