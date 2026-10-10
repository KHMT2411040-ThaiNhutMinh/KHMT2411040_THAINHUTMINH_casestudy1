import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _primaryBlue = Color(0xFF2F6FED);

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng đang được phát triển')),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? const Color(0xFF1B1B3A);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color ?? _primaryBlue, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: itemColor,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cá nhân',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B3A),
                ),
              ),
              const SizedBox(height: 16),

              // Thẻ thông tin người dùng
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _primaryBlue.withOpacity(0.15),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: _primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nguyễn Văn A',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B1B3A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'nguyenvana@example.com',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Danh sách chức năng
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _menuItem(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      onTap: () => _showComingSoon(context),
                    ),
                    const Divider(height: 1, indent: 52, color: Color(0xFFEDEFF5)),
                    _menuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Cài đặt ngân sách',
                      onTap: () => _showComingSoon(context),
                    ),
                    const Divider(height: 1, indent: 52, color: Color(0xFFEDEFF5)),
                    _menuItem(
                      icon: Icons.notifications_none,
                      title: 'Thông báo',
                      onTap: () => _showComingSoon(context),
                    ),
                    const Divider(height: 1, indent: 52, color: Color(0xFFEDEFF5)),
                    _menuItem(
                      icon: Icons.help_outline,
                      title: 'Trợ giúp & hỗ trợ',
                      onTap: () => _showComingSoon(context),
                    ),
                    const Divider(height: 1, indent: 52, color: Color(0xFFEDEFF5)),
                    _menuItem(
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      color: const Color(0xFFE53935),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}