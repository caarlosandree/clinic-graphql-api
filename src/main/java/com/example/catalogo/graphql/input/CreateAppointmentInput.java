package com.example.catalogo.graphql.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.UUID;

public record CreateAppointmentInput(
    @NotNull UUID clinicId,
    @NotNull UUID procedureId,
    @NotNull UUID professionalId,
    @NotBlank @Size(max = 200) String patientName,
    @Size(max = 20) String patientPhone,
    @NotNull LocalDateTime scheduledAt
) {}
