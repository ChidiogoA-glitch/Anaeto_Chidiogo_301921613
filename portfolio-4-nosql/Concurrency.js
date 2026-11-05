var sA = db.getMongo().startSession();
var sB = db.getMongo().startSession();
var a = sA.getDatabase("Miva_Hospital");
var b = sB.getDatabase("Miva_Hospital");
sA.startTransaction();
sB.startTransaction();

a.appointments.updateOne(
  { appointment_id: 34 },
  { $set: { status: "Cancelled" } },
);
print("Staff A updated appointment 34 (not yet committed)");

try {
  b.appointments.updateOne(
    { appointment_id: 34 },
    { $set: { status: "Rescheduled" } },
  );
} catch (e) {
  print("Staff B rejected:", e.codeName);
  sB.abortTransaction();
}

sA.commitTransaction();
print("Final status:", db.appointments.findOne({ appointment_id: 34 }).status);
sA.endSession();
sB.endSession();
