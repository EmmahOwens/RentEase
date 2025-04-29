import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_smart/core/constants.dart';
import 'package:rent_smart/core/widgets/custom_button.dart';
import 'package:rent_smart/core/widgets/custom_text_field.dart';
import 'package:rent_smart/features/properties/models/property.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalUnitsController = TextEditingController();
  PropertyType _selectedType = PropertyType.residential;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _totalUnitsController.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to add a property.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final newProperty = Property(
          id: '', // Firestore will generate ID
          name: _nameController.text,
          address: _addressController.text,
          type: _selectedType,
          totalUnits: int.tryParse(_totalUnitsController.text) ?? 0,
          ownerId: user.uid,
          createdAt: DateTime.now(), // Firestore timestamp will override
        );

        await FirebaseFirestore.instance
            .collection('properties')
            .add(newProperty.toFirestore());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property added successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add property: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Property Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: kDefaultPadding),
              CustomTextField(
                controller: _nameController,
                label: 'Property Name',
                hint: 'e.g., Acacia Apartments',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter property name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kDefaultPadding),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'e.g., 123 Main St, Kampala',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter property address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kDefaultPadding),
              CustomTextField(
                controller: _totalUnitsController,
                label: 'Total Units',
                hint: 'e.g., 10',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total number of units';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number of units';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kDefaultPadding),
              DropdownButtonFormField<PropertyType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Property Type',
                  border: OutlineInputBorder(),
                ),
                items: PropertyType.values.map((PropertyType type) {
                  return DropdownMenuItem<PropertyType>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (PropertyType? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: kDefaultPadding * 2),
              CustomButton(
                text: 'Add Property',
                onPressed: _saveProperty,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}