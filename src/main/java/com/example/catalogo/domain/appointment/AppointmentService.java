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
import com.example.catalogo.shared.logging.SensitiveDataMasker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class AppointmentService {

    private static final Logger log = LoggerFactory.getLogger(AppointmentService.class);

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
        log.debug("Buscando agendamento | appointmentId={}", id);
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

        log.info("Criando agendamento | clinicId={} | procedureId={} | professionalId={} | scheduledAt={} | patientName=[REDACTED] | patientPhone={}",
            clinic.getId(), procedure.getId(), professional.getId(), input.scheduledAt(),
            SensitiveDataMasker.maskPhone(input.patientPhone()));

        Appointment appointment = Appointment.builder()
            .patientName(input.patientName())
            .patientPhone(input.patientPhone())
            .scheduledAt(input.scheduledAt())
            .status(AppointmentStatus.SCHEDULED)
            .clinic(clinic)
            .procedure(procedure)
            .professional(professional)
            .build();

        Appointment saved = appointmentRepository.save(appointment);
        log.info("Agendamento criado | appointmentId={} | clinicId={} | scheduledAt={} | status={}",
            saved.getId(), clinic.getId(), saved.getScheduledAt(), saved.getStatus());
        return AppointmentDTO.fromEntity(saved);
    }

    @Transactional
    public AppointmentDTO cancel(UUID id) {
        Appointment appointment = appointmentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Agendamento não encontrado: " + id));

        if (appointment.getStatus() == AppointmentStatus.FINISHED) {
            log.warn("Tentativa de cancelar agendamento finalizado | appointmentId={} | currentStatus={}",
                id, appointment.getStatus());
            throw new BusinessException("Não é possível cancelar um agendamento já finalizado");
        }

        if (appointment.getStatus() == AppointmentStatus.CANCELLED) {
            log.warn("Tentativa de cancelar agendamento já cancelado | appointmentId={} | currentStatus={}",
                id, appointment.getStatus());
            throw new BusinessException("Agendamento já está cancelado");
        }

        log.info("Cancelando agendamento | appointmentId={} | clinicId={} | scheduledAt={}",
            appointment.getId(), appointment.getClinic().getId(), appointment.getScheduledAt());

        appointment.setStatus(AppointmentStatus.CANCELLED);
        Appointment saved = appointmentRepository.save(appointment);
        log.info("Agendamento cancelado | appointmentId={} | status={}", saved.getId(), saved.getStatus());
        return AppointmentDTO.fromEntity(saved);
    }

    @Transactional
    public AppointmentDTO finish(UUID id) {
        Appointment appointment = appointmentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Agendamento não encontrado: " + id));

        if (appointment.getStatus() == AppointmentStatus.CANCELLED) {
            log.warn("Tentativa de finalizar agendamento cancelado | appointmentId={} | currentStatus={}",
                id, appointment.getStatus());
            throw new BusinessException("Não é possível finalizar um agendamento cancelado");
        }

        if (appointment.getStatus() == AppointmentStatus.FINISHED) {
            log.warn("Tentativa de finalizar agendamento já finalizado | appointmentId={} | currentStatus={}",
                id, appointment.getStatus());
            throw new BusinessException("Agendamento já está finalizado");
        }

        log.info("Finalizando agendamento | appointmentId={} | clinicId={} | scheduledAt={}",
            appointment.getId(), appointment.getClinic().getId(), appointment.getScheduledAt());

        appointment.setStatus(AppointmentStatus.FINISHED);
        Appointment saved = appointmentRepository.save(appointment);
        log.info("Agendamento finalizado | appointmentId={} | status={}", saved.getId(), saved.getStatus());
        return AppointmentDTO.fromEntity(saved);
    }

    private void validateSameClinic(Clinic clinic, Procedure procedure, Professional professional) {
        if (!procedure.getClinic().getId().equals(clinic.getId())) {
            log.warn("Validação de agendamento falhou | reason=procedure_clinic_mismatch | clinicId={} | procedureId={}",
                clinic.getId(), procedure.getId());
            throw new BusinessException("O procedimento não pertence à clínica informada");
        }
        if (!professional.getClinic().getId().equals(clinic.getId())) {
            log.warn("Validação de agendamento falhou | reason=professional_clinic_mismatch | clinicId={} | professionalId={}",
                clinic.getId(), professional.getId());
            throw new BusinessException("O profissional não pertence à clínica informada");
        }
    }

    private void validateFutureSchedule(LocalDateTime scheduledAt) {
        if (scheduledAt.isBefore(LocalDateTime.now())) {
            log.warn("Validação de agendamento falhou | reason=past_schedule | scheduledAt={}", scheduledAt);
            throw new BusinessException("Não é permitido agendar no passado");
        }
    }
}
