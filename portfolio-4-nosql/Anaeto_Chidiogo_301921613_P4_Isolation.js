// TRANSACTION ISOLATION DEMONSTRATION


var s1 = db.getMongo().startSession();

var t1 = s1.getDatabase("Miva_Hospital");


// Snapshot isolation ensures the transaction reads from a consistent snapshot of the database.
s1.startTransaction({
  readConcern: { level: "snapshot" }
});

// This change is not yet committed to the database.
t1.patients.updateOne(
  { patient_id: 1034 },
  { $set: { phone: "08099999999" } }
);

// The transaction should see its own uncommitted update.
print(
  "Inside transaction sees: ",
  t1.patients.findOne({ patient_id: 1034 }).phone
);

// The outside session should still see the previously committed value.
print(
  "Outside transaction sees: ",
  db.getSiblingDB("Miva_Hospital")
    .patients.findOne({ patient_id: 1034 }).phone
);

// The update becomes permanent and visible to other sessions.
s1.commitTransaction();

s1.endSession();

// The updated phone number should now be visible outside the transaction.
print(
  "After commit, everyone sees: ",
  db.getSiblingDB("Miva_Hospital")
    .patients.findOne({ patient_id: 1034 }).phone
);
