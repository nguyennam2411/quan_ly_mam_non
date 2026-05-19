import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/chips/status_badge.dart';
import '../controllers/parent_invoice_controller.dart';
import 'parent_invoice_detail_view.dart';

class ParentInvoiceView extends GetView<ParentInvoiceController> {
  const ParentInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: const CircleBackButton(),
        title: Text(
          'Học phí',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterTabs(),
          const SizedBox(height: AppConstants.paddingM),
          Expanded(child: _buildInvoiceList()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Obx(() => ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTab('ALL', 'Tất cả'),
          const SizedBox(width: 8),
          _buildTab(AppDatabase.invoiceStatusUnpaid, 'Chưa đóng'),
          const SizedBox(width: 8),
          _buildTab(AppDatabase.invoiceStatusPaid, 'Đã đóng'),
        ],
      )),
    );
  }

  Widget _buildTab(String statusValue, String label) {
    final isSelected = controller.selectedStatus.value == statusValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) controller.selectedStatus.value = statusValue;
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.onSurface.withValues(alpha: 0.05),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: BorderSide.none,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildInvoiceList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final invoices = controller.filteredInvoices;

      if (invoices.isEmpty) {
        return const AppEmptyState(
          title: 'Không có thông báo học phí',
          description: 'Hiện chưa có khoản thu nào cần thanh toán.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          final isPaid = invoice.status == AppDatabase.invoiceStatusPaid;
          final isPending = invoice.status == AppDatabase.pending;
          final isOverdue = invoice.status == AppDatabase.invoiceStatusOverdue;
          final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

          return GestureDetector(
            onTap: () => Get.to(() => ParentInvoiceDetailView(invoice: invoice)),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isPaid ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Học phí tháng ${invoice.month ?? "--"}/${invoice.year ?? "--"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      StatusBadge(
                        text: isPaid ? 'ĐÃ ĐÓNG' : isPending ? 'CHỜ XÁC NHẬN' : isOverdue ? 'CÒN NỢ' : 'CHƯA ĐÓNG',
                        color: isPaid ? AppColors.success : isPending ? AppColors.warning : isOverdue ? const Color(0xFFB3261E) : AppColors.error,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hạn chót:', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      Text(
                        invoice.dueDate != null ? DateFormat('dd/MM/yyyy').format(invoice.dueDate!) : 'Đang cập nhật',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: AppColors.outlineVariant),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền:', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      Text(
                        formatCurrency.format(invoice.totalAmount),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  if (!isPaid && !isPending && !isOverdue) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.simulatePayment(invoice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Thanh toán ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ] else if (isOverdue) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9DEDC),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: const Text(
                        'Vui lòng thanh toán gộp trong hoá đơn tháng mới nhất.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFB3261E), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    )
                  ]
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
