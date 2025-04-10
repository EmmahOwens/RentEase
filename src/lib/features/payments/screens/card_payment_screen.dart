import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/layouts/dashboard_layout.dart';
import '../../../core/widgets/credit_card.dart';
import '../../../core/widgets/neu_button.dart';
import '../../../core/widgets/neu_text_field.dart';

class CardPaymentScreen extends StatefulWidget {
  final double amount;

  const CardPaymentScreen({
    super.key,
    required this.amount,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _showBackView = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onCvvFocused(bool focused) {
    setState(() {
      _showBackView = focused;
    });
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isProcessing = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardLayout(
      title: 'Card Payment',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Amount to Pay:',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'UGX ${widget.amount.toStringAsFixed(0)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          CreditCard(
            cardNumber: _cardNumberController.text.isEmpty
                ? '0000 0000 0000 0000'
                : _cardNumberController.text,
            cardHolder:
                _cardHolderController.text.isEmpty ? 'YOUR NAME' : _cardHolderController.text,
            expiryDate: _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text,
            cvv: _cvvController.text.isEmpty ? '000' : _cvvController.text,
            showBackView: _showBackView,
          ),
          const SizedBox(height: 32),
          NeuTextField(
            label: 'Card Number',
            hint: '0000 0000 0000 0000',
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberFormatter(),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          NeuTextField(
            label: 'Card Holder Name',
            hint: 'YOUR NAME',
            controller: _cardHolderController,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              UpperCaseTextFormatter(),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NeuTextField(
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpiryDateFormatter(),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Focus(
                  onFocusChange: _onCvvFocused,
                  child: NeuTextField(
                    label: 'CVV',
                    hint: '000',
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          NeuButton(
            onPressed: _processPayment,
            isLoading: _isProcessing,
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i += 4) {
      if (i > 0) buffer.write(' ');
      buffer.write(text.substring(i, i + 4 > text.length ? text.length : i + 4));
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    final buffer = StringBuffer();
    if (text.length >= 2) {
      buffer.write(text.substring(0, 2));
      buffer.write('/');
      if (text.length > 2) {
        buffer.write(text.substring(2));
      }
    } else {
      buffer.write(text);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}