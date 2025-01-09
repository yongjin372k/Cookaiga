package com.cookaiga.demo.api.repository;

import com.cookaiga.demo.models.RedemptionHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface RedemptionRepository extends JpaRepository<RedemptionHistory, Integer> {

    // Add a new redemption record (redeemedAt is automatically handled by the entity)
    @Transactional
    @Modifying
    @Query(
        value = "INSERT INTO REDEMPTION (userID, stickerID) VALUES (:userID, :stickerID)",
        nativeQuery = true)
    int addRedemption(
        @Param("userID") int userID,
        @Param("stickerID") int stickerID
    );

    // Find all redemptions by user ID
    @Query(value = "SELECT * FROM REDEMPTION WHERE userID = :userID", nativeQuery = true)
    List<RedemptionHistory> getRedemptionsByUserID(@Param("userID") int userID);

    // Find all stickers redeemed by a specific user
    @Query(value = "SELECT stickerID FROM REDEMPTION WHERE userID = :userID", nativeQuery = true)
    List<Integer> getStickerIDsByUserID(@Param("userID") int userID);

    // Check if a user has redeemed a specific sticker
    @Query(value = "SELECT COUNT(*) FROM REDEMPTION WHERE userID = :userID AND stickerID = :stickerID", nativeQuery = true)
    int hasUserRedeemedSticker(@Param("userID") int userID, @Param("stickerID") int stickerID);
}
