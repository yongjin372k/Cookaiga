package com.cookaiga.demo.api.repository;

import com.cookaiga.demo.models.Sticker;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface StickerRepository extends JpaRepository<Sticker, Integer> {

    // Insert a new sticker
    @Transactional
    @Modifying
    @Query(
        value = "INSERT INTO STICKER (stickerName, stickerDesc, points_required, file_path) VALUES (:stickerName, :stickerDesc, :pointsReq, :filePath)",
        nativeQuery = true)
    int addSticker(
        @Param("stickerName") String stickerName,
        @Param("stickerDesc") String stickerDesc,
        @Param("pointsReq") int pointsReq,
        @Param("filePath") String filePath
    );

    // Find a sticker by name
    @Query(value = "SELECT * FROM STICKER WHERE stickerName = :stickerName", nativeQuery = true)
    Sticker getStickerByName(@Param("stickerName") String stickerName);

    // Update sticker details
    @Transactional
    @Modifying
    @Query(
        value = "UPDATE STICKER SET stickerDesc = :stickerDesc, points_required = :pointsReq, file_path = :filePath WHERE stickerID = :stickerID",
        nativeQuery = true)
    int updateStickerDetails(
        @Param("stickerID") int stickerID,
        @Param("stickerDesc") String stickerDesc,
        @Param("pointsReq") int pointsReq,
        @Param("filePath") String filePath
    );

    // Check if a sticker exists by name
    @Query(value = "SELECT COUNT(*) FROM STICKER WHERE stickerName = :stickerName", nativeQuery = true)
    int checkExistingSticker(@Param("stickerName") String stickerName);

    // Get sticker ID by name
    @Query(value = "SELECT stickerID FROM STICKER WHERE stickerName = :stickerName", nativeQuery = true)
    int getStickerIDByName(@Param("stickerName") String stickerName);

    // Get file path by sticker ID
    @Query(value = "SELECT file_path FROM STICKER WHERE stickerID = :stickerID", nativeQuery = true)
    String getFilePathByStickerID(@Param("stickerID") int stickerID);
}
