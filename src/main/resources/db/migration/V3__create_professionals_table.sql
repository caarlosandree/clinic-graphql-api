CREATE TABLE professionals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    specialty VARCHAR(200) NOT NULL,
    clinic_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_professionals_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
);

CREATE INDEX idx_professionals_clinic_id ON professionals(clinic_id);
