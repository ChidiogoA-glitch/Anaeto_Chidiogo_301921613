var session = db.getMongo().startSession();
var hosp = session.getDatabase("Miva_Hospital");
session.startTransaction({
  readConcern: { level: "snapshot" },
  writeConcern: { w: "majority" },
});

hosp.appointments.insertOne({
  appointment_id: 5,
  patient_id: 43,
  doctor_id: 12,
  appointment_date: ISODate("2026-11-07T11:00:00Z"),
  reason: "Malaria follow-up",
  status: "Completed",
});
hosp.prescriptions.insertOne({
  prescription_id: 3,
  patient_id: 25,
  doctor_id: 21,
  appointment_id: 4,
  medication: "Vitamin B Complex",
  dosage: "1 tablet",
  frequency: "Daily",
  duration: "14 days",
  prescription_date: ISODate("2026-11-07T00:00:00Z"),
});

session.commitTransaction();
session.endSession();
print(
  "Committed. Appointment 4 count:",
  db.appointments.countDocuments({ appointment_id: 5 }),
  "| Prescription 3 count:",
  db.prescriptions.countDocuments({ prescription_id: 3 }),
);

print("========== COMMIT VERIFICATION ==========");

print("\nCommitted Appointment:");
printjson(
  db.getSiblingDB("Miva_Hospital").appointments.findOne({
    appointment_id: 5
  })
);

print("\nCommitted Prescription:");
printjson(
  db.getSiblingDB("Miva_Hospital").prescriptions.findOne({
    prescription_id: 3
  })
);

print("\n========== TRANSACTION SUCCESSFUL ==========");
