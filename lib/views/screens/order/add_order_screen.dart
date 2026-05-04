import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class AddOrderScreen extends StatelessWidget {
  const AddOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Pesanan Baru"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 17, right: 17, bottom: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Order Details
            Row(
              children: [
                Image.asset("assets/icons/order_detail_icon.png", width: 16),
                const SizedBox(width: 8),
                Text(
                  "DETAIL PESANAN",
                  style: semiBoldTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextfield(label: "Nomor Transaksi", prefixIcon: Icons.tag),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Nomor PO",
              prefixIcon: Icons.content_paste_outlined,
              hintText: "Enter PO Number",
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Tanggal Pesan",
              prefixIcon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 24),

            // Customer Information
            Row(
              children: [
                Image.asset(
                  "assets/icons/customer_information_icon.png",
                  width: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  "INFORMASI KONSUMEN",
                  style: semiBoldTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Nama Konsumen",
              prefixIcon: Icons.badge_outlined,
              hintText: 'PT....',
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Nomor Telepon",
              prefixIcon: Icons.phone_outlined,
              hintText: "08....",
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Alamat Email",
              prefixIcon: Icons.mail_outline_outlined,
              hintText: "email@mail.com",
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Alamat Pengiriman",
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),

            // Order Items
            Row(
              children: [
                Image.asset("assets/icons/order_items_icon.png", width: 16),
                const SizedBox(width: 8),
                Text(
                  "BARANG PESANAN",
                  style: semiBoldTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextfield(label: "Nama Barang", hintText: "Enter item name"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextfield(
                    label: "Harga",
                    hintText: "100",
                    prefixIcon: Icons.money_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 126,
                  child: CustomTextfield(label: "Jumlah", hintText: "1"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 30),

            // buttons
            CustomFilledbutton(
              title: "Buat Pesanan",
              iconButton: Icons.save_rounded,
            ),
            const SizedBox(height: 12),
            CustomFilledbutton(
              title: "Batalkan",
              buttonColor: semiSecondaryColor.withValues(alpha: 0.1),
              titleButtonColor: semiSecondaryColor,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
