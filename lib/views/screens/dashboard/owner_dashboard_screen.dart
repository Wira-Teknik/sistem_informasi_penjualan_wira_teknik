import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/dashboard_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/dashboard/all_activity_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/activity_item_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

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
                "Selamat datang Owner!",
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
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllActivityScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Lihat Semua",
                      style: semiBoldTextStyle.copyWith(color: primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!state.isLoading)
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

  Widget _buildCards(DashboardMetricsModel data) {
    return Column(
      children: [
        ItemDashboardOwner(
          backgroundImageUrl:
              "assets/images/card_pengiriman_berlangsung_image.png",
          title: "PENGIRIMAN BERLANGSUNG",
          value: "${data.pengirimanBerlangsungCount}",
          iconUrl: "assets/icons/berlangsung_icon.png",
        ),
        const SizedBox(height: 16),
        ItemDashboardOwner(
          backgroundImageUrl: "assets/images/card_pengiriman_selesai_image.png",
          title: "PENGIRIMAN SELESAI",
          value: "${data.pengirimanSelesaiCount}",
          iconUrl: "assets/icons/selesai_icon.png",
        ),
        const SizedBox(height: 16),
        ItemDashboardOwner(
          backgroundImageUrl: "assets/images/card_pesanan_di_proses_image.png",
          title: "PENGIRIMAN DI PROSES",
          value: "${data.pesananDiprosesCount}",
          iconUrl: "assets/icons/proses_icon.png",
        ),
      ],
    );
  }
}

class ItemDashboardOwner extends StatelessWidget {
  final String backgroundImageUrl;
  final String title;
  final String value;
  final String iconUrl;
  const ItemDashboardOwner({
    super.key,
    required this.backgroundImageUrl,
    required this.title,
    required this.value,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(backgroundImageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.1),
            blurRadius: 0.1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: boldTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
              Spacer(),
              Image.asset(iconUrl, width: 16, height: 16),
            ],
          ),
          Text(
            value,
            style: boldTextStyle.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
