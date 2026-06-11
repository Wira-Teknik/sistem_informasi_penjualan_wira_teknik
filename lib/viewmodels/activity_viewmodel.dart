import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart'; // Tambahkan import ini untuk memformat tanggal
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/activity_repository.dart';

class ActivityState {
  final bool isLoading;
  final bool isLoadMore;
  final bool isRefreshing;

  final List<DashboardActivityItemModel> activities;
  final List<DashboardActivityItemModel> filteredActivities;

  final String? errorMessage;

  final int currentPage;
  final bool hasReachedMax;
  final String searchQuery;

  // Parameter filter tanggal
  final DateTime? startDate;
  final DateTime? endDate;

  const ActivityState({
    this.isLoading = false,
    this.isLoadMore = false,
    this.isRefreshing = false,
    this.activities = const [],
    this.filteredActivities = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
  });

  bool get hasActiveFilter => startDate != null || endDate != null;

  ActivityState copyWith({
    bool? isLoading,
    bool? isLoadMore,
    bool? isRefreshing,
    List<DashboardActivityItemModel>? activities,
    List<DashboardActivityItemModel>? filteredActivities,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool clearError = false,
    bool clearDates = false, // Untuk mereset filter tanggal
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      activities: activities ?? this.activities,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }
}

class ActivityViewModel extends StateNotifier<ActivityState> {
  final ActivityRepository _repository;

  Timer? _debounceTimer;
  ActivityViewModel(this._repository) : super(const ActivityState()) {
    loadActivities();
  }

  // Helper untuk memformat tanggal ke yyyy-MM-dd
  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<DashboardActivityItemModel> _applyLocalFilter(
    List<DashboardActivityItemModel> itemsList,
    String query,
  ) {
    if (query.isEmpty) return itemsList;
    final keyword = query.toLowerCase().trim();
    return itemsList
        .where(
          (a) =>
              a.title.toLowerCase().contains(keyword) ||
              a.description.toLowerCase().contains(keyword),
        )
        .toList();
  }

  Future<void> loadActivities({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (state.hasReachedMax ||
          state.isLoading ||
          state.isLoadMore ||
          state.isRefreshing) {
        return;
      }
      state = state.copyWith(isLoadMore: true, clearError: true);
    } else {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        hasReachedMax: false,
        clearError: true,
      );
    }

    try {
      final response = await _repository.getAllActivities(
        page: state.currentPage,
        limit: 20,
        // Kirim parameter filter ke API
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
      );

      final newItems = response.data;
      final totalPages = response.pagination?.totalPages ?? 1;

      final currentList = isLoadMore
          ? List<DashboardActivityItemModel>.from(state.activities)
          : <DashboardActivityItemModel>[];
      currentList.addAll(newItems);

      state = state.copyWith(
        isLoading: false,
        isLoadMore: false,
        activities: currentList,
        filteredActivities: _applyLocalFilter(currentList, state.searchQuery),
        currentPage: isLoadMore ? state.currentPage + 1 : 2,
        hasReachedMax: isLoadMore
            ? (state.currentPage >= totalPages)
            : (1 >= totalPages),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadMore: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      currentPage: 1,
      hasReachedMax: false,
    );
    try {
      final response = await _repository.getAllActivities(
        page: 1,
        limit: 20,
        // Kirim parameter filter saat refresh
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
      );

      final newItems = response.data;
      final totalPages = response.pagination?.totalPages ?? 1;

      state = state.copyWith(
        isRefreshing: false,
        activities: newItems,
        filteredActivities: _applyLocalFilter(newItems, state.searchQuery),
        currentPage: 2,
        hasReachedMax: 1 >= totalPages,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredActivities: _applyLocalFilter(state.activities, query),
    );
  }

  // Fungsi untuk mengatur filter dari UI dan memuat ulang data
  void setDateFilter(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      state = state.copyWith(clearDates: true);
    } else {
      state = state.copyWith(startDate: start, endDate: end);
    }

    // Panggil ulang dari halaman 1 (bukan loadMore)
    loadActivities();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final activityViewModelProvider =
    StateNotifierProvider<ActivityViewModel, ActivityState>((ref) {
      final repository = ref.watch(activityRepositoryProvider);
      return ActivityViewModel(repository);
    });
