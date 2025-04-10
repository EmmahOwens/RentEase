import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/payment.dart';

class PaymentProvider with ChangeNotifier {
  static const String _paymentsKey = 'payments';
  late SharedPreferences _prefs;
  List<Payment> _payments = [];
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  PaymentProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _isLoading = true;
    notifyListeners();

    _prefs = await SharedPreferences.getInstance();
    _loadPayments();

    _isLoading = false;
    notifyListeners();
  }

  void _loadPayments() {
    final paymentsData = _prefs.getString(_paymentsKey);
    if (paymentsData != null) {
      final List<dynamic> decoded = json.decode(paymentsData);
      _payments = decoded.map((p) => Payment.fromJson(p)).toList();
      _payments.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<void> _savePayments() async {
    final encoded = json.encode(_payments.map((p) => p.toJson()).toList());
    await _prefs.setString(_paymentsKey, encoded);
  }

  Future<bool> addPayment({
    required String userId,
    required double amount,
    required PaymentMethod method,
    String? description,
  }) async {
    try {
      final payment = Payment(
        id: const Uuid().v4(),
        userId: userId,
        amount: amount,
        status: PaymentStatus.processing,
        method: method,
        date: DateTime.now(),
        description: description,
      );

      _payments.insert(0, payment);
      await _savePayments();
      notifyListeners();
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      final updatedPayment = Payment(
        id: payment.id,
        userId: payment.userId,
        amount: payment.amount,
        status: PaymentStatus.completed,
        method: payment.method,
        date: payment.date,
        description: payment.description,
      );

      _payments[_payments.indexWhere((p) => p.id == payment.id)] = updatedPayment;
      await _savePayments();
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  List<Payment> getPaymentsForUser(String userId) {
    return _payments.where((p) => p.userId == userId).toList();
  }

  double getTotalPaymentsForUser(String userId) {
    return _payments
        .where((p) => p.userId == userId && p.status == PaymentStatus.completed)
        .fold(0, (sum, p) => sum + p.amount);
  }

  Map<String, double> getPaymentMethodDistribution(String userId) {
    final userPayments = getPaymentsForUser(userId);
    final distribution = <String, double>{};

    for (final method in PaymentMethod.values) {
      final total = userPayments
          .where((p) => p.method == method && p.status == PaymentStatus.completed)
          .fold(0.0, (sum, p) => sum + p.amount);
      distribution[method.toString().split('.').last] = total;
    }

    return distribution;
  }
}