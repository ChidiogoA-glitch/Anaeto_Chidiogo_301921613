/*
TRANSACTION DEMONSTRATION 1: COMMIT
Database: PostgreSQL
Table: Appointments

Purpose:
Show that COMMIT permanently saves a change made inside a transaction.

*/

-- 1. Check the current value.
SELECT appointment_id, patient_id, doctor_id, status
FROM Appointments
WHERE appointment_id = 5000;

-- 2. Start a transaction and make a change.
BEGIN;

UPDATE Appointments
SET status = 'Confirmed'
WHERE appointment_id = 5000;

-- 3. Check the change inside the transaction.
SELECT appointment_id, status
FROM Appointments
WHERE appointment_id = 5000;

-- 4. Commit the transaction.
COMMIT;

-- 5. Verify that the committed value remains saved.
SELECT appointment_id, status
FROM Appointments
WHERE appointment_id = 5000;