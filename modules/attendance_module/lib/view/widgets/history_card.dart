import 'package:flutter/material.dart';
import '../../entity/attendance.dart';

class HistoryCard extends StatelessWidget {
  final Attendance attendance;

  const HistoryCard({Key? key, required this.attendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simple format time since we aren't using intl
    String formatTime(DateTime time) {
      String hour = time.hour > 12 ? '${time.hour - 12}' : '${time.hour == 0 ? 12 : time.hour}';
      hour = hour.padLeft(2, '0');
      String minute = time.minute.toString().padLeft(2, '0');
      String amPm = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $amPm';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image part
          Row(
            children: [
              // Check-in Image
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)),
                      child: Image.network(
                        attendance.checkinImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                              SizedBox(height: 4),
                              Text('Lỗi tải ảnh', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9), // Keeping single withOpacity for tiny tags
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'CHECK-IN',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Separator
              Container(width: 2, height: 150, color: Colors.white),
              // Check-out Image
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(12)),
                      child: Builder(builder: (context) {
                        final isCompleted = attendance.status == 'Completed';
                        final hasPhoto = attendance.checkoutImage.isNotEmpty;

                        if (!isCompleted) {
                          // Chưa check-out
                          return Container(
                            height: 150,
                            width: double.infinity,
                            color: const Color(0xFFF4F6FA),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pending_actions, size: 40, color: Colors.orange),
                                SizedBox(height: 8),
                                Text(
                                  'Waiting for Check-out',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        } else if (hasPhoto) {
                          // Đã check-out + có ảnh thật
                          return Image.network(
                            attendance.checkoutImage,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildCheckedOutPlaceholder(),
                          );
                        } else {
                          // Đã check-out nhưng không có ảnh
                          return _buildCheckedOutPlaceholder();
                        }
                      }),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'CHECK-OUT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Info part
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      attendance.storeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      formatTime(attendance.time),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F3c8f), // Navy
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      attendance.locationAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckedOutPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: const Color(0xFFE8F5E9),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 40, color: Color(0xFF388E3C)),
          SizedBox(height: 8),
          Text(
            'Đã Check-out',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF388E3C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
