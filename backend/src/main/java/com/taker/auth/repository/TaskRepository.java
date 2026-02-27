package com.taker.auth.repository;

import com.taker.auth.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TaskRepository extends JpaRepository<Task, Long> {

    List<Task> findByAssignedToId(Long userId);

    List<Task> findByAssignedToIdIn(List<Long> userIds);

    long countByAssignedToIdAndStatus(Long assignedToId, String status);
}
