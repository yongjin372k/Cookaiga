package com.cookaiga.demo.services;

import com.cookaiga.demo.models.RedemptionHistory;
import com.cookaiga.demo.api.repository.RedemptionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class RedemptionService {

    @Autowired
    private RedemptionRepository redemptionRepository;

    // Add a new redemption (redeemedAt is auto-handled)
    public RedemptionHistory addRedemption(int userID, int stickerID) {
        RedemptionHistory redemption = new RedemptionHistory();
        redemption.setUserID(userID);
        redemption.setStickerID(stickerID);
        return redemptionRepository.save(redemption);
    }

    // Get all redemptions for a user
    public List<RedemptionHistory> getRedemptionsByUserID(int userID) {
        return redemptionRepository.getRedemptionsByUserID(userID);
    }

    // Check if a user has redeemed a specific sticker
    public boolean hasUserRedeemedSticker(int userID, int stickerID) {
        return redemptionRepository.hasUserRedeemedSticker(userID, stickerID) > 0;
    }

    // Get all sticker IDs redeemed by a user
    public List<Integer> getStickerIDsByUserID(int userID) {
        return redemptionRepository.getStickerIDsByUserID(userID);
    }

    // Find redemption by ID
    public Optional<RedemptionHistory> getRedemptionByID(int redemptionID) {
        return redemptionRepository.findById(redemptionID);
    }
}
