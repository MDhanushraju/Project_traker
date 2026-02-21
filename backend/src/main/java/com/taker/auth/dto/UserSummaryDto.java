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
}
