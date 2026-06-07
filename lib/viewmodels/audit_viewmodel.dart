import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/audit_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/audit_repository.dart';

class AuditState {
  final bool isLoading;
  final bool isRefreshing;
  final List<AuditModel> audits;
  final List<AuditModel> filteredAudits;
  final String? errorMessage;

  const AuditState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.audits = const [],
    this.filteredAudits = const [],
    this.errorMessage,
  });

  AuditState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<AuditModel>? audits,
    List<AuditModel>? filteredAudits,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuditState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      audits: audits ?? this.audits,
      filteredAudits: filteredAudits ?? this.filteredAudits,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuditViewModel extends StateNotifier<AuditState> {
  final AuditRepository _repository;

  Timer? _debounceTimer;
  String _lastQuery = '';

  AuditViewModel(this._repository) : super(const AuditState()) {
    loadAudit();
  }

  Future<void> loadAudit() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final audits = await _repository.getAudit();
      state = state.copyWith(
        isLoading: false,
        audits: audits,
        filteredAudits: audits,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final audits = await _repository.getAudit();
      state = state.copyWith(
        isRefreshing: false,
        audits: audits,
        filteredAudits: audits,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void search(String query) {
    _lastQuery = query;

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      state = state.copyWith(filteredAudits: state.audits);
      return;
    }

    // Filter lokal dulu
    final keyword = query.toLowerCase();
    final local = state.audits
        .where(
          (a) =>
              a.adminName.toLowerCase().contains(keyword) ||
              a.description.toLowerCase().contains(keyword) ||
              a.action.toLowerCase().contains(keyword),
        )
        .toList();
    state = state.copyWith(filteredAudits: local);

    // Debounce hit API
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchFromApi(query);
    });
  }

  Future<void> _searchFromApi(String query) async {
    try {
      final audits = await _repository.getAudit(query: query);
      if (_lastQuery != query) return;
      state = state.copyWith(filteredAudits: audits);
    } on Exception catch (_) {
      // Tetap tampil hasil filter lokal
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final auditViewModelProvider =
    StateNotifierProvider<AuditViewModel, AuditState>((ref) {
      final repository = ref.watch(auditRepositoryProvider);
      return AuditViewModel(repository);
    });
