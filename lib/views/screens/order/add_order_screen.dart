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
                  "ORDER DETAILS",
                  style: semiBoldTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Transaction Number",
              prefixIcon: Icons.tag,
              hintText: "Enter Transaction Number",
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "PO Number",
              prefixIcon: Icons.content_paste_rounded,
              hintText: "Enter PO Number",
            ),
            const SizedBox(height: 16),

            CustomTextfield(label: "Order Date", prefixIcon: Icons.tag),
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
                  "CUSTOMER INFORMATION",
                  style: semiBoldTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Customer Name",
              prefixIcon: Icons.co_present_rounded,
              hintText: 'Your Name...',
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Phone Number",
              prefixIcon: Icons.phone_rounded,
              hintText: "08....",
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Email Address",
              prefixIcon: Icons.mail_rounded,
              hintText: "email@mail.com",
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              label: "Delivery Address",
              prefixIcon: Icons.mail_rounded,
            ),
            const SizedBox(height: 24),

            // Order Items
            Row(
              children: [
                Image.asset("assets/icons/order_items_icon.png", width: 16),
                const SizedBox(width: 8),
                Text(
                  "ORDER ITEMS",
                  style: semiBoldTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextfield(label: "Item Name", hintText: "Enter item name"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextfield(
                    label: "Price",
                    hintText: "100",
                    prefixIcon: Icons.money_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 126,
                  child: CustomTextfield(label: "Qty", hintText: "1"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 30),

            // buttons
            CustomFilledbutton(
              title: "Save Order",
              iconButton: Icons.save_rounded,
            ),
            const SizedBox(height: 12),
            CustomFilledbutton(
              title: "Cancel",
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
