package com.taker.auth.service;

import com.taker.auth.dto.ProjectDto;
import com.taker.auth.dto.CreateProjectRequest;
import com.taker.auth.entity.Project;
import com.taker.auth.repository.ProjectRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProjectService {
    private final ProjectRepository projectRepository;

    public ProjectService(ProjectRepository projectRepository) {
        this.projectRepository = projectRepository;
    }

    public List<ProjectDto> findAll() {
        return projectRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public ProjectDto create(CreateProjectRequest request) {
        String name = request.getName() != null ? request.getName().trim() : "";
        String status = request.getStatus() != null && !request.getStatus().isBlank() ? request.getStatus().trim() : "Active";
        int progress = request.getProgress() != null ? Math.max(0, Math.min(100, request.getProgress())) : 0;
        Project project = new Project(name, status, progress);
        project = projectRepository.save(project);
        return toDto(project);
    }

    private ProjectDto toDto(Project p) {
        ProjectDto dto = new ProjectDto();
        dto.setId(p.getId());
        dto.setName(p.getName());
        dto.setStatus(p.getStatus());
        dto.setProgress(p.getProgress());
        return dto;
    }
}
