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
}
