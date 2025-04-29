import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory Payment.fromFirestore(Map<String, dynamic> data) {
    // Helper function for safe enum parsing
    T? _parseEnum<T>(List<T> enumValues, String? value) {
      if (value == null) return null;
      try {
        return enumValues.firstWhere(
          (e) => e.toString().split('.').last == value,
        );
      } catch (e) {
        return null; // Return null if value doesn't match any enum case
      }
    }

    // Helper for safe DateTime parsing
    DateTime? _parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      } else if (value is Timestamp) {
        return value.toDate();
      }
      return null;
    }

    final statusString = data['status'] as String?;
    final methodString = data['method'] as String?;
    final dateValue = data['date'];

    return Payment(
      id: data['id'] as String? ?? '', // Provide default or handle error
      userId: data['userId'] as String? ?? '', // Provide default or handle error
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      status: _parseEnum(PaymentStatus.values, statusString) ?? PaymentStatus.pending, // Default status
      method: _parseEnum(PaymentMethod.values, methodString) ?? PaymentMethod.card, // Default method
      date: _parseDateTime(dateValue) ?? DateTime.now(), // Default date
      description: data['description'] as String?,
      propertyId: data['propertyId'] as String?,
      tenantId: data['tenantId'] as String?,
      landlordId: data['landlordId'] as String?,
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