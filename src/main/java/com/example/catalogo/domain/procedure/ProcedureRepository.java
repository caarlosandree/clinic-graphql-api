package com.example.catalogo.domain.procedure;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProcedureRepository extends JpaRepository<Procedure, UUID> {
    List<Procedure> findAllByClinicId(UUID clinicId);
}
