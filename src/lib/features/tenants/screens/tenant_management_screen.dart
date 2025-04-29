import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_smart/core/constants.dart';
import 'package:rent_smart/core/widgets/airbnb_button.dart'; // Added missing import
import 'package:rent_smart/core/widgets/airbnb_card.dart'; // Added missing import
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Added missing import
import '../models/tenant.dart';
import 'tenant_details_screen.dart';
import 'add_tenant_screen.dart';

class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TenantStatus? _selectedStatus;

  // Remove commented out static list and getter
  // final List<Tenant> _tenants = [...];
  // List<Tenant> get filteredTenants { ... }

  @override
  void initState() {
    super.initState(); // Correct initState: call super.initState()
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  Stream<QuerySnapshot> _getTenantsStream() {
    Query query = FirebaseFirestore.instance.collection('tenants');

    // Apply status filter
    if (_selectedStatus != null) {
      query = query.where('status', isEqualTo: _selectedStatus!.name); // Use .name for enum string
    }

    // Apply search query (simple prefix match on name for demonstration)
    // Firestore doesn't support case-insensitive 'contains' directly without third-party services like Algolia.
    // This searches for names starting with the query (case-sensitive).
    // For more robust search, consider searching multiple fields or using a search service.
    if (_searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }

    // Add ordering if needed, e.g., by name
    query = query.orderBy('name');

    return query.snapshots();
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
              padding: const EdgeInsets.all(kDefaultPadding), // Use constant
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AirbnbCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _searchController, // Assign controller
                          decoration: InputDecoration(
                            hintText: 'Search tenants by name...', // Updated hint
                            prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // Add clear button
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      // setState is called by the listener
                                    },
                                  )
                                : null,
                          ),
                          // onChanged removed, using listener in initState
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Add 'All' filter chip
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: const Text('All'),
                                  selected: _selectedStatus == null,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedStatus = null;
                                    });
                                  },
                                ),
                              ),
                              // Status filter chips
                              ...TenantStatus.values.map((status) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(status.displayTitle), // Use displayTitle
                                    selected: _selectedStatus == status,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedStatus = selected ? status : null;
                                      });
                                    },
                                    // Optional: Add avatar for visual distinction
                                    // avatar: CircleAvatar(
                                    //   backgroundColor: status.color.withOpacity(0.8),
                                    //   radius: 8,
                                    // ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Use StreamBuilder to display tenant count and list
                  StreamBuilder<QuerySnapshot>(
                    stream: _getTenantsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading indicator or shimmer effect while loading
                        // return const Center(child: CircularProgressIndicator());
                        // Or return the header part while loading data
                        return _buildTenantListHeader(context, 0, true);
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Column(
                          children: [
                            _buildTenantListHeader(context, 0, false),
                            const SizedBox(height: 16),
                            _buildEmptyState(theme),
                          ],
                        );
                      }

                      final tenants = snapshot.data!.docs
                          .map((doc) => Tenant.fromFirestore(doc))
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTenantListHeader(context, tenants.length, false),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tenants.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12), // Adjusted spacing
                            itemBuilder: (context, index) {
                              final tenant = tenants[index];
                              return _TenantCard(tenant: tenant);
                            },
                          ),
                        ],
                      );
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

  // Helper widget for the list header (count and add button)
  Widget _buildTenantListHeader(BuildContext context, int count, bool isLoading) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isLoading ? 'Loading Tenants...' : 'Tenants ($count)',
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
    );
  }

  // Helper widget for the empty state
  Widget _buildEmptyState(ThemeData theme) {
    return AirbnbCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0), // Add padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.usersSlash, // More relevant icon
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty && _selectedStatus == null
                    ? 'No tenants added yet'
                    : 'No tenants match your criteria',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty && _selectedStatus == null
                    ? 'Tap \'Add Tenant\' to get started.'
                    : 'Try adjusting your search or filters.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
    // Use the color from the TenantStatus enum directly
    final statusColor = tenant.status.color;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TenantDetailsScreen(tenantId: tenant.id),
          ),
        );
      },
      // Wrap with AirbnbCard for consistent styling
      child: AirbnbCard(
        padding: const EdgeInsets.all(kDefaultPadding), // Add padding
        child: Column( // Use Column instead of Padding
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?', // Handle empty name
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        // Removed redundant style
                      ),
                      const SizedBox(height: 2), // Add small spacing
                      Text(
                        'Unit ${tenant.unitNumber}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color, // Use bodySmall color
                        ),
                        // Removed redundant style
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
                    // Use status color with opacity
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tenant.status.displayTitle, // Use displayTitle
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor, // Use status color
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12), // Adjusted spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  context,
                  'Monthly Rent',
                  tenant.formattedMonthlyRent,
                  FontAwesomeIcons.moneyBillWave, // Updated icon
                ),
                _buildDetailItem(
                  context,
                  'Lease Ends',
                  tenant.formattedLeaseEnd,
                  FontAwesomeIcons.calendarCheck, // Updated icon
                  isWarning: tenant.isLeaseExpiringSoon, // Pass warning flag
                ),
              ],
            ),
            // Simplified lease expiring warning
            if (tenant.isLeaseExpiringSoon) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Colors.orange[700], // Use specific orange shade
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lease expiring soon',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange[800], // Use specific orange shade
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    {bool isWarning = false} // Add optional warning flag
  ) {
    final theme = Theme.of(context);
    final valueColor = isWarning ? Colors.orange[800] : theme.textTheme.bodyLarge?.color;
    final iconColor = isWarning ? Colors.orange[700] : theme.colorScheme.primary;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 2), // Add small spacing
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith( // Use bodyMedium for consistency
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}