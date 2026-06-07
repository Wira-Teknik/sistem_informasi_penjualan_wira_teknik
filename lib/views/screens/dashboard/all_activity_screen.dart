import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/activity_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class AllActivityScreen extends ConsumerStatefulWidget {
  const AllActivityScreen({super.key});

  @override
  ConsumerState<AllActivityScreen> createState() => _AllActivityScreenState();
}

class _AllActivityScreenState extends ConsumerState<AllActivityScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // Kelompokkan aktivitas berdasarkan tanggal
  Map<String, List<ActivityModel>> _groupByDate(
    List<ActivityModel> activities,
  ) {
    final Map<String, List<ActivityModel>> grouped = {};
    for (final activity in activities) {
      final date = _formatDate(activity.date);
      grouped.putIfAbsent(date, () => []).add(activity);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(title: 'Semua Aktivitas'),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CustomTextfield(
              controller: _searchController,
              hintText: 'Cari aktivitas',
              prefixIcon: Icons.search,
              onChanged: (value) =>
                  ref.read(activityViewModelProvider.notifier).search(value),
            ),
          ),

          Expanded(child: _buildContent(state)),
        ],
      ),
    );
  }

  Widget _buildContent(ActivityState state) {
    // Loading
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    // Error
    if (state.errorMessage != null) {
      return CustomRefreshErrorWidget(
        message: state.errorMessage!,
        onPressed: () =>
            ref.read(activityViewModelProvider.notifier).loadActivities(),
      );
    }

    // Kosong
    if (state.filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: semiSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Aktivitas tidak ditemukan'
                  : 'Belum ada aktivitas',
              style: regularTextStyle.copyWith(color: semiSecondaryColor),
            ),
          ],
        ),
      );
    }

    // Kelompokkan berdasarkan tanggal
    final grouped = _groupByDate(state.filteredActivities);

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: whiteColor,
      onRefresh: () => ref.read(activityViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final date = grouped.keys.elementAt(index);
          final activities = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label tanggal
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        date,
                        style: semiBoldTextStyle.copyWith(
                          fontSize: 11,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(
                        color: semiSecondaryColor.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),

              // List aktivitas per tanggal
              ...activities.map(
                (activity) => _ActivityItem(activity: activity),
              ),

              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityModel activity;

  const _ActivityItem({required this.activity});

  // Ikon berdasarkan judul aktivitas
  IconData _getIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('pengiriman')) return Icons.local_shipping_outlined;
    if (t.contains('pembayaran')) return Icons.payments_outlined;
    if (t.contains('pesanan')) return Icons.receipt_long_outlined;
    if (t.contains('konfirmasi')) return Icons.check_circle_outlined;
    return Icons.notifications_outlined;
  }

  Color _getIconColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('konfirmasi') || t.contains('selesai')) return greenColor;
    if (t.contains('pembayaran')) return primaryColor;
    if (t.contains('dikirim')) return orangeColor;
    return semiSecondaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getIconColor(activity.title).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIcon(activity.title),
              size: 18,
              color: _getIconColor(activity.title),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: boldTextStyle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: regularTextStyle.copyWith(
                    fontSize: 12,
                    color: semiSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
