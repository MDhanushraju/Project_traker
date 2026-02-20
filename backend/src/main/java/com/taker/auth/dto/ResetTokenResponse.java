package com.taker.auth.dto;

public class ResetTokenResponse {

    private String resetToken;

    public ResetTokenResponse() {}

    public ResetTokenResponse(String resetToken) {
        this.resetToken = resetToken;
    }

    public String getResetToken() { return resetToken; }
    public void setResetToken(String resetToken) { this.resetToken = resetToken; }
}
