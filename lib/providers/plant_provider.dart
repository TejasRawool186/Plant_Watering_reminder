import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/plant.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';

class PlantProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  List<Plant> _plants = [];
  bool _isLoading = true;

  List<Plant> get plants => List.unmodifiable(_plants);
  bool get isLoading => _isLoading;

  List<Plant> get plantsNeedingWater =>
      _plants.where((p) => p.needsWatering).toList();

  List<Plant> get overduePlants =>
      _plants.where((p) => p.isOverdue).toList();

  List<Plant> get todayPlants =>
      _plants.where((p) => p.isDueToday && !p.isOverdue).toList();

  List<Plant> get upcomingPlants =>
      _plants.where((p) => !p.needsWatering).toList()
        ..sort((a, b) => a.nextWateringDate.compareTo(b.nextWateringDate));

  List<Plant> get sortedByNextWatering {
    final sorted = List<Plant>.from(_plants);
    sorted.sort((a, b) => a.nextWateringDate.compareTo(b.nextWateringDate));
    return sorted;
  }

  Future<void> loadPlants() async {
    _isLoading = true;
    notifyListeners();

    _plants = await _storageService.loadPlants();
    
    // Fetch from cloud to restore data if local is wiped (like on a web refresh)
    final cloudPlants = await _firebaseService.fetchPlantsFromCloud();
    if (cloudPlants.isNotEmpty) {
      if (_plants.isEmpty) {
        _plants = cloudPlants;
        await _storageService.savePlants(_plants);
      } else {
        // Safely merge missing cloud plants into local
        final localIds = _plants.map((p) => p.id).toSet();
        bool needsSave = false;
        for (var cp in cloudPlants) {
          if (!localIds.contains(cp.id)) {
            _plants.add(cp);
            needsSave = true;
          }
        }
        if (needsSave) await _storageService.savePlants(_plants);
      }
    }

    _isLoading = false;
    notifyListeners();

    // Background sync existing plants to cloud on load
    _firebaseService.syncPlantsToCloud(_plants);

    // Check for any due notifications
    try {
      await _notificationService.checkAndNotify(_plants);
    } catch (_) {}
  }

  Future<void> addPlant({
    required String name,
    required int wateringFrequency,
    required DateTime lastWatered,
    String? imagePath,
    IconData icon = Icons.eco,
    Color color = const Color(0xFF52B788),
  }) async {
    final plant = Plant(
      id: _uuid.v4(),
      name: name,
      wateringFrequency: wateringFrequency,
      lastWatered: lastWatered,
      imagePath: imagePath,
      icon: icon,
      color: color,
    );

    _plants.add(plant);
    await _savePlants();
    notifyListeners();
  }

  Future<void> deletePlant(String id) async {
    _plants.removeWhere((p) => p.id == id);
    try {
      await _notificationService.cancelReminder(id);
    } catch (_) {}
    
    // Remote delete target from cloud
    _firebaseService.deletePlant(id);
    
    await _savePlants();
    notifyListeners();
  }

  Future<void> markAsWatered(String id) async {
    final index = _plants.indexWhere((p) => p.id == id);
    if (index != -1) {
      _plants[index] = _plants[index].copyWith(lastWatered: DateTime.now());
      await _savePlants();
      notifyListeners();
    }
  }

  Future<void> updatePlant(String id, {
    String? name,
    int? wateringFrequency,
    DateTime? lastWatered,
    String? imagePath,
    IconData? icon,
    Color? color,
  }) async {
    final index = _plants.indexWhere((p) => p.id == id);
    if (index != -1) {
      _plants[index] = _plants[index].copyWith(
        name: name,
        wateringFrequency: wateringFrequency,
        lastWatered: lastWatered,
        imagePath: imagePath,
        icon: icon,
        color: color,
      );
      await _savePlants();
      notifyListeners();
    }
  }

  Future<void> _savePlants() async {
    await _storageService.savePlants(_plants);
    // Background execution safely
    _firebaseService.syncPlantsToCloud(_plants);
  }
}
