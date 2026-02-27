package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Reset password: same email as forgot-password + captcha answer (e.g. 10 for \"2 + 8\") + new password")
public class ResetPasswordRequest {

    @Schema(description = "User email (same as in forgot-password)", requiredMode = Schema.RequiredMode.REQUIRED, example = "admin@taker.com")
    private String email;

    @Schema(description = "Answer to the math question (e.g. 10 for \"What is 2 + 8?\")", requiredMode = Schema.RequiredMode.REQUIRED, example = "10")
    private String captchaAnswer;

    @Schema(description = "New password", requiredMode = Schema.RequiredMode.REQUIRED, example = "NewPass@1")
    private String newPassword;

    @Schema(description = "Confirm new password", requiredMode = Schema.RequiredMode.REQUIRED, example = "NewPass@1")
    private String confirmPassword;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email != null ? email.trim().toLowerCase() : null; }
    public String getCaptchaAnswer() { return captchaAnswer; }
    public void setCaptchaAnswer(String captchaAnswer) { this.captchaAnswer = captchaAnswer; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
}
