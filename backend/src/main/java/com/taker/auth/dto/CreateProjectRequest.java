package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Request to create a project")
public class CreateProjectRequest {

    @NotBlank(message = "Project name is required")
    @Schema(example = "Website Redesign", required = true)
    private String name;

    @Schema(example = "Active")
    private String status = "Active";

    @Schema(example = "0")
    private Integer progress = 0;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status != null && !status.isBlank() ? status : "Active";
    }

    public Integer getProgress() {
        return progress;
    }

    public void setProgress(Integer progress) {
        this.progress = progress != null ? progress : 0;
    }
}
