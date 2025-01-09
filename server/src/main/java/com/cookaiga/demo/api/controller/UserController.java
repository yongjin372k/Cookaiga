package com.cookaiga.demo.api.controller;

import com.cookaiga.demo.models.User;
import com.cookaiga.demo.api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    // Create a new user
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        User createdUser = userService.createUser(user);
        return ResponseEntity.ok(createdUser);
    }

    // Get user by ID
    @GetMapping("/{userID}")
    public ResponseEntity<User> getUserById(@PathVariable int userID) {
        return userService.getUserById(userID)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Get user by username
    @GetMapping("/username/{username}")
    public ResponseEntity<User> getUserByUsername(@PathVariable String username) {
        User user = userService.getUserByUsername(username);
        if (user != null) {
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Update user points                          !! This ADDS additional points !! NOT OVERWRITE
    @PutMapping("/{userID}/points")
    public ResponseEntity<User> updateUserPoints(@PathVariable int userID, @RequestParam int points) {
        try {
            User updatedUser = userService.updateUserPoints(userID, points);
            return ResponseEntity.ok(updatedUser);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

}
