SELECT appointment_id, status AS status_before
FROM Appointments
WHERE appointment_id = 4000;

-- 2. Start a transaction and make a temporary change.
BEGIN;

UPDATE Appointments
SET status = 'Cancelled'
WHERE appointment_id = 4000;

-- 3. The transaction can see its own uncommitted change.
SELECT appointment_id, status AS temporary_status
FROM Appointments
WHERE appointment_id = 4000;

-- 4. Undo the change.
ROLLBACK;

-- 5. Verify that the original value has been restored.
SELECT appointment_id, status AS status_after_rollback
FROM Appointments
WHERE appointment_id = 4000;