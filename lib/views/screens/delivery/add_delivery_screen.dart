import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/barang_dikirim_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_upload_proof_widget.dart';

class AddDeliveryScreen extends StatelessWidget {
  const AddDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Buat Pengiriman"),
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

            // bukti kirim
            CustomUploadProofWidget(label: "Bukti Kirim", onTap: () {}),
            const SizedBox(height: 16),

            // surat jalan
            CustomUploadProofWidget(label: "Unggah Surat Jalan", onTap: () {}),
            const SizedBox(height: 16),

            // bon pesanan
            CustomUploadProofWidget(label: "Unggah Bon Pesanan", onTap: () {}),
            const SizedBox(height: 16),

            // invoice
            CustomUploadProofWidget(label: "Unggah Invoice", onTap: () {}),
            const SizedBox(height: 16),

            // barang yang dikirim
            BarangDikirimWidget(),
            const SizedBox(height: 40),

            // buttons
            CustomFilledbutton(
              title: "Kirim Barang",
              iconButton: Icons.edit_note_rounded,
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
