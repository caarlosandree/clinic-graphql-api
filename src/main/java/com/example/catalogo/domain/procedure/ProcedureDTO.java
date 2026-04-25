package com.example.catalogo.domain.procedure;

import com.example.catalogo.domain.clinic.ClinicDTO;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record ProcedureDTO(
    UUID id,
    String name,
    String description,
    Integer durationMinutes,
    BigDecimal price,
    ClinicDTO clinic,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
    public static ProcedureDTO fromEntity(Procedure procedure) {
        return new ProcedureDTO(
            procedure.getId(),
            procedure.getName(),
            procedure.getDescription(),
            procedure.getDurationMinutes(),
            procedure.getPrice(),
            ClinicDTO.fromEntity(procedure.getClinic()),
            procedure.getCreatedAt(),
            procedure.getUpdatedAt()
        );
    }
}
