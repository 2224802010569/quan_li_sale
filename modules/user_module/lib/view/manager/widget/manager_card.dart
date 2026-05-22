import 'package:flutter/material.dart';
import '../../../entity/user.dart';

class ManagerCard extends StatelessWidget {
  final List<User> users;
  final TextEditingController onSearch;
  final Function(User) onTapUser;
  final Function(User) onDeleteUser;
  final String? deletingUserId;
  final VoidCallback onAdd;

  const ManagerCard({
    super.key,
    required this.users,
    required this.onSearch,
    required this.onTapUser,
    required this.onDeleteUser,
    this.deletingUserId,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x140D47A1),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
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
          /// LIST
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final u = users[i];
              final deleting = deletingUserId == u.id;

              return Material(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: u.avatarUrl.isNotEmpty ? NetworkImage(u.avatarUrl) : null,
                        child: u.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: "Xem hồ sơ",
                        onPressed: () => onTapUser(u),
                        icon: const Icon(Icons.chevron_right),
                      ),
                      IconButton(
                        tooltip: "Xóa nhân viên",
                        onPressed: deleting ? null : () => onDeleteUser(u),
                        color: Colors.red,
                        icon: deleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
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
