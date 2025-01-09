package com.cookaiga.demo.api.service;

import com.cookaiga.demo.models.RedemptionHistory;
import com.cookaiga.demo.models.User;
import com.cookaiga.demo.models.Sticker;
import com.cookaiga.demo.api.repository.RedemptionRepository;
import com.cookaiga.demo.api.repository.UserRepository;
import com.cookaiga.demo.api.repository.StickerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class RedemptionService {

    @Autowired
    private RedemptionRepository redemptionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StickerRepository stickerRepository;

    // Add a new redemption (with points validation)
    public RedemptionHistory addRedemption(int userID, int stickerID) {
        // Fetch the user and sticker details
        User user = userRepository.findById(userID)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userID));
        Sticker sticker = stickerRepository.findById(stickerID)
                .orElseThrow(() -> new RuntimeException("Sticker not found with ID: " + stickerID));

        // Check if the user has enough points
        if (user.getPoints() < sticker.getPointsReq()) {
            throw new RuntimeException("User does not have enough points to redeem this sticker.");
        }

        // Deduct points from the user
        user.setPoints(user.getPoints() - sticker.getPointsReq());
        userRepository.save(user);

        // Add the redemption
        RedemptionHistory redemption = new RedemptionHistory();
        redemption.setUserID(userID);
        redemption.setStickerID(stickerID);
        redemption.setRedeemedAt(LocalDateTime.now());
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
