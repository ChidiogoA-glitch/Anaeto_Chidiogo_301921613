use("Miva_Hospital")

db.createCollection("patients")
db.createCollection("doctors")
db.createCollection("appointments")
db.createCollection("prescriptions")
db.createCollection("laboratory_records")

show collections

// insert into the collections

db.patients.insertMany([
  { patient_id: 1, first_name: "Ada", last_name: "Okafor", date_of_birth: ISODate("1992-04-18T00:00:00Z"), gender: "Female", phone: "08000000001" },
  { patient_id: 2, first_name: "Tunde", last_name: "Bello", date_of_birth: ISODate("1985-09-02T00:00:00Z"), gender: "Male", phone: "08000000002" },
  { patient_id: 3, first_name: "Ngozi", last_name: "Eze", date_of_birth: ISODate("2001-01-25T00:00:00Z"), gender: "Female", phone: "08000000003", allergies: ["Penicillin"] }
])
db.patients.find({}, { _id: 0 })

db.doctors.insertMany([
  { doctor_id: 1, doctor_name: "Dr Chika Nwosu", specialization: "General Practice" },
  { doctor_id: 2, doctor_name: "Dr Emeka Obi", specialization: "Internal Medicine" }
])

db.doctors.find({}, { _id: 0 })

db.appointments.insertMany([
  { appointment_id: 1, patient_id: 1, doctor_id: 1, appointment_date: ISODate("2026-11-05T09:00:00Z"), reason: "General check-up", status: "Completed" },
  { appointment_id: 2, patient_id: 2, doctor_id: 2, appointment_date: ISODate("2026-11-06T10:30:00Z"), reason: "Fever", status: "Completed" },
  { appointment_id: 3, patient_id: 3, doctor_id: 1, appointment_date: ISODate("2026-11-10T14:00:00Z"), reason: "Follow-up", status: "Scheduled" }
])

db.appointments.find({}, { _id: 0 })

db.prescriptions.insertMany([
  { prescription_id: 1, patient_id: 1, doctor_id: 1, appointment_id: 1, medication: "Paracetamol", dosage: "500mg", frequency: "Twice daily", duration: "5 days", prescription_date: ISODate("2026-11-05T00:00:00Z") },
  { prescription_id: 2, patient_id: 2, doctor_id: 2, appointment_id: 2, medication: "Artemether-Lumefantrine", dosage: "80/480mg", frequency: "Twice daily", duration: "3 days", prescription_date: ISODate("2026-11-06T00:00:00Z") }
])

db.prescriptions.find({}, { _id: 0 })

db.laboratory_records.insertMany([
  { lab_id: 1, patient_id: 1, appointment_id: 1, test_type: "Full Blood Count", test_date: ISODate("2026-11-05T10:00:00Z"), results: { haemoglobin: 13.2, wbc: 6.1, platelets: 250 }, status: "Completed" },
  { lab_id: 2, patient_id: 2, appointment_id: 2, test_type: "Malaria Parasite", test_date: ISODate("2026-11-06T11:00:00Z"), results: { parasite_detected: true, density: "++" }, status: "Completed" }
])

db.laboratory_records.find({}, { _id: 0 })

// Inserting 50 doctor records 

var specs = ["General Practice", "Paediatrics", "Cardiology", "Internal Medicine", "Obstetrics", "Dermatology"]
var docs = []
for (var d = 3; d <= 50; d++) {
  docs.push({ doctor_id: d, doctor_name: "Dr Test " + d, specialization: specs[d % specs.length] })
}
db.doctors.insertMany(docs)
print("Doctors now:", db.doctors.countDocuments())

//insert 10,000 into appointments

var statuses = ["Scheduled", "Completed", "Cancelled"]
var reasons = ["General check-up", "Fever", "Follow-up", "Consultation", "Lab review"]
var start = new Date("2026-01-01T08:00:00Z").getTime()
var batch = []
var total = 0

for (var i = 1; i <= 10000; i++) {
  batch.push({
    appointment_id: 1000 + i,
    patient_id: 1 + (i % 3),
    doctor_id: 1 + Math.floor(Math.random() * 50),
    appointment_date: new Date(start + Math.floor(Math.random() * 365) * 86400000),
    reason: reasons[i % reasons.length],
    status: statuses[i % statuses.length]
  })
  if (batch.length === 1000) {
    db.appointments.insertMany(batch)
    total += batch.length
    batch = []
  }
}
if (batch.length) { db.appointments.insertMany(batch); total += batch.length }

print("Inserted:", total, "| Appointments in collection:", db.appointments.countDocuments())

//insert 10,000 into Patients 

var firstF = ["Ada", "Ngozi", "Funke", "Aisha", "Chioma", "Bisi", "Amara", "Zainab", "Kemi", "Halima"]
var firstM = ["Tunde", "Emeka", "Musa", "Chidi", "Segun", "Ibrahim", "Obinna", "Femi", "Usman", "Kunle"]
var lastNames = ["Okafor", "Bello", "Eze", "Adeyemi", "Abubakar", "Nwosu", "Ogunleye", "Ibrahim", "Okoro", "Lawal", "Obi", "Danjuma"]
var allergyList = ["Penicillin", "Sulfa drugs", "Peanuts", "Latex", "Aspirin"]
var minDob = new Date("1950-01-01").getTime()
var maxDob = new Date("2020-12-31").getTime()
var batch = []
var total = 0

for (var i = 1; i <= 10000; i++) {
  var gender = Math.random() < 0.5 ? "Female" : "Male"
  var names = gender === "Female" ? firstF : firstM
  var p = {
    patient_id: 1000 + i,
    first_name: names[Math.floor(Math.random() * names.length)],
    last_name: lastNames[Math.floor(Math.random() * lastNames.length)],
    date_of_birth: new Date(minDob + Math.random() * (maxDob - minDob)),
    gender: gender,
    phone: "080" + (20000000 + i)
  }
  if (Math.random() < 0.15) {
    p.allergies = [allergyList[Math.floor(Math.random() * allergyList.length)]]
  }
  batch.push(p)
  if (batch.length === 1000) {
    db.patients.insertMany(batch)
    total += batch.length
    batch = []
  }
}
if (batch.length) { db.patients.insertMany(batch); total += batch.length }

print("Inserted:", total, "| Patients in collection:", db.patients.countDocuments())