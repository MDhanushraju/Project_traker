package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;

@Schema(description = "Task response")
public class TaskDto {
    @Schema(example = "1")
    private Long id;
    @Schema(example = "Setup development environment")
    private String title;
    @Schema(example = "ongoing", description = "need_to_start | ongoing | completed")
    private String status;
    @Schema(example = "2025-03-15")
    private LocalDate dueDate;
    @Schema(example = "Investigate login edge cases")
    private String description;
    @Schema(example = "3", description = "Assignee user ID")
    private Long assigneeId;
    @Schema(example = "Jane Doe", description = "Assignee display name")
    private String assigneeName;
    @Schema(example = "1", description = "Project ID")
    private Long projectId;
    @Schema(example = "Website Redesign", description = "Project name")
    private String projectName;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Long getAssigneeId() { return assigneeId; }
    public void setAssigneeId(Long assigneeId) { this.assigneeId = assigneeId; }
    public String getAssigneeName() { return assigneeName; }
    public void setAssigneeName(String assigneeName) { this.assigneeName = assigneeName; }
    public Long getProjectId() { return projectId; }
    public void setProjectId(Long projectId) { this.projectId = projectId; }
    public String getProjectName() { return projectName; }
    public void setProjectName(String projectName) { this.projectName = projectName; }
}
