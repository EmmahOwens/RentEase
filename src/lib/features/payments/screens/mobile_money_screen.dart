import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/layouts/dashboard_layout.dart';
import '../../../core/models/payment.dart';
import '../../../core/widgets/neu_button.dart';
import '../../../core/widgets/neu_card.dart';
import '../../../core/widgets/neu_text_field.dart';

class MobileMoneyScreen extends StatefulWidget {
  final double amount;
  final PaymentMethod method;

  const MobileMoneyScreen({
    super.key,
    required this.amount,
    required this.method,
  });

  @override
  State<MobileMoneyScreen> createState() => _MobileMoneyScreenState();
}

class _MobileMoneyScreenState extends State<MobileMoneyScreen> {
  final _phoneController = TextEditingController();
  bool _isProcessing = false;
  bool _codeSent = false;
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get methodName {
    switch (widget.method) {
      case PaymentMethod.mtnMoney:
        return 'MTN Mobile Money';
      case PaymentMethod.airtelMoney:
        return 'Airtel Money';
      default:
        return '';
    }
  }

  Color get methodColor {
    switch (widget.method) {
      case PaymentMethod.mtnMoney:
        return Colors.yellow.shade700;
      case PaymentMethod.airtelMoney:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _initiatePayment() async {
    if (_phoneController.text.isEmpty) return;

    setState(() => _isProcessing = true);

    // Simulate sending code
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _codeSent = true;
    });
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) return;

    setState(() => _isProcessing = true);

    // Simulate code verification
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardLayout(
      title: methodName,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          NeuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: methodColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.method == PaymentMethod.mtnMoney
                            ? Icons.mobile_friendly
                            : Icons.phone_android,
                        color: methodColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount to Pay',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'UGX ${widget.amount.toStringAsFixed(0)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (!_codeSent) ...[
            NeuTextField(
              label: 'Phone Number',
              hint: '07XX XXX XXX',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 16),
            NeuButton(
              onPressed: _initiatePayment,
              isLoading: _isProcessing,
              child: const Text('Continue'),
            ),
          ] else ...[
            Text(
              'Enter the verification code sent to ${_phoneController.text}',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            NeuTextField(
              label: 'Verification Code',
              hint: 'Enter code',
              controller: _codeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            const SizedBox(height: 16),
            NeuButton(
              onPressed: _verifyCode,
              isLoading: _isProcessing,
              child: const Text('Verify & Pay'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => _codeSent = false);
              },
              child: Text(
                'Change Phone Number',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}