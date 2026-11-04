/* ============================================================
   ORDER OF STEPS ACROSS BOTH FILES:
     STEP 0  -> Session A  (setup, once)
     STEP 1  -> Session A  (book the slot, DO NOT commit)
     STEP 2  -> Session B  (check slot + try to book -> hangs)
     STEP 3  -> Session A  (prove B is waiting, then COMMIT)
     STEP 4  -> Session B  (see the error, rollback, verify)

   Run ONE step at a time. Highlight only that step and run it.
   ============================================================ */
-- 0a. Check column names.
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'appointments'
ORDER BY ordinal_position;

-- 0b one active appointment per doctor per time slot.
CREATE UNIQUE INDEX IF NOT EXISTS ux_appointments_doctor_slot
ON Appointments (doctor_id, appointment_date)
WHERE status <> 'Cancelled';

-- 0c. Confirm the test slot is free. Expected: 0
SELECT count(*) AS existing_bookings
FROM Appointments
WHERE doctor_id = 1
  AND appointment_date = TIMESTAMP '2026-12-01 09:00:00'
  AND status <> 'Cancelled';

--Continue with STEP 1 below (still Session A).

-- Step 1
SET application_name = 'appt_session_a';

BEGIN ISOLATION LEVEL READ COMMITTED;

SHOW transaction_isolation;
-- Expected: read committed

INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status)
VALUES (1, 1, TIMESTAMP '2026-12-01 09:00:00', 'Scheduled');
-- Expected: INSERT 0 1

-- Go to SESSION B and run STEP 2.


-- 3a. Prove Session B is blocked.
SELECT application_name, state, wait_event_type, wait_event
FROM pg_stat_activity
WHERE application_name = 'appt_session_b';
-- Expected: appt_session_b | active | Lock | transactionid
-- 📸 Take a screenshot here.

-- 3b. Commit Patient 1's booking.
COMMIT;

-- Go to SESSION B and run STEP 4.

