import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_upload_proof_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/menunggu_pembayaran_widget.dart';

class AddPaymentScreen extends StatelessWidget {
  const AddPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Catat Pembayaran"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // tanggal kirim
            CustomTextfield(
              label: "Tanggal Kirim",
              prefixIcon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 16),

            // total jumlah uang
            CustomTextfield(
              label: "Total Jumlah Uang",
              prefixIcon: Icons.money_outlined,
            ),
            const SizedBox(height: 16),

            // unggah bukti bayar
            CustomUploadProofWidget(label: "Unggah Bukti Bayar", onTap: () {}),
            const SizedBox(height: 16),

            // menunggu pembayaran
            MenungguPembayaranWidget(),
            const SizedBox(height: 56),

            // button
            CustomFilledbutton(
              title: "Simpan Pembayaran",
              iconButton: Icons.save_outlined,
              buttonRadius: 12,
            ),
            const SizedBox(height: 12),

            CustomFilledbutton(
              title: "Batalkan",
              buttonColor: semiSecondaryColor.withValues(alpha: 0.1),
              titleButtonColor: semiSecondaryColor,
              buttonRadius: 12,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
