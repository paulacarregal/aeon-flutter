package com.aeon.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "professional_profiles")
public class ProfessionalProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String ownerUid;

    private String type;

    private String displayName;

    private String category;

    private String document;

    @Column(length = 2000)
    private String description;

    private String phone;

    private String website;

    private String instagram;

    private String city;

    private String address;

    private String status;

    private boolean active = true;

    public ProfessionalProfile() {
    }

    public ProfessionalProfile(
            String ownerUid,
            String type,
            String displayName,
            String category,
            String document,
            String description,
            String phone,
            String website,
            String instagram,
            String city,
            String address,
            String status
    ) {
        this.ownerUid = ownerUid;
        this.type = type;
        this.displayName = displayName;
        this.category = category;
        this.document = document;
        this.description = description;
        this.phone = phone;
        this.website = website;
        this.instagram = instagram;
        this.city = city;
        this.address = address;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public String getOwnerUid() {
        return ownerUid;
    }

    public void setOwnerUid(String ownerUid) {
        this.ownerUid = ownerUid;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDocument() {
        return document;
    }

    public void setDocument(String document) {
        this.document = document;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public String getInstagram() {
        return instagram;
    }

    public void setInstagram(String instagram) {
        this.instagram = instagram;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}