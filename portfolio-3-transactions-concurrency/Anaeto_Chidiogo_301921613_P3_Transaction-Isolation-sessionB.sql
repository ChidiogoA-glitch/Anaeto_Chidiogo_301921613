/*
   SESSION B  —  run in TAB 2
   Double-booking test (READ COMMITTED)
   Start Session A step 1 first.
   Run ONE step at a time. Highlight only that step and run it.
*/

--Step 2
SET application_name = 'appt_session_b';

BEGIN ISOLATION LEVEL READ COMMITTED;

SHOW transaction_isolation;
-- Expected: read committed

-- 2a. Check if the slot is free.
SELECT count(*) AS visible_bookings
FROM Appointments
WHERE doctor_id = 1
  AND appointment_date = TIMESTAMP '2026-12-01 09:00:00'
  AND status <> 'Cancelled';
-- Expected: 0
-- ISOLATION EVIDENCE: Session A's booking is not committed,
-- so the READ COMMITTED hides it. The slot LOOKS free.

-- 2b. Try to book it.
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status)
VALUES (2, 1, TIMESTAMP '2026-12-01 09:00:00', 'Scheduled');
-- Expected: query HANGS (keeps running, no result).

-- LEAVE IT TO WAIT.
-- Go back to SESSION A and run STEP 3.

--STEP 4 

-- The INSERT from STEP 2b should now have failed with:
--   ERROR: duplicate key value violates unique constraint
--          "ux_appointments_doctor_slot"

-- 4a. Clear the failed transaction.
ROLLBACK;

-- 4b. Verify: exactly ONE booking, belonging to patient 1.
SELECT appointment_id, patient_id, doctor_id, appointment_date, status
FROM Appointments
WHERE doctor_id = 1
  AND appointment_date = TIMESTAMP '2026-12-01 09:00:00'
  AND status <> 'Cancelled';
-- Expected: one row, patient_id = 1