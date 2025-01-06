package com.cookaiga.demo.api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Repository;

import com.cookaiga.demo.models.Kitchen;

@Repository
public interface ImageAnalysisRepository extends JpaRepository<Kitchen, Integer> {

    @Transactional
    @Modifying
    @Query(value = "INSERT INTO KITCHEN (userID, kitchenList) " +
                   "VALUES (:userID, :kitchenList) " +
                   "ON DUPLICATE KEY UPDATE kitchenList = VALUES(kitchenList)", nativeQuery = true)
    int insertOrUpdateKitchenList(@Param("userID") int userID,
                                  @Param("kitchenList") String kitchenList);
}
