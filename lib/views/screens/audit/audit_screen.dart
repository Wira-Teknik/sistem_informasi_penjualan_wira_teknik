import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/audit_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/audit_viewmodel.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_appbar.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_badge.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_refresh_error_widget.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/custom_textfield.dart';

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _actionColor(String actionRaw) {
    return switch (actionRaw.toUpperCase()) {
      'CREATE' => greenColor,
      'UPDATE' => primaryColor,
      'DELETE' => redColor,
      'LOGIN' => orangeColor,
      _ => semiSecondaryColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(title: 'Audit'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            CustomTextfield(
              controller: _searchController,
              hintText: "Cari nama admin",
              prefixIcon: Icons.search,
              onChanged: (value) =>
                  ref.read(auditViewModelProvider.notifier).search(value),
            ),
            const SizedBox(height: 20),

            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AuditState state) {
    // Loading
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    // Error
    if (state.errorMessage != null) {
      return CustomRefreshErrorWidget(
        message: state.errorMessage!,
        onPressed: () => ref.read(auditViewModelProvider.notifier).loadAudit(),
      );
    }

    // Kosong
    if (state.filteredAudits.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data audit',
          style: regularTextStyle.copyWith(color: semiSecondaryColor),
        ),
      );
    }

    // List
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () => ref.read(auditViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.filteredAudits.length,
        itemBuilder: (context, index) {
          return _AuditItem(
            audit: state.filteredAudits[index],
            actionColor: _actionColor,
          );
        },
      ),
    );
  }
}

class _AuditItem extends StatelessWidget {
  final AuditModel audit;
  final Color Function(String) actionColor;

  const _AuditItem({required this.audit, required this.actionColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama admin & badge action
          Row(
            children: [
              Expanded(
                child: Text(
                  audit.adminName,
                  style: boldTextStyle.copyWith(
                    fontSize: 16,
                    color: primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              CustomBadge(
                label: audit.action,
                badgeColor: actionColor(audit.actionRaw),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tanggal
          Text(
            audit.date,
            style: semiBoldTextStyle.copyWith(
              fontSize: 12,
              color: semiSecondaryColor,
            ),
          ),

          // Deskripsi
          Text(
            audit.description,
            style: mediumTextStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
