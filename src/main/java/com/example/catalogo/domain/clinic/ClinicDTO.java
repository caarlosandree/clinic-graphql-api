package com.example.catalogo.domain.clinic;

import java.time.LocalDateTime;
import java.util.UUID;

public record ClinicDTO(
    UUID id,
    String name,
    String cnpj,
    String phone,
    String address,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
    public static ClinicDTO fromEntity(Clinic clinic) {
        return new ClinicDTO(
            clinic.getId(),
            clinic.getName(),
            clinic.getCnpj(),
            clinic.getPhone(),
            clinic.getAddress(),
            clinic.getCreatedAt(),
            clinic.getUpdatedAt()
        );
    }
}
