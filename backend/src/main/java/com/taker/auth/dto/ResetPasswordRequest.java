package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Reset password with token from verify-captcha")
public class ResetPasswordRequest {

    @Schema(description = "New password (min 8 chars, 1 number, 1 special)", requiredMode = Schema.RequiredMode.REQUIRED, example = "NewPass@1")
    @NotBlank(message = "New password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String newPassword;

    @Schema(description = "Confirm new password", requiredMode = Schema.RequiredMode.REQUIRED, example = "NewPass@1")
    @NotBlank(message = "Confirm password is required")
    private String confirmPassword;

    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
}
