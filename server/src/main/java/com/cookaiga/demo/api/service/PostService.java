package com.cookaiga.demo.api.service;

import com.cookaiga.demo.models.Post;
import com.cookaiga.demo.api.DTO.PostDTO;
import com.cookaiga.demo.api.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class PostService {

    @Autowired
    private PostRepository postRepository;

    // Retrieve all posts
    public List<Post> getAllPosts() {
        return postRepository.findAllPosts();
    }

    // Retrieve all posts using DTO
    public List<PostDTO> getUsernamePosts() {

        List<Object[]> rawPosts = postRepository.findAllPostsRaw();

    return rawPosts.stream()
        .map(row -> new PostDTO(
            ((Number) row[0]).longValue(),                        // postID
            ((Number) row[1]).longValue(),                        // userID
            (String) row[2],                                      // imagePath
            (String) row[3],                                      // caption
            ((java.sql.Timestamp) row[4]).toLocalDateTime(),      // postDate
            (String) row[5]                                       // username
        ))
        .toList();
    }

    // Retrieve a post by ID
    public Optional<Post> getPostById(int postID) {
        return Optional.ofNullable(postRepository.findPostById(postID));
    }

    // Upload a new post
    public void uploadPost(int userID, String imagePath) {
        LocalDateTime postDate = LocalDateTime.now();
        postRepository.insertPost(userID, imagePath, "", postDate.toString());
    }

    // Retrieve all posts by a specific user
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
