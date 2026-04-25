package com.example.catalogo.domain.clinic;

import com.example.catalogo.exception.DuplicateResourceException;
import com.example.catalogo.exception.ResourceNotFoundException;
import com.example.catalogo.graphql.input.CreateClinicInput;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ClinicService {

    private final ClinicRepository clinicRepository;

    public ClinicService(ClinicRepository clinicRepository) {
        this.clinicRepository = clinicRepository;
    }

    public List<ClinicDTO> findAll() {
        return clinicRepository.findAll().stream()
            .map(ClinicDTO::fromEntity)
            .toList();
    }

    public ClinicDTO findById(UUID id) {
        return clinicRepository.findById(id)
            .map(ClinicDTO::fromEntity)
            .orElseThrow(() -> new ResourceNotFoundException("Clínica não encontrada: " + id));
    }

    @Transactional
    public ClinicDTO create(CreateClinicInput input) {
        if (clinicRepository.existsByCnpj(input.cnpj())) {
            throw new DuplicateResourceException("CNPJ já cadastrado: " + input.cnpj());
        }

        Clinic clinic = Clinic.builder()
            .name(input.name())
            .cnpj(input.cnpj())
            .phone(input.phone())
            .address(input.address())
            .build();

        return ClinicDTO.fromEntity(clinicRepository.save(clinic));
    }
}
