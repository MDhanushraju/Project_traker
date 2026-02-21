package com.taker.auth.repository;

import com.taker.auth.entity.ProjectAssignment;
import com.taker.auth.entity.ProjectRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProjectAssignmentRepository extends JpaRepository<ProjectAssignment, Long> {

    List<ProjectAssignment> findByUserId(Long userId);

    List<ProjectAssignment> findByProjectId(Long projectId);

    List<ProjectAssignment> findByUserIdAndProjectRole(Long userId, ProjectRole projectRole);
}
