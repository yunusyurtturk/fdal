# fdal
Database Abstraction Layer for Flutter

###  Flutter Database Abstraction Layer

- Firestore and Realtime Database... These are 2 different database solutions provided by Google's Firebase. They are different, but they have some common properties:
	- JSON based
	- Create, Read, Update, Delete Operations
	- Subscription to changes
	- Querying

So instead of directly using Firestore or Realtime Database's API, I made an abstraction layer for these 2 database solutions and provide common functionalities through it. Also make sure to read Warning! section!



### Core classes
                    
Class  | Description
------------- | ------------- 
DBService  | Provides initialization and initial operations, like getting a reference to an entry
DBRef   | Reference to an entry/document 
DBQuery   | Query interface  
DBSubscription   | Subscription interface  
DBDataSnapshot   | Snapshot interface  
DBField   | Field/Entry interface  
DBDataSnapshot   | Snapshot interface  

### Description
Instead of directly using Firestore or Realtime DB API, you should initialize corresponding database service classes (Firestore or Realtime DB) and provide Firebase app to their Init method.

```dart
DBService dBService = FirebaseFirestoreDBService(); // for Firestore
//OR
DBService dBService = FirebaseRealtimeDBService(); // for Realtime DB
dBService.Init(Firebase.apps[0]);	// Provide Firebase App
```
From now on, you can use FDAL's set, get, update, query, subscription operations.



#### Dart/Flutter code

```dart

// Create DBService
DBService dBService = FirebaseFirestoreDBService(); // for Firestore
// OR
DBService dBService = FirebaseRealtimeDBService(); // for Realtime DB

// Init service
dBService.Init(Firebase.apps[0]);

// Get references
DBRef entryRef = dbService.GetRef("node_name"); // Get Root->node_name,
DBRef someRef = dbService.GetRef("some_name"); // Get Root->some_name

// Get child reference of a reference
DBRef childRef = entryRef.getChild("child_name"); // Child ref of a ref
DBRef childRef = entryRef.getChild(null); // returns entryRef

// Stepping child references
childRef.getChild("child1").getChild("child2").getChild("child3"); // childRef.child1.child2.child3

// Querying
// Returns entries whose "code" field is equal to "some_string"
DBQuery nodeQuery = await dbService.query(refDB, 'code', isEqualTo: "some_string"); 

// Currently supports only isEqualTo, other querying properties are to be implemented


// Getting query result
DBDataSnapshot result = await nodeQuery.result()

await nodeQuery.result().then((value){
      if(value.isNotEmpty){
	  	List<dynamic> result = value.data; // Returns results as List (like docs for Firestore)
		Map<String, dynamic> json = result[0]; // Returns JSON like result
	  }
}

// Updating
Map<String, dynamic> json;	// A JSON data
Future<void> result = dbRef.update(json)	// Update data

// Subscribing
DBSubscription  subscription = dbRef.subscribe((event){
	// Event come as Map<String, dynamic>
});

// Inserting into arrays

/* 
   In Firestore, FieldValue.arrayUnion() method is used to combine/insert to arrays. 
   But in Realtime DB, you should do it manually (if not,  let me know!).
   So this method gets a little more parameters to support manually updating array. 
   (I don't want to mention Realtime DB has no concept of arrays :(
*/
List<dynamic> currentArray; // An existing array with values
dbRef.update({
   "array_name" : dbService.arrayCombine([entry], current: currentArray),
   //"players" : dbService!.arrayCombine([{userID :username}])
})


```

### Warning!
I build this library to solve my personal problems, later decided to share with public. I'm sure it'd give insights to many people. 
Use with caution. It is not complete (for example it is missing many querying options) and  I dont have passion to make it a complete library. 
It may not be  a complete solution for your problems. Don't hesitate to make it complete for you ;). 
