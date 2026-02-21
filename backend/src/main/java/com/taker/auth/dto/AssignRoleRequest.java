package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Assign or change user role (Admin/Manager only)")
public class AssignRoleRequest {

    @Schema(description = "New role: admin, manager, team_leader, member", requiredMode = Schema.RequiredMode.REQUIRED, example = "team_leader")
    @NotBlank(message = "Role is required")
    private String role;

    @Schema(description = "Position for team_leader/member: Developer, Tester, Designer, Analyst", example = "Tester")
    private String position;

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
}
