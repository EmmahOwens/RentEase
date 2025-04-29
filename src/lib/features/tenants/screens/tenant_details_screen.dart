import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_smart/core/constants.dart';
import 'package:rent_smart/core/widgets/custom_button.dart';
import '../models/tenant.dart';

class TenantDetailsScreen extends StatefulWidget { // Changed to StatefulWidget
  final String tenantId; // Pass tenantId instead of the whole object

  const TenantDetailsScreen({
    super.key,
    required this.tenantId,
  });

  @override
  State<TenantDetailsScreen> createState() => _TenantDetailsScreenState();
}

class _TenantDetailsScreenState extends State<TenantDetailsScreen> { // State class
  Future<void> _deleteTenant(BuildContext context, String tenantId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tenant?'),
        content: const Text('Are you sure you want to delete this tenant? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('tenants').doc(tenantId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tenant deleted successfully.')),
          );
          Navigator.of(context).pop(); // Go back after deletion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete tenant: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Details'),
        actions: [
          // TODO: Add Edit button
          // IconButton(
          //   icon: const Icon(Icons.edit_outlined),
          //   tooltip: 'Edit Tenant',
          //   onPressed: () {
          //     // Navigate to edit screen, passing tenantId
          //   },
          // ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('tenants').doc(widget.tenantId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Tenant not found.'));
          }

          final tenant = Tenant.fromFirestore(snapshot.data!); // Create Tenant from snapshot

          return SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Avatar and Name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                        tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'Joined: ${DateFormat.yMMMd().format(tenant.joinedDate)}', // Use joinedDate from model
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: kDefaultPadding * 2),

                // Contact Info
                _buildDetailSection(
                  context,
                  title: 'Contact Information',
                  children: [
                    _buildDetailRow(context, Icons.email_outlined, tenant.email),
                    _buildDetailRow(context, Icons.phone_outlined, tenant.phone),
                  ],
                ),
                const Divider(height: kDefaultPadding * 1.5),

                // Lease Details
                _buildDetailSection(
                  context,
                  title: 'Lease Details',
                  children: [
                    _buildDetailRow(context, Icons.home_outlined, 'Unit ${tenant.unitNumber}'),
                    _buildDetailRow(context, Icons.attach_money_outlined, tenant.formattedMonthlyRent),
                    _buildDetailRow(context, Icons.calendar_today_outlined, 'Start: ${tenant.formattedLeaseStart}'),
                    _buildDetailRow(
                      context,
                      Icons.event_busy_outlined,
                      'End: ${tenant.formattedLeaseEnd}',
                      isWarning: tenant.isLeaseExpiringSoon,
                    ),
                  ],
                ),
                const Divider(height: kDefaultPadding * 1.5),

                // Status
                _buildDetailSection(
                  context,
                  title: 'Status',
                  children: [
                    Row(
                      children: [
                        Icon(
                          tenant.status == TenantStatus.active
                              ? Icons.check_circle_outline
                              : tenant.status == TenantStatus.pending
                                  ? Icons.hourglass_empty_outlined
                                  : Icons.cancel_outlined,
                          color: tenant.status == TenantStatus.active
                              ? Colors.green
                              : tenant.status == TenantStatus.pending
                                  ? Colors.orange
                                  : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tenant.status.toString().split('.').last.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tenant.status == TenantStatus.active
                                    ? Colors.green
                                    : tenant.status == TenantStatus.pending
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: kDefaultPadding * 2),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Send Reminder', // Example action
                        onPressed: () {
                          // TODO: Implement reminder logic (e.g., email)
                        },
                        icon: Icons.notifications_active_outlined,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding),
                    Expanded(
                      child: CustomButton(
                        text: 'Delete Tenant',
                        onPressed: () => _deleteTenant(context, tenant.id),
                        icon: Icons.delete_outline,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kDefaultPadding),
                // TODO: Add button to change status (e.g., Activate/Deactivate)
                // CustomButton(
                //   text: tenant.status == TenantStatus.active ? 'Deactivate Tenant' : 'Activate Tenant',
                //   onPressed: () {
                //     // TODO: Implement status change logic in Firestore
                //   },
                //   icon: tenant.status == TenantStatus.active ? Icons.pause_circle_outline : Icons.play_circle_outline,
                //   backgroundColor: tenant.status == TenantStatus.active ? Colors.orange : Colors.green,
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: kDefaultPadding / 2),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isWarning ? Colors.orange : Colors.grey[700]),
          const SizedBox(width: kDefaultPadding / 2),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isWarning ? Colors.orange : null,
                    fontWeight: isWarning ? FontWeight.bold : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}