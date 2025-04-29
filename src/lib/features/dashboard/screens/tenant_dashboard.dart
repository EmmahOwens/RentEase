import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/payment.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../features/payments/providers/payment_provider.dart';
import '../../auth/providers/auth_provider.dart'; // Import AuthProvider
import '../../payments/screens/make_payment_screen.dart';
import '../../messages/screens/messages_screen.dart';

class TenantDashboard extends StatelessWidget {
  const TenantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>(); // Get AuthProvider
    final user = authProvider.currentUser; // Get the current user

    // Handle case where user might be null briefly during auth state changes
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final payments = context.watch<PaymentProvider>();
    final userPayments = payments.getPaymentsForUser(user.uid);
    final totalPaid = payments.getTotalPaymentsForUser(user.uid);
    final currencyFormatter = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );

    // Mock data for demonstration
    final propertyImages = [
      'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg',
      'https://images.pexels.com/photos/1643384/pexels-photo-1643384.jpeg',
      'https://images.pexels.com/photos/2724749/pexels-photo-2724749.jpeg',
    ];

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
                'Welcome, ${user.displayName?.split(' ')[0] ?? 'Guest'}',
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
                  AirbnbCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.buildingUser,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Residence',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 200,
                            child: PageView.builder(
                              itemCount: propertyImages.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  propertyImages[index],
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Modern Apartment',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '123 Sample Street, Kampala',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildFeatureItem(
                              context,
                              FontAwesomeIcons.bed,
                              '2 Bedrooms',
                            ),
                            const SizedBox(width: 16),
                            _buildFeatureItem(
                              context,
                              FontAwesomeIcons.bath,
                              '1 Bathroom',
                            ),
                            const SizedBox(width: 16),
                            _buildFeatureItem(
                              context,
                              FontAwesomeIcons.ruler,
                              '75 m²',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payment Overview',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  AirbnbCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Payment',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Due March 1, 2024',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Text(
                              currencyFormatter.format(800000),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        AirbnbButton(
                          text: 'Make Payment',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MakePaymentScreen(),
                              ),
                            );
                          },
                          icon: FontAwesomeIcons.creditCard,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (userPayments.isEmpty)
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
                            'No recent activity',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your payment history will appear here',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: userPayments
                          .take(3)
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

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        FaIcon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium,
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