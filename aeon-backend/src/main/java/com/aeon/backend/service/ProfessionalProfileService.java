package com.aeon.backend.service;

import com.aeon.backend.dto.ProfessionalProfileRequest;
import com.aeon.backend.dto.ProfessionalProfileResponse;
import com.aeon.backend.exception.ResourceNotFoundException;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ProfessionalProfileService {

    private static final String COLLECTION = "professionalProfiles";

    public List<ProfessionalProfileResponse> findAll() {

        try {
            Firestore db = FirestoreClient.getFirestore();

            ApiFuture<QuerySnapshot> future =
                    db.collection(COLLECTION).get();

            List<QueryDocumentSnapshot> documents =
                    future.get().getDocuments();

            List<ProfessionalProfileResponse> profiles =
                    new ArrayList<>();

            for (QueryDocumentSnapshot document : documents) {
                profiles.add(toResponse(document));
            }

            return profiles;

        } catch (Exception e) {
            throw new RuntimeException(
                    "Erro ao consultar perfis profissionais no Firebase.",
                    e
            );
        }
    }

    public ProfessionalProfileResponse findById(String id) {

        try {
            Firestore db = FirestoreClient.getFirestore();

            DocumentReference reference =
                    db.collection(COLLECTION).document(id);

            DocumentSnapshot document =
                    reference.get().get();

            if (!document.exists()) {
                throw new ResourceNotFoundException(
                        "Perfil profissional não encontrado."
                );
            }

            return toResponse(document);

        } catch (ResourceNotFoundException e) {
            throw e;

        } catch (Exception e) {
            throw new RuntimeException(
                    "Erro ao consultar perfil profissional.",
                    e
            );
        }
    }

    public ProfessionalProfileResponse create(
            ProfessionalProfileRequest request
    ) {

        try {
            Firestore db = FirestoreClient.getFirestore();

            Map<String, Object> data =
                    buildData(request);

            DocumentReference reference =
                    db.collection(COLLECTION).document();

            reference.set(data).get();

            DocumentSnapshot document =
                    reference.get().get();

            return toResponse(document);

        } catch (Exception e) {
            throw new RuntimeException(
                    "Erro ao criar perfil profissional no Firebase.",
                    e
            );
        }
    }

    public ProfessionalProfileResponse update(
            String id,
            ProfessionalProfileRequest request
    ) {

        try {
            Firestore db = FirestoreClient.getFirestore();

            DocumentReference reference =
                    db.collection(COLLECTION).document(id);

            DocumentSnapshot existing =
                    reference.get().get();

            if (!existing.exists()) {
                throw new ResourceNotFoundException(
                        "Perfil profissional não encontrado."
                );
            }

            Map<String, Object> data =
                    buildData(request);

            reference.set(data).get();

            DocumentSnapshot updated =
                    reference.get().get();

            return toResponse(updated);

        } catch (ResourceNotFoundException e) {
            throw e;

        } catch (Exception e) {
            throw new RuntimeException(
                    "Erro ao atualizar perfil profissional.",
                    e
            );
        }
    }

    public void delete(String id) {

        try {
            Firestore db = FirestoreClient.getFirestore();

            DocumentReference reference =
                    db.collection(COLLECTION).document(id);

            DocumentSnapshot existing =
                    reference.get().get();

            if (!existing.exists()) {
                throw new ResourceNotFoundException(
                        "Perfil profissional não encontrado."
                );
            }

            reference.delete().get();

        } catch (ResourceNotFoundException e) {
            throw e;

        } catch (Exception e) {
            throw new RuntimeException(
                    "Erro ao excluir perfil profissional.",
                    e
            );
        }
    }

    private Map<String, Object> buildData(
            ProfessionalProfileRequest request
    ) {

        Map<String, Object> data =
                new HashMap<>();

        data.put("ownerUid", request.ownerUid());
        data.put("type", request.type());
        data.put("displayName", request.displayName());
        data.put("category", request.category());
        data.put("document", request.document());
        data.put("description", request.description());
        data.put("phone", request.phone());
        data.put("website", request.website());
        data.put("instagram", request.instagram());
        data.put("city", request.city());
        data.put("address", request.address());
        data.put("status", request.status());

        return data;
    }

    private ProfessionalProfileResponse toResponse(
            DocumentSnapshot document
    ) {

        return new ProfessionalProfileResponse(
                document.getId(),
                getString(document, "ownerUid"),
                getString(document, "type"),
                getString(document, "displayName"),
                getString(document, "category"),
                getString(document, "document"),
                getString(document, "description"),
                getString(document, "phone"),
                getString(document, "website"),
                getString(document, "instagram"),
                getString(document, "city"),
                getString(document, "address"),
                getString(document, "status"),
                getBoolean(document, "active")
        );
    }

    private String getString(
            DocumentSnapshot document,
            String field
    ) {

        String value = document.getString(field);

        return value != null ? value : "";
    }

    private boolean getBoolean(
            DocumentSnapshot document,
            String field
    ) {

        Boolean value =
                document.getBoolean(field);

        return value != null && value;
    }
}