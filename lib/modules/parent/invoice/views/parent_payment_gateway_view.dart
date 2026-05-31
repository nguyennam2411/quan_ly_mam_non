import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../data/models/invoice_model.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../controllers/parent_invoice_controller.dart';

class ParentPaymentGatewayView extends GetView<ParentInvoiceController> {
  final InvoiceModel invoice;
  
  const ParentPaymentGatewayView({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    
    // Tự sinh nội dung chuyển khoản: HocPhi_<TenBe>_T<Thang>
    final studentName = invoice.student?.name.split(' ').last ?? 'Be';
    final transferContent = 'HocPhi_${studentName}_T${invoice.month}';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: const CircleBackButton(),
        title: const Text(
          'Thanh toán chuyển khoản',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          children: [
            const Text(
              'Vui lòng chuyển khoản đúng số tiền và nội dung bên dưới để nhà trường tự động đối soát.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 32),
            
            // Khu vực Thông tin chuyển khoản
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://img.vietqr.io/image/970436-1041252698-compact2.png?amount=${invoice.totalAmount.toInt()}&addInfo=$transferContent&accountName=DOAN QUY NHAN',
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('THÔNG TIN CHUYỂN KHOẢN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                  const SizedBox(height: 24),
                  
                  // Thông tin chi tiết
                  _buildInfoRow('Ngân hàng:', 'Vietcombank'),
                  _buildInfoRow('Chủ tài khoản:', 'ĐOÀN QUÝ NHÂN'),
                  _buildCopyableRow('Số tài khoản:', '1041252698'),
                  _buildInfoRow('Số tiền:', formatCurrency.format(invoice.totalAmount), isHighlight: true),
                  _buildCopyableRow('Nội dung:', transferContent),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Nút Xác nhận
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  controller.confirmPayment(invoice);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                ),
                child: const Text(
                  'Tôi đã chuyển khoản thành công',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'Nếu giao dịch thành công, hệ thống sẽ gạch nợ sau vài phút. Cần hỗ trợ xin liên hệ phòng kế toán.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? AppColors.primary : AppColors.onSurface,
                fontSize: isHighlight ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar('Đã sao chép', value, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
