package com.cookaiga.demo.api.controller;

import com.cookaiga.demo.models.Post;
import com.cookaiga.demo.api.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

    // Create a new post
    @PostMapping
    public ResponseEntity<Post> createPost(@RequestBody Post post) {
        Post newPost = postService.createOrUpdatePost(post);
        return ResponseEntity.ok(newPost);
    }

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
