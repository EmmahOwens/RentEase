import 'package:cloud_firestore/cloud_firestore.dart';

enum PropertyType { residential, commercial, mixedUse }

class Property {
  final String id;
  final String name;
  final String address;
  final PropertyType type;
  final int totalUnits;
  final String ownerId; // Link to the landlord/user
  final List<String> imageUrls;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.totalUnits,
    required this.ownerId,
    this.imageUrls = const [],
    required this.createdAt,
  });

  // Factory constructor to create a Property from a Firestore document
  factory Property.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Property(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      type: PropertyType.values.firstWhere(
        (e) => e.toString() == 'PropertyType.${data['type']}',
        orElse: () => PropertyType.residential, // Default type
      ),
      totalUnits: (data['totalUnits'] as num?)?.toInt() ?? 0,
      ownerId: data['ownerId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to convert a Property instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'type': type.toString().split('.').last,
      'totalUnits': totalUnits,
      'ownerId': ownerId,
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(), // Set timestamp on creation
    };
  }
}