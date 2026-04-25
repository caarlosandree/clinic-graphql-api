package com.example.catalogo.domain.appointment;

import com.example.catalogo.domain.clinic.ClinicDTO;
import com.example.catalogo.domain.procedure.ProcedureDTO;
import com.example.catalogo.domain.professional.ProfessionalDTO;

import java.time.LocalDateTime;
import java.util.UUID;

public record AppointmentDTO(
    UUID id,
    String patientName,
    String patientPhone,
    LocalDateTime scheduledAt,
    AppointmentStatus status,
    ClinicDTO clinic,
    ProcedureDTO procedure,
    ProfessionalDTO professional,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
    public static AppointmentDTO fromEntity(Appointment appointment) {
        return new AppointmentDTO(
            appointment.getId(),
            appointment.getPatientName(),
            appointment.getPatientPhone(),
            appointment.getScheduledAt(),
            appointment.getStatus(),
            ClinicDTO.fromEntity(appointment.getClinic()),
            ProcedureDTO.fromEntity(appointment.getProcedure()),
            ProfessionalDTO.fromEntity(appointment.getProfessional()),
            appointment.getCreatedAt(),
            appointment.getUpdatedAt()
        );
    }
}
