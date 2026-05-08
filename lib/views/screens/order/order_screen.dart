import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/order/add_order_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/order/detail_order_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_order_section.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/item_pesanan_widget.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _activeFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Pesanan"),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          children: [
            CustomTextfield(
              hintText: "Cari nomor PO, nama perusahaan",
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 12),

            FilterOrderSection(
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
                  return ItemPesananWidget(
                    onTap: () {
                      // navigasi ke detail pesanan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailOrderScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddOrderScreen()),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
        backgroundColor: primaryColor,
        child: Icon(Icons.add_rounded, color: whiteColor),
      ),
    );
  }
}
