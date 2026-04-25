package com.example.catalogo.graphql.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateClinicInput(
    @NotBlank @Size(max = 200) String name,
    @NotBlank @Size(max = 14) String cnpj,
    @Size(max = 20) String phone,
    @Size(max = 500) String address
) {}
