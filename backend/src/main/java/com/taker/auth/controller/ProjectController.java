package com.taker.auth.controller;

import com.taker.auth.dto.ApiResponse;
import com.taker.auth.dto.CreateProjectRequest;
import com.taker.auth.dto.ProjectDto;
import com.taker.auth.dto.ProjectTeamDto;
import com.taker.auth.service.DataService;
import com.taker.auth.service.ProjectService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Projects", description = "List projects - requires auth. Frontend expects { success, message, data: list }.")
@RestController
@RequestMapping("/api/projects")
public class ProjectController {

    private final ProjectService projectService;
    private final DataService dataService;

    public ProjectController(ProjectService projectService, DataService dataService) {
        this.projectService = projectService;
        this.dataService = dataService;
    }

    @Operation(summary = "List projects", description = "Returns all projects with id, name, status, progress")
    @GetMapping
    public ResponseEntity<ApiResponse<List<ProjectDto>>> getAll() {
        return ResponseEntity.ok(ApiResponse.success("OK", projectService.findAll()));
    }

    @Operation(summary = "Create project", description = "Create a new project. Requires auth.")
    @PostMapping
    public ResponseEntity<ApiResponse<ProjectDto>> create(@Valid @RequestBody CreateProjectRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Project created", projectService.create(request)));
    }

    @Operation(summary = "Delete project", description = "Delete project by ID. Also removes its tasks and assignments.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@Parameter(description = "Project ID") @PathVariable Long id) {
        projectService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Get project team", description = "Returns project team: manager, team leader(s), team member(s) with roles and photos.")
    @GetMapping("/{id}/team")
    public ResponseEntity<ApiResponse<ProjectTeamDto>> getTeam(
            @Parameter(description = "Project ID") @PathVariable Long id) {
        ProjectTeamDto team = dataService.getProjectTeam(id);
        if (team == null) {
            return ResponseEntity.status(404).body(ApiResponse.failure(404, "Project not found"));
        }
        return ResponseEntity.ok(ApiResponse.success("OK", team));
    }
}
