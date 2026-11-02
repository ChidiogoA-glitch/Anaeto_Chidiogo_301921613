-- ---------------------------------------------------------------------
-- 10,000 patients
-- ---------------------------------------------------------------------
INSERT INTO Patients (first_name, last_name, date_of_birth, gender, phone, email)
SELECT
    f.first_name,
    l.last_name,
    DATE '1940-01-01' + (i * 7919 % 30000),                  -- spread of birth dates, 1940-2022
    CASE WHEN i % 2 = 0 THEN 'Female' ELSE 'Male' END,
    '080' || LPAD(i::TEXT, 8, '0'),
    CASE WHEN i % 25 = 0 THEN NULL                           -- some patients have no email
         ELSE LOWER(f.first_name || '.' || l.last_name) || i || '@example.test' END
FROM generate_series(1, 10000) AS i
CROSS JOIN LATERAL (SELECT (ARRAY['Ada','Tunde','Ngozi','Emeka','Halima','Chidi','Aisha','Femi',
        'Zainab','Ifeanyi','Bisi','Musa','Amaka','Segun','Fatima','Obinna','Kemi','Yusuf',
        'Chioma','Dayo'])[1 + i % 20] AS first_name) AS f
CROSS JOIN LATERAL (SELECT (ARRAY['Okafor','Bello','Eze','Obi','Sani','Adeyemi','Ibrahim','Nwosu',
        'Okeke','Balogun','Abubakar','Okonkwo','Lawal','Umeh','Ogunleye','Danjuma','Nnamdi',
        'Afolabi','Garba','Onyeka'])[1 + (i / 20) % 20] AS last_name) AS l;

-- ---------------------------------------------------------------------
-- 10,000 doctors
-- ---------------------------------------------------------------------
INSERT INTO Doctors (doctor_name, specialization, phone, email)
SELECT
    'Dr ' || (ARRAY['Chika','Musa','Funmi','Bola','Kunle','Hauwa','Uche','Tolu','Sade','Ibrahim'])[1 + i % 10]
          || ' ' || (ARRAY['Nwosu','Ibrahim','Adeyemi','James','Okoro','Bello','Eze','Ajayi','Lawal','Obi'])[1 + (i / 10) % 10],
    (ARRAY['General Practice','Cardiology','Internal Medicine','Paediatrics','Dermatology',
           'Neurology','Orthopaedics','Obstetrics and Gynaecology','Psychiatry','Radiology'])[1 + i % 10],
    '081' || LPAD(i::TEXT, 8, '0'),
    'doctor' || i || '@example.test'
FROM generate_series(1, 10000) AS i;

-- ---------------------------------------------------------------------
-- 10,000 appointments (all in 2025, one every 37 minutes)
-- h is a repeatable pseudo-random number from PostgreSQL's built-in
-- hashtext() function; it varies the reason, diagnosis and doctor.
-- ---------------------------------------------------------------------
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, reason, diagnosis, status)
SELECT
    -- every 4th visit goes to a "regular" patient (ids 1-500), so each has several visits
    CASE WHEN i % 4 = 0 THEN 1 + (i / 4 * 7) % 500 ELSE 1 + (i * 7) % 10000 END,
    -- every 3rd visit goes to a "busy" doctor (ids 1-200)
    CASE WHEN i % 3 = 0 THEN 1 + (h / 64) % 200 ELSE 1 + (i * 13) % 10000 END,
    TIMESTAMP '2025-01-01 08:00:00' + i * INTERVAL '37 minutes',
    (ARRAY['Routine consultation','Persistent headache','Chest discomfort','Fever and cough',
           'Blood pressure review','Skin rash','Back pain','Follow-up visit'])[1 + h % 8],
    CASE WHEN h % 11 = 0 THEN NULL                           -- cancelled: no diagnosis
         ELSE (ARRAY['Tension-type headache','Hypertension','Upper respiratory tract infection',
                     'Malaria','Contact dermatitis','Lower back strain','No abnormality found',
                     'Type 2 diabetes review'])[1 + h % 8] || ' (synthetic)' END,
    CASE WHEN h % 11 = 0 THEN 'Cancelled' ELSE 'Completed' END
FROM generate_series(1, 10000) AS i
CROSS JOIN LATERAL (SELECT hashtext('appt' || i) & 2147483647 AS h) AS r;

