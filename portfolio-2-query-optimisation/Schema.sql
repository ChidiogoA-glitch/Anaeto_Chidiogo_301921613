-- create DB
CREATE DATABASE miva_hospital;

-- create Tables 
CREATE TABLE Patients (
    patient_id INT GENERATED ALWAYS AS IDENTITY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    date_of_birth DATE NULL,
    gender VARCHAR(20) NULL,
    phone VARCHAR(25) NULL,
    email VARCHAR(120) NULL,
    CONSTRAINT PK_Patients PRIMARY KEY (patient_id),
    CONSTRAINT UQ_Patients_Email UNIQUE (email)
);

CREATE TABLE Doctors (
    doctor_id INT GENERATED ALWAYS AS IDENTITY,
    doctor_name VARCHAR(120) NOT NULL,
    specialization VARCHAR(100) NULL,
    phone VARCHAR(25) NULL,
    email VARCHAR(120) NULL,
    CONSTRAINT PK_Doctors PRIMARY KEY (doctor_id),
    CONSTRAINT UQ_Doctors_Email UNIQUE (email)
);

CREATE TABLE Appointments (
    appointment_id INT GENERATED ALWAYS AS IDENTITY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date TIMESTAMP(0) NOT NULL,
    reason VARCHAR(255) NULL,
    diagnosis TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT PK_Appointments PRIMARY KEY (appointment_id),
    CONSTRAINT FK_Appointments_Patients FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id),
    CONSTRAINT FK_Appointments_Doctors FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id),
    CONSTRAINT CK_Appointments_Status
        CHECK (status IN ('Scheduled', 'Completed', 'Cancelled'))
);

CREATE TABLE Prescriptions (
    prescription_id INT GENERATED ALWAYS AS IDENTITY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT NULL,
    medication VARCHAR(150) NOT NULL,
    dosage VARCHAR(100) NULL,
    frequency VARCHAR(100) NULL,
    duration VARCHAR(60) NULL,
    prescription_date TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Prescriptions PRIMARY KEY (prescription_id),
    CONSTRAINT FK_Prescriptions_Patients FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id),
    CONSTRAINT FK_Prescriptions_Doctors FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id),
    CONSTRAINT FK_Prescriptions_Appointments FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id)
);

CREATE TABLE Laboratory_Records (
    lab_id INT GENERATED ALWAYS AS IDENTITY,
    patient_id INT NOT NULL,
    doctor_id INT NULL,
    appointment_id INT NULL,
    test_name VARCHAR(150) NOT NULL,
    test_result TEXT NULL,
    result_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    test_date TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Laboratory_Records PRIMARY KEY (lab_id),
    CONSTRAINT FK_LabRecords_Patients FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id),
    CONSTRAINT FK_LabRecords_Doctors FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id),
    CONSTRAINT FK_LabRecords_Appointments FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id)
);
