package com.example.backend.controller;

import com.example.backend.dto.UserDTO;
import com.example.backend.model.User;
import com.example.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    // Explicit root endpoint for getting all users
    @GetMapping
    public ResponseEntity<Map<String, Object>> all() {
        List<User> users = userService.getAllUsers();
        LocalDate today = LocalDate.now();
        long activeUsers = users.stream().filter(this::isActiveUser).count();
        long newUsersToday = users.stream().filter(user -> user.getCreatedAt() != null && user.getCreatedAt().toLocalDate().isEqual(today)).count();

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("users", users);
        response.put("totalUsers", userService.countUsers());
        response.put("activeUsers", activeUsers);
        response.put("newUsersToday", newUsersToday);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> get(@PathVariable Long id) {
        User user = userService.getById(id).orElse(null);
        if (user != null) {
            return ResponseEntity.ok(user);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(createErrorResponse("User not found"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody UserDTO dto) {
        try {
            User updated = userService.update(id, dto);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(createErrorResponse(ex.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.ok(createMessageResponse("User deleted successfully"));
    }

    private boolean isActiveUser(User user) {
        if (user.getCreatedAt() == null) {
            return false;
        }
        LocalDateTime threshold = LocalDateTime.now().minusDays(30);
        return user.getCreatedAt().isAfter(threshold);
    }

    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> response = new LinkedHashMap<String, Object>();
        response.put("error", message);
        return response;
    }

    private Map<String, Object> createMessageResponse(String message) {
        Map<String, Object> response = new LinkedHashMap<String, Object>();
        response.put("message", message);
        return response;
    }
}
