import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/dashboard_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/activity_item_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(title: "CV.Wira Teknik"),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: whiteColor,
        onRefresh: () =>
            ref.read(dashboardViewModelProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat datang Admin!",
                style: mediumTextStyle.copyWith(color: semiSecondaryColor),
              ),
              Text("Dashboard", style: boldTextStyle.copyWith(fontSize: 24)),
              const SizedBox(height: 20),

              // Loading
              if (state.isLoading)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              // Error
              else if (state.errorMessage != null)
                CustomRefreshErrorWidget(
                  message: state.errorMessage!,
                  onPressed: () => ref
                      .read(dashboardViewModelProvider.notifier)
                      .loadDashboard(),
                )
              // Data
              else if (state.data != null)
                _buildCards(state.data!),

              const SizedBox(height: 30),

              // Aktivitas Terakhir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Aktivitas Terakhir",
                    style: boldTextStyle.copyWith(fontSize: 18),
                  ),
                  Text(
                    "Lihat Semua",
                    style: semiBoldTextStyle.copyWith(color: primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (state.isLoading)
                const SizedBox()
              else
                ListView.builder(
                  padding: const EdgeInsets.only(left: 1, top: 1, right: 1),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.data?.aktivitasTerakhir.length ?? 0,
                  itemBuilder: (context, index) {
                    final activity = state.data!.aktivitasTerakhir[index];
                    return ActivityItem(activity: activity);
                  },
                ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCards(DashboardModel data) {
    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      runSpacing: 16,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ItemDashboardAdmin(
                iconSource: "assets/icons/total_pesanan_icon.png",
                title: "TOTAL PESANAN",
                count: "${data.totalPesananCount}",
                subtitle: "Pesanan",
              ),
            ),
            const SizedBox(width: 18),
            Flexible(
              child: ItemDashboardAdmin(
                iconSource: "assets/icons/dikirim_icon.png",
                title: "DIKIRIM",
                count: "${data.dikirimCount}",
                subtitle: "Dalam Perjalanan",
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ItemDashboardAdmin(
                iconSource: "assets/icons/pesanan_selesai_icon.png",
                title: "PESANAN SELESAI",
                count: "${data.pesananSelesaiCount}",
                subtitle: "Selesai",
              ),
            ),
            const SizedBox(width: 18),
            Flexible(
              child: ItemDashboardAdmin(
                iconSource: "assets/icons/belum_bayar_icon.png",
                title: "BELUM BAYAR",
                count: formatRupiah(data.belumBayarAmount),
                subtitle: "${data.belumBayarCount} invoices",
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ItemDashboardAdmin extends StatelessWidget {
  final String iconSource;
  final String title;
  final String count;
  final String subtitle;

  const ItemDashboardAdmin({
    super.key,
    required this.iconSource,
    required this.title,
    required this.count,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.2),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(iconSource, width: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: boldTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: boldTextStyle.copyWith(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          Text(
            subtitle,
            style: mediumTextStyle.copyWith(
              fontSize: 10,
              color: semiSecondaryColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
