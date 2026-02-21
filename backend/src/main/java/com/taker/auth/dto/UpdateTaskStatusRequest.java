package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Update task status")
public class UpdateTaskStatusRequest {

    @Schema(description = "New status: need_to_start, ongoing, completed", requiredMode = Schema.RequiredMode.REQUIRED, example = "ongoing")
    @NotBlank(message = "Status is required")
    private String status;

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
