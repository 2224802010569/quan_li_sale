class ManageUserUC {
  final List<Map<String, dynamic>> users = [];

  void addUser(Map<String, dynamic> user) {
    users.add(user);
  }

  List<Map<String, dynamic>> getAll() {
    return users;
  }
}
