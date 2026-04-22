import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Audit'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            CustomTextfield(
              hintText: "Cari nama admin",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    height: 104,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Dino Wahyu",
                              style: boldTextStyle.copyWith(
                                fontSize: 16,
                                color: primaryColor,
                              ),
                            ),
                            Spacer(),
                            CustomBadge(
                              label: "Update",
                              badgeColor: primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Text(
                          "Oct 28, 2026 12:30",
                          style: semiBoldTextStyle.copyWith(
                            fontSize: 12,
                            color: semiSecondaryColor,
                          ),
                        ),
                        Text(
                          "Admin Mengupdate Pemesanan LL20482",
                          style: mediumTextStyle.copyWith(fontSize: 12),
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
