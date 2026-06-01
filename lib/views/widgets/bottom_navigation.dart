import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/dashboard_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/login_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/audit/audit_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/dashboard/admin_dashboard_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/dashboard/owner_dashboard_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/order/order_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment/payment_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/profile/profile_screen.dart';

class BottomNavigation extends ConsumerStatefulWidget {
  const BottomNavigation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomNavigationState();
}

class _BottomNavigationState extends ConsumerState<BottomNavigation> {
  int _currentIndex = 0;

  List<Widget> _getPages(String role) {
    if (role == 'owner') {
      return const [OwnerDashboardScreen(), AuditScreen(), ProfileScreen()];
    }
    return const [
      AdminDashboardScreen(),
      OrderScreen(),
      PaymentScreen(),
      ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> _getNavItems(String role) {
    const dashboard = BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/dashboard_icon.png'), size: 18),
      label: 'DASHBOARD',
    );
    const audit = BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/audit_icon.png'), size: 18),
      label: 'AUDIT',
    );
    const order = BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/order_icon.png'), size: 18),
      label: 'PESANAN',
    );
    const payment = BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/bayar_icon.png'), size: 18),
      label: 'BAYAR',
    );
    const profile = BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/profile_icon.png'), size: 18),
      label: 'PROFIL',
    );

    if (role == 'owner') return [dashboard, audit, profile];
    return [dashboard, order, payment, profile];
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _triggerReload(index);
  }

  void _triggerReload(int index) {
    final role = ref.read(loginViewModelProvider).user?.role ?? 'admin';

    if (role == 'owner') {
      switch (index) {
        case 0:
          ref.read(dashboardViewModelProvider.notifier).refresh();
          break;
        case 1:
          break;
        case 2: // Profile — tidak perlu reload
          break;
      }
    } else {
      switch (index) {
        case 0:
          ref.read(dashboardViewModelProvider.notifier).refresh();
          break;
        case 1:
          break;
        case 2:
          ref.read(paymentViewModelProvider.notifier).refresh();
          break;
        case 3: // Profile — tidak perlu reload
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final role = state.user?.role ?? 'admin';
    final pages = _getPages(role);
    final navItems = _getNavItems(role);
    final safeIndex = _currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: whiteColor,
            elevation: 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: semiSecondaryColor.withValues(alpha: 0.6),
            selectedLabelStyle: boldTextStyle.copyWith(fontSize: 10),
            unselectedLabelStyle: boldTextStyle.copyWith(fontSize: 10),
            items: navItems,
          ),
        ),
      ),
    );
  }
}
