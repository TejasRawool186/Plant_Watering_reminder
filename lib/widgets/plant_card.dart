import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plant.dart';
import '../theme/app_theme.dart';
import 'urgency_badge.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  final VoidCallback onWater;
  final VoidCallback? onDelete;
  final int index;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onWater,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Plant Icon/Image
                Hero(
                  tag: 'plant_${plant.id}',
                  child: _buildPlantAvatar(),
                ),
                const SizedBox(width: 16),
                // Plant Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Every ${plant.wateringFrequency} ${plant.wateringFrequency == 1 ? 'day' : 'days'}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      UrgencyBadge(plant: plant),
                    ],
                  ),
                ),
                // Delete Button (if provided)
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.overdueColor),
                    tooltip: 'Delete Plant',
                  ),
                // Water Button
                _buildWaterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantAvatar() {
    if (plant.imagePath != null && (kIsWeb || File(plant.imagePath!).existsSync())) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: [
            BoxShadow(
              color: plant.color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Image(
            image: (kIsWeb ? NetworkImage(plant.imagePath!) : FileImage(File(plant.imagePath!))) as ImageProvider,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon();
            },
          ),
        ),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            plant.color.withValues(alpha: 0.15),
            plant.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Icon(
        plant.icon,
        size: 30,
        color: plant.color,
      ),
    );
  }

  Widget _buildWaterButton() {
    final bool needsWater = plant.needsWatering;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onWater,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: needsWater
                ? AppTheme.wateredColor.withValues(alpha: 0.12)
                : AppTheme.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: needsWater
                  ? AppTheme.wateredColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.water_drop_rounded,
            color: needsWater ? AppTheme.wateredColor : AppTheme.textLight,
            size: 22,
          ),
        ),
      ),
    );
  }
}
