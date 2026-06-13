import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/attachment_model.dart';
import '../data/models/add_shipment_model.dart';
import '../data/repositories/shipment_repository.dart';

class ShipmentState {
  final bool isSubmitting;
  final bool isConfirming;
  final bool isUploading;
  final bool isLoadingAttachments;
  final double uploadProgress;
  final String? errorMessage;
  final bool isSuccess;
  final List<AttachmentModel> attachments;

  const ShipmentState({
    this.isSubmitting = false,
    this.isConfirming = false,
    this.isUploading = false,
    this.isLoadingAttachments = false,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.isSuccess = false,
    this.attachments = const [],
  });

  ShipmentState copyWith({
    bool? isSubmitting,
    bool? isConfirming,
    bool? isUploading,
    bool? isLoadingAttachments,
    double? uploadProgress,
    String? errorMessage,
    bool? isSuccess,
    List<AttachmentModel>? attachments,
    bool clearError = false,
    bool clearAttachments = false,
  }) {
    return ShipmentState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isConfirming: isConfirming ?? this.isConfirming,
      isUploading: isUploading ?? this.isUploading,
      isLoadingAttachments: isLoadingAttachments ?? this.isLoadingAttachments,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      attachments: clearAttachments
          ? const []
          : (attachments ?? this.attachments),
    );
  }
}

class ShipmentViewModel extends StateNotifier<ShipmentState> {
  final ShipmentRepository _repository;

  ShipmentViewModel(this._repository) : super(const ShipmentState());

  Future<bool> addShipment({
    required String orderId,
    required String shippingDate,
    required List<ShipmentItemRequest> items,
    required File buktiKirim,
    required File suratJalan,
    required File bonPesanan,
    required File invoiceFile,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.addShipment(
        AddShipmentRequest(
          orderId: orderId,
          shippingDate: shippingDate,
          items: items,
          buktiKirim: buktiKirim,
          suratJalan: suratJalan,
          bonPesanan: bonPesanan,
          invoiceFile: invoiceFile,
        ),
      );

      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateShipment(
    String shipmentId,
    List<Map<String, dynamic>> items,
  ) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.updateShipment(shipmentId, items);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> confirmReceivedWithProof({
    required String shipmentId,
    required File proofFile,
  }) async {
    state = state.copyWith(
      isConfirming: true,
      clearError: true,
      uploadProgress: 0.0,
    );

    try {
      // Step 1 — Konfirmasi terima barang
      await _repository.confirmReceived(shipmentId);

      // Step 2 — Upload bukti
      state = state.copyWith(isConfirming: false, isUploading: true);

      await _repository.uploadAttachment(
        relatedId: shipmentId,
        file: proofFile,
        category: 'shipment_received',
      );

      state = state.copyWith(isUploading: false, isSuccess: true);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isConfirming: false,
        isUploading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> loadAttachments(String shipmentId) async {
    state = state.copyWith(
      isLoadingAttachments: true,
      clearError: true,
      clearAttachments: true,
    );
    try {
      final attachments = await _repository.getAttachments(shipmentId);
      state = state.copyWith(
        isLoadingAttachments: false,
        attachments: attachments,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoadingAttachments: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() => state = const ShipmentState();
}

final shipmentViewModelProvider =
    StateNotifierProvider<ShipmentViewModel, ShipmentState>((ref) {
      final repository = ref.watch(shipmentRepositoryProvider);
      return ShipmentViewModel(repository);
    });
