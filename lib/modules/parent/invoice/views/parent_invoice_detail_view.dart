import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/user_role.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../data/models/invoice_model.dart';
import '../controllers/parent_invoice_controller.dart';

class ParentInvoiceDetailView extends GetView<ParentInvoiceController> {
  final InvoiceModel invoice;

  const ParentInvoiceDetailView({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    // Nhóm các items theo group (A, B, D, E)
    final groupA = invoice.items.where((i) => i.group == 'A').toList();
    final groupB = invoice.items.where((i) => i.group == 'B').toList();
    final groupD = invoice.items.where((i) => i.group == 'D').toList();
    final groupE = invoice.items.where((i) => i.group == 'E').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(
        title: 'Chi tiết Học phí',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin chung
            Center(
              child: Column(
                children: [
                  Text(
                    'Tháng ${invoice.month ?? "--"}/${invoice.year ?? "--"}',
                    style: const TextStyle(fontSize: 18, color: AppColors.outline),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency.format(invoice.totalAmount),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),

            // Nhóm A: Phí cố định
            if (groupA.isNotEmpty) ...[
              _buildSectionTitle('Các khoản nộp trong tháng'),
              ...groupA.map((item) => _buildFeeRow(item.name, item.amount, formatCurrency)),
              const Divider(height: 32),
            ],

            // Nhóm B: Tiền ăn tháng mới
            if (groupB.isNotEmpty) ...[
              _buildSectionTitle('Tiền ăn dự kiến'),
              ...groupB.map((item) => _buildFeeRow(item.name, item.amount, formatCurrency)),
              const Divider(height: 32),
            ],

            // Nhóm D: Hoàn trả (Giảm trừ)
            if (groupD.isNotEmpty) ...[
              _buildSectionTitle('Giảm trừ (Tiền thừa / Nghỉ học)'),
              ...groupD.map((item) => _buildFeeRow(item.name, item.amount, formatCurrency, isDeduction: true)),
              const Divider(height: 32),
            ],

            // Nhóm E: Nợ cũ
            if (groupE.isNotEmpty) ...[
              _buildSectionTitle('Nợ kỳ trước chuyển sang'),
              ...groupE.map((item) => _buildFeeRow(item.name, item.amount, formatCurrency)),
              const Divider(height: 32),
            ],

            // Tổng cộng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TỔNG CỘNG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text(
                  formatCurrency.format(invoice.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserRole.isTeacher(AuthService.to.userRole.value) 
          ? null 
          : invoice.status == AppDatabase.invoiceStatusOverdue
          ? Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9DEDC),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Text(
                  'Hoá đơn đã quá hạn. Vui lòng thanh toán gộp trong hoá đơn tháng mới nhất.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFB3261E), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : (invoice.status != AppDatabase.invoiceStatusPaid && invoice.status != AppDatabase.pending)
              ? Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: PrimaryButton(
                    text: 'THANH TOÁN NGAY',
                    onPressed: () => controller.simulatePayment(invoice),
                  ),
                )
              : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.outline,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFeeRow(String name, double amount, NumberFormat format, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            format.format(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDeduction ? AppColors.error : AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
