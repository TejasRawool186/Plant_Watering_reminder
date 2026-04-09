import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/plant.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'plants';

  Future<void> syncPlantsToCloud(List<Plant> currentPlants) async {
    try {
      final batch = _firestore.batch();
      for (var plant in currentPlants) {
        final docRef = _firestore.collection(_collectionName).doc(plant.id);
        batch.set(docRef, plant.toJson(), SetOptions(merge: true));
      }
      await batch.commit();
      debugPrint('☁️ Successfully backed up ${currentPlants.length} plants to Firebase.');
    } catch (e) {
      debugPrint('⚠️ Error syncing to Firebase: $e');
    }
  }

  Future<List<Plant>> fetchPlantsFromCloud() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      final plants = snapshot.docs.map((doc) => Plant.fromJson(doc.data())).toList();
      debugPrint('☁️ Successfully fetched ${plants.length} plants from Firebase.');
      return plants;
    } catch (e) {
      debugPrint('⚠️ Error fetching from Firebase: $e');
      return [];
    }
  }

  Future<void> deletePlant(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      debugPrint('☁️ Successfully deleted plant $id from Firebase.');
    } catch (e) {
      debugPrint('⚠️ Error deleting from Firebase: $e');
    }
  }
}
