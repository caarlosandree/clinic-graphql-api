CREATE TABLE procedures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description VARCHAR(1000),
    duration_minutes INTEGER NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    clinic_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_procedures_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
);

CREATE INDEX idx_procedures_clinic_id ON procedures(clinic_id);
