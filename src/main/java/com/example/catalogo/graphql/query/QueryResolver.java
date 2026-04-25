package com.example.catalogo.graphql.query;

import com.example.catalogo.domain.appointment.AppointmentDTO;
import com.example.catalogo.domain.appointment.AppointmentService;
import com.example.catalogo.domain.appointment.AppointmentStatus;
import com.example.catalogo.domain.clinic.ClinicDTO;
import com.example.catalogo.domain.clinic.ClinicService;
import com.example.catalogo.domain.procedure.ProcedureDTO;
import com.example.catalogo.domain.procedure.ProcedureService;
import com.example.catalogo.domain.professional.ProfessionalDTO;
import com.example.catalogo.domain.professional.ProfessionalService;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.UUID;

@Controller
public class QueryResolver {

    private final ClinicService clinicService;
    private final ProcedureService procedureService;
    private final ProfessionalService professionalService;
    private final AppointmentService appointmentService;

    public QueryResolver(
        ClinicService clinicService,
        ProcedureService procedureService,
        ProfessionalService professionalService,
        AppointmentService appointmentService
    ) {
        this.clinicService = clinicService;
        this.procedureService = procedureService;
        this.professionalService = professionalService;
        this.appointmentService = appointmentService;
    }

    @QueryMapping
    public List<ClinicDTO> clinics() {
        return clinicService.findAll();
    }

    @QueryMapping
    public ClinicDTO clinicById(@Argument UUID id) {
        return clinicService.findById(id);
    }

    @QueryMapping
    public List<ProcedureDTO> proceduresByClinic(@Argument UUID clinicId) {
        return procedureService.findByClinicId(clinicId);
    }

    @QueryMapping
    public List<ProfessionalDTO> professionalsByClinic(@Argument UUID clinicId) {
        return professionalService.findByClinicId(clinicId);
    }

    @QueryMapping
    public List<AppointmentDTO> appointmentsByClinic(@Argument UUID clinicId) {
        return appointmentService.findByClinicId(clinicId);
    }

    @QueryMapping
    public List<AppointmentDTO> appointmentsByStatus(@Argument AppointmentStatus status) {
        return appointmentService.findByStatus(status);
    }
}
