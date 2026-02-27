package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Create a new task")
public class CreateTaskRequest {

    @Schema(description = "Task title", requiredMode = Schema.RequiredMode.REQUIRED, example = "Setup development environment")
    @NotBlank(message = "Title is required")
    private String title;

    @Schema(description = "Status: need_to_start, ongoing, completed", example = "need_to_start")
    private String status = "need_to_start";

    @Schema(description = "Due date (yyyy-MM-dd)", example = "2025-03-15")
    private String dueDate;

    @Schema(description = "Optional description / details for the task", example = "Check edge cases and write report")
    private String description;

    @Schema(description = "Optional user ID to assign to; null = current user", example = "3")
    private Long assignedToId;

    @Schema(description = "Optional project ID", example = "1")
    private Long projectId;

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDueDate() { return dueDate; }
    public void setDueDate(String dueDate) { this.dueDate = dueDate; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Long getAssignedToId() { return assignedToId; }
    public void setAssignedToId(Long assignedToId) { this.assignedToId = assignedToId; }
    public Long getProjectId() { return projectId; }
    public void setProjectId(Long projectId) { this.projectId = projectId; }
}
