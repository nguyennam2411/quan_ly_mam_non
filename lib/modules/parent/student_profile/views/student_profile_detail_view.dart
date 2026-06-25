import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/app_database.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/dialogs/app_loading.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../data/models/student_guardian_model.dart';
import '../controllers/student_profile_controller.dart';

class StudentProfileDetailView extends GetView<StudentProfileController> {
  const StudentProfileDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    const parentAccent = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(
        title: AppStrings.studentProfileDetailTitle,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Card (Avatar + Tên + Lớp)
            Obx(() => _buildHeaderCard(context, parentAccent)),
            AppConstants.spacingL,

            // 2. Thông tin cá nhân
            Obx(() => _buildPersonalInfoCard(context, parentAccent)),
            AppConstants.spacingL,

            // 3. Chỉ số phát triển gần nhất
            _buildHealthCard(context, parentAccent),
            AppConstants.spacingL,

            // 4. Liên hệ gia đình
            Obx(() => _buildParentContactCard(context, parentAccent)),
            AppConstants.spacingL,

            // 5. Người giám hộ đưa đón
            _buildGuardiansSection(context, parentAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Color themeColor) {
    final student = controller.student;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: () async {
              final source = await AppDialogs.showImageSourcePicker(
                title: AppStrings.studentProfileChangeAvatarPicker,
              );
              if (source != null) {
                controller.updateStudentAvatar(source);
              }
            },
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.2),
                      width: 2.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: themeColor.withValues(alpha: 0.08),
                        backgroundImage: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                            ? NetworkImage(student.avatarUrl!)
                            : null,
                        child: student.avatarUrl == null || student.avatarUrl!.isEmpty
                            ? Icon(
                                Icons.face_rounded,
                                size: 54,
                                color: themeColor,
                              )
                            : null,
                      ),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Container(
                            width: 108,
                            height: 108,
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: themeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppConstants.spacingM,
          // Name
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          AppConstants.spacingS,
          // Class / Grade
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${student.gradeName ?? "Khối"} • ${student.classroomName ?? AppStrings.profileUnassignedChildClass}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, Color themeColor) {
    final student = controller.student;
    final birthdayStr = student.birthday != null
        ? DateHelper.formatDate(student.birthday!)
        : AppStrings.notUpdated;
    
    final genderStr = student.gender?.toUpperCase() == 'MALE'
        ? AppStrings.studentProfileLabelBoy
        : (student.gender?.toUpperCase() == 'FEMALE' ? AppStrings.studentProfileLabelGirl : AppStrings.unknownLabel);

    return _buildSectionCard(
      title: AppStrings.studentProfilePersonalInfo,
      icon: Icons.badge_outlined,
      themeColor: themeColor,
      items: [
        _buildInfoRow(Icons.cake_rounded, AppStrings.studentProfileBirthday, birthdayStr, themeColor),
        const _ItemDivider(),
        _buildInfoRow(Icons.transgender_rounded, AppStrings.studentProfileGender, genderStr, themeColor),
        const _ItemDivider(),
        _buildInfoRow(Icons.tag_rounded, AppStrings.studentProfileId, student.id.substring(0, 8).toUpperCase(), themeColor),
      ],
    );
  }

