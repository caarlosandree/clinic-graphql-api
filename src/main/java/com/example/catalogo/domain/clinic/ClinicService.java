package com.example.catalogo.domain.clinic;

import com.example.catalogo.exception.DuplicateResourceException;
import com.example.catalogo.exception.ResourceNotFoundException;
import com.example.catalogo.graphql.input.CreateClinicInput;
import com.example.catalogo.shared.logging.SensitiveDataMasker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ClinicService {

    private static final Logger log = LoggerFactory.getLogger(ClinicService.class);

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
        log.debug("Buscando clínica | clinicId={}", id);
        return clinicRepository.findById(id)
            .map(ClinicDTO::fromEntity)
            .orElseThrow(() -> new ResourceNotFoundException("Clínica não encontrada: " + id));
    }

    @Transactional
    public ClinicDTO create(CreateClinicInput input) {
        if (clinicRepository.existsByCnpj(input.cnpj())) {
            log.warn("Tentativa de cadastro com CNPJ duplicado | cnpj={}",
                SensitiveDataMasker.maskCnpj(input.cnpj()));
            throw new DuplicateResourceException("CNPJ já cadastrado: " + input.cnpj());
        }

        log.info("Criando clínica | name={} | cnpj={}",
            input.name(), SensitiveDataMasker.maskCnpj(input.cnpj()));

        Clinic clinic = Clinic.builder()
            .name(input.name())
            .cnpj(input.cnpj())
            .phone(input.phone())
            .address(input.address())
            .build();

        Clinic saved = clinicRepository.save(clinic);
        log.info("Clínica criada | clinicId={} | name={}", saved.getId(), saved.getName());
        return ClinicDTO.fromEntity(saved);
    }
}
