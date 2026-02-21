package com.taker.auth.controller;

import com.taker.auth.dto.AssignTaskRequest;
import com.taker.auth.dto.CreateTaskRequest;
import com.taker.auth.dto.TaskDto;
import com.taker.auth.dto.UpdateTaskStatusRequest;
import com.taker.auth.service.TaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Tasks", description = "Task CRUD, status updates, assign - requires auth")
@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @Operation(summary = "List tasks", description = "Get all tasks or filter by userId. Example: ?userId=3")
    @GetMapping
    public ResponseEntity<List<TaskDto>> getTasks(
            @RequestParam(required = false) Long userId) {
        List<TaskDto> tasks = userId != null
                ? taskService.findByAssignedUser(userId)
                : taskService.findAll();
        return ResponseEntity.ok(tasks);
    }

    @Operation(summary = "Create task", description = "Create task. Example: title=Setup env, status=need_to_start, dueDate=2025-03-15")
    @PostMapping
    public ResponseEntity<TaskDto> createTask(@Valid @RequestBody CreateTaskRequest request) {
        return ResponseEntity.ok(taskService.createTask(request));
    }

    @Operation(summary = "Update task status", description = "Set status: need_to_start, ongoing, completed. Example: status=ongoing")
    @PatchMapping("/{id}/status")
    public ResponseEntity<TaskDto> updateStatus(
            @Parameter(description = "Task ID", example = "1") @PathVariable Long id,
            @Valid @RequestBody UpdateTaskStatusRequest request) {
        return ResponseEntity.ok(taskService.updateStatus(id, request));
    }

    @Operation(summary = "Delete task", description = "Delete task by ID")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@Parameter(description = "Task ID", example = "1") @PathVariable Long id) {
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Assign task", description = "Create/assign task to user. Example: userId=3, taskTitle=Review design, dueDate=2025-03-20")
    @PostMapping("/assign")
    public ResponseEntity<TaskDto> assignTask(@Valid @RequestBody AssignTaskRequest request) {
        TaskDto task = taskService.assignTask(
                request.getUserId(),
                request.getTaskTitle(),
                request.getDueDate(),
                request.getProjectId());
        return ResponseEntity.ok(task);
    }
}
