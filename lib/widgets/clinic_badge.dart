import 'package:flutter/material.dart';
import 'package:vetsync/theme/app_colors.dart';

/// Pill badge indicating the clinic branch associated with a pet or medical visit.
class ClinicBadge extends StatelessWidget {
  final String branchName;
  final bool isCompact;
  final bool isHighlighted;

  const ClinicBadge({
    super.key,
    required this.branchName,
    this.isCompact = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = branchName.isNotEmpty ? branchName : 'Delhi Central Clinic';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primarySoft : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlighted ? AppColors.primaryLight.withAlpha(80) : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.apartment_rounded,
            size: isCompact ? 12 : 14,
            color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isCompact ? 11 : 12,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                color: isHighlighted ? AppColors.primaryDark : AppColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
