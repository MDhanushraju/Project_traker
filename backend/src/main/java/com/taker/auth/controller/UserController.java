package com.taker.auth.controller;

import com.taker.auth.dto.*;
import com.taker.auth.service.DataService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "Users", description = "User management - requires Admin/Manager token. Team Leader/Member endpoints return role-specific data.")
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final DataService dataService;

    public UserController(DataService dataService) {
        this.dataService = dataService;
    }

    @Operation(summary = "Create user", description = "Admin/Manager: Add new user with role and position. Use fake: fullName=Jane, email=jane@test.com, role=member, position=Developer")
    @PostMapping
    public ResponseEntity<ApiResponse<UserSummaryDto>> create(@Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.ok(ApiResponse.success("User created", dataService.createUser(request)));
    }

    @Operation(summary = "Assign role", description = "Admin/Manager: Change user role. Example: id=3, role=team_leader, position=Tester")
    @PatchMapping("/{id}/role")
    public ResponseEntity<ApiResponse<UserSummaryDto>> assignRole(
            @Parameter(description = "User ID", example = "3") @PathVariable Long id,
            @Valid @RequestBody AssignRoleRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Role updated", dataService.assignRole(id, request)));
    }

    @Operation(summary = "Get all users", description = "Returns list of all users with id, name, role, position. Requires auth.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<UserSummaryDto>>> getAll() {
        return ResponseEntity.ok(ApiResponse.success("OK", dataService.getAllUsers()));
    }

    @Operation(summary = "Team Leader: My projects", description = "Returns project names assigned to logged-in Team Leader.")
    @GetMapping("/team-leader/projects")
    public ResponseEntity<ApiResponse<List<String>>> teamLeaderProjects() {
        return ResponseEntity.ok(ApiResponse.success("OK", dataService.getTeamLeaderAssignedProjects()));
    }

    @Operation(summary = "Team Leader: Team members by project", description = "Returns map of projectName -> list of team members.")
    @GetMapping("/team-leader/team-members")
    public ResponseEntity<ApiResponse<Map<String, List<TeamMemberDto>>>> teamLeaderTeamMembers() {
        return ResponseEntity.ok(ApiResponse.success("OK", dataService.getTeamLeaderTeamMembers()));
    }

    @Operation(summary = "Team Leader: My manager", description = "Returns name and title of the manager for the Team Leader's projects.")
    @GetMapping("/team-leader/team-manager")
    public ResponseEntity<ApiResponse<Map<String, String>>> teamManager() {
        return ResponseEntity.ok(ApiResponse.success("OK", dataService.getTeamManager()));
    }

    @Operation(summary = "Team Member: My projects", description = "Returns project names assigned to logged-in Team Member.")
    @GetMapping("/member/projects")
    public ResponseEntity<ApiResponse<List<String>>> memberProjects() {
        return ResponseEntity.ok(ApiResponse.success("OK", dataService.getMemberAssignedProjects()));
    }

    @Operation(summary = "Team Member: My contacts", description = "Returns contacts (Manager, Team Leader, members) from projects.")
    @GetMapping("/member/contacts")
    public ResponseEntity<ApiResponse<List<ContactDto>>> memberContacts() {
        return ResponseEntity.ok(ApiResponse.success("OK", dataService.getMemberContacts()));
    }
}
