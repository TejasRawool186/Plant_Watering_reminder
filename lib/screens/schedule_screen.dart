import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/urgency_badge.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<PlantProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (provider.plants.isEmpty) {
            return const EmptyState(
              title: 'No Schedule Yet',
              subtitle:
                  'Add some plants and their watering schedule will appear here! 📅',
              icon: Icons.calendar_month_outlined,
            );
          }

          final grouped = _groupPlants(provider);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 20,
                    20,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watering\nSchedule',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.plants.length} plants total · ${provider.plantsNeedingWater.length} need water',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Schedule Groups
              ...grouped.entries.map((entry) {
                return SliverToBoxAdapter(
                  child: _buildGroup(context, entry.key, entry.value, provider),
                );
              }),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Plant>> _groupPlants(PlantProvider provider) {
    final Map<String, List<Plant>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(const Duration(days: 7));

    for (final plant in provider.sortedByNextWatering) {
      final nextDate = DateTime(
        plant.nextWateringDate.year,
        plant.nextWateringDate.month,
        plant.nextWateringDate.day,
      );

      String group;
      if (plant.isOverdue) {
        group = '⚠️ Overdue';
      } else if (nextDate.isAtSameMomentAs(today)) {
        group = '💧 Today';
      } else if (nextDate.isAtSameMomentAs(tomorrow)) {
        group = '📅 Tomorrow';
      } else if (nextDate.isBefore(endOfWeek)) {
        group = '📆 This Week';
      } else {
        group = '🌿 Later';
      }

      groups.putIfAbsent(group, () => []);
      groups[group]!.add(plant);
    }

    return groups;
  }

  Widget _buildGroup(
    BuildContext context,
    String title,
    List<Plant> plants,
    PlantProvider provider,
  ) {
    final isOverdue = title.contains('Overdue');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppTheme.overdueColor.withValues(alpha: 0.1)
                  : AppTheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isOverdue
                        ? AppTheme.overdueColor
                        : AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? AppTheme.overdueColor.withValues(alpha: 0.15)
                        : AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${plants.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOverdue
                          ? AppTheme.overdueColor
                          : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Schedule Items
          ...plants.map((plant) => _buildScheduleItem(
                context, plant, provider)),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    Plant plant,
    PlantProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Plant Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  plant.color.withValues(alpha: 0.15),
                  plant.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(plant.icon, color: plant.color, size: 22),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('EEEE, MMM d').format(plant.nextWateringDate),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),

          // Badge + Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UrgencyBadge(plant: plant, compact: true),
              if (plant.needsWatering) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    provider.markAsWatered(plant.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('💧 ${plant.name} watered!'),
                        backgroundColor: AppTheme.wateredColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.wateredColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.wateredColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.water_drop_rounded,
                            size: 12, color: AppTheme.wateredColor),
                        const SizedBox(width: 4),
                        Text(
                          'Water',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.wateredColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
