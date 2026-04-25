import 'package:flutter/material.dart';
import '../../../entity/user.dart';

class ManagerCard extends StatelessWidget {
  final List<User> users;
  final TextEditingController onSearch;
  final Function(User) onTapUser;
  final VoidCallback onAdd;

  const ManagerCard({
    required this.users,
    required this.onSearch,
    required this.onTapUser,
    required this.onAdd,
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          const Text(
            "Danh sách nhân sự",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          /// SEARCH
          TextField(
            controller: onSearch,
            decoration: InputDecoration(
              hintText: "Tìm kiếm nhân viên...",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 16),

          /// LIST
          SizedBox(
            height: 320,
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final u = users[i];

                return GestureDetector(
                  onTap: () => onTapUser(u),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                u.phone,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          /// BUTTON
          GestureDetector(
            onTap: onAdd,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF003178),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Center(
                child: Text(
                  "Thêm nhân viên",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
