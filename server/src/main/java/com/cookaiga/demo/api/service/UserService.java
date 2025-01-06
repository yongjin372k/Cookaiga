package com.cookaiga.demo.api.service;

import com.cookaiga.demo.models.User;
import com.cookaiga.demo.api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    // Create a new user
    public User createUser(User user) {
        return userRepository.save(user);
    }

    // Get user by ID
    public Optional<User> getUserById(int userID) {
        return userRepository.findById(userID);
    }

    // Get user by username
    public User getUserByUsername(String username) {
        return userRepository.getUserInfo(username);
    }

    // Update user points
    public User updateUserPoints(int userID, int points) {
        Optional<User> userOptional = userRepository.findById(userID);

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setPoints(user.getPoints() + points);
            return userRepository.save(user);
        } else {
            throw new RuntimeException("User not found with ID: " + userID);
        }
    }

}
