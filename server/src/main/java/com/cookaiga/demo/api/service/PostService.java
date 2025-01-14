package com.cookaiga.demo.api.service;

import com.cookaiga.demo.models.Post;
import com.cookaiga.demo.api.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PostService {

    @Autowired
    private PostRepository postRepository;

    // Retrieve all posts
    public List<Post> getAllPosts() {
        return postRepository.findAll();
    }

    // Retrieve a post by ID
    public Optional<Post> getPostById(int postID) {
        return postRepository.findById(postID);
    }

    // Create or update a post
    public Post createOrUpdatePost(Post post) {
        return postRepository.save(post);
    }

    // Get all posts by userID
    public List<Post> getAllPostsByUserId(int userID) {
        return postRepository.findAllPostsByUserId(userID);
    }

    // Delete a post by ID
    public void deletePost(int postID) {
        if (postRepository.existsById(postID)) {
            postRepository.deleteById(postID);
        } else {
            throw new RuntimeException("Post not found with ID: " + postID);
        }
    }

}
