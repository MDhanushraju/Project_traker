package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Register a new user account")
public class SignUpRequest {

    @Schema(description = "Full name", requiredMode = Schema.RequiredMode.REQUIRED, example = "John Doe")
    @NotBlank(message = "Full name is required")
    private String fullName;

    @Schema(description = "Email address", requiredMode = Schema.RequiredMode.REQUIRED, example = "john@example.com")
    @NotBlank(message = "Email is required")
    private String email;

    @Schema(description = "Optional ID card number", example = "000-0000-005")
    private String idCardNumber;

    @Schema(description = "Password (min 8 chars, 1 number, 1 special char)", requiredMode = Schema.RequiredMode.REQUIRED, example = "Password@1")
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @Schema(description = "Confirm password (must match password)", requiredMode = Schema.RequiredMode.REQUIRED, example = "Password@1")
    @NotBlank(message = "Confirm password is required")
    private String confirmPassword;

    @Schema(description = "Role: admin, manager, member, team_leader", example = "member")
    private String role;

    @Schema(description = "Position for team_leader/member: Developer, Tester, Designer, Analyst", example = "Developer")
    private String position;

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getIdCardNumber() { return idCardNumber; }
    public void setIdCardNumber(String idCardNumber) { this.idCardNumber = idCardNumber; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
}
