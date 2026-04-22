import 'package:flutter/material.dart';

class VerifyCard extends StatelessWidget {
  final TextEditingController codeCtrl;
  final Future<void> Function() onVerify;
  final String error;
  final String time;
  final bool loading;

  const VerifyCard({
    super.key,
    required this.codeCtrl,
    required this.onVerify,
    required this.error,
    required this.time,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x140D47A1),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: codeCtrl,
            keyboardType: TextInputType.number,
            onSubmitted: (_) => loading ? null : onVerify(),
            decoration: const InputDecoration(hintText: "Nhập mã 6 số"),
          ),

          const SizedBox(height: 16),

          if (error.isNotEmpty)
            Text(error, style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: loading ? null : onVerify,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Xác thực"),
          ),

          const SizedBox(height: 12),

          Text("Hết hạn sau: $time"),
        ],
      ),
    );
  }
}