-- ---------------------------------------------------------------------
-- Prescriptions, one per completed appointment.
-- patient_id and doctor_id are taken from that appointment, so they
-- always match the visit at which the medicine was prescribed.
-- ---------------------------------------------------------------------
INSERT INTO Prescriptions
    (patient_id, doctor_id, appointment_id, medication, dosage, frequency, duration, prescription_date)
SELECT
    a.patient_id,
    a.doctor_id,
    a.appointment_id,
    'Example medicine ' || CHR(65 + h % 26),                 -- A-Z
    (ARRAY['One tablet','Two tablets','5 ml','10 ml','As directed'])[1 + (h / 26) % 5],
    (ARRAY['Once daily','Twice daily','Three times daily','At night'])[1 + (h / 130) % 4],
    (ARRAY['5 days','7 days','14 days','30 days'])[1 + (h / 520) % 4],
    a.appointment_date + INTERVAL '30 minutes'
FROM Appointments a
CROSS JOIN LATERAL (SELECT hashtext('rx' || a.appointment_id) & 2147483647 AS h) AS r
WHERE a.status = 'Completed'
ORDER BY a.appointment_id;

-- Top up to exactly 10,000 by adding a second prescription
-- (a supplement) to the earliest completed visits.
INSERT INTO Prescriptions
    (patient_id, doctor_id, appointment_id, medication, dosage, frequency, duration, prescription_date)
SELECT
    a.patient_id, a.doctor_id, a.appointment_id,
    'Example supplement ' || CHR(65 + a.appointment_id % 26),
    'One tablet', 'Once daily', '30 days',
    a.appointment_date + INTERVAL '30 minutes'
FROM Appointments a
WHERE a.status = 'Completed'
ORDER BY a.appointment_id
LIMIT (10000 - (SELECT COUNT(*) FROM Prescriptions));

-- ---------------------------------------------------------------------
-- Laboratory records, one per completed appointment
-- ---------------------------------------------------------------------
INSERT INTO Laboratory_Records
    (patient_id, doctor_id, appointment_id, test_name, test_result, result_status, test_date)
SELECT
    a.patient_id,
    a.doctor_id,
    a.appointment_id,
    (ARRAY['Full Blood Count','Malaria Test','Lipid Profile','Fasting Blood Sugar',
           'Urinalysis','Liver Function Test','ECG','Chest X-ray'])[1 + h % 8],
    CASE WHEN (h / 8) % 5 = 0 THEN NULL
         ELSE 'Within reference range (synthetic)' END,
    CASE WHEN (h / 8) % 5 = 0 THEN 'Pending' ELSE 'Completed' END,
    a.appointment_date + INTERVAL '1 hour'
FROM Appointments a
CROSS JOIN LATERAL (SELECT hashtext('lab' || a.appointment_id) & 2147483647 AS h) AS r
WHERE a.status = 'Completed'
ORDER BY a.appointment_id;

-- Top up to exactly 10,000 with a follow-up Full Blood Count
-- for the earliest completed visits.
INSERT INTO Laboratory_Records
    (patient_id, doctor_id, appointment_id, test_name, test_result, result_status, test_date)
SELECT
    a.patient_id, a.doctor_id, a.appointment_id,
    'Full Blood Count', 'Within reference range (synthetic)', 'Completed',
    a.appointment_date + INTERVAL '2 hours'
FROM Appointments a
WHERE a.status = 'Completed'
ORDER BY a.appointment_id
LIMIT (10000 - (SELECT COUNT(*) FROM Laboratory_Records));

-- ---------------------------------------------------------------------
-- Refresh planner statistics after the bulk load
-- ---------------------------------------------------------------------
ANALYZE Patients;
ANALYZE Doctors;
ANALYZE Appointments;
ANALYZE Prescriptions;
ANALYZE Laboratory_Records;

-- ---------------------------------------------------------------------
-- Verification: row counts per table
-- ---------------------------------------------------------------------
SELECT 'Patients' AS table_name, COUNT(*) AS row_count FROM Patients
UNION ALL SELECT 'Doctors', COUNT(*) FROM Doctors
UNION ALL SELECT 'Appointments', COUNT(*) FROM Appointments
UNION ALL SELECT 'Prescriptions', COUNT(*) FROM Prescriptions
UNION ALL SELECT 'Laboratory_Records', COUNT(*) FROM Laboratory_Records;