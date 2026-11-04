-- Session B: patient cancelling appointment 1 online

-- 2: patient checks the appointment and cancels it
BEGIN;
SELECT a.appointment_id, p.first_name || ' ' || p.last_name AS patient,
       a.appointment_date, a.status
FROM Appointments a
JOIN Patients p ON p.patient_id = a.patient_id
WHERE a.appointment_id = 1;
UPDATE Appointments SET status = 'Cancelled' WHERE appointment_id = 1;
COMMIT;

-- 5: patient tries to cancel while the doctor is reviewing (waits)
BEGIN;
UPDATE Appointments a SET status = 'Cancelled'
FROM Patients p
WHERE p.patient_id = a.patient_id
  AND a.appointment_id = 1
  AND a.status = 'Scheduled';

-- 7: cancel finds the appointment already completed (UPDATE 0)
COMMIT;