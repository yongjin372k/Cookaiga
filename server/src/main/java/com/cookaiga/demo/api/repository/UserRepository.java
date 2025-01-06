package com.cookaiga.demo.api.repository;

import com.cookaiga.demo.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    // Insert a new user
    @Transactional
    @Modifying
    @Query(
        value = "INSERT INTO USER (username, fullname, points, created_at) VALUES (:username, :fullname, :points, :created_at)",
        nativeQuery = true)
    int registerUser(
        @Param("username") String username,
        @Param("fullname") String fullname,
        @Param("points") int points,
        @Param("created_at") String createdAt
    );

    // Find user by username
    @Query(value = "SELECT * FROM USER WHERE username = :username", nativeQuery = true)
    User getUserInfo(@Param("username") String username);

    // Update points for a user
    @Transactional
    @Modifying
    @Query(
        value = "UPDATE USER SET points = points + :points WHERE userID = :userID",
        nativeQuery = true)
    int updateUserPoints(@Param("userID") int userID, @Param("points") int points);

    // Check if a username exists
    @Query(value = "SELECT COUNT(*) FROM USER WHERE username = :username", nativeQuery = true)
    int checkExistingUsername(@Param("username") String username);

    // Get the user ID by username
    @Query(value = "SELECT userID FROM USER WHERE username = :username", nativeQuery = true)
    int getUserID(@Param("username") String username);

    // Get the username by user ID
    @Query(value = "SELECT username FROM USER WHERE userID = :userID", nativeQuery = true)
    String getNameFromID(@Param("userID") int userID);
}
