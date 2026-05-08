import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/card_recap_item.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_recap_widget.dart';

class PaymentRecapDetailTotalPaidScreen extends StatelessWidget {
  const PaymentRecapDetailTotalPaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Detail Total Paid',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined, color: primaryColor),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // periode waktu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periode Waktu',
                      style: boldTextStyle.copyWith(
                        fontSize: 10,
                        color: semiSecondaryColor,
                      ),
                    ),
                    Text('1 Jan 2026 - 31 Jan 2026', style: semiBoldTextStyle),
                  ],
                ),
                Spacer(),
                CustomBadge(label: "142 Orders", badgeColor: greenColor),
              ],
            ),
            const SizedBox(height: 14),

            // card info
            CardRecapItem(
              iconSource: "assets/icons/total_paid_icon.png",
              title: "TOTAL PAID",
              value: "Rp 32.400.000",
              valueColor: greenColor,
            ),
            const SizedBox(height: 10),

            // search bar
            CustomTextfield(
              hintText: "Cari berdasarkan konsumen, PO",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 10),

            // list item
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ItemRecapWidget(
                    noPO: "P5537XJJ22",
                    namaKonsumen: "PT.KIRANA PERMATA",
                    tanggal: "Oct 23, 2026",
                    jumlahTotal: "Rp 2.000.000",
                    badgeName: "Paid",
                    badgeColor: greenColor,
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
