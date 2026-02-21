package com.taker.auth.controller;

import com.taker.auth.dto.ProjectDto;
import com.taker.auth.service.ProjectService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Projects", description = "List projects - requires auth")
@RestController
@RequestMapping("/api/projects")
public class ProjectController {

    private final ProjectService projectService;

    public ProjectController(ProjectService projectService) {
        this.projectService = projectService;
    }

    @Operation(summary = "List projects", description = "Returns all projects with id, name, status, progress")
    @GetMapping
    public ResponseEntity<List<ProjectDto>> getAll() {
        return ResponseEntity.ok(projectService.findAll());
    }
}
