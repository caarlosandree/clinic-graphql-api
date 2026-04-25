CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_name VARCHAR(200) NOT NULL,
    patient_phone VARCHAR(20),
    scheduled_at TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    clinic_id UUID NOT NULL,
    procedure_id UUID NOT NULL,
    professional_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointments_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
    CONSTRAINT fk_appointments_procedure FOREIGN KEY (procedure_id) REFERENCES procedures(id),
    CONSTRAINT fk_appointments_professional FOREIGN KEY (professional_id) REFERENCES professionals(id)
);

CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_clinic_id ON appointments(clinic_id);
CREATE INDEX idx_appointments_scheduled_at ON appointments(scheduled_at);
