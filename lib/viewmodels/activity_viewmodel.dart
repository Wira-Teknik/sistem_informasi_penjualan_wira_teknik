import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/activity_repository.dart';

class ActivityState {
  final bool isLoading;
  final bool isRefreshing;
  final List<ActivityModel> activities;
  final List<ActivityModel> filteredActivities;
  final String? errorMessage;

  const ActivityState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.activities = const [],
    this.filteredActivities = const [],
    this.errorMessage,
  });

  ActivityState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<ActivityModel>? activities,
    List<ActivityModel>? filteredActivities,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      activities: activities ?? this.activities,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ActivityViewModel extends StateNotifier<ActivityState> {
  final ActivityRepository _repository;

  Timer? _debounceTimer;
  // ignore: unused_field
  String _lastQuery = '';

  ActivityViewModel(this._repository) : super(const ActivityState()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final activities = await _repository.getAllActivities();
      state = state.copyWith(
        isLoading: false,
        activities: activities,
        filteredActivities: activities,
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
      final activities = await _repository.getAllActivities();
      state = state.copyWith(
        isRefreshing: false,
        activities: activities,
        filteredActivities: activities,
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
      state = state.copyWith(filteredActivities: state.activities);
      return;
    }

    // Filter lokal dulu — instan
    final keyword = query.toLowerCase();
    final filtered = state.activities
        .where(
          (a) =>
              a.title.toLowerCase().contains(keyword) ||
              a.description.toLowerCase().contains(keyword),
        )
        .toList();
    state = state.copyWith(filteredActivities: filtered);
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
