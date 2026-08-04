package com.example.backend.controller;

import com.example.backend.model.User;
import com.example.backend.repository.UserRepository;
import com.example.backend.security.JwtUtil;
import com.example.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001", "https://user-management-system-ten-gold.vercel.app"}, allowCredentials = "true")
public class AuthController {
    private final UserService userService;
    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    @Autowired
    public AuthController(UserService userService, AuthenticationManager authenticationManager, JwtUtil jwtUtil, UserRepository userRepository) {
        this.userService = userService;
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
    }

    @PostMapping(value = "/register", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> register(@RequestBody Map<String, String> requestBody) {
        if (requestBody == null) {
            return ResponseEntity.badRequest().body(createErrorResponse("Request body is required"));
        }

        try {
            User user = new User();
            user.setFullName(requestBody.getOrDefault("fullName", "").trim());
            user.setEmail(requestBody.getOrDefault("email", "").trim());
            user.setMobile(requestBody.getOrDefault("mobile", ""));
            user.setUsername(requestBody.getOrDefault("username", "").trim());
            user.setPassword(requestBody.getOrDefault("password", ""));

            User saved = userService.register(user);
            Map<String, Object> response = new HashMap<String, Object>();
            response.put("message", "User registered successfully");
            Map<String, Object> userResponse = new LinkedHashMap<String, Object>();
            userResponse.put("id", saved.getId());
            userResponse.put("username", saved.getUsername());
            userResponse.put("email", saved.getEmail());
            userResponse.put("fullName", saved.getFullName());
            response.put("user", userResponse);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(createErrorResponse(ex.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String usernameOrEmail = body.getOrDefault("username", "").trim();
        String password = body.getOrDefault("password", "");

        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(createErrorResponse("Username/email and password are required"));
        }

        try {
            User user = userRepository.findByUsername(usernameOrEmail)
                    .orElseGet(() -> userRepository.findByEmail(usernameOrEmail).orElseThrow(() -> new BadCredentialsException("Invalid credentials")));

            authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(user.getUsername(), password));
            String token = jwtUtil.generateToken(user.getUsername());

            Map<String, Object> response = new HashMap<String, Object>();
            response.put("token", token);
            Map<String, Object> userResponse = new LinkedHashMap<String, Object>();
            userResponse.put("id", user.getId());
            userResponse.put("username", user.getUsername());
            userResponse.put("email", user.getEmail());
            userResponse.put("fullName", user.getFullName());
            userResponse.put("mobile", user.getMobile());
            userResponse.put("role", user.getRole());
            response.put("user", userResponse);
            return ResponseEntity.ok(response);
        } catch (AuthenticationException ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(createErrorResponse("Invalid credentials"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(createErrorResponse(ex.getMessage()));
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        return ResponseEntity.ok(createMessageResponse("Logged out successfully"));
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
