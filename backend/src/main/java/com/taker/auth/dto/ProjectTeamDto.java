package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "Project team: manager(s), team leader(s), team members")
public class ProjectTeamDto {
    @Schema(example = "1")
    private Long projectId;
    @Schema(example = "Website Redesign")
    private String projectName;
    @Schema(description = "All assigned users with their project role")
    private List<ProjectTeamMemberDto> members;

    public Long getProjectId() { return projectId; }
    public void setProjectId(Long projectId) { this.projectId = projectId; }
    public String getProjectName() { return projectName; }
    public void setProjectName(String projectName) { this.projectName = projectName; }
    public List<ProjectTeamMemberDto> getMembers() { return members; }
    public void setMembers(List<ProjectTeamMemberDto> members) { this.members = members; }
}
