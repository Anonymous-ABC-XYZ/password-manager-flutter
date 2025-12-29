class Credential {
  final String website;
  final String username;
  final String email;
  final String password;
  final String? category;

  Credential({
    required this.website,
    required this.username,
    required this.email,
    required this.password,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'Website': website,
      'Username': username,
      'Email': email,
      'Password': password,
      'category': category,
    };
  }

  factory Credential.fromMap(Map<String, dynamic> map) {
    return Credential(
      website: map['Website'] as String,
      username: map['Username'] as String,
      email: map['Email'] as String,
      password: map['Password'] as String,
      category: map['category'] as String?,
    );
  }
}
