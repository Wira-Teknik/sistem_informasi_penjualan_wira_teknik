import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_history_transaction_section.dart';

class HistoryTransactionScreen extends StatefulWidget {
  const HistoryTransactionScreen({super.key});

  @override
  State<HistoryTransactionScreen> createState() =>
      _HistoryTransactionScreenState();
}

class _HistoryTransactionScreenState extends State<HistoryTransactionScreen> {
  int _activeFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Laporan Riwayat Transaksi",
        actions: [
          IconButton(
            icon: Icon(Icons.file_download_outlined, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          children: [
            CustomTextfield(
              hintText: "Cari nomor PO",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 12),

            FilterHistoryTransactionSection(
              onFilterChanged: (index) {
                // update data di parent tanpa rebuild seluruh halaman
                setState(() => _activeFilter = index);
              },
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(
                      left: 1,
                      right: 1,
                      top: 1,
                      bottom: 16,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: semiSecondaryColor.withValues(alpha: 0.5),
                          blurRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TXN-8842 | P2152KPT22",
                                  style: semiBoldTextStyle.copyWith(
                                    fontSize: 12,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  "PT.KIRANA PERMATA",
                                  style: boldTextStyle.copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                            const Spacer(),
                            CustomBadge(
                              label: "Partial",
                              badgeColor: orangeColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Admin - Dino",
                                  style: mediumTextStyle.copyWith(fontSize: 12),
                                ),
                                Text(
                                  "Nov 05, 2026 12:10",
                                  style: regularTextStyle.copyWith(
                                    fontSize: 12,
                                    color: semiSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "JUMLAH TOTAL",
                                  style: boldTextStyle.copyWith(
                                    fontSize: 10,
                                    color: semiSecondaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),

                                Text(
                                  "Rp 500.000",
                                  style: boldTextStyle.copyWith(
                                    fontSize: 16,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
