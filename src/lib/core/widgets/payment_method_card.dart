import 'package:flutter/material.dart';
import '../theme/neu_theme.dart';
import '../models/payment.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onTap;
  final bool isSelected;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.onTap,
    this.isSelected = false,
  });

  String get methodName {
    switch (method) {
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.mtnMoney:
        return 'MTN Mobile Money';
      case PaymentMethod.airtelMoney:
        return 'Airtel Money';
    }
  }

  IconData get methodIcon {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.mtnMoney:
        return Icons.mobile_friendly;
      case PaymentMethod.airtelMoney:
        return Icons.phone_android;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: NeuTheme.getNeumorphicDecoration(
          context: context,
          isPressed: isSelected,
          radius: 16,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              methodIcon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              methodName,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}