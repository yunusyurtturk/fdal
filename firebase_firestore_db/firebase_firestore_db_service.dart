import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hizli_pisti/game/db_service/db_service_if.dart';

class FirestoreDBRef implements DBRef{
  
  FirestoreDBRef.collection(this._ref){ isCollection = true; }
  FirestoreDBRef.document(this._ref2);
  
  bool isCollection = false;
  CollectionReference<Map<String, dynamic>>? _ref;
  DocumentReference<Map<String, dynamic>>? _ref2;

  CollectionReference<Map<String, dynamic>>? getCollection() => _ref;
  DocumentReference<Map<String, dynamic>>? getDocument() => (isCollection)?_ref!.doc():_ref2;

  DBRef get(){
    return (isCollection)?FirestoreDBRef.collection(_ref):FirestoreDBRef.document(_ref2);
  }

  @override
  Future<void> set(Map<String, dynamic> map, {String? path}) {
    if(path==null)
      return getDocument()!.set(map);
    else
      return get().getChild(path).set(map);
  }

  @override
  Future<void> update(Map<String, dynamic> map, {String? path}) {
    if(path==null)
      return getDocument()!.update(map);
    else
      return get().getChild(path).update(map);
  }

  @override
  DBRef getChild(String? path){
    
    return (path==null)
            ?this
            :(isCollection
              ?FirestoreDBRef.document(getCollection()!.doc(path))
              :FirestoreDBRef.collection(getDocument()!.collection(path)
             )
            );
  }
  
  @override
  DBSubscription subscribe(Function onUpdate) {
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> subscription;
    if(isCollection){
      subscription = getCollection()!.doc().snapshots().listen((event) {
        onUpdate(event);
      });
    }else{
      subscription  =  getDocument()!.snapshots().listen((event) {
        onUpdate(event.data());
      });
    }

    return FirestoreDBSubscription(subscription);
  }
  
  @override
  String get id => getDocument()!.id;
  
  
  
  
}


class FirestoreDBDataSnapshot implements DBDataSnapshot
{
  FirestoreDBDataSnapshot(this._snapshot){
    
      isNotEmpty = _snapshot.docs.isNotEmpty;
      if(isNotEmpty){
        _data = _snapshot.docs.map((e) => {e.id: e.data()}).toList();
        _reference = _snapshot.docs.map((e) => FirestoreDBRef.document(e.reference)).toList();
      }
    ;
  }

  
  bool _isNotEmpty = false;
  final QuerySnapshot<Map<String, dynamic>> _snapshot;
  late List<FirestoreDBRef> _reference;
  late List<Map<String, dynamic>> _data;
  
  QuerySnapshot<Map<String, dynamic>> get() => _snapshot;
  bool get isNotEmpty => _isNotEmpty;
  set isNotEmpty(bool val) => _isNotEmpty = val;
  
  @override
  List<Map<String, dynamic>> get data => _data;

  @override
  List<FirestoreDBRef> get references => _reference;

  

}

class FirestoreDBQuery implements DBQuery
{
  FirestoreDBQuery(this._query);

  final Query<Map<String, dynamic>> _query;

  Query<Map<String, dynamic>> get() => _query;
  
  @override
  Future<DBDataSnapshot> result() async{
    QuerySnapshot<Map<String, dynamic>> res =  await get().get();
    FirestoreDBDataSnapshot dbSnapshot = FirestoreDBDataSnapshot(res);
    return dbSnapshot;
  }
  
  @override
  DBRef resultRef() {
    // TODO: implement resultRef
    throw UnimplementedError();
  }
}

class FirestoreDBSubscription implements DBSubscription
{
  final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _subscription;
  FirestoreDBSubscription(this._subscription);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> get() => _subscription;

  Future<void> unsubscribe()
  {
    return get().cancel();
  }
}

class FirestoreDBField implements DBField
{
  final List<dynamic>  _fieldValue;
  FirestoreDBField(this._fieldValue);

  FieldValue get() => FieldValue.arrayUnion(_fieldValue);
  // FieldValue.arrayUnion([{userID :username}])}
}
class FirebaseFirestoreDBService implements DBService
{
  late FirebaseApp _app;

  @override
  DBRef GetRef(String collectionName) {
    final CollectionReference<Map<String, dynamic>> collectionRef = FirebaseFirestore.instance.collection(collectionName);
    return FirestoreDBRef.collection(collectionRef);
  }



  @override
  void Init(FirebaseApp app) {
    _app = app;
     
  }
  
  @override
  DBRef GetChild(DBRef ref, String child){
 
    FirestoreDBRef dbref = ref as FirestoreDBRef;
    
    return dbref;
  }
  
  @override
  Read(ref) {
    // TODO: implement Read
    throw UnimplementedError();
  }
  
  @override
  DBSubscription Subscribe(DBRef ref, Function onUpdate) {
    FirestoreDBRef dbref = ref as FirestoreDBRef;
    return dbref.subscribe(onUpdate);
  }

  @override
  Future<void> set(DBRef ref, Map<String, dynamic> map) {
    FirestoreDBRef dbref = ref as FirestoreDBRef;
    return dbref.set(map);
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

    FirestoreDBRef dbref = ref as FirestoreDBRef;
    CollectionReference<Map<String, dynamic>>? collection_ref = dbref.getCollection();
    
    return FirestoreDBQuery(
      collection_ref!.where(field, 
        isEqualTo: isEqualTo, isNotEqualTo: isNotEqualTo, isLessThan: isLessThan, isLessThanOrEqualTo: isLessThanOrEqualTo, isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo, arrayContains: arrayContains, arrayContainsAny: arrayContainsAny, whereIn: whereIn, whereNotIn: whereNotIn, isNull: isNull
      )
    );

  }
  
  @override
  dynamic arrayCombine(List vals, {List? current}) {
    return FirestoreDBField(vals).get();
  }
  
  

  


  
}