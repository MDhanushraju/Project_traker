package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Create a new user (Admin/Manager only)")
public class CreateUserRequest {

    @Schema(description = "Full name", requiredMode = Schema.RequiredMode.REQUIRED, example = "Jane Smith")
    @NotBlank(message = "Full name is required")
    private String fullName;

    @Schema(description = "Email (unique)", requiredMode = Schema.RequiredMode.REQUIRED, example = "jane@taker.com")
    @NotBlank(message = "Email is required")
    private String email;

    @Schema(description = "Password (optional; default Welcome@1 if blank)", example = "Welcome@1")
    private String password;

    @Schema(description = "Role: admin, manager, team_leader, member", requiredMode = Schema.RequiredMode.REQUIRED, example = "member")
    @NotBlank(message = "Role is required")
    private String role;

    @Schema(description = "Position for team_leader/member: Developer, Tester, Designer, Analyst", example = "Developer")
    private String position;

    @Schema(description = "Job title", example = "Senior Developer")
    private String title;

    @Schema(description = "Mark as temporary position", example = "false")
    private Boolean temporary = false;

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Boolean getTemporary() { return temporary; }
    public void setTemporary(Boolean temporary) { this.temporary = temporary; }
}
