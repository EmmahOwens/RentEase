import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../models/tenant.dart';

class TenantDetailsScreen extends StatelessWidget {
  final Tenant tenant;

  const TenantDetailsScreen({
    super.key,
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        child: Text(
                          tenant.name[0].toUpperCase(),
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tenant.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  AirbnbCard(
                    child: Column(
                      children: [
                        _buildContactItem(
                          context,
                          FontAwesomeIcons.envelope,
                          'Email',
                          tenant.email,
                        ),
                        const Divider(),
                        _buildContactItem(
                          context,
                          FontAwesomeIcons.phone,
                          'Phone',
                          tenant.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lease Details',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  AirbnbCard(
                    child: Column(
                      children: [
                        _buildDetailItem(
                          context,
                          'Unit Number',
                          tenant.unitNumber,
                          FontAwesomeIcons.building,
                        ),
                        const Divider(),
                        _buildDetailItem(
                          context,
                          'Monthly Rent',
                          tenant.formattedMonthlyRent,
                          FontAwesomeIcons.moneyBill,
                        ),
                        const Divider(),
                        _buildDetailItem(
                          context,
                          'Lease Start',
                          tenant.formattedLeaseStart,
                          FontAwesomeIcons.calendarPlus,
                        ),
                        const Divider(),
                        _buildDetailItem(
                          context,
                          'Lease End',
                          tenant.formattedLeaseEnd,
                          FontAwesomeIcons.calendarMinus,
                        ),
                        if (tenant.isLeaseExpiringSoon) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.triangleExclamation,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Lease is expiring soon. Consider initiating renewal process.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AirbnbButton(
                          text: 'Send Message',
                          onPressed: () {
                            // TODO: Implement messaging
                          },
                          icon: FontAwesomeIcons.solidMessage,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AirbnbButton(
                          text: 'Edit Details',
                          onPressed: () {
                            // TODO: Navigate to edit tenant screen
                          },
                          icon: FontAwesomeIcons.penToSquare,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AirbnbButton(
                    text: tenant.status == TenantStatus.active
                        ? 'End Tenancy'
                        : 'Delete Tenant',
                    onPressed: () {
                      // TODO: Show confirmation dialog
                    },
                    icon: tenant.status == TenantStatus.active
                        ? FontAwesomeIcons.rightFromBracket
                        : FontAwesomeIcons.trashCan,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              icon,
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
                  label,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}