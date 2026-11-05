var session2 = db.getMongo().startSession();
var hosp2 = session2.getDatabase("Miva_Hospital");

session2.startTransaction({
  readConcern: { level: "snapshot" },
  writeConcern: { w: "majority" },
});

// Insert appointment inside transaction
hosp2.appointments.insertOne({
  appointment_id: 20,
  patient_id: 300,
  doctor_id: 24,
  appointment_date: ISODate("2026-11-12T09:00:00Z"),
  reason: "Consultation",
  status: "Scheduled",
});

// Display document inside transaction
print("========== BEFORE ROLLBACK ==========");
printjson(
  hosp2.appointments.findOne({ appointment_id: 20 })
);

// Abort transaction
session2.abortTransaction();
session2.endSession();

// Verify outside transaction
var hospCheck = db.getSiblingDB("Miva_Hospital");

print("\n========== AFTER ROLLBACK ==========");
printjson(
  hospCheck.appointments.findOne({ appointment_id: 20 })
);

print("\n========== ROLLBACK VERIFICATION ==========");
print(
  "Appointment 20 count:",
  hospCheck.appointments.countDocuments({ appointment_id: 20 })
);

print("Transaction successfully rolled back.");