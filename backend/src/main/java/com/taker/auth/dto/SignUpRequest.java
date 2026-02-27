package com.taker.auth.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Register a new user account")
@JsonIgnoreProperties(ignoreUnknown = true)
public class SignUpRequest {

    @Schema(description = "Full name", requiredMode = Schema.RequiredMode.REQUIRED, example = "John Doe")
    private String fullName;

    @Schema(description = "Email address", requiredMode = Schema.RequiredMode.REQUIRED, example = "john@example.com")
    private String email;

    @Schema(description = "Optional ID card number", example = "000-0000-005")
    private String idCardNumber;

    @Schema(description = "Password (min 8 chars)", requiredMode = Schema.RequiredMode.REQUIRED, example = "Password@1")
    private String password;

    @Schema(description = "Confirm password (must match password)", requiredMode = Schema.RequiredMode.REQUIRED, example = "Password@1")
    private String confirmPassword;

    @Schema(description = "What role are you signing in as: admin, manager, team_leader, member", example = "member")
    private String role;

    @Schema(description = "Which team are you in: Developer, Tester, Designer, Analyst", example = "Developer")
    private String position;

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName != null ? fullName.trim() : null; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email != null ? email.trim() : null; }
    public String getIdCardNumber() { return idCardNumber; }
    public void setIdCardNumber(String idCardNumber) { this.idCardNumber = idCardNumber != null ? idCardNumber.trim() : null; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role != null ? role.trim() : null; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position != null ? position.trim() : null; }
    /** Alias for position: "Which team are you in?" sends team (Developer, Tester, etc.) */
    public String getTeam() { return position; }
    public void setTeam(String team) { this.position = team != null ? team.trim() : null; }
}
