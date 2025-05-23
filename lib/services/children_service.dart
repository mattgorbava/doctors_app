import 'package:doctors_app/model/child.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class ChildrenService {
  static final ChildrenService _instance = ChildrenService._internal();
  factory ChildrenService() {
    return _instance;
  }
  ChildrenService._internal();

  var logger = Logger();

  final DatabaseReference _childrenRef = FirebaseDatabase.instance.ref().child('Children');

  Future<List<Child>> getAllChildrenByParentId(String parentId) async {
    List<Child> children = [];
    try {
      final snapshot = await _childrenRef.orderByChild('parentId').equalTo(parentId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          children.add(Child.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      logger.e('Error fetching children: $e');
    }
    return children;
  }

  Future<Child?> getChildById(String id) async {
    final snapshot = await _childrenRef.child(id).once();
    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      return Child.fromMap(Map<String, dynamic>.from(data), id);
    }
    return null;
  }

  Future<bool> addChild(Map<String, dynamic> child) async {
    try {
      await _childrenRef.orderByChild('uid').equalTo(child['cnp']).once().then((snapshot) {
        if (snapshot.snapshot.exists) {
          return false; 
        }
      });
      await _childrenRef.push().set(child);
      return true;
    } catch (e) {
      logger.e('Error adding child: $e');
      return false;
    }
  }

  Future<void> updateChild(Child child) async {
    try {
      await _childrenRef.child(child.uid).update(child.toMap());
    } catch (e) {
      logger.e('Error updating child: $e');
    }
  }

  Future<void> deleteChild(String id) async {
    try {
      await _childrenRef.child(id).remove();
    } catch (e) {
      logger.e('Error deleting child: $e');
    }
  }
}