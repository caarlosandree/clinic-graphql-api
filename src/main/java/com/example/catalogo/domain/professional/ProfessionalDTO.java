package com.example.catalogo.domain.professional;

import com.example.catalogo.domain.clinic.ClinicDTO;

import java.time.LocalDateTime;
import java.util.UUID;

public record ProfessionalDTO(
    UUID id,
    String name,
    String specialty,
    ClinicDTO clinic,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
    public static ProfessionalDTO fromEntity(Professional professional) {
        return new ProfessionalDTO(
            professional.getId(),
            professional.getName(),
            professional.getSpecialty(),
            ClinicDTO.fromEntity(professional.getClinic()),
            professional.getCreatedAt(),
            professional.getUpdatedAt()
        );
    }
}
