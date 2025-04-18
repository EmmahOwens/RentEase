import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/layouts/dashboard_layout.dart';
import '../../../core/models/payment.dart';
import '../../../core/widgets/neu_button.dart';
import '../../../core/widgets/neu_text_field.dart';
import '../../../core/widgets/payment_method_card.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'card_payment_screen.dart';
import 'mobile_money_screen.dart';
import 'payment_confirmation_screen.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  PaymentMethod? _selectedMethod;
  final bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool? paymentSuccess;
    if (_selectedMethod == PaymentMethod.card) {
      paymentSuccess = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => CardPaymentScreen(amount: amount),
        ),
      );
    } else {
      paymentSuccess = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => MobileMoneyScreen(
            amount: amount,
            method: _selectedMethod!,
          ),
        ),
      );
    }

    if (!mounted) return;

    if (paymentSuccess == true) {
      final payment = Payment(
        id: const Uuid().v4(),
        userId: context.read<AuthProvider>().currentUser!.id,
        amount: amount,
        status: PaymentStatus.completed,
        method: _selectedMethod!,
        date: DateTime.now(),
        description: _descriptionController.text.trim(),
      );

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(payment: payment),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Make Payment',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            NeuTextField(
              label: 'Amount (UGX)',
              hint: '0',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) {
                    return newValue;
                  }
                  final num = int.tryParse(
                    newValue.text.replaceAll(',', ''),
                  );
                  if (num == null) {
                    return oldValue;
                  }
                  final formatted = num.toString()
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );
                  return TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value.replaceAll(',', ''));
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            NeuTextField(
              label: 'Description (Optional)',
              hint: 'Enter payment description',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: PaymentMethod.values.map((method) {
                return PaymentMethodCard(
                  method: method,
                  isSelected: _selectedMethod == method,
                  onTap: () {
                    setState(() {
                      _selectedMethod = method;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            NeuButton(
              onPressed: _processPayment,
              isLoading: _isProcessing,
              child: const Text('Process Payment'),
            ),
          ],
        ),
      ),
    );
  }
}