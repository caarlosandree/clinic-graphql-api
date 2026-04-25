package com.example.catalogo.domain.procedure;

import com.example.catalogo.domain.clinic.Clinic;
import com.example.catalogo.domain.clinic.ClinicRepository;
import com.example.catalogo.exception.BusinessException;
import com.example.catalogo.exception.ResourceNotFoundException;
import com.example.catalogo.graphql.input.CreateProcedureInput;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ProcedureService {

    private final ProcedureRepository procedureRepository;
    private final ClinicRepository clinicRepository;

    public ProcedureService(ProcedureRepository procedureRepository, ClinicRepository clinicRepository) {
        this.procedureRepository = procedureRepository;
        this.clinicRepository = clinicRepository;
    }

    public List<ProcedureDTO> findByClinicId(UUID clinicId) {
        return procedureRepository.findAllByClinicId(clinicId).stream()
            .map(ProcedureDTO::fromEntity)
            .toList();
    }

    public ProcedureDTO findById(UUID id) {
        return procedureRepository.findById(id)
            .map(ProcedureDTO::fromEntity)
            .orElseThrow(() -> new ResourceNotFoundException("Procedimento não encontrado: " + id));
    }

    @Transactional
    public ProcedureDTO create(CreateProcedureInput input) {
        Clinic clinic = clinicRepository.findById(input.clinicId())
            .orElseThrow(() -> new ResourceNotFoundException("Clínica não encontrada: " + input.clinicId()));

        if (input.durationMinutes() <= 0) {
            throw new BusinessException("A duração deve ser maior que 0 minutos");
        }

        if (input.price().compareTo(java.math.BigDecimal.ZERO) < 0) {
            throw new BusinessException("O preço não pode ser negativo");
        }

        Procedure procedure = Procedure.builder()
            .name(input.name())
            .description(input.description())
            .durationMinutes(input.durationMinutes())
            .price(input.price())
            .clinic(clinic)
            .build();

        return ProcedureDTO.fromEntity(procedureRepository.save(procedure));
    }
}
