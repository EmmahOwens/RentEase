import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../models/tenant.dart';
import 'tenant_details_screen.dart';
import 'add_tenant_screen.dart';

class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  String _searchQuery = '';
  TenantStatus? _selectedStatus;

  // Mock data for demonstration
  final List<Tenant> _tenants = [
    Tenant(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+256 701 234 567',
      unitNumber: 'A101',
      leaseStart: DateTime(2023, 6, 1),
      leaseEnd: DateTime(2024, 5, 31),
      monthlyRent: 800000,
      status: TenantStatus.active,
      joinedDate: DateTime(2023, 6, 1),
    ),
    Tenant(
      id: '2',
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      phone: '+256 702 345 678',
      unitNumber: 'B202',
      leaseStart: DateTime(2023, 8, 1),
      leaseEnd: DateTime(2024, 7, 31),
      monthlyRent: 950000,
      status: TenantStatus.active,
      joinedDate: DateTime(2023, 8, 1),
    ),
    Tenant(
      id: '3',
      name: 'Michael Johnson',
      email: 'michael.j@example.com',
      phone: '+256 703 456 789',
      unitNumber: 'C303',
      leaseStart: DateTime(2024, 2, 1),
      leaseEnd: DateTime(2024, 3, 31),
      monthlyRent: 750000,
      status: TenantStatus.pending,
      joinedDate: DateTime(2024, 2, 1),
    ),
  ];

  List<Tenant> get filteredTenants {
    return _tenants.where((tenant) {
      final matchesSearch = tenant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tenant.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tenant.unitNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == null || tenant.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                'Tenant Management',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AirbnbCard(
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Search tenants...',
                            prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: TenantStatus.values.map((status) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(status.toString().split('.').last),
                                  selected: _selectedStatus == status,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedStatus = selected ? status : null;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tenants (${filteredTenants.length})',
                        style: theme.textTheme.titleLarge,
                      ),
                      AirbnbButton(
                        text: 'Add Tenant',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTenantScreen(),
                            ),
                          );
                        },
                        icon: FontAwesomeIcons.plus,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filteredTenants.isEmpty)
                    AirbnbCard(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.userLarge,
                              size: 48,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tenants found',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTenants.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tenant = filteredTenants[index];
                        return _TenantCard(tenant: tenant);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final Tenant tenant;

  const _TenantCard({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getStatusColor() {
      switch (tenant.status) {
        case TenantStatus.active:
          return Colors.green;
        case TenantStatus.pending:
          return Colors.orange;
        case TenantStatus.inactive:
          return Colors.red;
      }
    }

    return AirbnbCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TenantDetailsScreen(tenant: tenant),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  tenant.name[0].toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'Unit ${tenant.unitNumber}',
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
                  tenant.status.toString().split('.').last.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                context,
                'Monthly Rent',
                tenant.formattedMonthlyRent,
                FontAwesomeIcons.moneyBill,
              ),
              _buildDetailItem(
                context,
                'Lease Ends',
                tenant.formattedLeaseEnd,
                FontAwesomeIcons.calendar,
              ),
            ],
          ),
          if (tenant.isLeaseExpiringSoon) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
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
                  Text(
                    'Lease expiring soon',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}