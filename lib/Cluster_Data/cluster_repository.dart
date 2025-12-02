

import 'package:sqflite/sqflite.dart';
import '../Databases/dp_helper.dart';
import 'cluster_model.dart';

class ClusterRepository {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insertTravelData(ClusterModel data) async {
    final db = await _dbHelper.db;
    return await db.insert('TravelDataMasterTable', data.toMap());
  }

  Future<List<ClusterModel>> getAllTravelData() async {
    final db = await _dbHelper.db;
    final result = await db.query('TravelDataMasterTable');
    return result.map((e) => ClusterModel.fromMap(e)).toList();
  }

  Future<List<ClusterModel>> getTravelDataByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.db;
    final result = await db.query(
      'TravelDataMasterTable',
      where: 'travel_date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return result.map((e) => ClusterModel.fromMap(e)).toList();
  }

  Future<List<ClusterModel>> getTravelDataByCluster(int clusterId) async {
    final db = await _dbHelper.db;
    final result = await db.query(
      'TravelDataMasterTable',
      where: 'cluster_id = ?',
      whereArgs: [clusterId],
    );
    return result.map((e) => ClusterModel.fromMap(e)).toList();
  }

  Future<int> updateTravelData(ClusterModel data) async {
    final db = await _dbHelper.db;
    return await db.update('TravelDataMasterTable', data.toMap(),
        where: 'id = ?', whereArgs: [data.id]);
  }

  Future<int> deleteTravelData(int id) async {
    final db = await _dbHelper.db;
    return await db.delete('TravelDataMasterTable', where: 'id = ?', whereArgs: [id]);
  }

  // Bulk update cluster information
  Future<void> updateClusterInformation(List<ClusterModel> data) async {
    final db = await _dbHelper.db;
    final batch = db.batch();

    for (final item in data) {
      batch.update(
        'TravelDataMasterTable',
        {
          'cluster_id': item.clusterId,
          'cluster_type': item.clusterType,
          'cluster_center_lat': item.clusterCenterLat,
          'cluster_center_lon': item.clusterCenterLon,
          'points_in_cluster': item.pointsInCluster,
        },
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }

    await batch.commit();
  }
}