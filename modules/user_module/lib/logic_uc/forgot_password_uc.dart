import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../logic_data/user_data.dart';

class ForgotPasswordUC {
  static final ForgotPasswordUC _instance = ForgotPasswordUC._internal();
  factory ForgotPasswordUC() => _instance;
  ForgotPasswordUC._internal();

  final _userData = UserData();
  final Map<String, _OtpSession> _sessions = {};

  String _generateCode() {
    final rand = Random();
    return (rand.nextInt(900000) + 100000).toString();
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<bool> sendCode(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    if (normalizedEmail.isEmpty || !normalizedEmail.contains("@")) {
      throw Exception("Email không hợp lệ");
    }

    final user = await _userData.getByEmail(normalizedEmail);
    if (user == null) {
      throw Exception("Email chưa được đăng ký");
    }

    final code = _generateCode();
    _sessions[normalizedEmail] = _OtpSession(
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    const username = "2224802010569@student.tdmu.edu.vn";
    const password = "jkpzkigyzjycfayq";
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, "Sale App")
      ..recipients.add(normalizedEmail)
      ..subject = "Mã xác thực tài khoản"
      ..text = "Mã OTP của bạn là: $code\nCó hiệu lực trong 5 phút.";

    try {
      await send(message, smtpServer);
      debugPrint("OTP[$normalizedEmail]: $code");
      return true;
    } catch (e) {
      _sessions.remove(normalizedEmail);
      throw Exception("Gửi email thất bại: $e");
    }
  }

  Future<bool> verifyCode({
    required String email,
    required String code,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final session = _sessions[normalizedEmail];

    if (session == null) {
      throw Exception("Không tìm thấy phiên xác thực, vui lòng gửi lại mã");
    }

    if (DateTime.now().isAfter(session.expiresAt)) {
      _sessions.remove(normalizedEmail);
      throw Exception("Mã xác thực đã hết hạn");
    }

    final isValid = code.trim() == session.code;
    debugPrint("VERIFY[$normalizedEmail]: ${code.trim()} / ${session.code}");

    if (isValid) {
      session.isVerified = true;
    }

    return isValid;
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final session = _sessions[normalizedEmail];

    if (session == null || !session.isVerified) {
      throw Exception("Bạn cần xác thực mã trước khi đổi mật khẩu");
    }

    if (DateTime.now().isAfter(session.expiresAt)) {
      _sessions.remove(normalizedEmail);
      throw Exception("Phiên xác thực đã hết hạn");
    }

    if (newPassword.trim().length < 6) {
      throw Exception("Mật khẩu mới phải có ít nhất 6 ký tự");
    }

    final updated = await _userData.updatePasswordByEmail(
      normalizedEmail,
      newPassword.trim(),
    );

    if (!updated) {
      throw Exception("Không thể cập nhật mật khẩu");
    }

    _sessions.remove(normalizedEmail);
    return true;
  }
}

class _OtpSession {
  final String code;
  final DateTime expiresAt;
  bool isVerified = false;

  _OtpSession({
    required this.code,
    required this.expiresAt,
  });
}
