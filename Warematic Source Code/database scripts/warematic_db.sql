-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 07, 2020 at 06:02 AM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.2.27

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
CREATE DATABASE IF NOT EXISTS `warematic_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `warematic_db`;

-- --------------------------------------------------------

--
-- Table structure for table `t_bins`
--

CREATE TABLE `t_bins` (
  `ID_Bin` int(4) NOT NULL,
  `Description` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `t_bins`
--

INSERT INTO `t_bins` (`ID_Bin`, `Description`) VALUES
(1, 'B001'),
(2, 'B002'),
(3, 'B003'),
(4, 'B004'),
(5, 'B005'),
(6, 'B006'),
(7, 'B007'),
(8, 'B008'),
(9, 'B009'),
(10, 'B010'),
(11, 'B011'),
(12, 'B012'),
(13, 'B013'),
(14, 'B014'),
(15, 'B015'),
(16, 'B016'),
(17, 'B017'),
(18, 'B018'),
(19, 'B019'),
(20, 'B020'),
(21, 'B021'),
(22, 'B022'),
(23, 'B023'),
(24, 'B024'),
(25, 'B025'),
(26, 'B026'),
(27, 'B027'),
(28, 'B028'),
(29, 'B029'),
(30, 'B030'),
(31, 'B031'),
(32, 'B032'),
(33, 'B033'),
(34, 'B034'),
(35, 'B035'),
(36, 'B036'),
(37, 'B037'),
(38, 'B038'),
(39, 'B039'),
(40, 'B040'),
(41, 'B041'),
(42, 'B042'),
(43, 'B043'),
(44, 'B044'),
(45, 'B045'),
(46, 'B046'),
(47, 'B047'),
(48, 'B048'),
(49, 'B049'),
(50, 'B050');

-- --------------------------------------------------------

--
-- Table structure for table `t_goods_units`
--

CREATE TABLE `t_goods_units` (
  `ID_Good_Unit` int(11) NOT NULL,
  `Unit_Description` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `t_goods_units`
--

INSERT INTO `t_goods_units` (`ID_Good_Unit`, `Unit_Description`) VALUES
(1, 'Each'),
(2, 'Box(5)'),
(3, 'Box(10)'),
(4, 'Box(12)'),
(5, 'Package(5)'),
(6, 'Package(10)'),
(7, 'Package(15)');

-- --------------------------------------------------------

--
-- Table structure for table `t_goods_user`
--

CREATE TABLE `t_goods_user` (
  `SKU` varchar(8) NOT NULL,
  `Good_Description` varchar(60) NOT NULL,
  `ID_Good_Unit` int(11) DEFAULT NULL,
  `ID_Bin` int(11) DEFAULT NULL,
  `ID_Slot` int(11) DEFAULT NULL,
  `Available_Quantity` int(11) NOT NULL,
  `ID_User` int(11) NOT NULL,
  `IN_WAREHOUSE` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_location_rows`
--

