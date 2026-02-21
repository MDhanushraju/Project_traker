package com.taker.auth.service;

import com.taker.auth.dto.CreateTaskRequest;
import com.taker.auth.dto.TaskDto;
import com.taker.auth.dto.UpdateTaskStatusRequest;
import com.taker.auth.entity.Task;
import com.taker.auth.entity.User;
import com.taker.auth.exception.NotFoundException;
import com.taker.auth.repository.TaskRepository;
import com.taker.auth.repository.UserRepository;
import com.taker.auth.util.SecurityUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TaskService {
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;

    public TaskService(TaskRepository taskRepository, UserRepository userRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
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
        task = taskRepository.save(task);
        return toDto(task);
    }

    @Transactional
    public TaskDto updateStatus(Long taskId, UpdateTaskStatusRequest req) {
        Task task = taskRepository.findById(taskId).orElseThrow(() -> new NotFoundException("Task not found"));
        task.setStatus(normalizeStatus(req.getStatus()));
        task = taskRepository.save(task);
        return toDto(task);
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
        task = taskRepository.save(task);
        return toDto(task);
    }

    private TaskDto toDto(Task t) {
        TaskDto dto = new TaskDto();
        dto.setId(t.getId());
        dto.setTitle(t.getTitle());
        dto.setStatus(t.getStatus());
        if (t.getDueDate() != null) dto.setDueDate(t.getDueDate());
        return dto;
    }
}
