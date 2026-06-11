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
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/reusable_advance_filter.dart';

// PASTIKAN MENGIMPOR WIDGET ReusableAdvanceFilter DI SINI
// import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/reusable_advance_filter.dart';

class AllActivityScreen extends ConsumerStatefulWidget {
  const AllActivityScreen({super.key});

  @override
  ConsumerState<AllActivityScreen> createState() => _AllActivityScreenState();
}

class _AllActivityScreenState extends ConsumerState<AllActivityScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(activityViewModelProvider);

      if (!state.isLoadMore && !state.hasReachedMax && !state.isLoading) {
        ref
            .read(activityViewModelProvider.notifier)
            .loadActivities(isLoadMore: true);
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  void _showAdvanceFilter(ActivityState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ReusableAdvanceFilter(
          title: 'Filter Aktivitas',
          showDateRange: true,
          initialStartDate: state.startDate,
          initialEndDate: state.endDate,
          hasActiveFilter: state.startDate != null && state.endDate != null,
          onApply: (startDate, endDate, status) async {
            ref
                .read(activityViewModelProvider.notifier)
                .setDateFilter(startDate, endDate);
          },
          onReset: () async {
            ref
                .read(activityViewModelProvider.notifier)
                .setDateFilter(null, null);
          },
        );
      },
    );
  }

  Map<String, List<DashboardActivityItemModel>> _groupByDate(
    List<DashboardActivityItemModel> activities,
  ) {
    final Map<String, List<DashboardActivityItemModel>> grouped = {};
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
      appBar: CustomAppbar(
        title: 'Semua Aktivitas',
        actions: [
          IconButton(
            onPressed: () => _showAdvanceFilter(state),
            icon: Icon(
              Icons.filter_list_rounded,
              size: 28,
              color: state.hasActiveFilter ? primaryColor : secondaryColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Search & Tombol Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextfield(
                    controller: _searchController,
                    hintText: 'Cari aktivitas',
                    prefixIcon: Icons.search,
                    onChanged: (value) => ref
                        .read(activityViewModelProvider.notifier)
                        .search(value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Konten Utama
          Expanded(child: _buildContent(state)),
        ],
      ),
    );
  }

  Widget _buildContent(ActivityState state) {
    if (state.isLoading && state.filteredActivities.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (state.errorMessage != null && state.filteredActivities.isEmpty) {
      return CustomRefreshErrorWidget(
        message: state.errorMessage!,
        onPressed: () =>
            ref.read(activityViewModelProvider.notifier).loadActivities(),
      );
    }

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
              _searchController.text.isNotEmpty || state.startDate != null
                  ? 'Aktivitas tidak ditemukan'
                  : 'Belum ada aktivitas',
              style: regularTextStyle.copyWith(color: semiSecondaryColor),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDate(state.filteredActivities);

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: whiteColor,
      onRefresh: () => ref.read(activityViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: grouped.length + (state.isLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == grouped.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            );
          }

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
  final DashboardActivityItemModel activity;

  const _ActivityItem({required this.activity});

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
