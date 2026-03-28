import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  List<OrderItem> items = [OrderItem()];

  void addItem() {
    setState(() {
      items.add(OrderItem());
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 22,
            color: primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambah Pemesanan",
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0.5,
        shadowColor: semiSecondaryColor.withValues(alpha: 0.2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= BASIC INFORMATION =================
              _buildTextField("Transaction No", "NF/WT/0002/2026"),
              const SizedBox(height: 20),
              _buildTextField("PO Number", "PO-XXXX"),
              const SizedBox(height: 20),
              _buildDateField("Order Date"),
              const SizedBox(height: 20),
              _buildTextField("Customer Name", "PT. Example"),
              const SizedBox(height: 20),
              _buildTextField("Customer Contact (No HP)", "0812..."),
              const SizedBox(height: 20),
              _buildTextField("Customer Email", "email@example.com"),
              const SizedBox(height: 20),
              _buildTextField(
                "Delivery Address",
                "Jl. Sudirman No 1...",
                maxLines: 2,
              ),

              const SizedBox(height: 20),
              Divider(color: semiSecondaryColor.withValues(alpha: 0.5)),
              const SizedBox(height: 20),

              /// ================= ORDER ITEMS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Order Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  OutlinedButton(
                    onPressed: addItem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: primaryColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                        SizedBox(width: 2),
                        Text("Tambah", style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(items.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTextField("Item Name", "Part Name"),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(child: _buildTextField("Qty", "1")),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField("Unit Price", "0"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (items.length > 1)
                            SizedBox(
                              width: 80,
                              child: OutlinedButton(
                                onPressed: () => removeItem(index),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: BorderSide(color: Colors.red),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_forever_rounded,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      "Hapus",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          Divider(
                            color: semiSecondaryColor.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 10),

              /// ================= BUTTONS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        Text("Batalkan", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // save order
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(children: [Text("Simpan Pesanan")]),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= HELPER WIDGETS =================
Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: primaryColor.withValues(alpha: 0.2),
        ),
      ),
    ],
  );
}

Widget _buildDateField(String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: "mm/dd/yyyy",
          suffixIcon: const Icon(Icons.calendar_today),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: primaryColor.withValues(alpha: 0.2),
        ),
      ),
    ],
  );
}

class OrderItem {}