  Widget _buildHealthCard(BuildContext context, Color themeColor) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          height: 150,
          decoration: _cardDecoration(),
          child: const AppLoading(),
        );
      }

      final record = controller.latestHealth.value;
      final heightStr = record != null ? '${(record.height * 100).toStringAsFixed(1)} cm' : AppStrings.notUpdated;
      final weightStr = record != null ? '${record.weight.toStringAsFixed(1)} kg' : AppStrings.notUpdated;
      final dateStr = record != null ? DateHelper.formatDate(record.date) : '';

      return _buildSectionCard(
        title: AppStrings.studentProfileLatestGrowth,
        icon: Icons.monitor_heart_outlined,
        themeColor: themeColor,
        subtitle: dateStr.isNotEmpty ? '${AppStrings.studentProfileUpdatedDate} $dateStr' : null,
        items: [
          _buildInfoRow(Icons.height_rounded, AppStrings.studentProfileHeight, heightStr, themeColor),
          const _ItemDivider(),
          _buildInfoRow(Icons.monitor_weight_rounded, AppStrings.studentProfileWeight, weightStr, themeColor),
        ],
      );
    });
  }

  Widget _buildParentContactCard(BuildContext context, Color themeColor) {
    final profile = AuthService.to.userProfile;
    final parentName = profile[AppDatabase.colName]?.toString() ?? AppStrings.labelParent;
    final email = AuthService.to.currentUser.value?.email ?? '—';
    final phone = profile['phone']?.toString() ?? AppStrings.notUpdated;

    return _buildSectionCard(
      title: AppStrings.studentProfileFamilyContact,
      icon: Icons.family_restroom_outlined,
      themeColor: themeColor,
      items: [
        _buildInfoRow(Icons.person_pin_rounded, AppStrings.studentProfileParentManager, parentName, themeColor),
        const _ItemDivider(),
        _buildInfoRow(Icons.phone_android_rounded, AppStrings.profilePhone, phone, themeColor),
        const _ItemDivider(),
        _buildInfoRow(Icons.email_outlined, AppStrings.studentProfileEmailContact, email, themeColor),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color themeColor,
    String? subtitle,
    required List<Widget> items,
  }) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: themeColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: themeColor, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.outlineVariant.withValues(alpha: 0.15),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.015),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildGuardiansSection(BuildContext context, Color themeColor) {
    return Obx(() {
      if (controller.isGuardiansLoading.value && controller.guardians.isEmpty) {
        return Container(
          height: 150,
          decoration: _cardDecoration(),
          child: const AppLoading(),
        );
      }

      final items = <Widget>[];

      if (controller.guardians.isEmpty) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 48,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                AppConstants.spacingM,
                const Text(
                  AppStrings.studentProfileNoGuardians,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else {
        for (int i = 0; i < controller.guardians.length; i++) {
          final guardian = controller.guardians[i];
          items.add(_buildGuardianRow(context, guardian, themeColor));
          if (i < controller.guardians.length - 1) {
            items.add(const _ItemDivider());
          }
        }
      }

      // Add a spacer and the "Add Guardian" button
      items.add(AppConstants.spacingM);
      items.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showGuardianFormDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor.withValues(alpha: 0.08),
              foregroundColor: themeColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: themeColor.withValues(alpha: 0.2)),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              AppStrings.guardianAddButton,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      );

      return _buildSectionCard(
        title: AppStrings.guardianSectionTitle,
        icon: Icons.supervised_user_circle_outlined,
        themeColor: themeColor,
        items: items,
      );
    });
  }

  Widget _buildGuardianRow(BuildContext context, StudentGuardianModel guardian, Color themeColor) {
    final relationshipColor = _getRelationshipColor(guardian.relationship);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name, Badge, and Phone Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        guardian.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: relationshipColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        guardian.relationship,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: relationshipColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Phone number
                InkWell(
                  onTap: () => _callPhoneNumber(guardian.phone),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 13,
                          color: themeColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          guardian.phone,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Actions: Edit & Delete
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showGuardianFormDialog(context, editGuardian: guardian),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.75),
                ),
                tooltip: AppStrings.editLabel,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                splashRadius: 20,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context, guardian),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
                tooltip: AppStrings.deleteLabel,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRelationshipColor(String relationship) {
    switch (relationship) {
      case 'Bố':
      case 'Mẹ':
        return AppColors.primary;
      case 'Ông':
      case 'Bà':
        return AppColors.secondary;
      case 'Tài xế':
        return AppColors.tertiary;
      default:
        return AppColors.outline;
    }
  }

  Future<void> _callPhoneNumber(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        Get.snackbar(
          AppStrings.errorTitle,
          '${AppStrings.studentProfileCallError} $phone',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.errorTitle,
        '${AppStrings.studentProfileCallError}: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, StudentGuardianModel guardian) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          AppStrings.dialogConfirmTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('${AppStrings.guardianDeleteConfirm}\n\n- ${guardian.name} (${guardian.relationship})'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              AppStrings.dialogCancel,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeGuardian(guardian.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(AppStrings.deleteLabel),
          ),
        ],
      ),
    );
  }

  void _showGuardianFormDialog(BuildContext context, {StudentGuardianModel? editGuardian}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: editGuardian?.name);
    final phoneController = TextEditingController(text: editGuardian?.phone);
    String? selectedRelationship = editGuardian?.relationship;

    final relationships = ['Bố', 'Mẹ', 'Ông', 'Bà', 'Cô', 'Chú', 'Tài xế', 'Khác'];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    editGuardian == null ? AppStrings.guardianAddButton : AppStrings.guardianEditTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppStrings.guardianNameLabel,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.guardianNameEmpty;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone Field
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: AppStrings.guardianPhoneLabel,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.guardianPhoneEmpty;
                      }
                      final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return AppStrings.guardianPhoneInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Relationship Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedRelationship,
                    decoration: InputDecoration(
                      labelText: AppStrings.guardianRelationshipLabel,
                      prefixIcon: const Icon(Icons.family_restroom_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    items: relationships.map((r) {
                      return DropdownMenuItem<String>(
                        value: r,
                        child: Text(r),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.guardianRelationshipEmpty;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      selectedRelationship = value;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          AppStrings.dialogCancel,
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Get.back();
                            if (editGuardian == null) {
                              controller.addGuardian(
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                relationship: selectedRelationship!,
                              );
                            } else {
                              controller.editGuardian(
                                id: editGuardian.id,
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                relationship: selectedRelationship!,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          AppStrings.confirmLabel,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

class _ItemDivider extends StatelessWidget {
  const _ItemDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 20,
      indent: 0,
      color: AppColors.outlineVariant.withValues(alpha: 0.12),
    );
  }
}
