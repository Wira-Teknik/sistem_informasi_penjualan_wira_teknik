import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class AddCustomerScreen extends StatelessWidget {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Tambah Konsumen"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          children: [
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

            // buttons
            CustomFilledbutton(
              title: "Tambah Konsumen",
              iconButton: Icons.save_rounded,
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
