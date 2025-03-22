package com.cookaiga.demo.api.controller;

import com.cookaiga.demo.models.LoginRequest;
import com.cookaiga.demo.models.User;

import net.minidev.json.JSONObject;

import com.cookaiga.demo.api.service.UserService;
import com.cookaiga.demo.api.service.JwtTokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired JwtTokenService jwtTokenService;

    // Create a new user
    // @PostMapping
    // public ResponseEntity<User> createUser(@RequestBody User user) {
    //     User createdUser = userService.createUser(user);
    //     return ResponseEntity.ok(createdUser);
    // }

    // Register a new user
    @RequestMapping(
      value = "/register",
      method = RequestMethod.POST,
      produces = {"application/json"})
    @ResponseBody
    public ResponseEntity<?> registerUser(@RequestBody User user) {
    
        if (user == null) {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("status", "error");
        jsonObject.put("message", "User is null");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(jsonObject.toString());
        }
        // check username
        else if (userService.checkExistingUsername(user.getUsername()) > 0) {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("status", "error");
        jsonObject.put("message", "Username already exists!");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(jsonObject.toString());

        }
        else {
        userService.createUser(user);
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("status", "success");
        jsonObject.put("message", "User registered successfully");
        return ResponseEntity.status(HttpStatus.OK).body(jsonObject.toString());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> authenticate(@RequestBody LoginRequest loginRequest) {
        // Authenticate the user
        boolean authenticated =
            userService.authenticate(loginRequest.getUsername(), loginRequest.getPassword());
        if (authenticated) {
        String token = jwtTokenService.generateToken(loginRequest.getUsername());
        Map<String, String> responseMap = new HashMap<>();
        responseMap.put("token", token);

        // Return the Map as JSON
        return ResponseEntity.ok(responseMap);
        } else {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Authentication failed");
        }
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
