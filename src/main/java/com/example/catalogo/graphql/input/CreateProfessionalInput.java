package com.example.catalogo.graphql.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record CreateProfessionalInput(
    @NotNull UUID clinicId,
    @NotBlank @Size(max = 200) String name,
    @NotBlank @Size(max = 200) String specialty
) {}
