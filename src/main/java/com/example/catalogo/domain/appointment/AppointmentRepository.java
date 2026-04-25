package com.example.catalogo.domain.appointment;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, UUID> {
    List<Appointment> findAllByClinicId(UUID clinicId);
    List<Appointment> findAllByStatus(AppointmentStatus status);
}
