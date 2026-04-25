class RouteStoreInput {
  final bool requireLogin;

  RouteStoreInput({required this.requireLogin});

  factory RouteStoreInput.requireLogin() {
    return RouteStoreInput(requireLogin: true);
  }

  bool isValid({String? userId, String? role}) {
    if (requireLogin && userId == null) return false;
    return true;
  }

  String defaultView(String role) {
    if (role == 'Manager') return 'HOME_MANAGER';
    return 'HOME_SALE';
  }
}
