package com.example.catalogo.domain.professional;

import com.example.catalogo.domain.clinic.Clinic;
import com.example.catalogo.domain.clinic.ClinicRepository;
import com.example.catalogo.exception.ResourceNotFoundException;
import com.example.catalogo.graphql.input.CreateProfessionalInput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ProfessionalService {

    private static final Logger log = LoggerFactory.getLogger(ProfessionalService.class);

    private final ProfessionalRepository professionalRepository;
    private final ClinicRepository clinicRepository;

    public ProfessionalService(ProfessionalRepository professionalRepository, ClinicRepository clinicRepository) {
        this.professionalRepository = professionalRepository;
        this.clinicRepository = clinicRepository;
    }

    public List<ProfessionalDTO> findByClinicId(UUID clinicId) {
        return professionalRepository.findAllByClinicId(clinicId).stream()
            .map(ProfessionalDTO::fromEntity)
            .toList();
    }

    public ProfessionalDTO findById(UUID id) {
        log.debug("Buscando profissional | professionalId={}", id);
        return professionalRepository.findById(id)
            .map(ProfessionalDTO::fromEntity)
            .orElseThrow(() -> new ResourceNotFoundException("Profissional não encontrado: " + id));
    }

    @Transactional
    public ProfessionalDTO create(CreateProfessionalInput input) {
        Clinic clinic = clinicRepository.findById(input.clinicId())
            .orElseThrow(() -> new ResourceNotFoundException("Clínica não encontrada: " + input.clinicId()));

        log.info("Criando profissional | clinicId={} | name={} | specialty={}",
            clinic.getId(), input.name(), input.specialty());

        Professional professional = Professional.builder()
            .name(input.name())
            .specialty(input.specialty())
            .clinic(clinic)
            .build();

        Professional saved = professionalRepository.save(professional);
        log.info("Profissional criado | professionalId={} | clinicId={} | name={} | specialty={}",
            saved.getId(), clinic.getId(), saved.getName(), saved.getSpecialty());
        return ProfessionalDTO.fromEntity(saved);
    }
}
