package com.taker.auth.entity;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

/**
 * Converts Role enum for JPA. Accepts both "TEAM_LEADER" and "TEAM LEADER" from DB to avoid 500 when column has a space.
 */
@Converter(autoApply = true)
public class RoleConverter implements AttributeConverter<Role, String> {

    @Override
    public String convertToDatabaseColumn(Role role) {
        if (role == null) return null;
        return role.name();
    }

    @Override
    public Role convertToEntityAttribute(String dbValue) {
        if (dbValue == null || dbValue.isBlank()) return Role.MEMBER;
        String normalized = dbValue.trim().toUpperCase().replace(" ", "_");
        try {
            return Role.valueOf(normalized);
        } catch (IllegalArgumentException e) {
            return Role.MEMBER;
        }
    }
}
