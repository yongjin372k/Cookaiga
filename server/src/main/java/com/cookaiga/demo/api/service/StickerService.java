package com.cookaiga.demo.api.service;

import com.cookaiga.demo.models.Sticker;
import com.cookaiga.demo.models.User;
import com.cookaiga.demo.api.repository.RedemptionRepository;
import com.cookaiga.demo.api.repository.StickerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Random;

@Service
public class StickerService {

    @Autowired
    private StickerRepository stickerRepository;

    @Autowired
    private RedemptionRepository redemptionRepository;

    @Autowired
    private UserService userService;

    // Retrieve all stickers
    public List<Sticker> getAllStickers() {
        return stickerRepository.findAll();
    }

    // Retrieve a single sticker by ID
    public Optional<Sticker> getStickerById(int stickerID) {
        return stickerRepository.findById(stickerID);
    }

    // Add a new sticker
    public Sticker addSticker(Sticker sticker) {
        return stickerRepository.save(sticker);
    }

    // Update an existing sticker
    public Sticker updateSticker(int stickerID, Sticker stickerDetails) {
        return stickerRepository.findById(stickerID).map(sticker -> {
            sticker.setStickerName(stickerDetails.getStickerName());
            sticker.setStickerDesc(stickerDetails.getStickerDesc());
            sticker.setPointsReq(stickerDetails.getPointsReq());
            sticker.setFilePath(stickerDetails.getFilePath());
            return stickerRepository.save(sticker);
        }).orElseThrow(() -> new RuntimeException("Sticker not found with ID: " + stickerID));
    }

    // Get stickers by UserID
    public List<Sticker> getStickersByUserID(int userID) {
        System.out.println("UserID to get Stickers: " + userID);
        return stickerRepository.findStickersByUserID(userID);
    }

    // Delete a sticker by ID
    public void deleteSticker(int stickerID) {
        stickerRepository.deleteById(stickerID);
    }

    // Get a random sticker for the user and deduct points
    public Sticker getRandomStickerForUser(int userID) {
        // Get all stickers that the user does not own
        var unownedStickers = stickerRepository.findUnownedStickersByUserId(userID);

        if (unownedStickers.isEmpty()) {
            throw new RuntimeException("No stickers available for the user.");
        }

        // Select a random sticker from the unowned stickers
        Random random = new Random();
        Sticker randomSticker = unownedStickers.get(random.nextInt(unownedStickers.size()));

        // Deduct 60 points from the user's points
        User user = userService.getUserById(userID).orElseThrow(() -> new RuntimeException("User not found with ID: " + userID));

        if (user.getPoints() < 60) {
            throw new RuntimeException("Insufficient points. User has only " + user.getPoints() + " points.");
        }

        userService.updateUserPoints(userID, -60);

        // Update the redemption table to show the user owns this sticker
        redemptionRepository.addRedemption(userID, randomSticker.getStickerID());

        return randomSticker;
    }
}
