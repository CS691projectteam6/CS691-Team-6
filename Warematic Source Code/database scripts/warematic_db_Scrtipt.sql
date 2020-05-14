USE warematic_db;

-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: March 29, 2020 at 23:49 PM
-- Server version: 10.1.36-MariaDB
-- PHP Version: 7.2.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `warematic_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `T_Users_Profiles`
--

CREATE TABLE `T_Users_Profiles` (
    `Profile_ID` INT NOT NULL AUTO_INCREMENT, 
    `Profile_Description` VARCHAR(50) NOT NULL,
    
    PRIMARY KEY(Profile_ID)

) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Order_Type`
--

CREATE TABLE `T_Order_Type` (
    `ID_Order_Type` INT NOT NULL AUTO_INCREMENT, 
    `Desc_Type` VARCHAR(20) NOT NULL,
    
    PRIMARY KEY(ID_Order_Type)

) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Order_Status`
--

CREATE TABLE `T_Order_Status` (
    `ID_Order_Status` INT NOT NULL AUTO_INCREMENT, 
    `Description` VARCHAR(30) NOT NULL,
    
    PRIMARY KEY(ID_Order_Status)

) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_States`
--

CREATE TABLE `T_States` (
    `ID_State` CHAR(2), 
    `State_Desc` VARCHAR(30),
    
    PRIMARY KEY(ID_State)

) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Goods_Units`
--

CREATE TABLE `T_Goods_Units` (
    `ID_Good_Unit` INT NOT NULL AUTO_INCREMENT, 
    `Unit_Description` VARCHAR(20) NOT NULL,
    
    PRIMARY KEY(ID_Good_Unit)

) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Bins`
--

CREATE TABLE `T_Bins` (
    `ID_Bin` INT(4) NOT NULL AUTO_INCREMENT, 
    `Description` VARCHAR(20) NOT NULL,
    
    PRIMARY KEY(ID_Bin)

) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Location_Rows`
--

CREATE TABLE `T_Location_Rows` (
    `ID_Row` INT NOT NULL AUTO_INCREMENT, 
    `Description` VARCHAR(20) NOT NULL,
    
    PRIMARY KEY(ID_Row)

) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Location_Slots`
--

CREATE TABLE `T_Location_Slots` (
    `ID_Slot` INT NOT NULL AUTO_INCREMENT, 
    `Description` VARCHAR(20) NOT NULL,
    `ID_Row` INT NOT NULL,
    
    PRIMARY KEY(ID_Slot),
    FOREIGN KEY (ID_Row)
        REFERENCES T_Location_Rows(ID_Row)

) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Slots_Bins`
--

CREATE TABLE `T_Slots_Bins` (
    `ID_Slot` INT NOT NULL, 
    `ID_Bin` INT NOT NULL,
    
    PRIMARY KEY(ID_Slot, ID_Bin),
    
    FOREIGN KEY (ID_Slot)
        REFERENCES T_Location_Slots(ID_Slot),
	
    FOREIGN KEY (ID_Bin)
        REFERENCES T_Bins(ID_Bin)


) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Users`
--

