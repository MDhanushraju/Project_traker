package com.taker.auth.service;

import com.taker.auth.dto.CreateTaskRequest;
import com.taker.auth.dto.TaskDto;
import com.taker.auth.dto.UpdateTaskStatusRequest;
import com.taker.auth.entity.ProjectAssignment;
import com.taker.auth.entity.ProjectRole;
import com.taker.auth.entity.Role;
import com.taker.auth.entity.Task;
import com.taker.auth.entity.User;
import com.taker.auth.exception.ForbiddenException;
import com.taker.auth.exception.NotFoundException;
import com.taker.auth.repository.ProjectAssignmentRepository;
import com.taker.auth.repository.ProjectRepository;
import com.taker.auth.repository.TaskRepository;
import com.taker.auth.repository.UserRepository;
import com.taker.auth.util.SecurityUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class TaskService {
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;
    private final ProjectRepository projectRepository;
    private final ProjectAssignmentRepository assignmentRepository;

    public TaskService(TaskRepository taskRepository, UserRepository userRepository,
                       ProjectRepository projectRepository, ProjectAssignmentRepository assignmentRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
        this.projectRepository = projectRepository;
        this.assignmentRepository = assignmentRepository;
    }

    public List<TaskDto> findAll() {
        return taskRepository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    public List<TaskDto> findByAssignedUser(Long userId) {
        return taskRepository.findByAssignedToId(userId).stream().map(this::toDto).collect(Collectors.toList());
    }

    @Transactional
    public TaskDto createTask(CreateTaskRequest req) {
        String email = SecurityUtils.currentUserEmail();
        if (email == null) throw new NotFoundException("Not authenticated");
        User currentUser = userRepository.findByEmail(email).orElseThrow(() -> new NotFoundException("User not found"));
        User assignTo = req.getAssignedToId() != null
                ? userRepository.findById(req.getAssignedToId()).orElse(currentUser)
                : currentUser;
        Task task = new Task();
        task.setTitle(req.getTitle().trim());
        task.setStatus(normalizeStatus(req.getStatus()));
        task.setAssignedTo(assignTo);
        if (req.getDueDate() != null && !req.getDueDate().isBlank()) {
            try {
                task.setDueDate(LocalDate.parse(req.getDueDate(), DateTimeFormatter.ISO_LOCAL_DATE));
            } catch (Exception ignored) {}
        }
        if (req.getProjectId() != null) {
            projectRepository.findById(req.getProjectId()).ifPresent(task::setProject);
        }
        task = taskRepository.save(task);
        return toDto(task);
    }

    @Transactional
    public TaskDto updateStatus(Long taskId, UpdateTaskStatusRequest req) {
        String email = SecurityUtils.currentUserEmail();
        if (email == null || email.isBlank()) throw new ForbiddenException("Not authenticated");
        User current = userRepository.findByEmail(email).orElseThrow(() -> new NotFoundException("User not found"));
        Task task = taskRepository.findById(taskId).orElseThrow(() -> new NotFoundException("Task not found"));
        if (!canUpdateTask(current, task)) throw new ForbiddenException("You cannot update this task's status");
        task.setStatus(normalizeStatus(req.getStatus()));
        task = taskRepository.save(task);
        return toDto(task);
    }

    private boolean canUpdateTask(User current, Task task) {
        User assignee = task.getAssignedTo();
        if (assignee == null) return true;
        if (current.getId().equals(assignee.getId())) return true;
        Role role = current.getRole();
        if (role == Role.ADMIN) return assignee.getRole() != Role.ADMIN;
        if (role == Role.MANAGER) {
            if (assignee.getRole() != Role.TEAM_LEADER && assignee.getRole() != Role.MEMBER) return false;
            List<ProjectAssignment> myManagerAssignments = assignmentRepository.findByUserIdAndProjectRole(current.getId(), ProjectRole.MANAGER);
            for (ProjectAssignment a : myManagerAssignments) {
                boolean assigneeInProject = assignmentRepository.findByProjectId(a.getProject().getId()).stream()
                    .anyMatch(pa -> pa.getUser().getId().equals(assignee.getId()));
                if (assigneeInProject) return true;
            }
            return false;
        }
        if (role == Role.TEAM_LEADER) {
            if (assignee.getRole() != Role.MEMBER) return false;
            List<ProjectAssignment> tlAssignments = assignmentRepository.findByUserIdAndProjectRole(current.getId(), ProjectRole.TEAM_LEADER);
            for (ProjectAssignment a : tlAssignments) {
                boolean assigneeInProject = assignmentRepository.findByProjectId(a.getProject().getId()).stream()
                    .anyMatch(pa -> pa.getUser().getId().equals(assignee.getId()));
                if (assigneeInProject) return true;
            }
            return false;
        }
        return false;
    }

    @Transactional
    public void deleteTask(Long taskId) {
        if (!taskRepository.existsById(taskId)) throw new NotFoundException("Task not found");
        taskRepository.deleteById(taskId);
    }

    private static String normalizeStatus(String s) {
        if (s == null || s.isBlank()) return "need_to_start";
        String lower = s.trim().toLowerCase().replace(" ", "_");
        if (lower.contains("ongoing") || "in_progress".equals(lower)) return "ongoing";
        if (lower.contains("complete") || "done".equals(lower)) return "completed";
        if (lower.contains("start") || "yet_to_start".equals(lower) || "todo".equals(lower)) return "need_to_start";
        return lower;
    }

    @Transactional
    public TaskDto assignTask(Long userId, String taskTitle, String dueDateStr, Long projectId) {
        User user = userRepository.findById(userId).orElseThrow(() -> new NotFoundException("User not found"));
        Task task = new Task();
        task.setTitle(taskTitle);
        task.setStatus("need_to_start");
        task.setAssignedTo(user);
        if (dueDateStr != null && !dueDateStr.isBlank()) {
            try {
                task.setDueDate(LocalDate.parse(dueDateStr, DateTimeFormatter.ISO_LOCAL_DATE));
            } catch (Exception ignored) {}
        }
        if (projectId != null) {
            projectRepository.findById(projectId).ifPresent(task::setProject);
        }
        task = taskRepository.save(task);
        return toDto(task);
    }

    /** Tasks visible to current user: Admin = all; Manager = TL + members in their projects; TL = self + members; Member = own only. */
    public List<TaskDto> findTasksForCurrentUser() {
        String email = SecurityUtils.currentUserEmail();
        if (email == null || email.isBlank()) return List.of();
        User current = userRepository.findByEmail(email).orElse(null);
        if (current == null) return List.of();

        Set<Long> visibleUserIds = new HashSet<>();
        Role role = current.getRole();

        if (role == Role.ADMIN) {
            userRepository.findAll().stream().map(User::getId).forEach(visibleUserIds::add);
        } else if (role == Role.MANAGER) {
            List<ProjectAssignment> myAssignments = assignmentRepository.findByUserIdAndProjectRole(current.getId(), ProjectRole.MANAGER);
            for (ProjectAssignment a : myAssignments) {
                assignmentRepository.findByProjectId(a.getProject().getId()).stream()
                    .map(ProjectAssignment::getUser)
                    .filter(u -> u.getRole() != Role.ADMIN)
                    .map(User::getId)
                    .forEach(visibleUserIds::add);
            }
        } else if (role == Role.TEAM_LEADER) {
            visibleUserIds.add(current.getId());
            List<ProjectAssignment> tlAssignments = assignmentRepository.findByUserIdAndProjectRole(current.getId(), ProjectRole.TEAM_LEADER);
            for (ProjectAssignment a : tlAssignments) {
                assignmentRepository.findByProjectId(a.getProject().getId()).stream()
                    .map(ProjectAssignment::getUser)
                    .map(User::getId)
                    .forEach(visibleUserIds::add);
            }
        } else {
            visibleUserIds.add(current.getId());
        }

        if (visibleUserIds.isEmpty()) return List.of();
        List<Task> tasks = taskRepository.findByAssignedToIdIn(new ArrayList<>(visibleUserIds));
        return tasks.stream().map(this::toDto).collect(Collectors.toList());
    }

    private TaskDto toDto(Task t) {
        TaskDto dto = new TaskDto();
        dto.setId(t.getId());
        dto.setTitle(t.getTitle());
        dto.setStatus(t.getStatus());
        if (t.getDueDate() != null) dto.setDueDate(t.getDueDate());
        if (t.getAssignedTo() != null) {
            dto.setAssigneeId(t.getAssignedTo().getId());
            dto.setAssigneeName(t.getAssignedTo().getFullName());
        }
        if (t.getProject() != null) {
            dto.setProjectId(t.getProject().getId());
            dto.setProjectName(t.getProject().getName());
        }
        return dto;
    }
}
