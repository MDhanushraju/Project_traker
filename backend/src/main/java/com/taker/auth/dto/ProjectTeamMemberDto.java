package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "User in a project team with their project role")
public class ProjectTeamMemberDto {
    @Schema(example = "1")
    private Long id;
    @Schema(example = "Sarah Jenkins")
    private String name;
    @Schema(example = "Director of Product Operations")
    private String title;
    @Schema(example = "manager@taker.com")
    private String email;
    @Schema(example = "Developer")
    private String position;
    @Schema(example = "manager", description = "Project role: manager, team_leader, team_member")
    private String projectRole;
    @Schema(example = "https://example.com/photo.jpg")
    private String photoUrl;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
    public String getProjectRole() { return projectRole; }
    public void setProjectRole(String projectRole) { this.projectRole = projectRole; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
}
