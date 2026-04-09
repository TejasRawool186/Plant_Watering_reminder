import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/plant_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_card.dart';
import '../widgets/empty_state.dart';
import 'add_plant_screen.dart';
import 'plant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PlantProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            );
          }

          if (provider.plants.isEmpty) {
            return EmptyState(
              title: 'No Plants Yet',
              subtitle:
                  'Start by adding your first plant and we\'ll help you keep it happy and hydrated! 🌱',
              icon: Icons.yard_outlined,
              actionLabel: 'Add Your First Plant',
              onAction: () => _navigateToAddPlant(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadPlants();
            },
            color: AppTheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(provider),
                ),
              // Stats Cards
              SliverToBoxAdapter(
                child: _buildStatsRow(provider),
              ),
              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Your Plants',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              // Plant List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final plant = provider.sortedByNextWatering[index];
                      return Slidable(
                        key: ValueKey(plant.id),
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          dismissible: DismissiblePane(
                            onDismissed: () {
                              provider.deletePlant(plant.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${plant.name} removed'),
                                  backgroundColor: AppTheme.overdueColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      provider.addPlant(
                                        name: plant.name,
                                        wateringFrequency:
                                            plant.wateringFrequency,
                                        lastWatered: plant.lastWatered,
                                        imagePath: plant.imagePath,
                                        icon: plant.icon,
                                        color: plant.color,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                provider.deletePlant(plant.id);
                              },
                              backgroundColor: AppTheme.overdueColor,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd),
                            ),
                          ],
                        ),
                        child: PlantCard(
                          plant: plant,
                          index: index,
                          onTap: () => _navigateToDetail(context, plant),
                          onDelete: () {
                            provider.deletePlant(plant.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${plant.name} deleted!'),
                                backgroundColor: AppTheme.overdueColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          onWater: () {
                            provider.markAsWatered(plant.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '💧 ${plant.name} has been watered!'),
                                backgroundColor: AppTheme.wateredColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: provider.plants.length,
                  ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(PlantProvider provider) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXl),
          bottomRight: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting 🌿',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plant Care',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          if (provider.plantsNeedingWater.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.plantsNeedingWater.length} plant${provider.plantsNeedingWater.length > 1 ? 's' : ''} need watering today',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(PlantProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.yard_rounded,
            label: 'Total',
            value: '${provider.plants.length}',
            color: AppTheme.primary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.warning_rounded,
            label: 'Overdue',
            value: '${provider.overduePlants.length}',
            color: AppTheme.overdueColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.schedule_rounded,
            label: 'Today',
            value: '${provider.todayPlants.length}',
            color: AppTheme.dueTodayColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddPlant(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddPlantScreen()),
    );
  }

  void _navigateToDetail(BuildContext context, plant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlantDetailScreen(plant: plant),
      ),
    );
  }
}
