package com.example.catalogo.graphql.mutation;

import com.example.catalogo.domain.appointment.AppointmentDTO;
import com.example.catalogo.domain.appointment.AppointmentService;
import com.example.catalogo.domain.clinic.ClinicDTO;
import com.example.catalogo.domain.clinic.ClinicService;
import com.example.catalogo.domain.procedure.ProcedureDTO;
import com.example.catalogo.domain.procedure.ProcedureService;
import com.example.catalogo.domain.professional.ProfessionalDTO;
import com.example.catalogo.domain.professional.ProfessionalService;
import com.example.catalogo.graphql.input.CreateAppointmentInput;
import com.example.catalogo.graphql.input.CreateClinicInput;
import com.example.catalogo.graphql.input.CreateProcedureInput;
import com.example.catalogo.graphql.input.CreateProfessionalInput;
import jakarta.validation.Valid;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.stereotype.Controller;

import java.util.UUID;

@Controller
public class MutationResolver {

    private final ClinicService clinicService;
    private final ProcedureService procedureService;
    private final ProfessionalService professionalService;
    private final AppointmentService appointmentService;

    public MutationResolver(
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

    @MutationMapping
    public ClinicDTO createClinic(@Argument @Valid CreateClinicInput input) {
        return clinicService.create(input);
    }

    @MutationMapping
    public ProcedureDTO createProcedure(@Argument @Valid CreateProcedureInput input) {
        return procedureService.create(input);
    }

    @MutationMapping
    public ProfessionalDTO createProfessional(@Argument @Valid CreateProfessionalInput input) {
        return professionalService.create(input);
    }

    @MutationMapping
    public AppointmentDTO createAppointment(@Argument @Valid CreateAppointmentInput input) {
        return appointmentService.create(input);
    }

    @MutationMapping
    public AppointmentDTO cancelAppointment(@Argument UUID id) {
        return appointmentService.cancel(id);
    }

    @MutationMapping
    public AppointmentDTO finishAppointment(@Argument UUID id) {
        return appointmentService.finish(id);
    }
}