CREATE TABLE `t_location_rows` (
  `ID_Row` int(4) NOT NULL,
  `Description` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `t_location_rows`
--

INSERT INTO `t_location_rows` (`ID_Row`, `Description`) VALUES
(1, 'Row 1'),
(2, 'Row 2'),
(3, 'Row 3'),
(4, 'Row 4'),
(5, 'Row 5'),
(6, 'Row 6'),
(7, 'Row 7'),
(8, 'Row 8'),
(9, 'Row 9'),
(10, 'Row 10');

-- --------------------------------------------------------

--
-- Table structure for table `t_location_slots`
--

CREATE TABLE `t_location_slots` (
  `ID_Slot` int(11) NOT NULL,
  `Description` varchar(20) NOT NULL,
  `ID_Row` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `t_location_slots`
--

INSERT INTO `t_location_slots` (`ID_Slot`, `Description`, `ID_Row`) VALUES
(1, 'Slot 1', 1),
(2, 'Slot 2', 1),
(3, 'Slot 3', 1),
(4, 'Slot 4', 1),
(5, 'Slot 5', 1),
(6, 'Slot 6', 1),
(7, 'Slot 7', 1),
(8, 'Slot 8', 1),
(9, 'Slot 9', 1),
(10, 'Slot 10', 1),
(11, 'Slot 11', 1),
(12, 'Slot 12', 1),
(13, 'Slot 13', 1),
(14, 'Slot 14', 1),
(15, 'Slot 15', 1),
(16, 'Slot 16', 1),
(17, 'Slot 17', 1),
(18, 'Slot 18', 1),
(19, 'Slot 19', 2),
(20, 'Slot 20', 2),
(21, 'Slot 21', 2),
(22, 'Slot 22', 2),
(23, 'Slot 23', 2),
(24, 'Slot 24', 2),
(25, 'Slot 25', 2),
(26, 'Slot 26', 2),
(27, 'Slot 27', 2),
(28, 'Slot 28', 2),
(29, 'Slot 29', 2),
(30, 'Slot 30', 2),
(31, 'Slot 31', 2),
(32, 'Slot 32', 2),
(33, 'Slot 33', 2),
(34, 'Slot 34', 2),
(35, 'Slot 35', 2),
(36, 'Slot 36', 2),
(37, 'Slot 37', 3),
(38, 'Slot 38', 3),
(39, 'Slot 39', 3),
(40, 'Slot 40', 3),
(41, 'Slot 41', 3),
(42, 'Slot 42', 3),
(43, 'Slot 43', 3),
(44, 'Slot 44', 3),
(45, 'Slot 45', 3),
(46, 'Slot 46', 3),
(47, 'Slot 47', 3),
(48, 'Slot 48', 3),
(49, 'Slot 49', 3),
(50, 'Slot 50', 3),
(51, 'Slot 51', 3),
(52, 'Slot 52', 3),
(53, 'Slot 53', 3),
(54, 'Slot 54', 3),
(55, 'Slot 55', 4),
(56, 'Slot 56', 4),
(57, 'Slot 57', 4),
(58, 'Slot 58', 4),
(59, 'Slot 59', 4),
(60, 'Slot 60', 4),
(61, 'Slot 61', 4),
(62, 'Slot 62', 4),
(63, 'Slot 63', 4),
(64, 'Slot 64', 4),
(65, 'Slot 65', 4),
(66, 'Slot 66', 4),
(67, 'Slot 67', 4),
(68, 'Slot 68', 4),
(69, 'Slot 69', 4),
(70, 'Slot 70', 4),
(71, 'Slot 71', 4),
(72, 'Slot 72', 4),
(73, 'Slot 73', 5),
(74, 'Slot 74', 5),
(75, 'Slot 75', 5),
(76, 'Slot 76', 5),
(77, 'Slot 77', 5),
(78, 'Slot 78', 5),
(79, 'Slot 79', 5),
(80, 'Slot 82', 5),
(81, 'Slot 81', 5),
(82, 'Slot 82', 5),
(83, 'Slot 83', 5),
(84, 'Slot 84', 5),
(85, 'Slot 85', 5),
(86, 'Slot 86', 5),
(87, 'Slot 87', 5),
(88, 'Slot 88', 5),
(89, 'Slot 89', 5),
(90, 'Slot 90', 5),
(91, 'Slot 91', 6);

-- --------------------------------------------------------

--
-- Table structure for table `t_orders`
--

CREATE TABLE `t_orders` (
  `ID_Order` int(11) NOT NULL,
  `ID_Order_Type` int(11) NOT NULL,
  `Order_Date` timestamp NOT NULL DEFAULT current_timestamp(),
  `Receiver_Name` varchar(60) DEFAULT NULL,
  `Street_Address` varchar(60) DEFAULT NULL,
  `House_Address` varchar(60) DEFAULT NULL,
  `City` varchar(50) DEFAULT NULL,
  `State` varchar(2) DEFAULT NULL,
  `ZipCode` varchar(5) DEFAULT NULL,
  `PickUp_Date` date DEFAULT NULL,
  `Delivery_Date` date DEFAULT NULL,
  `ID_User` int(11) NOT NULL,
  `ID_Order_Status` int(11) NOT NULL,
  `Order_Active` int(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_order_goods`
--

CREATE TABLE `t_order_goods` (
  `ID_Order` int(11) NOT NULL,
  `SKU` varchar(8) NOT NULL,
  `Quantity_Order` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_order_status`
--

CREATE TABLE `t_order_status` (
  `ID_Order_Status` int(11) NOT NULL,
  `Description` varchar(30) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `t_order_status`
--

INSERT INTO `t_order_status` (`ID_Order_Status`, `Description`) VALUES
(1, 'In Process'),
(2, 'Processed'),
(3, 'In Transit'),
(4, 'Received at Warehouse'),
(5, 'Received at destination'),
(6, 'Deleted');

-- --------------------------------------------------------

--
-- Table structure for table `t_order_tracking`
--

CREATE TABLE `t_order_tracking` (
  `ID_Order` int(11) NOT NULL,
  `Process_Date` date NOT NULL,
  `ID_Order_Status` int(11) NOT NULL,
  `ID_User` int(11) NOT NULL,
  `Order_Comments` varchar(60) DEFAULT NULL,
  `Time_Stamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_order_type`
--

CREATE TABLE `t_order_type` (
  `ID_Order_Type` int(11) NOT NULL,
  `Desc_Type` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `t_order_type`
--

INSERT INTO `t_order_type` (`ID_Order_Type`, `Desc_Type`) VALUES
(1, 'Picking Goods'),
(2, 'Delivery Goods');

-- --------------------------------------------------------

--
-- Table structure for table `t_slots_bins`
--

CREATE TABLE `t_slots_bins` (
  `ID_Slot` int(11) NOT NULL,
  `ID_Bin` int(4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_states`
--

CREATE TABLE `t_states` (
  `ID_State` char(2) NOT NULL,
  `State_Desc` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `t_states`
--

INSERT INTO `t_states` (`ID_State`, `State_Desc`) VALUES
('AL', 'Alabama'),
('AK', 'Alaska'),
('AZ', 'Arizona'),
('AR', 'Arkansas'),
('CA', 'California'),
('CO', 'Colorado'),
('CT', 'Conneticut'),
('DE', 'Delaware'),
('FL', 'Florida'),
('GA', 'Georgia'),
('HI', 'Hawaii'),
('ID', 'Idaho'),
('IL', 'Ilinois'),
('IN', 'Indianapolis'),
('IA', 'Iowa'),
('KS', 'Kansas'),
('KY', 'Kentucky'),
('LA', 'Louisiana'),
('ME', 'Maine'),
('MD', 'Maryland'),
('MA', 'Massachusetts'),
('MI', 'Michigan'),
('MN', 'Minnesota'),
('MS', 'Mississippi'),
('MO', 'Missouri'),
('MT', 'Montana'),
('NE', 'Nebraska'),
('NV', 'Nevada'),
('NH', 'New Hampshire'),
('NJ', 'New Jersey'),
('NM', 'New Mexico'),
('NY', 'New York'),
('NC', 'North Carolina'),
('ND', 'North Dakota'),
('OH', 'Ohio'),
('OK', 'Oklahoma City'),
('OR', 'Oregon'),
('PA', 'Pennsilvania'),
('RI', 'Rhode Island'),
('SC', 'South Carolina'),
('SD', 'South Dakota'),
('TN', 'Tennesse'),
('TX', 'Texas'),
('UT', 'Utah'),
('VT', 'Vermont'),
('WA', 'Washington'),
('WV', 'West Virginia'),
('WI', 'Wisconsin'),
('WY', 'Wyoming');

-- --------------------------------------------------------

--
-- Table structure for table `t_token_email`
--

CREATE TABLE `t_token_email` (
  `Token` varchar(100) DEFAULT NULL,
  `User_Email` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_users`
--

CREATE TABLE `t_users` (
  `ID_User` int(11) NOT NULL,
  `User_Name` varchar(100) NOT NULL,
  `User_Password` varchar(100) NOT NULL,
  `User_FirstName` varchar(50) NOT NULL,
  `User_LastName` varchar(50) NOT NULL,
  `User_Phone` varchar(15) DEFAULT NULL,
  `Street_Address` varchar(60) DEFAULT NULL,
  `House_Address` varchar(60) DEFAULT NULL,
  `City` varchar(50) DEFAULT NULL,
  `State` varchar(2) DEFAULT NULL,
  `ZipCode` varchar(5) DEFAULT NULL,
  `Register_Date` timestamp NOT NULL DEFAULT current_timestamp(),
  `Profile_ID` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_users_profiles`
--

CREATE TABLE `t_users_profiles` (
  `Profile_ID` int(11) NOT NULL,
  `Profile_Description` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `t_users_profiles`
--

INSERT INTO `t_users_profiles` (`Profile_ID`, `Profile_Description`) VALUES
(1, 'Warehouse Admin'),
(2, 'Warehouse Clerk'),
(3, 'Runner'),
(4, 'General Customer');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_completed_orders`
-- (See below for the actual view)
--
CREATE TABLE `v_completed_orders` (
`ID_Order` int(11)
,`ID_User` int(11)
,`ID_Order_Type` int(11)
,`Desc_Type` varchar(20)
,`Order_Date` timestamp
,`Order_Date_F` varchar(10)
,`ID_Order_Status` int(11)
,`Order_Status` varchar(30)
,`Order_Active` int(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_goods_user`
-- (See below for the actual view)
--
CREATE TABLE `v_goods_user` (
`SKU` varchar(8)
,`GOOD_DESC` varchar(60)
,`ID_BIN` int(11)
,`BIN_DESC` varchar(20)
,`ID_SLOT` int(11)
,`SLOT_DESC` varchar(41)
,`ID_GOOD_UNIT` int(11)
,`UNIT_DESC` varchar(20)
,`AVAI_QUAN` int(11)
,`ID_USER` int(11)
,`IN_Warehouse` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_slots_occupied`
-- (See below for the actual view)
--
CREATE TABLE `v_slots_occupied` (
`ID_Slot` int(11)
,`Count_Slot` bigint(21)
,`Full_Slot` varchar(1)
);

-- --------------------------------------------------------

--
-- Structure for view `v_completed_orders`
--
DROP TABLE IF EXISTS `v_completed_orders`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_completed_orders`  AS  select `o`.`ID_Order` AS `ID_Order`,`o`.`ID_User` AS `ID_User`,`o`.`ID_Order_Type` AS `ID_Order_Type`,`ot`.`Desc_Type` AS `Desc_Type`,`o`.`Order_Date` AS `Order_Date`,concat(month(`o`.`Order_Date`),'-',dayofmonth(`o`.`Order_Date`),'-',year(`o`.`Order_Date`)) AS `Order_Date_F`,`o`.`ID_Order_Status` AS `ID_Order_Status`,if(`o`.`Order_Active` = 1,`s`.`Description`,'Deleted') AS `Order_Status`,`o`.`Order_Active` AS `Order_Active` from ((`t_orders` `o` join `t_order_type` `ot` on(`o`.`ID_Order_Type` = `ot`.`ID_Order_Type`)) join `t_order_status` `s` on(`o`.`ID_Order_Status` = `s`.`ID_Order_Status`)) where (`o`.`ID_Order_Status` = 4 or `o`.`ID_Order_Status` = 5) and `o`.`Order_Active` = 1 or `o`.`Order_Active` = 0 ;

-- --------------------------------------------------------

--
-- Structure for view `v_goods_user`
--
DROP TABLE IF EXISTS `v_goods_user`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_goods_user`  AS  select `gu`.`SKU` AS `SKU`,`gu`.`Good_Description` AS `GOOD_DESC`,`gu`.`ID_Bin` AS `ID_BIN`,`b`.`Description` AS `BIN_DESC`,`gu`.`ID_Slot` AS `ID_SLOT`,concat(`r`.`Description`,' ',`s`.`Description`) AS `SLOT_DESC`,`gu`.`ID_Good_Unit` AS `ID_GOOD_UNIT`,`u`.`Unit_Description` AS `UNIT_DESC`,`gu`.`Available_Quantity` AS `AVAI_QUAN`,`gu`.`ID_User` AS `ID_USER`,`gu`.`IN_WAREHOUSE` AS `IN_Warehouse` from ((((`t_goods_user` `gu` join `t_goods_units` `u` on(`gu`.`ID_Good_Unit` = `u`.`ID_Good_Unit`)) join `t_bins` `b` on(`gu`.`ID_Bin` = `b`.`ID_Bin`)) join `t_location_slots` `s` on(`gu`.`ID_Slot` = `s`.`ID_Slot`)) join `t_location_rows` `r` on(`s`.`ID_Row` = `r`.`ID_Row`)) order by `b`.`ID_Bin` ;

-- --------------------------------------------------------

--
-- Structure for view `v_slots_occupied`
--
DROP TABLE IF EXISTS `v_slots_occupied`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_slots_occupied`  AS  select `t_slots_bins`.`ID_Slot` AS `ID_Slot`,count(`t_slots_bins`.`ID_Slot`) AS `Count_Slot`,if(count(`t_slots_bins`.`ID_Slot`) = 3,'1','0') AS `Full_Slot` from `t_slots_bins` group by `t_slots_bins`.`ID_Slot` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `t_bins`
--
ALTER TABLE `t_bins`
  ADD PRIMARY KEY (`ID_Bin`);

--
-- Indexes for table `t_goods_units`
--
ALTER TABLE `t_goods_units`
  ADD PRIMARY KEY (`ID_Good_Unit`);

--
-- Indexes for table `t_goods_user`
--
ALTER TABLE `t_goods_user`
  ADD PRIMARY KEY (`SKU`),
  ADD KEY `SKU` (`SKU`),
  ADD KEY `ID_Good_Unit` (`ID_Good_Unit`),
  ADD KEY `ID_Bin` (`ID_Bin`),
  ADD KEY `ID_Slot` (`ID_Slot`),
  ADD KEY `ID_User` (`ID_User`);

--
-- Indexes for table `t_location_rows`
--
ALTER TABLE `t_location_rows`
  ADD PRIMARY KEY (`ID_Row`);

--
-- Indexes for table `t_location_slots`
--
ALTER TABLE `t_location_slots`
  ADD PRIMARY KEY (`ID_Slot`),
  ADD KEY `ID_Row` (`ID_Row`);

--
-- Indexes for table `t_orders`
--
ALTER TABLE `t_orders`
  ADD PRIMARY KEY (`ID_Order`),
  ADD KEY `ID_Order` (`ID_Order`),
  ADD KEY `fk_orderType` (`ID_Order_Type`),
  ADD KEY `fk_user` (`ID_User`),
  ADD KEY `fk_orderStatus` (`ID_Order_Status`);

--
-- Indexes for table `t_order_goods`
--
ALTER TABLE `t_order_goods`
  ADD PRIMARY KEY (`ID_Order`,`SKU`),
  ADD KEY `SKU` (`SKU`);

--
-- Indexes for table `t_order_status`
--
ALTER TABLE `t_order_status`
  ADD PRIMARY KEY (`ID_Order_Status`);

--
-- Indexes for table `t_order_tracking`
--
ALTER TABLE `t_order_tracking`
  ADD PRIMARY KEY (`ID_Order`,`Process_Date`,`ID_Order_Status`),
  ADD KEY `ID_Order` (`ID_Order`),
  ADD KEY `fk_orderStatus` (`ID_Order_Status`),
  ADD KEY `fk_user` (`ID_User`);

--
-- Indexes for table `t_order_type`
--
ALTER TABLE `t_order_type`
  ADD PRIMARY KEY (`ID_Order_Type`);

--
-- Indexes for table `t_slots_bins`
--
ALTER TABLE `t_slots_bins`
  ADD PRIMARY KEY (`ID_Slot`,`ID_Bin`),
  ADD KEY `ID_Bin` (`ID_Bin`);

--
-- Indexes for table `t_states`
--
ALTER TABLE `t_states`
  ADD PRIMARY KEY (`ID_State`);

--
-- Indexes for table `t_users`
--
ALTER TABLE `t_users`
  ADD PRIMARY KEY (`ID_User`,`User_Name`),
  ADD KEY `User_Name` (`User_Name`),
  ADD KEY `Profile_ID` (`Profile_ID`);

--
-- Indexes for table `t_users_profiles`
--
ALTER TABLE `t_users_profiles`
  ADD PRIMARY KEY (`Profile_ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `t_bins`
--
ALTER TABLE `t_bins`
  MODIFY `ID_Bin` int(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `t_goods_units`
--
ALTER TABLE `t_goods_units`
  MODIFY `ID_Good_Unit` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `t_location_rows`
--
ALTER TABLE `t_location_rows`
  MODIFY `ID_Row` int(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `t_location_slots`
--
ALTER TABLE `t_location_slots`
  MODIFY `ID_Slot` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT for table `t_orders`
--
ALTER TABLE `t_orders`
  MODIFY `ID_Order` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `t_order_status`
--
ALTER TABLE `t_order_status`
  MODIFY `ID_Order_Status` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `t_order_type`
--
ALTER TABLE `t_order_type`
  MODIFY `ID_Order_Type` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `t_users`
--
ALTER TABLE `t_users`
  MODIFY `ID_User` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `t_users_profiles`
--
ALTER TABLE `t_users_profiles`
  MODIFY `Profile_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
