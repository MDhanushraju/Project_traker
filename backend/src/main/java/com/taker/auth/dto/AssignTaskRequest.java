package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Assign a task to a user")
public class AssignTaskRequest {

    @Schema(description = "User ID to assign task to", requiredMode = Schema.RequiredMode.REQUIRED, example = "3")
    @NotNull
    private Long userId;

    @Schema(description = "Task title to create/assign", requiredMode = Schema.RequiredMode.REQUIRED, example = "Review API design")
    @NotBlank
    private String taskTitle;

    @Schema(description = "Due date (yyyy-MM-dd)", example = "2025-03-20")
    private String dueDate;

    @Schema(description = "Optional project ID", example = "1")
    private Long projectId;

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getTaskTitle() { return taskTitle; }
    public void setTaskTitle(String taskTitle) { this.taskTitle = taskTitle; }
    public String getDueDate() { return dueDate; }
    public void setDueDate(String dueDate) { this.dueDate = dueDate; }
    public Long getProjectId() { return projectId; }
    public void setProjectId(Long projectId) { this.projectId = projectId; }
}
