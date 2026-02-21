package com.taker.auth.service;

import com.taker.auth.dto.ProjectDto;
import com.taker.auth.entity.Project;
import com.taker.auth.repository.ProjectRepository;
import org.springframework.stereotype.Service;

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
                .map(p -> {
                    ProjectDto dto = new ProjectDto();
                    dto.setId(p.getId());
                    dto.setName(p.getName());
                    dto.setStatus(p.getStatus());
                    dto.setProgress(p.getProgress());
                    return dto;
                })
                .collect(Collectors.toList());
    }
}
