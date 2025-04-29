import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_smart/core/constants.dart';
import 'package:rent_smart/core/widgets/custom_button.dart';
import 'package:rent_smart/features/properties/models/property.dart'; // Import Property model
import 'package:rent_smart/features/properties/screens/add_property_screen.dart'; // Import AddPropertyScreen
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/payment.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../features/payments/providers/payment_provider.dart';
import '../../messages/screens/messages_screen.dart';

class LandlordDashboard extends StatefulWidget { // Changed from StatelessWidget
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState(); // Added createState
}

class _LandlordDashboardState extends State<LandlordDashboard> { // Existing State class
  // Moved helper methods and build logic into the State class

  final currencyFormatter = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payments = context.watch<PaymentProvider>();
    final allPayments = payments.payments;
    final totalRevenue = allPayments
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, p) => sum + p.amount);

    // Mock data for demonstration (can remain here or move to initState if needed)
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
                  color: theme.colorScheme.onSurface,
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
                          // TODO: Replace with Firestore property count
                          'Loading...',
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
                              // TODO: Replace with Firestore occupied units
                              'Loading...',
                              FontAwesomeIcons.userCheck,
                              Colors.green,
                            ),
                            _buildPropertyStat(
                              context,
                              'Vacant',
                              // TODO: Replace with Firestore vacant units
                              'Loading...',
                              FontAwesomeIcons.doorOpen,
                              theme.colorScheme.primary,
                            ),
                            _buildPropertyStat(
                              context,
                              'Maintenance',
                              // TODO: Replace with Firestore maintenance requests
                              'Loading...',
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

  // Moved helper methods inside the State class
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              FaIcon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
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
        FaIcon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  BarChartGroupData _createBarGroup(
    int x,
    double y,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: theme.colorScheme.primary,
          width: 16,
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
    final dateFormatter = DateFormat('MMM d, yyyy');

    IconData statusIcon;
    Color statusColor;
    switch (payment.status) {
      case PaymentStatus.completed:
        statusIcon = FontAwesomeIcons.solidCircleCheck;
        statusColor = Colors.green;
        break;
      case PaymentStatus.pending:
        statusIcon = FontAwesomeIcons.clock;
        statusColor = Colors.orange;
        break;
      case PaymentStatus.failed:
        statusIcon = FontAwesomeIcons.solidCircleXmark;
        statusColor = Colors.red;
        break;
      case PaymentStatus.processing:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    return AirbnbCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: FaIcon(statusIcon, size: 18, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment from Tenant', // Replace with actual tenant name if available
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormatter.format(payment.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            currencyFormatter.format(payment.amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}