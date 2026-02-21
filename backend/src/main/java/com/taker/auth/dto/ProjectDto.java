package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Project response")
public class ProjectDto {
    @Schema(example = "1")
    private Long id;
    @Schema(example = "Website Redesign")
    private String name;
    @Schema(example = "Active")
    private String status;
    @Schema(example = "65")
    private Integer progress;

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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getProgress() {
        return progress;
    }

    public void setProgress(Integer progress) {
        this.progress = progress;
    }
}
