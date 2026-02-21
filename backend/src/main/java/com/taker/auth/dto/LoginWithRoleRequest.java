package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Demo login - gets first user with given role (for testing)")
public class LoginWithRoleRequest {

    @Schema(description = "Role: admin, manager, team_leader, member", requiredMode = Schema.RequiredMode.REQUIRED, example = "admin")
    @NotBlank
    private String role;

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
