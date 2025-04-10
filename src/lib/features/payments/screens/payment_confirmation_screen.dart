import 'package:flutter/material.dart';
import '../../../core/layouts/dashboard_layout.dart';
import '../../../core/models/payment.dart';
import '../../../core/widgets/neu_button.dart';
import '../../../core/widgets/neu_card.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final Payment payment;

  const PaymentConfirmationScreen({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardLayout(
      title: 'Payment Confirmation',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Icon(
            payment.status == PaymentStatus.completed
                ? Icons.check_circle_outline
                : Icons.error_outline,
            size: 80,
            color: payment.status == PaymentStatus.completed
                ? Colors.green
                : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            payment.status == PaymentStatus.completed
                ? 'Payment Successful!'
                : 'Payment Failed',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: payment.status == PaymentStatus.completed
                  ? Colors.green
                  : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            payment.status == PaymentStatus.completed
                ? 'Your payment has been processed successfully.'
                : 'There was an error processing your payment.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          NeuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  context,
                  'Amount',
                  payment.formattedAmount,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'Payment Method',
                  payment.method.toString().split('.').last,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'Date',
                  payment.formattedDate,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'Transaction ID',
                  payment.id.substring(0, 8).toUpperCase(),
                ),
                if (payment.description != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Description',
                    payment.description!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          NeuButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Back to Dashboard'),
          ),
          if (payment.status != PaymentStatus.completed) ...[
            const SizedBox(height: 16),
            NeuButton(
              onPressed: () {
                Navigator.pop(context);
              },
              isPrimary: false,
              child: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}