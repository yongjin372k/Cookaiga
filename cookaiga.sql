-- Cookaiga Database --

create database if not exists cookaiga;

use cookaiga;

-- USER TABLE -- 
CREATE TABLE IF NOT EXISTS USER (
	userID INT PRIMARY KEY auto_increment,
    username VARCHAR(50) NOT NULL,
    fullname VARCHAR(50),
    points INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- drop table user;
-- CREATE TABLE IF NOT EXISTS USER (
-- 	userID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
-- 	username VARCHAR(255) NOT NULL UNIQUE,
-- 	password_hash VARCHAR(255) NOT NULL,                         -- May not need if hardcode
-- 	role ENUM('consumer', 'admin') NOT NULL,
-- 	profile_pic_url VARCHAR(500),
-- 	description TEXT,                                                                        -- URL to user's profile picture (cloud storage URL like Azure)
-- 	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- );


-- INGREDIENTS TABLE --
drop table ingredients;
CREATE TABLE IF NOT EXISTS INGREDIENTS ( 				-- ** UNSURE IF NEED AN INGREDIENTS TABLE TO SHOW PICTURE
	foodID INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255) NOT NULL,                   				-- Name of ingredients (e.g. tomato, onion)
	food_pic_url VARCHAR(500), 							-- (Optional) URL of the image of the ingredient
);

-- KITCHEN TABLE --
drop table kitchen;
CREATE TABLE IF NOT EXISTS KITCHEN (							-- This is the MyKitchen, Processes current items ready for cooking
	kitchenID INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    kitchenList TEXT,
	userID INT NOT NULL,
	added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (userID) REFERENCES user(userID)
);
-- drop table kitchen;
-- CREATE TABLE IF NOT EXISTS KITCHEN (							-- This is the MyKitchen, keeps track of pantry items
-- 	kitchenID INT PRIMARY KEY AUTO_INCREMENT,
-- 	userID INT NOT NULL,
-- 	foodID INT NOT NULL,
-- 	quantity DECIMAL(10,2),									-- Amount of ingredients the user has (e.g. 250g of meat)
-- 	unit VARCHAR(50),										-- Unit of measurement (e.g. grams, pieces)
-- 	expiry_date DATE,
-- 	added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- 	FOREIGN KEY (userID) REFERENCES user(userID),
-- 	FOREIGN KEY (foodID) REFERENCES ingredients(foodID)
-- );

-- RECIPE TABLE --											-- NOT SURE, NOT IN USE
drop table recipe;
CREATE TABLE IF NOT EXISTS RECIPE (
	recipeID INT PRIMARY KEY AUTO_INCREMENT,
	kitchenID INT NOT NULL,
	foodID INT NOT NULL,
	recipeName VARCHAR(255) NOT NULL, 
	recipeDesc TEXT NOT NULL,
	recipeSteps TEXT NOT NULL,
	quantity DECIMAL(10,2),
	recipe_pic_url VARCHAR(500),
	FOREIGN KEY (kitchenID) REFERENCES kitchen(kitchenID),
	FOREIGN KEY (quantity) REFERENCES kitchen(quantity)
);

-- STICKER TABLE --								-- The Collection. Use Coins to Redeem
drop table sticker;
CREATE TABLE IF NOT EXISTS STICKER (
    stickerID INT PRIMARY KEY AUTO_INCREMENT,
    stickerName VARCHAR(100) NOT NULL,
    stickerDesc TEXT,
    points_required INT NOT NULL,
    file_path VARCHAR(255) 
);

-- REDEMPTION HISTORY TABLE --							-- Used to check relation between Users and Stickers. If a user has redeemed the sticker before.
drop table redemption;
CREATE TABLE IF NOT EXISTS REDEMPTION (
    redemptionID INT PRIMARY KEY AUTO_INCREMENT,
    userID INT NOT NULL,
    stickerID INT NOT NULL,
    redeemed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES USER(userID),
    FOREIGN KEY (stickerID) REFERENCES STICKER(stickerID)
);
