import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class DBRef
{
  Future<void> set(Map<String, dynamic> map, {String? path});
  Future<void> update(Map<String, dynamic> map, {String? path});
  DBRef getChild(String? path);
  DBSubscription subscribe(Function onUpdate);
  String get id;
}

abstract class DBDataSnapshot
{
  DBDataSnapshot(Future<QuerySnapshot<Map<String, dynamic>>> future);
  set isNotEmpty(bool val);
  bool get isNotEmpty;
  List<Map<String, dynamic>> get data;
  List<DBRef> get references;

}

abstract class DBQuery{
  Future<DBDataSnapshot> result();
  DBRef resultRef();
}

abstract class DBSubscription
{
  Future<void> unsubscribe();
}

abstract class DBField
{

}
abstract class DBService
{
  void Init(FirebaseApp app) ;

  DBRef GetRef(String path);

  DBRef GetChild(DBRef ref, String child);

  dynamic Read(dynamic ref); 

  DBSubscription Subscribe(DBRef ref, Function onUpdate);

  DBQuery query(DBRef ref, Object field, {
      Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      List<Object?>? arrayContainsAny,
      List<Object?>? whereIn,
      List<Object?>? whereNotIn,
      bool? isNull,
  }) ;

  dynamic arrayCombine(List<dynamic> vals, {List<dynamic>? current});

  Future<void> set(DBRef ref, Map<String, dynamic> map);


}