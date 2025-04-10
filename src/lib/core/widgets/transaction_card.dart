import 'package:flutter/material.dart';
import '../models/payment.dart';

class TransactionCard extends StatelessWidget {
  final Payment payment;

  const TransactionCard({
    super.key,
    required this.payment,
  });

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (payment.status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return theme.colorScheme.primary;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  IconData _getMethodIcon() {
    switch (payment.method) {
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
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMethodIcon(),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.formattedAmount,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.formattedDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                payment.status.toString().split('.').last.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}