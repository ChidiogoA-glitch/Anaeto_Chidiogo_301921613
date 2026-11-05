// STEP 1: Query before indexing
var beforeIndex = db.appointments
  .find({ doctor_id: 29 })
  .sort({ appointment_date: 1 })
  .explain("executionStats");

print("BEFORE INDEXING");
printjson(beforeIndex.executionStats);


// STEP 2: Create compound index
db.appointments.createIndex({
  doctor_id: 1,
  appointment_date: 1
});

// STEP 3: Create unique index
db.patients.createIndex(
  { patient_id: 1 },
  { unique: true }
);

// STEP 4: Display indexes
print("CREATED INDEXES");
printjson(db.appointments.getIndexes());
printjson(db.patients.getIndexes());


// STEP 5: Run the same query after indexing
var afterIndex = db.appointments
  .find({ doctor_id: 29 })
  .sort({ appointment_date: 1 })
  .explain("executionStats");

print("AFTER INDEXING");
printjson(afterIndex.executionStats);