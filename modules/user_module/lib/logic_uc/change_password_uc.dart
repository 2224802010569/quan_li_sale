class ChangePasswordUC {
  bool execute(String oldPass, String newPass) {
    if (oldPass == "123") {
      return true;
    }
    return false;
  }
}
