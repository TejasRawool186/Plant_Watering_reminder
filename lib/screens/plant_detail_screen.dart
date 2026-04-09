import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/watering_button.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantProvider>(
      builder: (context, provider, _) {
        // Get the latest version of this plant from the provider
        final currentPlant = provider.plants
            .cast<Plant?>()
            .firstWhere((p) => p!.id == plant.id, orElse: () => null);

        if (currentPlant == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco_outlined,
                      size: 64, color: AppTheme.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'Plant not found',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteDialog(context, provider, currentPlant);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    color: AppTheme.overdueColor, size: 20),
                                SizedBox(width: 8),
                                Text('Delete Plant'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeroHeader(currentPlant),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plant Name & Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentPlant.name,
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          _buildStatusChip(currentPlant),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info Cards
                      _buildInfoGrid(currentPlant),
                      const SizedBox(height: 24),

                      // Watering Progress
                      _buildWateringProgress(currentPlant),
                      const SizedBox(height: 32),

                      // Water Button
                      Center(
                        child: WateringButton(
                          onPressed: () {
                            provider.markAsWatered(currentPlant.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '💧 ${currentPlant.name} has been watered!'),
                                backgroundColor: AppTheme.wateredColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(Plant p) {
    if (p.imagePath != null && (kIsWeb || File(p.imagePath!).existsSync())) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: (kIsWeb ? NetworkImage(p.imagePath!) : FileImage(File(p.imagePath!))) as ImageProvider,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallbackHero(p),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  p.color.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _buildFallbackHero(p);
  }

  Widget _buildFallbackHero(Plant p) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            p.color.withValues(alpha: 0.3),
            p.color.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Hero(
          tag: 'plant_${p.id}',
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  p.color.withValues(alpha: 0.3),
                  p.color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: p.color.withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(p.icon, size: 60, color: p.color),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Plant p) {
    Color bgColor;
    Color textColor;
    String label;

    if (p.isOverdue) {
      bgColor = AppTheme.overdueColor;
      textColor = Colors.white;
      label = '${p.daysOverdue}d Overdue';
    } else if (p.isDueToday) {
      bgColor = AppTheme.dueTodayColor;
      textColor = Colors.white;
      label = 'Due Today';
    } else {
      bgColor = AppTheme.upcomingColor;
      textColor = Colors.white;
      final days = p.daysUntilWatering;
      label = days == 1 ? 'Tomorrow' : 'In $days days';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoGrid(Plant p) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.water_drop_rounded,
            label: 'Last Watered',
            value: DateFormat('MMM d').format(p.lastWatered),
            color: AppTheme.wateredColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.schedule_rounded,
            label: 'Next Due',
            value: DateFormat('MMM d').format(p.nextWateringDate),
            color: p.isOverdue ? AppTheme.overdueColor : AppTheme.dueTodayColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.repeat_rounded,
            label: 'Frequency',
            value: '${p.wateringFrequency}d',
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWateringProgress(Plant p) {
    final totalDays = p.wateringFrequency;
    final elapsed = DateTime.now().difference(p.lastWatered).inDays;
    final progress = (elapsed / totalDays).clamp(0.0, 1.0);

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = AppTheme.overdueColor;
    } else if (progress >= 0.75) {
      progressColor = AppTheme.dueTodayColor;
    } else {
      progressColor = AppTheme.upcomingColor;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Watering Cycle',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: progressColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $elapsed of $totalDays',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                elapsed > totalDays
                    ? '${elapsed - totalDays}d overdue'
                    : '${totalDays - elapsed}d remaining',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, PlantProvider provider, Plant p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        title: Text(
          'Delete ${p.name}?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to remove this plant?',
          style: GoogleFonts.inter(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deletePlant(p.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.overdueColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
