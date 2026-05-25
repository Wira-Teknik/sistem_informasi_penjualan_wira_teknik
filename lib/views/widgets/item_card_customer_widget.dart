import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_model.dart';

class ItemCardCustomerWidget extends StatelessWidget {
  const ItemCardCustomerWidget({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomerModel customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: semiSecondaryColor.withValues(alpha: 0.5),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Nama customer
          Row(
            children: [
              Image.asset(
                "assets/icons/building_icon.png",
                width: 20,
                height: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer.customerName.toUpperCase(),
                  style: boldTextStyle.copyWith(
                    fontSize: 16,
                    color: primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Email
          Row(
            children: [
              Icon(Icons.mail_outline, size: 20, color: secondaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer.customerEmail,
                  style: regularTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Telepon
          Row(
            children: [
              Icon(Icons.call_outlined, size: 20, color: secondaryColor),
              const SizedBox(width: 8),
              Text(customer.customerPhone, style: regularTextStyle),
            ],
          ),
          const SizedBox(height: 8),

          Divider(color: secondaryColor.withValues(alpha: 0.1)),
          const SizedBox(height: 4),

          // Alamat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                "assets/icons/location_icon.png",
                width: 20,
                height: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  customer.customerAddress,
                  style: regularTextStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tombol aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: IconButton(
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 24,
                width: 24,
                child: IconButton(
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.delete_outline, color: redColor, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
