class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isVerified;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'isVerified': isVerified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}