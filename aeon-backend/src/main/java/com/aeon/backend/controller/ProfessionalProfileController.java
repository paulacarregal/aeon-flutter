package com.aeon.backend.controller;

import com.aeon.backend.dto.ProfessionalProfileRequest;
import com.aeon.backend.dto.ProfessionalProfileResponse;
import com.aeon.backend.service.ProfessionalProfileService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/professional-profiles")
public class ProfessionalProfileController {

    private final ProfessionalProfileService service;

    public ProfessionalProfileController(
            ProfessionalProfileService service
    ) {
        this.service = service;
    }

    @GetMapping
    public List<ProfessionalProfileResponse> findAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ProfessionalProfileResponse findById(
            @PathVariable String id
    ) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProfessionalProfileResponse create(
            @Valid @RequestBody ProfessionalProfileRequest request
    ) {
        return service.create(request);
    }

    @PutMapping("/{id}")
    public ProfessionalProfileResponse update(
            @PathVariable String id,
            @Valid @RequestBody ProfessionalProfileRequest request
    ) {
        return service.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @PathVariable String id
    ) {
        service.delete(id);
    }
}