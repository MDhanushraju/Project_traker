package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "User summary response")
public class UserSummaryDto {
    @Schema(example = "1")
    private Long id;
    @Schema(example = "Admin User")
    private String name;
    @Schema(example = "Administrator")
    private String title;
    @Schema(example = "admin")
    private String role;
    @Schema(example = "Developer")
    private String position;
    @Schema(example = "false")
    private Boolean temporary;
    @Schema(example = "admin@taker.com")
    private String email;
    @Schema(example = "10001")
    private Integer loginId;
    @Schema(example = "https://example.com/photo.jpg")
    private String photoUrl;
    @Schema(example = "28")
    private Integer age;
    @Schema(example = "Java, React, SQL")
    private String skills;
    @Schema(example = "Project Alpha")
    private String currentProject;
    @Schema(example = "3")
    private Integer projectsCompletedCount;
    @Schema(example = "Sarah Jenkins")
    private String managerName;
    @Schema(example = "Marcus Thorne")
    private String teamLeaderName;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public Boolean getTemporary() {
        return temporary;
    }

    public void setTemporary(Boolean temporary) {
        this.temporary = temporary;
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Integer getLoginId() { return loginId; }
    public void setLoginId(Integer loginId) { this.loginId = loginId; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    public String getSkills() { return skills; }
    public void setSkills(String skills) { this.skills = skills; }
    public String getCurrentProject() { return currentProject; }
    public void setCurrentProject(String currentProject) { this.currentProject = currentProject; }
    public Integer getProjectsCompletedCount() { return projectsCompletedCount; }
    public void setProjectsCompletedCount(Integer projectsCompletedCount) { this.projectsCompletedCount = projectsCompletedCount; }
    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }
    public String getTeamLeaderName() { return teamLeaderName; }
    public void setTeamLeaderName(String teamLeaderName) { this.teamLeaderName = teamLeaderName; }
}
