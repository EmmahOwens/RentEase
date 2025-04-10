import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/layouts/dashboard_layout.dart';
import '../../../core/models/payment.dart';
import '../../../core/widgets/neu_card.dart';
import '../../../core/widgets/transaction_card.dart';
import '../providers/payment_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser!;
    final payments = context.watch<PaymentProvider>();
    final userPayments = payments.getPaymentsForUser(user.id);
    final totalPaid = payments.getTotalPaymentsForUser(user.id);
    final paymentMethods = payments.getPaymentMethodDistribution(user.id);

    return DashboardLayout(
      title: 'Transaction History',
      body: payments.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NeuCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Payments',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'UGX ${totalPaid.toStringAsFixed(0)}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (paymentMethods.isNotEmpty) ...[
                          Text(
                            'Payment Methods',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AspectRatio(
                            aspectRatio: 2,
                            child: NeuCard(
                              padding: const EdgeInsets.all(24),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceBetween,
                                  maxY: paymentMethods.values.reduce((a, b) => a > b ? a : b),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final methods = paymentMethods.keys.toList();
                                          if (value >= 0 && value < methods.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                methods[value.toInt()]
                                                    .split('.')
                                                    .last
                                                    .replaceAll('Money', ''),
                                                style: theme.textTheme.bodySmall,
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: false),
                                  barGroups: paymentMethods.entries
                                      .map(
                                        (e) => BarChartGroupData(
                                          x: paymentMethods.keys
                                              .toList()
                                              .indexOf(e.key),
                                          barRods: [
                                            BarChartRodData(
                                              toY: e.value,
                                              color: theme.colorScheme.primary,
                                              width: 20,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          'Recent Transactions',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (userPayments.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final payment = userPayments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TransactionCard(payment: payment),
                          );
                        },
                        childCount: userPayments.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}