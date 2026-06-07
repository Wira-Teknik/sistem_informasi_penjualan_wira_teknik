import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/functions.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/payment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/payment/add_payment_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/filter_payment_section.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/order_payment_card.dart';

class DetailPaymentScreen extends ConsumerStatefulWidget {
  final CustomerBillingModel billing;

  const DetailPaymentScreen({super.key, required this.billing});

  @override
  ConsumerState<DetailPaymentScreen> createState() =>
      _DetailPaymentScreenState();
}

class _DetailPaymentScreenState extends ConsumerState<DetailPaymentScreen> {
  int _activeFilter = 0;
  String _searchQuery = '';

  // ← Simpan billing lokal agar bisa diupdate
  late CustomerBillingModel _billing;

  @override
  void initState() {
    super.initState();
    _billing = widget.billing; // ← inisialisasi dari parameter
  }

  // ← Ambil billing terbaru dari viewmodel berdasarkan customerName
  void _syncBillingFromState(PaymentState state) {
    final updated = state.billings.firstWhere(
      (b) => b.customerName == _billing.customerName,
      orElse: () => _billing,
    );
    if (updated != _billing) {
      setState(() => _billing = updated);
    }
  }

  List<OrderModel> get _filteredOrders {
    final filterStatus = _filterStatus[_activeFilter];
    var orders = _billing.orders; // ← pakai _billing lokal

    if (filterStatus != null) {
      orders = orders
          .where(
            (o) => o.paymentStatus.toLowerCase() == filterStatus.toLowerCase(),
          )
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final keyword = _searchQuery.toLowerCase();
      orders = orders
          .where(
            (o) =>
                o.poNo.toLowerCase().contains(keyword) ||
                o.transactionNo.toLowerCase().contains(keyword),
          )
          .toList();
    }

    return orders;
  }

  static const _filterStatus = {0: null, 1: 'unpaid', 2: 'partial', 3: 'paid'};

  int get _totalRemainingBalance =>
      _billing.orders.fold(0, (sum, o) => sum + o.remainingBalance);

  String get _overallStatus {
    final orders = _billing.orders;
    if (orders.every((o) => o.paymentStatus.toLowerCase() == 'paid')) {
      return 'Paid';
    } else if (orders.every((o) => o.paymentStatus.toLowerCase() == 'unpaid')) {
      return 'Unpaid';
    }
    return 'Partial';
  }

  Color get _overallStatusColor {
    return switch (_overallStatus) {
      'Paid' => greenColor,
      'Unpaid' => redColor,
      'Partial' => orangeColor,
      _ => semiSecondaryColor,
    };
  }

  Color _paymentStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'paid' => greenColor,
      'partial' => orangeColor,
      'unpaid' => redColor,
      _ => semiSecondaryColor,
    };
  }

  String _paymentStatusLabel(String status) {
    return switch (status.toLowerCase()) {
      'paid' => 'Paid',
      'partial' => 'Partial',
      'unpaid' => 'Unpaid',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    // ← Pantau perubahan state — sync billing saat data berubah
    ref.listen<PaymentState>(paymentViewModelProvider, (previous, next) {
      // Hanya sync jika tidak sedang loading dan billings sudah ada
      if (!next.isLoading && next.billings.isNotEmpty) {
        _syncBillingFromState(next);
      }
    });

    final paymentState = ref.watch(paymentViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(title: 'Detail Pembayaran'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // Informasi pembayaran customer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: semiSecondaryColor.withValues(alpha: 0.5),
                    blurRadius: 0.5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _billing.customerName.toUpperCase(),
                              style: boldTextStyle.copyWith(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _overallStatus,
                              style: semiBoldTextStyle.copyWith(
                                fontSize: 12,
                                color: _overallStatusColor,
                              ),
                            ),
                            Text(
                              _totalRemainingBalance == 0
                                  ? ''
                                  : formatRupiah(_totalRemainingBalance),
                              style: boldTextStyle.copyWith(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Image.asset("assets/icons/wallet_icon.png", width: 34),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Loading saat submit payment
                  if (paymentState.isSubmitting)
                    Center(
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            color: primaryColor,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Memproses pembayaran...',
                            style: regularTextStyle.copyWith(
                              fontSize: 12,
                              color: semiSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_totalRemainingBalance == 0)
                    CustomInfoMessageWidget(
                      color: greenColor,
                      message: 'Semua pembayaran sudah lunas',
                      icons: Icons.check_rounded,
                    )
                  else
                    CustomFilledbutton(
                      title: "Catat Pembayaran",
                      iconButton: Icons.payments_outlined,
                      onPressed: () async {
                        final success = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPaymentScreen(
                              billing: _billing, // ← pakai _billing lokal
                            ),
                          ),
                        );

                        // ← Viewmodel sudah reload di addPayment()
                        // ref.listen di atas otomatis sync _billing
                        if (success == true && mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: CustomInfoMessageWidget(
                                color: greenColor,
                                message: 'Pembayaran berhasil dicatat',
                                icons: Icons.check_rounded,
                              ),
                              backgroundColor: whiteColor,
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Aktivitas Pesanan",
              style: boldTextStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),

            CustomTextfield(
              hintText: "Cari nomor PO",
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 14),

            FilterPaymentSection(
              activeFilter: _activeFilter,
              onFilterChanged: (index) => setState(() => _activeFilter = index),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: _filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data',
                        style: regularTextStyle.copyWith(
                          color: semiSecondaryColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 1, bottom: 24),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return OrderPaymentCard(
                          order: _filteredOrders[index],
                          formatRupiah: formatRupiah,
                          paymentStatusColor: _paymentStatusColor,
                          paymentStatusLabel: _paymentStatusLabel,
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
