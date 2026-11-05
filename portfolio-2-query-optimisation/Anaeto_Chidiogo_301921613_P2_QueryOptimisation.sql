--Run Analyze query
EXPLAIN (ANALYZE, BUFFERS)
SELECT appointment_id, appointment_date, status, diagnosis
FROM Appointments
WHERE patient_id = 1
ORDER BY appointment_date DESC;

-- create index query
CREATE INDEX IX_Appointments_Patient_Date
ON Appointments(patient_id, appointment_date DESC)
INCLUDE (doctor_id, status, diagnosis);

CREATE INDEX IX_Appointments_Doctor_Date
ON Appointments(doctor_id, appointment_date)
INCLUDE (patient_id, status);

CREATE INDEX IX_Prescriptions_Patient_Date
ON Prescriptions(patient_id, prescription_date DESC)
INCLUDE (doctor_id, medication, dosage);

CREATE INDEX IX_LabRecords_Patient_Date
ON Laboratory_Records(patient_id, test_date DESC)
INCLUDE (doctor_id, test_name, result_status);

-- Refresh planner statistics after creating indexes or loading data
ANALYZE Appointments;
ANALYZE Prescriptions;
ANALYZE Laboratory_Records;

--Re run Analyze

EXPLAIN (ANALYZE, BUFFERS)
SELECT appointment_id, appointment_date, status, diagnosis
FROM Appointments
WHERE patient_id = 1
ORDER BY appointment_date DESC;