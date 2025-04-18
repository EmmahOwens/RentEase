import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/airbnb_text_field.dart';

class AddTenantScreen extends StatefulWidget {
  const AddTenantScreen({super.key});

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _unitController = TextEditingController();
  final _rentController = TextEditingController();
  DateTime? _leaseStart;
  DateTime? _leaseEnd;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _unitController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _leaseStart = picked;
        } else {
          _leaseEnd = picked;
        }
      });
    }
  }

  Future<void> _saveTenant() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // TODO: Implement actual tenant creation
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Tenant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep == 0 ? () => Navigator.pop(context) : _previousStep,
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Step content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildContactInfoStep(),
                  _buildLeaseDetailsStep(),
                  _buildConfirmationStep(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the tenant\'s basic information',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AirbnbCard(
            child: Column(
              children: [
                AirbnbTextField(
                  label: 'Full Name',
                  hint: 'Enter tenant\'s full name',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tenant\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AirbnbButton(
                  text: 'Continue',
                  onPressed: _nextStep,
                  icon: FontAwesomeIcons.arrowRight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add contact details for the tenant',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AirbnbCard(
            child: Column(
              children: [
                AirbnbTextField(
                  label: 'Email',
                  hint: 'Enter tenant\'s email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tenant\'s email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AirbnbTextField(
                  label: 'Phone Number',
                  hint: 'Enter tenant\'s phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tenant\'s phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AirbnbButton(
                  text: 'Continue',
                  onPressed: _nextStep,
                  icon: FontAwesomeIcons.arrowRight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lease Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Specify unit and lease information',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AirbnbCard(
            child: Column(
              children: [
                AirbnbTextField(
                  label: 'Unit Number',
                  hint: 'Enter unit number',
                  controller: _unitController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter unit number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AirbnbTextField(
                  label: 'Monthly Rent (UGX)',
                  hint: 'Enter monthly rent amount',
                  controller: _rentController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter monthly rent';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Lease Start Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _leaseStart == null
                              ? 'Select date'
                              : '${_leaseStart!.day}/${_leaseStart!.month}/${_leaseStart!.year}',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Lease End Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _leaseEnd == null
                              ? 'Select date'
                              : '${_leaseEnd!.day}/${_leaseEnd!.month}/${_leaseEnd!.year}',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AirbnbButton(
                  text: 'Continue',
                  onPressed: _nextStep,
                  icon: FontAwesomeIcons.arrowRight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Details',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Review and confirm tenant information',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AirbnbCard(
            child: Column(
              children: [
                _buildConfirmationItem(
                  'Personal Information',
                  FontAwesomeIcons.user,
                  [
                    'Name: ${_nameController.text}',
                  ],
                ),
                const Divider(),
                _buildConfirmationItem(
                  'Contact Information',
                  FontAwesomeIcons.addressBook,
                  [
                    'Email: ${_emailController.text}',
                    'Phone: ${_phoneController.text}',
                  ],
                ),
                const Divider(),
                _buildConfirmationItem(
                  'Lease Details',
                  FontAwesomeIcons.fileContract,
                  [
                    'Unit: ${_unitController.text}',
                    'Rent: UGX ${_rentController.text}',
                    if (_leaseStart != null)
                      'Start Date: ${_leaseStart!.day}/${_leaseStart!.month}/${_leaseStart!.year}',
                    if (_leaseEnd != null)
                      'End Date: ${_leaseEnd!.day}/${_leaseEnd!.month}/${_leaseEnd!.year}',
                  ],
                ),
                const SizedBox(height: 24),
                AirbnbButton(
                  text: 'Add Tenant',
                  onPressed: _saveTenant,
                  isLoading: _isLoading,
                  icon: FontAwesomeIcons.check,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationItem(String title, IconData icon, List<String> details) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Text(
              detail,
              style: theme.textTheme.bodyMedium,
            ),
          )),
        ],
      ),
    );
  }
}