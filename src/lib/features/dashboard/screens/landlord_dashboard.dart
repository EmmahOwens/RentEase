import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/payment.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../features/payments/providers/payment_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../messages/screens/messages_screen.dart';

class LandlordDashboard extends StatelessWidget {
  const LandlordDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser!;
    final payments = context.watch<PaymentProvider>();
    final allPayments = payments.payments;
    final totalRevenue = allPayments
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, p) => sum + p.amount);

    final currencyFormatter = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );

    // Mock data for demonstration
    final propertyDetails = {
      'totalUnits': 10,
      'occupiedUnits': 8,
      'maintenanceRequests': 2,
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Landlord Dashboard',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onBackground,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.solidBell),
                onPressed: () {
                  // TODO: Show notifications
                },
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.solidMessage),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MessagesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Revenue',
                          currencyFormatter.format(totalRevenue),
                          FontAwesomeIcons.sackDollar,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Units',
                          '${propertyDetails['totalUnits']}',
                          FontAwesomeIcons.building,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Property Overview',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  AirbnbCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPropertyStat(
                              context,
                              'Occupied',
                              '${propertyDetails['occupiedUnits']}/${propertyDetails['totalUnits']}',
                              FontAwesomeIcons.userCheck,
                              Colors.green,
                            ),
                            _buildPropertyStat(
                              context,
                              'Vacant',
                              '${propertyDetails['totalUnits']! - propertyDetails['occupiedUnits']!}',
                              FontAwesomeIcons.doorOpen,
                              theme.colorScheme.primary,
                            ),
                            _buildPropertyStat(
                              context,
                              'Maintenance',
                              '${propertyDetails['maintenanceRequests']}',
                              FontAwesomeIcons.wrench,
                              Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 1000000,
                              barGroups: [
                                _createBarGroup(0, 800000, context),
                                _createBarGroup(1, 750000, context),
                                _createBarGroup(2, 900000, context),
                                _createBarGroup(3, 850000, context),
                              ],
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
                                      const months = ['Jan', 'Feb', 'Mar', 'Apr'];
                                      return Text(
                                        months[value.toInt()],
                                        style: theme.textTheme.bodySmall,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Payments',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (allPayments.isEmpty)
                    AirbnbCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.clock,
                            size: 48,
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payments yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Payment history will appear here',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: allPayments
                          .take(5)
                          .map((payment) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildPaymentItem(context, payment),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return AirbnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                icon,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  BarChartGroupData _createBarGroup(int x, double value, BuildContext context) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: Theme.of(context).colorScheme.primary,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(BuildContext context, Payment payment) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );

    IconData getMethodIcon() {
      switch (payment.method) {
        case PaymentMethod.card:
          return FontAwesomeIcons.creditCard;
        case PaymentMethod.mtnMoney:
          return FontAwesomeIcons.mobile;
        case PaymentMethod.airtelMoney:
          return FontAwesomeIcons.mobileScreen;
      }
    }

    Color getStatusColor() {
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

    return AirbnbCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              getMethodIcon(),
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currencyFormatter.format(payment.amount),
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  payment.formattedDate,
                  style: theme.textTheme.bodyMedium,
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
              color: getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              payment.status.toString().split('.').last.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: getStatusColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}