CREATE TABLE `T_Users` (
    `ID_User` INT NOT NULL AUTO_INCREMENT, 
    `User_Name` VARCHAR(100) NOT NULL,
    `User_Password` VARCHAR(100) NOT NULL,
    `User_FirstName` VARCHAR(50) NOT NULL,
    `User_LastName`  VARCHAR(50) NOT NULL,
    `User_Phone`  VARCHAR(15),
    `Street_Address`  VARCHAR(60),
    `House_Address`  VARCHAR(60),
    `City`  VARCHAR(50),
    `State`  VARCHAR(2),
    `ZipCode`  VARCHAR(5),
    `Register_Date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `Profile_ID`  INT NOT NULL,
    
     PRIMARY KEY(ID_User, User_Name),
     INDEX (User_Name),
     
     FOREIGN KEY (Profile_ID)
        REFERENCES T_Users_Profiles(Profile_ID)
     
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Goods_User`
--

CREATE TABLE `T_Goods_User` (
    `SKU` VARCHAR(8) NOT NULL, 
    `Good_Description` VARCHAR(60) NOT NULL,
    `ID_Good_Unit` INT,
    `ID_Bin` INT,
    `ID_Slot`  INT,
    `Available_Quantity`  INT NOT NULL,
    `ID_User`  INT NOT NULL,
    `IN_WAREHOUSE` INT,
     
     PRIMARY KEY(SKU),
     INDEX (SKU),
     
	FOREIGN KEY (ID_Good_Unit)
        REFERENCES T_Goods_Units(ID_Good_Unit),
	
    FOREIGN KEY (ID_Bin)
        REFERENCES T_Bins(ID_Bin),
	
    FOREIGN KEY (ID_Slot)
        REFERENCES T_Location_Slots(ID_Slot),
	
    FOREIGN KEY (ID_User)
        REFERENCES T_Users(ID_User)
     
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `T_Orders`
--

CREATE TABLE `T_Orders` (
	`ID_Order` INT NOT NULL AUTO_INCREMENT,
    `ID_Order_Type` INT NOT NULL,
    `Order_Date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `Receiver_Name` VARCHAR(60),
	`Street_Address`  VARCHAR(60),
    `House_Address`  VARCHAR(60),
    `City`  VARCHAR(50),
    `State`  VARCHAR(2),
    `ZipCode`  VARCHAR(5),
    `PickUp_Date` DATE,
    `Delivery_Date` DATE,
    `ID_User`  INT NOT NULL,
    `ID_Order_Status`  INT NOT NULL,
    
    PRIMARY KEY(ID_Order),
	INDEX (ID_Order),
    
    CONSTRAINT fk_orderType
    FOREIGN KEY (ID_Order_Type)
        REFERENCES T_Order_Type(ID_Order_Type),
    
    CONSTRAINT fk_user
    FOREIGN KEY (ID_User)
        REFERENCES T_Users(ID_User),
	
    CONSTRAINT fk_orderStatus
    FOREIGN KEY (ID_Order_Status)
        REFERENCES T_Order_Status(ID_Order_Status)
    
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `T_Order_Goods`
--
CREATE TABLE `T_Order_Goods` (
    `ID_Order` INT NOT NULL, 
    `SKU` VARCHAR(8) NOT NULL,
    `Quantity_Order` INT NOT NULL,
    
    CONSTRAINT PK_Order_Goods PRIMARY KEY(ID_Order, SKU),
    
    FOREIGN KEY (ID_Order)
        REFERENCES T_Orders(ID_Order),
	
    FOREIGN KEY (SKU)
        REFERENCES T_Goods_User(SKU)


) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `T_Order_Tracking`
--

CREATE TABLE `T_Order_Tracking` (
    `ID_Order` INT NOT NULL, 
    `Process_Date` DATE NOT NULL,
    `ID_Order_Status` INT NOT NULL,
    `ID_User` INT NOT NULL,
    `Order_Comments` VARCHAR(60),
    `Time_Stamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
         
     PRIMARY KEY(ID_Order, Process_Date, ID_Order_Status),
     INDEX (ID_Order),
     
	CONSTRAINT fk_order
	FOREIGN KEY (ID_Order)
        REFERENCES T_Orders(ID_Order),
    
    CONSTRAINT fk_orderStatus
    FOREIGN KEY (ID_Order_Status)
        REFERENCES T_Order_Status(ID_Order_Status),
	
    CONSTRAINT fk_user
    FOREIGN KEY (ID_User)
        REFERENCES T_Users(ID_User)
      
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- CREATE VIEW v_goods_user
--

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_goods_user` AS
    SELECT 
        `gu`.`SKU` AS `SKU`,
        `gu`.`Good_Description` AS `GOOD_DESC`,
        `gu`.`ID_Bin` AS `ID_BIN`,
        `b`.`Description` AS `BIN_DESC`,
        `gu`.`ID_Slot` AS `ID_SLOT`,
        CONCAT(`r`.`Description`,
                ' ',
                `s`.`Description`) AS `SLOT_DESC`,
        `gu`.`ID_Good_Unit` AS `ID_GOOD_UNIT`,
        `u`.`Unit_Description` AS `UNIT_DESC`,
        `gu`.`Available_Quantity` AS `AVAI_QUAN`,
        `gu`.`ID_User` AS `ID_USER`,
        `gu`.`IN_WAREHOUSE` AS `IN_Warehouse`
    FROM
        ((((`t_goods_user` `gu`
        JOIN `t_goods_units` `u` ON (`gu`.`ID_Good_Unit` = `u`.`ID_Good_Unit`))
        JOIN `t_bins` `b` ON (`gu`.`ID_Bin` = `b`.`ID_Bin`))
        JOIN `t_location_slots` `s` ON (`gu`.`ID_Slot` = `s`.`ID_Slot`))
        JOIN `t_location_rows` `r` ON (`s`.`ID_Row` = `r`.`ID_Row`))
    ORDER BY `b`.`ID_Bin`;


--
-- Dumping data for table `T_Order_Type`
--
INSERT INTO `T_Order_Type` (`Desc_Type`) VALUES ('Picking Goods'), ('Delivery Goods');

--
-- Dumping data for table `T_Users_Profiles`
--
INSERT INTO `T_Users_Profiles` (`Profile_Description`) VALUES ('Warehouse Admin'), ('Warehouse Clerk'), ('Runner'), ('General Customer');

--
-- Dumping data for table `T_Order_Status`
--
INSERT INTO `T_Order_Status` (`Description`) 
VALUES 
('In Process'), ('Processed'), ('In Transit'), ('Received at Warehouse'), ('Received at destination');

--
-- Dumping data for table `T_Goods_Units`
--
INSERT INTO `T_Goods_Units` (`Unit_Description`) 
VALUES 
('Each'), ('Box(5)'), ('Box(10)'), ('Box(12)'), ('Package(5)'), ('Package(10)'), ('Package(15)');

--
-- Dumping data for table `T_Bins`
--
INSERT INTO `T_Bins` (`Description`) 
VALUES 
('B001'), ('B002'), ('B003'), ('B004'), ('B005'), ('B006'), ('B007'), ('B008'), ('B009'), ('B010'),
('B011'), ('B012'), ('B013'), ('B014'), ('B015'), ('B016'), ('B017'), ('B018'), ('B019'), ('B020'),
('B021'), ('B022'), ('B023'), ('B024'), ('B025'), ('B026'), ('B027'), ('B028'), ('B029'), ('B030'),
('B031'), ('B032'), ('B033'), ('B034'), ('B035'), ('B036'), ('B037'), ('B038'), ('B039'), ('B040'),
('B041'), ('B042'), ('B043'), ('B044'), ('B045'), ('B046'), ('B047'), ('B048'), ('B049'), ('B050');

--
-- Dumping data for table `T_Location_Rows`
--
INSERT INTO `T_Location_Rows` (`Description`) 
VALUES 
('Row 1'), ('Row 2'), ('Row 3'), ('Row 4'), ('Row 5'), ('Row 6'), ('Row 7'), ('Row 8'), ('Row 9'), ('Row 10');

--
-- Dumping data for table `T_Location_Slots`
--
INSERT INTO `T_Location_Slots` (`Description`, `ID_Row`)
VALUES
('Slot 1', 1),('Slot 2', 1),('Slot 3', 1),('Slot 4', 1),('Slot 5', 1),('Slot 6', 1),
('Slot 7', 1),('Slot 8', 1),('Slot 9', 1),('Slot 10', 1),('Slot 11', 1),('Slot 12', 1),
('Slot 13', 1),('Slot 14', 1),('Slot 15', 1),('Slot 16', 1),('Slot 17', 1),('Slot 18', 1),
('Slot 19', 2),('Slot 20', 2),('Slot 21', 2),('Slot 22', 2),('Slot 23', 2),('Slot 24', 2),
('Slot 25', 2),('Slot 26', 2),('Slot 27', 2),('Slot 28', 2),('Slot 29', 2),('Slot 30', 2),
('Slot 31', 2),('Slot 32', 2),('Slot 33', 2),('Slot 34', 2),('Slot 35', 2),('Slot 36', 2),
('Slot 37', 3),('Slot 38', 3),('Slot 39', 3),('Slot 40', 3),('Slot 41', 3),('Slot 42', 3),
('Slot 43', 3),('Slot 44', 3),('Slot 45', 3),('Slot 46', 3),('Slot 47', 3),('Slot 48', 3),
('Slot 49', 3),('Slot 50', 3),('Slot 51', 3),('Slot 52', 3),('Slot 53', 3),('Slot 54', 3),
('Slot 55', 4),('Slot 56', 4),('Slot 57', 4),('Slot 58', 4),('Slot 59', 4),('Slot 60', 4),
('Slot 61', 4),('Slot 62', 4),('Slot 63', 4),('Slot 64', 4),('Slot 65', 4),('Slot 66', 4),
('Slot 67', 4),('Slot 68', 4),('Slot 69', 4),('Slot 70', 4),('Slot 71', 4),('Slot 72', 4),
('Slot 73', 5),('Slot 74', 5),('Slot 75', 5),('Slot 76', 5),('Slot 77', 5),('Slot 78', 5),
('Slot 79', 5),('Slot 82', 5),('Slot 81', 5),('Slot 82', 5),('Slot 83', 5),('Slot 84', 5),
('Slot 85', 5),('Slot 86', 5),('Slot 87', 5),('Slot 88', 5),('Slot 89', 5),('Slot 90', 5);

--
-- Dumping data for table `T_States`
--
INSERT INTO `T_States` (`ID_State`, `State_Desc`) VALUES
('AL', 'Alabama'), ('AK', 'Alaska'), ('AZ', 'Arizona'), ('AR', 'Arkansas'), ('CA', 'California'),
('CO', 'Colorado'), ('CT', 'Conneticut'), ('DE', 'Delaware'), ('FL', 'Florida'), ('GA', 'Georgia'),
('HI', 'Hawaii'), ('ID', 'Idaho'), ('IL', 'Illinois'), ('IN', 'Indianapolis'), ('IA', 'Iowa'),
('KS', 'Kansas'), ('KY', 'Kentucky'), ('LA', 'Louisiana'), ('ME', 'Maine'), ('MD', 'Maryland'),
('MA', 'Massachusetts'), ('MI', 'Michigan'), ('MN', 'Minnesota'), ('MS', 'Mississippi'), ('MO', 'Missouri'),
('MT', 'Montana'), ('NE', 'Nebraska'), ('NV', 'Nevada'), ('NH', 'New Hampshire'), ('NJ', 'New Jersey'),
('NM', 'New Mexico'), ('NY', 'New York'), ('NC', 'North Carolina'), ('ND', 'North Dakota'), ('OH', 'Ohio'),
('OK', 'Oklahoma City'), ('OR', 'Oregon'), ('PA', 'Pennsilvania'), ('RI', 'Rhode Island'), ('SC', 'South Carolina'),
('SD', 'South Dakota'), ('TN', 'Tennesse'), ('TX', 'Texas'), ('UT', 'Utah'), ('VT', 'Vermont'),
('WA', 'Washington'), ('WV', 'West Virginia'), ('WI', 'Wisconsin'), ('WY', 'Wyoming');

-- --------------------------------------------------------

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT   */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION   */;
