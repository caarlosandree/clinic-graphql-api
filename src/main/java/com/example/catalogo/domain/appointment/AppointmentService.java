package com.example.catalogo.domain.appointment;

import com.example.catalogo.domain.clinic.Clinic;
import com.example.catalogo.domain.clinic.ClinicRepository;
import com.example.catalogo.domain.procedure.Procedure;
import com.example.catalogo.domain.procedure.ProcedureRepository;
import com.example.catalogo.domain.professional.Professional;
import com.example.catalogo.domain.professional.ProfessionalRepository;
import com.example.catalogo.exception.BusinessException;
import com.example.catalogo.exception.ResourceNotFoundException;
import com.example.catalogo.graphql.input.CreateAppointmentInput;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final ClinicRepository clinicRepository;
    private final ProcedureRepository procedureRepository;
    private final ProfessionalRepository professionalRepository;

    public AppointmentService(
        AppointmentRepository appointmentRepository,
        ClinicRepository clinicRepository,
        ProcedureRepository procedureRepository,
        ProfessionalRepository professionalRepository
    ) {
        this.appointmentRepository = appointmentRepository;
        this.clinicRepository = clinicRepository;
        this.procedureRepository = procedureRepository;
        this.professionalRepository = professionalRepository;
    }

    public List<AppointmentDTO> findByClinicId(UUID clinicId) {
        return appointmentRepository.findAllByClinicId(clinicId).stream()
            .map(AppointmentDTO::fromEntity)
            .toList();
    }

    public List<AppointmentDTO> findByStatus(AppointmentStatus status) {
        return appointmentRepository.findAllByStatus(status).stream()
            .map(AppointmentDTO::fromEntity)
            .toList();
    }

    public AppointmentDTO findById(UUID id) {
        return appointmentRepository.findById(id)
            .map(AppointmentDTO::fromEntity)
            .orElseThrow(() -> new ResourceNotFoundException("Agendamento não encontrado: " + id));
    }

    @Transactional
    public AppointmentDTO create(CreateAppointmentInput input) {
        Clinic clinic = clinicRepository.findById(input.clinicId())
            .orElseThrow(() -> new ResourceNotFoundException("Clínica não encontrada: " + input.clinicId()));

        Procedure procedure = procedureRepository.findById(input.procedureId())
            .orElseThrow(() -> new ResourceNotFoundException("Procedimento não encontrado: " + input.procedureId()));

        Professional professional = professionalRepository.findById(input.professionalId())
            .orElseThrow(() -> new ResourceNotFoundException("Profissional não encontrado: " + input.professionalId()));

        validateSameClinic(clinic, procedure, professional);
        validateFutureSchedule(input.scheduledAt());

        Appointment appointment = Appointment.builder()
            .patientName(input.patientName())
            .patientPhone(input.patientPhone())
            .scheduledAt(input.scheduledAt())
            .status(AppointmentStatus.SCHEDULED)
            .clinic(clinic)
            .procedure(procedure)
            .professional(professional)
            .build();

        return AppointmentDTO.fromEntity(appointmentRepository.save(appointment));
    }

    @Transactional
    public AppointmentDTO cancel(UUID id) {
        Appointment appointment = appointmentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Agendamento não encontrado: " + id));

        if (appointment.getStatus() == AppointmentStatus.FINISHED) {
            throw new BusinessException("Não é possível cancelar um agendamento já finalizado");
        }

        if (appointment.getStatus() == AppointmentStatus.CANCELLED) {
            throw new BusinessException("Agendamento já está cancelado");
        }

        appointment.setStatus(AppointmentStatus.CANCELLED);
        return AppointmentDTO.fromEntity(appointmentRepository.save(appointment));
    }

    @Transactional
    public AppointmentDTO finish(UUID id) {
        Appointment appointment = appointmentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Agendamento não encontrado: " + id));

        if (appointment.getStatus() == AppointmentStatus.CANCELLED) {
            throw new BusinessException("Não é possível finalizar um agendamento cancelado");
        }

        if (appointment.getStatus() == AppointmentStatus.FINISHED) {
            throw new BusinessException("Agendamento já está finalizado");
        }

        appointment.setStatus(AppointmentStatus.FINISHED);
        return AppointmentDTO.fromEntity(appointmentRepository.save(appointment));
    }

    private void validateSameClinic(Clinic clinic, Procedure procedure, Professional professional) {
        if (!procedure.getClinic().getId().equals(clinic.getId())) {
            throw new BusinessException("O procedimento não pertence à clínica informada");
        }
        if (!professional.getClinic().getId().equals(clinic.getId())) {
            throw new BusinessException("O profissional não pertence à clínica informada");
        }
    }

    private void validateFutureSchedule(LocalDateTime scheduledAt) {
        if (scheduledAt.isBefore(LocalDateTime.now())) {
            throw new BusinessException("Não é permitido agendar no passado");
        }
    }
}
