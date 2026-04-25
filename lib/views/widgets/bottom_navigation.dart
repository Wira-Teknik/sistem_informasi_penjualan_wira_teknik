import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/audit/audit_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/dashboard/admin_dashboard_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/order/order_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment/payment_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/profile/profile_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardScreen(),
    AuditScreen(),
    OrderScreen(),
    PaymentScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: whiteColor,
            elevation: 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: semiSecondaryColor.withValues(alpha: 0.6),
            selectedLabelStyle: boldTextStyle.copyWith(fontSize: 10),
            unselectedLabelStyle: boldTextStyle.copyWith(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/dashboard_icon.png'),
                  size: 18,
                ),
                label: 'DASHBOARD',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/audit_icon.png'),
                  size: 18,
                ),
                label: 'AUDIT',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/order_icon.png'),
                  size: 18,
                ),
                label: 'PESANAN',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/bayar_icon.png'),
                  size: 18,
                ),
                label: 'BAYAR',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/profile_icon.png'),
                  size: 18,
                ),
                label: 'PROFIL',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
