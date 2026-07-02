import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/state/app_loading.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../data/models/student_guardian_model.dart';
import '../controllers/teacher_classroom_controller.dart';

class TeacherStudentDetailView extends GetView<TeacherStudentDetailController> {
  const TeacherStudentDetailView({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      AppDialogs.error(message: '${AppStrings.studentProfileCallError} $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(
        title: 'Thông tin học sinh',
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hồ sơ lý lịch tích hợp (Avatar + Tên + Thông tin)
            _buildPersonalInfoCard(context, accentColor),
            AppConstants.spacingL,

            // 2. Liên hệ phụ huynh (Tài khoản phụ huynh quản lý)
            Obx(() => _buildParentContactCard(context, accentColor)),
            AppConstants.spacingL,

            // 3. Danh sách người giám hộ đưa đón
            Obx(() => _buildGuardiansSection(context, accentColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, Color themeColor) {
    final student = controller.student;
    final hasAvatar = student.avatarUrl != null && student.avatarUrl!.isNotEmpty;
    final birthdayStr = student.birthday != null
        ? DateHelper.formatDate(student.birthday!)
        : AppStrings.notUpdated;
    
    final isBoy = student.gender?.toLowerCase() == 'male' || student.gender?.toLowerCase() == 'nam';
    final genderStr = isBoy ? 'Nam' : 'Nữ';

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phần Header: Avatar + Tên + Lớp học nằm ngang để tiết kiệm diện tích
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: themeColor.withValues(alpha: 0.08),
                  backgroundImage: hasAvatar ? NetworkImage(student.avatarUrl!) : null,
                  child: !hasAvatar
                      ? Icon(
                          Icons.face_rounded,
                          size: 36,
                          color: themeColor,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (student.classroomName != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Lớp: ${student.classroomName}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _ItemDivider(),
          const SizedBox(height: 8),
          
          // Các dòng chi tiết hồ sơ
          _buildInfoRow(Icons.cake_rounded, 'Ngày sinh', birthdayStr, themeColor),
          const _ItemDivider(),
          _buildInfoRow(isBoy ? Icons.male_rounded : Icons.female_rounded, 'Giới tính', genderStr, themeColor),
          const _ItemDivider(),
          _buildInfoRow(Icons.tag_rounded, 'Mã học sinh', student.id.substring(0, 8).toUpperCase(), themeColor),
        ],
      ),
    );
  }

  Widget _buildParentContactCard(BuildContext context, Color themeColor) {
    if (controller.isParentLoading.value) {
      return Container(
        height: 100,
        decoration: _cardDecoration(),
        child: const Center(child: AppLoading()),
      );
    }

    final parent = controller.parentProfile.value;
    if (parent == null) {
      return _buildSectionCard(
        title: 'Liên hệ phụ huynh',
        icon: Icons.contacts_outlined,
        themeColor: themeColor,
        items: [
          _buildInfoRow(Icons.person_outline_rounded, 'Họ tên', 'Chưa có thông tin phụ huynh', themeColor),
        ],
      );
    }

    final name = parent['name']?.toString() ?? 'Chưa cập nhật';
    final phone = parent['phone']?.toString() ?? 'Chưa cập nhật';
    final email = parent['email']?.toString() ?? '—';

    return _buildSectionCard(
      title: 'Liên hệ phụ huynh',
      icon: Icons.contacts_outlined,
      themeColor: themeColor,
      items: [
        _buildInfoRow(
          Icons.person_rounded, 
          'Phụ huynh quản lý', 
          name, 
          themeColor,
        ),
        const _ItemDivider(),
        _buildInfoRow(
          Icons.phone_rounded, 
          'Số điện thoại', 
          phone, 
          themeColor,
          trailing: phone != 'Chưa cập nhật'
              ? IconButton(
                  icon: const Icon(Icons.call_rounded, color: AppColors.success),
                  onPressed: () => _makePhoneCall(phone),
                )
              : null,
        ),
        const _ItemDivider(),
        _buildInfoRow(
          Icons.email_rounded, 
          'Email liên hệ', 
          email, 
          themeColor,
        ),
      ],
    );
  }

  Widget _buildGuardiansSection(BuildContext context, Color themeColor) {
    if (controller.isGuardiansLoading.value) {
      return Container(
        height: 100,
        decoration: _cardDecoration(),
        child: const Center(child: AppLoading()),
      );
    }

    final guardiansList = controller.guardians;

    if (guardiansList.isEmpty) {
      return _buildSectionCard(
        title: 'Người giám hộ khác',
        icon: Icons.people_outline_rounded,
        themeColor: themeColor,
        items: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Chưa đăng ký thông tin người giám hộ khác.',
              style: TextStyle(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.assignment_ind_rounded, size: 20, color: themeColor),
              const SizedBox(width: 8),
              const Text(
                'Người giám hộ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: guardiansList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final guardian = guardiansList[index];
            return _buildGuardianCard(context, guardian, themeColor);
          },
        ),
      ],
    );
  }

  Widget _buildGuardianCard(BuildContext context, StudentGuardianModel guardian, Color themeColor) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: themeColor.withValues(alpha: 0.08),
            child: Icon(Icons.person_rounded, color: themeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guardian.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mối quan hệ: ${guardian.relationship}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SĐT: ${guardian.phone}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: AppColors.success),
            onPressed: () => _makePhoneCall(guardian.phone),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color themeColor,
    required List<Widget> items,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: themeColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
          ),
          const _ItemDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon, 
    String label, 
    String value, 
    Color themeColor, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _ItemDivider extends StatelessWidget {
  const _ItemDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
