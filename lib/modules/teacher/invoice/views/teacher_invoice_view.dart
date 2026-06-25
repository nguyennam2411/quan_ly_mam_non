import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/chips/status_badge.dart';
import '../../../parent/invoice/views/parent_invoice_detail_view.dart';
import '../controllers/teacher_invoice_controller.dart';

class TeacherInvoiceView extends GetView<TeacherInvoiceController> {
  const TeacherInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: const CircleBackButton(),
        title: const Text(
          'Thu Học Phí',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 12),
          Expanded(child: _buildStudentList()),
        ],
      ),
      floatingActionButton: Obx(() {
        if (!controller.isLoading.value && controller.allInvoices.isEmpty) {
          return FloatingActionButton.extended(
            onPressed: () => _showGenerateConfirmDialog(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
            label: const Text('Phát hành tháng này', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
            onPressed: controller.previousMonth,
          ),
          Obx(() => Text(
            'Tháng ${controller.currentMonth.value} / ${controller.currentYear.value}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            onPressed: controller.nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredInvoices.isEmpty) {
        return const AppEmptyState(
          title: 'Chưa có dữ liệu',
          description: 'Không có hoá đơn nào phù hợp với bộ lọc hiện tại.',
        );
      }

      final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        itemCount: controller.filteredInvoices.length,
        itemBuilder: (context, index) {
          final invoice = controller.filteredInvoices[index];
          final student = invoice.student;
          final isPaid = invoice.status == AppDatabase.invoiceStatusPaid;

          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(
                color: isPaid ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  backgroundImage: student?.avatarUrl != null ? NetworkImage(student!.avatarUrl!) : null,
                  child: student?.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
                ),
                title: Text(
                  student?.name ?? 'Không rõ tên',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatCurrency.format(invoice.totalAmount),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      StatusBadge(
                        text: isPaid ? 'ĐÃ ĐÓNG' : invoice.status == AppDatabase.pending ? 'CHỜ XÁC NHẬN' : invoice.status == AppDatabase.invoiceStatusOverdue ? 'CÒN NỢ' : 'CHƯA ĐÓNG',
                        color: isPaid ? AppColors.success : invoice.status == AppDatabase.pending ? AppColors.warning : invoice.status == AppDatabase.invoiceStatusOverdue ? const Color(0xFFB3261E) : AppColors.error,
                      ),
                    ],
                  ),
                ),
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Chi tiết các khoản thu:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.outline)),
                        const SizedBox(height: 8),
                        ...invoice.items.map((item) {
                          final isRefund = item.amount < 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('- ${item.name}', style: TextStyle(fontSize: 13, color: isRefund ? AppColors.error : AppColors.onSurfaceVariant)),
                                ),
                                Text(formatCurrency.format(item.amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isRefund ? AppColors.error : AppColors.onSurface)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Tái sử dụng màn hình Detail của Phụ huynh để xem chi tiết
                              Get.to(() => ParentInvoiceDetailView(invoice: invoice));
                            },
                            icon: const Icon(Icons.receipt_long_rounded, size: 18),
                            label: const Text('Xem phiếu'),
                          ),
                        ),
                        if (invoice.status == AppDatabase.pending) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showConfirmDialog(context, invoice.id ?? '', student?.name ?? ''),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                              ),
                              icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              label: const Text(
                                'Xác nhận thu',
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ] else if (invoice.status == AppDatabase.invoiceStatusOverdue) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9DEDC),
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Thu gộp ở HĐ mới',
                                style: TextStyle(color: Color(0xFFB3261E), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showConfirmDialog(BuildContext context, String invoiceId, String studentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thu tiền'),
        content: Text('Bạn xác nhận phụ huynh bé $studentName đã nộp đủ tiền mặt cho tháng này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy', style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.markAsPaid(invoiceId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showGenerateConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phát hành Học phí'),
        content: Text(
          'Hệ thống sẽ tự động tính toán tổng tiền học và trừ tiền ăn (nếu bé có nghỉ phép vào tháng trước) cho toàn bộ học sinh trong lớp.\n\nBạn có chắc chắn muốn phát hành hoá đơn tháng ${controller.currentMonth.value}/${controller.currentYear.value} không?'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy', style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.generateInvoices();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Tiến hành', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterChips() {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        child: Row(
          children: [
            _buildFilterChip('ALL', 'Tất cả'),
            const SizedBox(width: 8),
            _buildFilterChip('PAID', 'Đã đóng'),
            const SizedBox(width: 8),
            _buildFilterChip('UNPAID', 'Chưa đóng'),
            const SizedBox(width: 8),
            _buildFilterChip('DEBT', 'Còn nợ'),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = controller.selectedFilter.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) controller.selectedFilter.value = value;
      },
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surfaceContainerLowest,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.outlineVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
    );
  }
}
