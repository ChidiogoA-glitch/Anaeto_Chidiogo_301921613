-- Session A: doctor completing appointment 1

-- 1: doctor opens the appointment to review it
BEGIN;
SELECT a.appointment_id, p.first_name || ' ' || p.last_name AS patient,
       d.doctor_name AS doctor, a.appointment_date, a.reason, a.status
FROM Appointments a
JOIN Patients p ON p.patient_id = a.patient_id
JOIN Doctors d ON d.doctor_id = a.doctor_id
WHERE a.appointment_id = 1;

-- 3: doctor marks it completed, unaware the patient just cancelled
UPDATE Appointments SET status = 'Completed', diagnosis = 'Routine check, no issues'
WHERE appointment_id = 1;
COMMIT;
SELECT a.appointment_id, p.first_name || ' ' || p.last_name AS patient,
       d.doctor_name AS doctor, a.diagnosis, a.status
FROM Appointments a
JOIN Patients p ON p.patient_id = a.patient_id
JOIN Doctors d ON d.doctor_id = a.doctor_id
WHERE a.appointment_id = 1;

-- 4: reset, then doctor opens and locks the appointment while reviewing
UPDATE Appointments SET status = 'Scheduled', diagnosis = NULL WHERE appointment_id = 1;
BEGIN;
SELECT a.appointment_id, p.first_name || ' ' || p.last_name AS patient,
       d.doctor_name AS doctor, a.appointment_date, a.reason, a.status
FROM Appointments a
JOIN Patients p ON p.patient_id = a.patient_id
JOIN Doctors d ON d.doctor_id = a.doctor_id
WHERE a.appointment_id = 1
FOR UPDATE OF a;

-- 6: doctor marks it completed and releases the lock
UPDATE Appointments SET status = 'Completed', diagnosis = 'Routine check, no issues'
WHERE appointment_id = 1;
COMMIT;

-- 8: check the final status
SELECT a.appointment_id, p.first_name || ' ' || p.last_name AS patient,
       d.doctor_name AS doctor, a.diagnosis, a.status
FROM Appointments a
JOIN Patients p ON p.patient_id = a.patient_id
JOIN Doctors d ON d.doctor_id = a.doctor_id
WHERE a.appointment_id = 1;
