import 'package:flutter/material.dart';
import '../../../../global_widgets/headers/section_header.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: title,
      trailing: onSeeAll != null
          ? TextButton(
              onPressed: onSeeAll,
              child: const Text(AppStrings.labelSeeAll),
            )
          : null,
    );
  }
}
