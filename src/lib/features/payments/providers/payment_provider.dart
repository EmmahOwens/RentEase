import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore import
import '../../../core/models/payment.dart';
import '../../auth/providers/auth_provider.dart'; // Assuming AuthProvider provides user ID

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider _authProvider;
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _userId;
  String? _errorMessage;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  PaymentProvider(this._authProvider) { // Accept AuthProvider in constructor
    _userId = _authProvider.currentUser?.uid;
    if (_userId != null) {
      _listenToPayments();
    } else {
      // Handle case where user is not logged in initially
      _authProvider.addListener(_onAuthStateChanged);
    }
  }

  void _onAuthStateChanged() {
    final newUserId = _authProvider.currentUser?.uid;
    if (newUserId != _userId) {
      _userId = newUserId;
      if (_userId != null) {
        _listenToPayments();
      } else {
        _payments = []; // Clear payments if user logs out
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _listenToPayments() {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    // Listen to payments collection, potentially filtering by userId if needed
    // Adjust the query based on your data model (e.g., filter by landlordId or tenantId)
    _firestore
        .collection('payments')
        // .where('userId', isEqualTo: _userId) // Example: Filter by user ID if payments are user-specific
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _payments = snapshot.docs
          .map((doc) => Payment.fromFirestore(doc.data()))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Error listening to payments: $error");
      _isLoading = false;
      notifyListeners();
      // Handle error appropriately (e.g., show a message)
    });
  }

  Future<bool> addPayment({
    required String userId, // Keep userId for the payment record itself
    required double amount,
    required PaymentMethod method,
    String? description,
    String? propertyId, // Optional: Link payment to a property
    String? tenantId, // Optional: Link payment to a tenant
    String? landlordId, // Optional: Link payment to a landlord
  }) async {
    if (_userId == null) return false;

  bool _validatePaymentPermissions(String userId) {
    final currentUser = _authProvider.currentUser;
    final currentUserRole = _authProvider.userRole;
    if (currentUser == null || currentUserRole == null) return false;

    // Check if the user making the request is the one associated with the payment
    // and if their role matches either 'tenant' or 'landlord'.
    final isTenant = userId == currentUser.uid && currentUserRole == 'tenant';
    final isLandlord = userId == currentUser.uid && currentUserRole == 'landlord';
    return isTenant || isLandlord;
  }

    try {
      final paymentId = const Uuid().v4();
      final payment = Payment(
        id: paymentId,
        userId: userId, // The user initiating the payment (could be tenant or landlord)
        amount: amount,
        status: PaymentStatus.completed, // Assume completion for now, adjust if processing needed
        method: method,
        date: DateTime.now(),
        description: description,
        propertyId: propertyId,
        tenantId: tenantId,
        landlordId: landlordId,
      );

      // Save to Firestore
      await _firestore.collection('payments').doc(paymentId).set(payment.toJson());

      // No need to manually add to _payments list, the stream listener will update it.
      // notifyListeners(); // Stream listener handles notification

      return true;
    } catch (e) {
      print("Error adding payment: $e");
      return false;
    }
  }

  // Methods below might need adjustment based on how you query/filter in Firestore
  // Or they can operate on the locally synced _payments list

  List<Payment> getPaymentsForUser(String userId) {
    // This now operates on the locally synced list, which is updated by the stream
    return _payments.where((p) => p.userId == userId || p.tenantId == userId || p.landlordId == userId).toList();
  }

  double getTotalPaymentsForUser(String userId) {
    // Operates on the locally synced list
    return _payments
        .where((p) => (p.userId == userId || p.tenantId == userId || p.landlordId == userId) && p.status == PaymentStatus.completed)
        .fold(0, (sum, p) => sum + p.amount);
  }

  Map<String, double> getPaymentMethodDistribution(String userId) {
    // Operates on the locally synced list
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