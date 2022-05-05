

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hizli_pisti/game/db_service/db_service_if.dart';

class RealtimeDBRef implements DBRef
{
  final DatabaseReference _ref;
  RealtimeDBRef(this._ref){
  
  }

  DatabaseReference get() => _ref;
  
  @override
  Future<void> set(Map<String, dynamic> map, {String? path}) {

    DatabaseReference temp = (path==null)?get():(get().child(path));
  
    return temp.set(map);
  }
  
  @override
  DBRef getChild(String? path) {
    return (path == null)?RealtimeDBRef(get()):RealtimeDBRef(get().child(path));
  }
  
  @override
  DBSubscription subscribe(Function onUpdate) {

    StreamSubscription<DatabaseEvent> subscription = get().onValue.listen((event){
      if (event.snapshot.exists){
        onUpdate(jsonDecode(jsonEncode(event.snapshot.value)));
      }
    });
    return RealtimeDBSubscription(subscription);
  }
  
  @override
  String get id => get().key!;
  
  @override
  Future<void> update(Map<String, dynamic> map, {String? path}) {
    return get().update(map);
  }
}

class RealtimeDBDataSnapshot implements DBDataSnapshot
{
  final DataSnapshot _snapshot;
  RealtimeDBDataSnapshot(this._snapshot){
    if(_snapshot.exists){
      isNotEmpty = true;

      
    }

  }
  bool _isNotEmpty = false;
  DataSnapshot get() => _snapshot;
  bool get isNotEmpty => _isNotEmpty;
  set isNotEmpty(bool val) => _isNotEmpty = val;

  
  @override
  List<Map<String, dynamic>> get data {
    
    Map<String, dynamic> res2 = jsonDecode(jsonEncode(get().value));
    //Map<String, dynamic> res1 = get().value as Map<String, dynamic>;
    
    return List.filled(1, res2);
  }
  
  @override
  List<DBRef> get references => List.filled(1, RealtimeDBRef(get().ref));

}

class RealtimeDBQuery implements DBQuery
{
  final Query _query;
  RealtimeDBQuery(this._query);

  Query get() => _query;
  
  @override
  Future<DBDataSnapshot> result() async {

    DataSnapshot res = await get().get();
    RealtimeDBDataSnapshot dbSnapshot = RealtimeDBDataSnapshot(res);
    return dbSnapshot;
  }
  
  @override
  DBRef resultRef() {
    return RealtimeDBRef(get().ref);
  }
}

class RealtimeDBSubscription implements DBSubscription
{
  final StreamSubscription<DatabaseEvent> _subscription;
  RealtimeDBSubscription(this._subscription);
  StreamSubscription<DatabaseEvent> get() => _subscription;

  Future<void> unsubscribe()
  {
    return get().cancel();
  }
}

class FirebaseRealtimeDBService implements DBService
{
  late FirebaseDatabase instance;
  late FirebaseApp _app;

  @override
  DBRef GetRef(String path) {
    DatabaseReference ref = FirebaseDatabase.instanceFor(app: _app, databaseURL: "https://hizlipisti-default-rtdb.europe-west1.firebasedatabase.app/").ref(path);
   
    return new RealtimeDBRef(ref);
  }



  @override
  void Init(FirebaseApp app) {
    _app = app;
     instance = FirebaseDatabase.instanceFor(app: _app, databaseURL: "https://hizlipisti-default-rtdb.europe-west1.firebasedatabase.app/" );
  }
  
  @override
  DBRef GetChild(DBRef ref, String child) {
    RealtimeDBRef dbref = ref as RealtimeDBRef;
    return new RealtimeDBRef(dbref.get().child(child));
  }
  
  @override
  Read(ref) {
    // TODO: implement Read
    throw UnimplementedError();
  }
  
  @override
  DBSubscription Subscribe(DBRef ref, Function onUpdate) {
    RealtimeDBRef dbref = ref as RealtimeDBRef;
    Stream<DatabaseEvent> stream = dbref.get().onValue;

    return RealtimeDBSubscription(
      stream.listen((DatabaseEvent event){
        onUpdate(jsonDecode(jsonEncode(event.snapshot.value)));
      })
    );

  }
  
  @override
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
  }){
    RealtimeDBRef dbref = ref as RealtimeDBRef;
    Query query = dbref.get();

    query = (isEqualTo!=null)?query.orderByChild('code').equalTo((isEqualTo as String)):query;

    return  RealtimeDBQuery(query);
  }
  
  @override
  Future<void> set(DBRef ref, Map<String, dynamic> map) {
    RealtimeDBRef dbref = ref as RealtimeDBRef;
    return dbref.get().set(map);
  }
  
  @override
  dynamic arrayCombine(List vals, {List? current}) {
    return [...vals, ...current!];

  }

  


  
}