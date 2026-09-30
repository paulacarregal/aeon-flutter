package com.aeon.backend.repository;

import com.aeon.backend.model.ProfessionalProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProfessionalProfileRepository
        extends JpaRepository<ProfessionalProfile, Long> {
}