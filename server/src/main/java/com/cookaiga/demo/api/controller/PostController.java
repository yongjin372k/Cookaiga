package com.cookaiga.demo.api.controller;

import com.cookaiga.demo.models.Post;
import com.cookaiga.demo.api.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/posts")
public class PostController {

    @Autowired
    private PostService postService;

    // Retrieve all community posts
    @GetMapping
    public ResponseEntity<List<Post>> getAllPosts() {
        List<Post> posts = postService.getAllPosts();
        return ResponseEntity.ok(posts);
    }

    // Retrieve a single post by ID
    @GetMapping("/{postID}")
    public ResponseEntity<Post> getPostById(@PathVariable int postID) {
        return postService.getPostById(postID)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Create a Post
    @PostMapping("/upload")
    public ResponseEntity<String> uploadPost(
            @RequestParam("userID") int userID,
            @RequestParam("imagePath") MultipartFile file) {

        try {
            // Define the directory inside the server folder
            String uploadDir = new File("src/main/resources/assets/posts").getAbsolutePath();
            File directory = new File(uploadDir);
            if (!directory.exists()) {
                directory.mkdirs(); // Create the directory if it doesn't exist
            }

            // Generate a unique file name
            String fileName = file.getOriginalFilename();
            String filePath = uploadDir + File.separator + fileName;

            // Save the file
            File destinationFile = new File(filePath);
            file.transferTo(destinationFile);
            System.out.println("File saved to: " + filePath);

            // Save the relative file path to the database
            String relativePath = "assets/posts/" + fileName;
            postService.uploadPost(userID, relativePath);

            return ResponseEntity.ok("File uploaded successfully. Access it at: " + relativePath);
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to upload file.");
        }
    }


    // Retrieve all posts by a specific user
    @GetMapping("/user/{userID}")
    public ResponseEntity<List<Post>> getAllPostsByUserId(@PathVariable int userID) {
        List<Post> userPosts = postService.getAllPostsByUserId(userID);
        return ResponseEntity.ok(userPosts);
    }

    // Delete a post by ID
    @DeleteMapping("/{postID}")
    public ResponseEntity<Void> deletePost(@PathVariable int postID) {
        try {
            postService.deletePost(postID);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
