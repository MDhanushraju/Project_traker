package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Assign user to a project with a project role (new joiner)")
public class AssignProjectRequest {

    @Schema(description = "Project ID", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "Project ID is required")
    private Long projectId;

    @Schema(description = "Project role: manager, team_leader, team_member", requiredMode = Schema.RequiredMode.REQUIRED, example = "team_member")
    @NotNull(message = "Project role is required")
    private String projectRole;

    public Long getProjectId() { return projectId; }
    public void setProjectId(Long projectId) { this.projectId = projectId; }
    public String getProjectRole() { return projectRole; }
    public void setProjectRole(String projectRole) { this.projectRole = projectRole; }
}
