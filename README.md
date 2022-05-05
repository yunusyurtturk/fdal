# fdal
Database Abstraction Layer for Flutter


###  Flutter Database Abstraction Layer

- Firestore and Realtime Database. These are 2 different database solutions provided by Google's Firebase. They are different, but they have some common properties:
	- JSON based
	- Create, Read, Update, Delete Operations
	- Subscription to changes
	- Querying

So instead of directly using Firestore or Realtime Database's API, I made an abstraction layer for these 2 database solutions and provide common functionalities through it.

###Correspondance Table
                    
Class  | Description
------------- | ------------- 
DBService  | Provides initialization and initial operations, like getting a reference to an entry
DBRef   | Reference to an entry/document 
DBQuery   | Query interface  
DBSubscription   | Subscription interface  
DBDataSnapshot   | Snapshot interface  
DBField   | Field/Entry interface  
DBDataSnapshot   | Snapshot interface  


####Dart/Flutter code

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
```
