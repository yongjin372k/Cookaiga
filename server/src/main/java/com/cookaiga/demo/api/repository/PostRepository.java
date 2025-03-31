package com.cookaiga.demo.api.repository;

import com.cookaiga.demo.api.DTO.PostDTO;
import com.cookaiga.demo.models.Post;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface PostRepository extends JpaRepository<Post, Integer> {

    // Insert a new post
    @Transactional
    @Modifying
    @Query(value = "INSERT INTO POST (userID, imagePath, caption, postDate) " +
                   "VALUES (:userID, :imagePath, :caption, :postDate)", nativeQuery = true)
    int insertPost(
            @Param("userID") int userID,
            @Param("imagePath") String imagePath,
            @Param("caption") String caption,
            @Param("postDate") String postDate
    );

    // Retrieve all posts ordered by postDate in descending order
    @Query(value = "SELECT * FROM POST ORDER BY postDate DESC", nativeQuery = true)
    List<Post> findAllPosts();

    @Query(value = "SELECT p.postID, p.userID, p.imagePath, p.caption, p.postDate, u.username " +
               "FROM POST p " +
               "INNER JOIN USER u ON p.userID = u.userID " +
               "ORDER BY p.postDate DESC", nativeQuery = true)
               List<Object[]> findAllPostsRaw(); // Return raw data


    // Retrieve a post by its ID
    @Query(value = "SELECT * FROM POST WHERE postID = :postID", nativeQuery = true)
    Post findPostById(@Param("postID") int postID);

    // Retrieve all posts by a specific user, ordered by postDate in descending order
    @Query(value = "SELECT * FROM POST WHERE userID = :userID ORDER BY postDate DESC", nativeQuery = true)
    List<Post> findAllPostsByUserId(@Param("userID") int userID);

    // Delete a post by its ID
    @Transactional
    @Modifying
    @Query(value = "DELETE FROM POST WHERE postID = :postID", nativeQuery = true)
    void deletePostById(@Param("postID") int postID);

}
