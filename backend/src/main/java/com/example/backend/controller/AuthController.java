package com.example.backend.controller;

import com.example.backend.model.User;
import com.example.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, String> requestBody) {
        if (requestBody == null || requestBody.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "Request body cannot be empty");
            return ResponseEntity.badRequest().body(error);
        }

        try {
            User user = new User();
            user.setFullName(requestBody.getOrDefault("fullName", ""));
            user.setEmail(requestBody.getOrDefault("email", ""));
            user.setMobile(requestBody.getOrDefault("mobile", ""));
            user.setUsername(requestBody.getOrDefault("username", ""));
            user.setPassword(requestBody.getOrDefault("password", ""));

            userService.register(user);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "User registered successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
}