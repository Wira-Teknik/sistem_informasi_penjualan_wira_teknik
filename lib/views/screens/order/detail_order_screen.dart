import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/attachment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/order_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/shipment_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/delivery/add_delivery_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/order/edit_order_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_filledbutton.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_info_message_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_upload_proof_widget.dart';

class DetailOrderScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const DetailOrderScreen({super.key, required this.order});

  @override
  ConsumerState<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends ConsumerState<DetailOrderScreen> {
  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  // Refresh dari list order di viewmodel
  Future<void> _onRefresh() async {
    final updated = await ref
        .read(orderViewModelProvider.notifier)
        .refreshDetail(_order.id);
    debugPrint('UPDATED ORDER: ${updated?.shipments.length}');
    // Update tampilan jika berhasil
    if (updated != null) {
      setState(() => _order = updated);
    }
  }

  // Format rupiah
  String _formatRupiah(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // Format tanggal
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // Warna badge order status
  Color _orderStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => primaryColor,
      'partial' => yellowColor,
      'shipped' => yellowColor,
      'completed' => greenColor,
      _ => semiSecondaryColor,
    };
  }

  // Label badge order status
  String _orderStatusLabel(String status) {
    return switch (status.toLowerCase()) {
      'pending' => 'Pending',
      'partial' => 'Partial',
      'shipped' => 'Shipped',
      'completed' => 'Completed',
      _ => status,
    };
  }

  // Warna badge shipping status
  Color _shippingStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'dikirim' => yellowColor,
      'diterima' => greenColor,
      _ => semiSecondaryColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Detail Pesanan",
        actions: [
          if (_order.orderStatus.toUpperCase() != "COMPLETED")
            IconButton(
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditOrderScreen(order: _order),
                  ),
                );

                // Jika ada update, ambil data terbaru dari state
                if (updated == true) {
                  final latest = ref
                      .read(orderViewModelProvider)
                      .orders
                      .firstWhere(
                        (o) => o.id == _order.id,
                        orElse: () => _order,
                      );

                  setState(() => _order = latest);
                }
              },
              icon: ImageIcon(
                const AssetImage("assets/icons/edit_pesanan.png"),
                color: secondaryColor,
                size: 20,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi pesanan
              _buildOrderInfoCard(),
              const SizedBox(height: 20),

              // Informasi konsumen
              Text("INFORMASI KONSUMEN", style: boldTextStyle),
              const SizedBox(height: 12),
              _buildRecipientCard(),
              const SizedBox(height: 20),

              // Barang pesanan
              Text(
                "BARANG PESANAN (${_order.items.length})",
                style: boldTextStyle,
              ),
              const SizedBox(height: 12),
              _buildItemsCard(),
              const SizedBox(height: 20),

              // Status pembayaran
              Text("STATUS PEMBAYARAN", style: boldTextStyle),
              const SizedBox(height: 12),
              _buildPaymentCard(),
              const SizedBox(height: 20),

              // Pengiriman
              if (_order.shipments.isNotEmpty) ...[
                Text("PENGIRIMAN", style: boldTextStyle),
                const SizedBox(height: 12),
                ..._order.shipments.map(
                  (shipment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildShipmentCard(shipment),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Tombol buat pengiriman
              if (_order.orderStatus.toUpperCase() != "COMPLETED")
                CustomFilledbutton(
                  title: "Buat Pengiriman",
                  iconButton: Icons.edit_note_rounded,
                  buttonRadius: 12,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddDeliveryScreen(order: _order),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // Card informasi pesanan
  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/icons/box_icon.png",
                    width: 18,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "No Transaksi",
                    style: semiBoldTextStyle.copyWith(
                      fontSize: 12,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _order.transactionNo,
                style: boldTextStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                "Updated: ${_formatDate(_order.updatedAt)}",
                style: regularTextStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          CustomBadge(
            label: _orderStatusLabel(_order.orderStatus),
            badgeColor: _orderStatusColor(_order.orderStatus),
          ),
        ],
      ),
    );
  }

  // Card informasi konsumen
  Widget _buildRecipientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/icons/company_icon.png",
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order.recipientName.toUpperCase(),
                      style: boldTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "No PO: ${_order.poNo}",
                      style: regularTextStyle.copyWith(
                        fontSize: 12,
                        color: semiSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            _order.recipientEmail,
            style: regularTextStyle.copyWith(color: semiSecondaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            _order.recipientPhone,
            style: regularTextStyle.copyWith(color: semiSecondaryColor),
          ),

          const SizedBox(height: 10),
          Divider(color: semiSecondaryColor.withValues(alpha: 0.2)),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                "assets/icons/location_icon.png",
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _order.recipientAddress,
                  style: regularTextStyle.copyWith(color: semiSecondaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card daftar barang
  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: _order.items.asMap().entries.map((entry) {
          final item = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName, style: semiBoldTextStyle),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _formatRupiah(item.unitPrice),
                    style: boldTextStyle.copyWith(color: primaryColor),
                  ),
                  const Spacer(),
                  Text(
                    "x ${item.orderQty}",
                    style: boldTextStyle.copyWith(color: primaryColor),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Divider(color: semiSecondaryColor.withValues(alpha: 0.2)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Card status pembayaran
  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Status Sekarang", style: semiBoldTextStyle),
              const Spacer(),
              // Status pembayaran belum ada di model order
              // sesuaikan saat endpoint payment tersedia
              CustomBadge(label: "Unpaid", badgeColor: redColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "JUMLAH TOTAL",
                style: boldTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
              const Spacer(),
              Text(
                _formatRupiah(_order.totalAmount),
                style: boldTextStyle.copyWith(color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card per shipment
  Widget _buildShipmentCard(ShipmentModel shipment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (shipment.shippingStatus.toUpperCase() == "DIKIRIM") ...[
                SizedBox(
                  height: 18,
                  width: 18,
                  child: IconButton(
                    onPressed: () {},
                    icon: ImageIcon(
                      const AssetImage("assets/icons/edit_pengiriman_icon.png"),
                      size: 18,
                      color: secondaryColor,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              CustomBadge(
                label: shipment.shippingStatus.toUpperCase(),
                badgeColor: _shippingStatusColor(shipment.shippingStatus),
              ),
              const Spacer(),
              Text(
                _formatDate(shipment.shippingDate),
                style: regularTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item pengiriman — match dengan item order by order_item_id
          ...shipment.items.map((shipItem) {
            final orderItem = _order.items.firstWhere(
              (o) => o.id == shipItem.orderItemId,
              orElse: () => OrderItemModel(
                id: '',
                orderId: '',
                productName: 'Produk tidak diketahui',
                orderQty: 0,
                remainingQty: 0,
                unitPrice: 0,
                ppn: 0,
                subtotal: 0,
                createdAt: '',
                updatedAt: '',
              ),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      orderItem.productName,
                      style: semiBoldTextStyle,
                    ),
                  ),
                  Text(
                    "x ${shipItem.shippingQty}",
                    style: semiBoldTextStyle.copyWith(color: primaryColor),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomFilledbutton(
                title: "Dokumen Pendukung",
                buttonColor: secondaryColor,
                buttonRadius: 20,
                buttonTitleSize: 10,
                onPressed: () => _showDokumenDialog(context, shipment.id),
              ),

              if (shipment.shippingStatus.toUpperCase() == "DIKIRIM") ...[
                const SizedBox(width: 10),
                CustomFilledbutton(
                  title: "Unggah Bukti",
                  buttonRadius: 20,
                  buttonTitleSize: 10,
                  onPressed: () =>
                      _showConfirmReceivedDialog(context, shipment.id),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmReceivedDialog(BuildContext context, String shipmentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ConfirmReceivedDialog(
        shipmentId: shipmentId,
        onSuccess: () {
          // Refresh detail setelah berhasil
          _onRefresh();
        },
      ),
    );
  }

  void _showDokumenDialog(BuildContext context, String shipmentId) {
    // Reset & load attachments saat dialog dibuka
    ref.read(shipmentViewModelProvider.notifier).loadAttachments(shipmentId);

    showDialog(
      context: context,
      builder: (context) => _DokumenPendukungDialog(shipmentId: shipmentId),
    );
  }

  // Dekorasi card yang konsisten
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: whiteColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: secondaryColor.withValues(alpha: 0.3), blurRadius: 1),
      ],
    );
  }
}

class _ConfirmReceivedDialog extends ConsumerStatefulWidget {
  final String shipmentId;
  final VoidCallback onSuccess;

  const _ConfirmReceivedDialog({
    required this.shipmentId,
    required this.onSuccess,
  });

  @override
  ConsumerState<_ConfirmReceivedDialog> createState() =>
      _ConfirmReceivedDialogState();
}

class _ConfirmReceivedDialogState
    extends ConsumerState<_ConfirmReceivedDialog> {
  File? _selectedFile;

  Future<void> _onKonfirmasi() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomInfoMessageWidget(
            color: redColor,
            message: 'Pilih file bukti terlebih dahulu',
            icons: Icons.error_outline_outlined,
          ),
          backgroundColor: whiteColor,
        ),
      );
      return;
    }

    final success = await ref
        .read(shipmentViewModelProvider.notifier)
        .confirmReceivedWithProof(
          shipmentId: widget.shipmentId,
          proofFile: _selectedFile!,
        );

    if (success && context.mounted) {
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomInfoMessageWidget(
            color: greenColor,
            message: 'Barang berhasil dikonfirmasi diterima',
            icons: Icons.done,
          ),
          backgroundColor: whiteColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shipmentViewModelProvider);

    final loadingLabel = state.isConfirming
        ? 'Mengkonfirmasi penerimaan...'
        : state.isUploading
        ? 'Mengupload bukti...'
        : '';

    return PopScope(
      canPop: !state.isConfirming && !state.isUploading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: whiteColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Konfirmasi Terima Barang',
                    style: boldTextStyle.copyWith(fontSize: 14),
                  ),
                  const Spacer(),
                  if (!state.isConfirming && !state.isUploading)
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(shipmentViewModelProvider.notifier)
                            .resetState();
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: semiSecondaryColor,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Upload bukti penerimaan untuk mengkonfirmasi barang telah diterima.',
                style: regularTextStyle.copyWith(
                  fontSize: 12,
                  color: semiSecondaryColor,
                ),
              ),

              const SizedBox(height: 16),
              IgnorePointer(
                // Nonaktifkan interaksi saat loading
                ignoring: state.isConfirming || state.isUploading,
                child: CustomUploadProofWidget(
                  label: "Bukti Penerimaan *",
                  onFileSelected: (file) {
                    setState(() => _selectedFile = file);
                  },
                ),
              ),

              // Error
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                CustomInfoMessageWidget(
                  color: redColor,
                  message: state.errorMessage!,
                  icons: Icons.error_outline_outlined,
                ),
              ],

              const SizedBox(height: 20),

              // Loading indicator
              if (state.isConfirming || state.isUploading) ...[
                LinearProgressIndicator(
                  color: primaryColor,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    loadingLabel,
                    style: regularTextStyle.copyWith(
                      fontSize: 11,
                      color: semiSecondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Tombol
              if (!state.isConfirming && !state.isUploading)
                Row(
                  children: [
                    Expanded(
                      child: CustomFilledbutton(
                        title: "Batal",
                        titleButtonColor: semiSecondaryColor,
                        buttonColor: semiSecondaryColor.withValues(alpha: 0.2),
                        buttonTitleSize: 14,
                        onPressed: () {
                          ref
                              .read(shipmentViewModelProvider.notifier)
                              .resetState();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomFilledbutton(
                        title: "Unggah",
                        buttonTitleSize: 14,
                        onPressed: _onKonfirmasi,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DokumenPendukungDialog extends ConsumerWidget {
  final String shipmentId;

  const _DokumenPendukungDialog({required this.shipmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shipmentViewModelProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Dokumen Pendukung',
                  style: boldTextStyle.copyWith(fontSize: 14),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    color: semiSecondaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content
            _buildContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ShipmentState state) {
    // Loading
    if (state.isLoadingAttachments) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    // Error
    if (state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: redColor, size: 36),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: regularTextStyle.copyWith(color: semiSecondaryColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Filter hanya image dan pdf
    final docs = state.attachments.where((a) => a.isImage || a.isPdf).toList();

    // Kosong
    if (docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                color: semiSecondaryColor,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada dokumen',
                style: regularTextStyle.copyWith(color: semiSecondaryColor),
              ),
            ],
          ),
        ),
      );
    }

    // List dokumen
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: docs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _AttachmentItem(attachment: docs[index]);
        },
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final AttachmentModel attachment;

  const _AttachmentItem({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label kategori
        Row(
          children: [
            Icon(
              attachment.isImage
                  ? Icons.image_outlined
                  : Icons.picture_as_pdf_rounded,
              size: 14,
              color: primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              attachment.categoryLabel,
              style: semiBoldTextStyle.copyWith(
                fontSize: 12,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Preview image
        if (attachment.isImage)
          GestureDetector(
            onTap: () => _showFullImage(context, attachment.fullUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                attachment.fullUrl,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: semiSecondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: semiSecondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: semiSecondaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gagal memuat gambar',
                        style: regularTextStyle.copyWith(
                          fontSize: 11,
                          color: semiSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Preview PDF — tidak bisa render, tampil tap to open
        if (attachment.isPdf)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PDF Document',
                        style: semiBoldTextStyle.copyWith(color: Colors.red),
                      ),
                      Text(
                        attachment.fileUrl.split('/').last,
                        style: regularTextStyle.copyWith(
                          fontSize: 11,
                          color: Colors.red.shade300,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Full screen image viewer
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.close_rounded, color: whiteColor, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
