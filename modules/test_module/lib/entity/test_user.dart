class TestUser {
  final String id;
  final String name;
  final String password;

  TestUser({required this.id, required this.name, required this.password});

  factory TestUser.fromMap(Map<String, dynamic> map) {
    return TestUser(
      id: map['id'],
      name: map['name'],
      password: map['password'],
    );
  }
}
