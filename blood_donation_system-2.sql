-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 17, 2023 at 12:33 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `blood_donation_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `adminLogin`
--

CREATE TABLE `adminLogin` (
  `adminId` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `adminLogin`
--

INSERT INTO `adminLogin` (`adminId`, `username`, `password`) VALUES
(4, 'muhammadSunaam', 'c00a524b91ec59b494c87a7665f0153c'),
(5, 'shehroz', '81dc9bdb52d04dc20036dbd8313ed055'),
(6, 'sunaam', '81dc9bdb52d04dc20036dbd8313ed055');

-- --------------------------------------------------------

--
-- Table structure for table `BloodBank`
--

CREATE TABLE `BloodBank` (
  `BloodBankId` int(11) NOT NULL,
  `BloodBankName` varchar(50) DEFAULT NULL,
  `BloodBankAddress` varchar(50) DEFAULT NULL,
  `BloodBankContact` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `BloodBank`
--

INSERT INTO `BloodBank` (`BloodBankId`, `BloodBankName`, `BloodBankAddress`, `BloodBankContact`) VALUES
(1, 'Red Cross Blood Bank', '123 Main St', '123-456-890'),
(2, 'BloodCare Foundation', '456 Park Ave', '987-654-210'),
(3, 'BloodLife Institute', '789 Maple St', '111-222-333'),
(4, 'LifeBlood Services', '321 Maple St', '444-555-666'),
(5, 'BloodNet', '654 Park Ave', '777-888-999'),
(6, 'BloodWorks', '987 Main St', '111-222-333'),
(10, 'Taha Blood Bank', 'GWA', '001');

-- --------------------------------------------------------

--
-- Stand-in structure for view `bloodbanktopatient`
-- (See below for the actual view)
--
CREATE TABLE `bloodbanktopatient` (
`BloodBankName` varchar(50)
,`BloodBankId` int(11)
,`QuantityRecieved` int(11)
,`DateRecieved` date
,`PatientId` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `BloodStock`
--

CREATE TABLE `BloodStock` (
  `BloodId` int(11) NOT NULL,
  `BloodGroup` varchar(3) DEFAULT NULL,
  `Quantity` int(11) NOT NULL,
  `BloodBankID` int(11) NOT NULL,
  `DonorID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `BloodStock`
--

INSERT INTO `BloodStock` (`BloodId`, `BloodGroup`, `Quantity`, `BloodBankID`, `DonorID`) VALUES
(24, 'O+', 300, 10, 12);

-- --------------------------------------------------------

--
-- Table structure for table `DonationHistory`
--

CREATE TABLE `DonationHistory` (
  `HistoryId` int(11) NOT NULL,
  `TransfusionDate` date DEFAULT NULL,
  `BloodGroup` varchar(3) NOT NULL,
  `PatientId` int(11) DEFAULT NULL,
  `BloodBankId` int(11) DEFAULT NULL,
  `DonorId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `DonationHistory`
--

INSERT INTO `DonationHistory` (`HistoryId`, `TransfusionDate`, `BloodGroup`, `PatientId`, `BloodBankId`, `DonorId`) VALUES
(11, '2022-12-30', 'O+', 1, 2, NULL),
(12, '2023-01-06', 'O+', 1, 10, NULL);

--
-- Triggers `DonationHistory`
--
DELIMITER $$
CREATE TRIGGER `datetriggerDH` BEFORE INSERT ON `DonationHistory` FOR EACH ROW BEGIN
    IF NEW.TransfusionDate > CURDATE() THEN
      SET NEW.transfusiondate = CURDATE();
    End if; 
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `DonationToBank`
--

CREATE TABLE `DonationToBank` (
  `BloodBankId` int(11) DEFAULT NULL,
  `DonorId` int(11) DEFAULT NULL,
  `DonationId` int(11) NOT NULL,
  `DateDonated` date NOT NULL,
  `QuantityDonated` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `DonationToBank`
--

INSERT INTO `DonationToBank` (`BloodBankId`, `DonorId`, `DonationId`, `DateDonated`, `QuantityDonated`) VALUES
(2, 1, 31, '2022-12-30', 120),
(1, 1, 32, '2022-12-30', 120),
(10, 12, 33, '2023-01-06', 300);

--
-- Triggers `DonationToBank`
--
DELIMITER $$
CREATE TRIGGER `check_date_trigger` BEFORE INSERT ON `DonationToBank` FOR EACH ROW BEGIN
    IF NEW.datedonated > CURDATE() THEN
      SET NEW.datedonated = CURDATE();
    End if; 
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_into_bloodstock` AFTER INSERT ON `DonationToBank` FOR EACH ROW BEGIN
  INSERT INTO BloodStock (DonorId, BloodGroup, Quantity, BloodBankID)
  SELECT DonorId, NULL, QuantityDonated, DonationToBank.BloodBankId
  FROM DonationToBank
  WHERE DonationId = NEW.DonationId;

  UPDATE BloodStock
  SET BloodGroup = (SELECT BloodGroup FROM Donor WHERE DonorId = NEW.DonorId)
  WHERE DonorId = NEW.DonorId;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Donor`
--

CREATE TABLE `Donor` (
  `DonorId` int(11) NOT NULL,
  `DonorName` varchar(50) NOT NULL,
  `BloodGroup` varchar(3) NOT NULL,
  `DonorMedicalReport` blob DEFAULT NULL,
  `DonorAddress` varchar(50) DEFAULT NULL,
  `DonorContact` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Donor`
--

INSERT INTO `Donor` (`DonorId`, `DonorName`, `BloodGroup`, `DonorMedicalReport`, `DonorAddress`, `DonorContact`) VALUES
(1, 'John Smith', 'O+', NULL, '123 Main St', '123-456-789'),
(2, 'Jane Doe', 'A-', NULL, '456 Park Ave', '987-654-321'),
(3, 'Bill Smith', 'B+', NULL, '789 Maple St', '111-222-333'),
(4, 'Emma Williams', 'AB+', NULL, '321 Maple St', '444-555-666'),
(5, 'Michael Johnson', 'O-', NULL, '654 Park Ave', '777-888-999'),
(6, 'Sophia Thompson', 'A+', NULL, '987 Main St', '111-222-333'),
(11, 'Shehroz', 'O-', NULL, 'G-11', '1234'),
(12, 'Mohsin', 'O+', NULL, 'ndskjfn', 'sdkjfn');

-- --------------------------------------------------------

--
-- Stand-in structure for view `donortobloodbank`
-- (See below for the actual view)
--
CREATE TABLE `donortobloodbank` (
`BloodBankId` int(11)
,`DonorId` int(11)
,`DateDonated` date
,`QuantityDonated` int(11)
,`BloodBankName` varchar(50)
,`DonorName` varchar(50)
);

-- --------------------------------------------------------

--
-- Table structure for table `GiveToPatient`
--

CREATE TABLE `GiveToPatient` (
  `BloodBankId` int(11) DEFAULT NULL,
  `PatientId` int(11) DEFAULT NULL,
  `RecieveId` int(11) NOT NULL,
  `DateRecieved` date DEFAULT NULL,
  `QuantityRecieved` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `GiveToPatient`
--

INSERT INTO `GiveToPatient` (`BloodBankId`, `PatientId`, `RecieveId`, `DateRecieved`, `QuantityRecieved`) VALUES
(2, 1, 25, '2022-12-30', 120),
(10, 1, 26, '2023-01-06', 120);

--
-- Triggers `GiveToPatient`
--
DELIMITER $$
CREATE TRIGGER `datetriggerGTP` BEFORE INSERT ON `GiveToPatient` FOR EACH ROW BEGIN
    IF NEW.DateRecieved > CURDATE() THEN
      SET NEW.dateRecieved = CURDATE();
    End if; 
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `give_blood_to_patient` BEFORE INSERT ON `GiveToPatient` FOR EACH ROW BEGIN
  DECLARE available_quantity INT;

  SELECT Quantity INTO available_quantity
  FROM BloodStock
  WHERE bloodstock.BloodGroup = (select BloodGroup from patient where patient.PatientId = new.PatientId)
  limit 1;

  IF available_quantity > NEW.QuantityRecieved  or available_quantity = NEW.QuantityRecieved THEN
    delete from BloodStock
    WHERE BloodGroup = (select BloodGroup from patient where patient.PatientId = new.PatientId)
    limit 1;
  else
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough blood of specified group available in stock';
		
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_into_donation_history` AFTER INSERT ON `GiveToPatient` FOR EACH ROW BEGIN
  INSERT INTO DonationHistory (TransfusionDate,BloodGroup, PatientId, BloodBankId, DonorId)
  VALUES (NEW.DateRecieved, (select BloodGroup from patient where patient.PatientId = new.PatientId ), NEW.PatientId, NEW.BloodBankId, NULL);
  
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Patient`
--

CREATE TABLE `Patient` (
  `PatientId` int(11) NOT NULL,
  `PatientName` varchar(50) DEFAULT NULL,
  `BloodGroup` varchar(3) NOT NULL,
  `PatientDisease` varchar(30) DEFAULT NULL,
  `PatientAddress` varchar(50) DEFAULT NULL,
  `PatientContact` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Patient`
--

INSERT INTO `Patient` (`PatientId`, `PatientName`, `BloodGroup`, `PatientDisease`, `PatientAddress`, `PatientContact`) VALUES
(1, 'Adam Johnson', 'O+', 'Leukemia', '123 Main St', '123-456-790'),
(2, 'Emily Williams', 'A-', 'Thalassemia', '456 Park Ave', '987-654-210'),
(3, 'Samuel Thompson', 'B+', 'Anemia', '789 Maple St', '111-222-333'),
(4, 'Olivia Jones', 'AB+', 'Sickle cell disease', '321 Maple St', '444-55-666'),
(5, 'William Smith', 'O-', 'Lymphoma', '654 Park Ave', '777-888-999'),
(6, 'Ava Thompson', 'A+', 'Multiple myeloma', '987 Main St', '111-222-333');

-- --------------------------------------------------------

--
-- Stand-in structure for view `totalbloods`
-- (See below for the actual view)
--
CREATE TABLE `totalbloods` (
`Oplus` decimal(32,0)
,`Ominus` decimal(32,0)
,`Aplus` decimal(32,0)
,`Aminus` decimal(32,0)
,`Bplus` decimal(32,0)
,`Bminus` decimal(32,0)
,`ABplus` decimal(32,0)
,`ABminus` decimal(32,0)
,`BloodBankId` int(11)
);

-- --------------------------------------------------------

--
-- Structure for view `bloodbanktopatient`
--
DROP TABLE IF EXISTS `bloodbanktopatient`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bloodbanktopatient`  AS SELECT `bloodbank`.`BloodBankName` AS `BloodBankName`, `givetopatient`.`BloodBankId` AS `BloodBankId`, `givetopatient`.`QuantityRecieved` AS `QuantityRecieved`, `givetopatient`.`DateRecieved` AS `DateRecieved`, `givetopatient`.`PatientId` AS `PatientId` FROM (`bloodbank` join `givetopatient`) WHERE `bloodbank`.`BloodBankId` = `givetopatient`.`BloodBankId``BloodBankId`  ;

-- --------------------------------------------------------

--
-- Structure for view `donortobloodbank`
--
DROP TABLE IF EXISTS `donortobloodbank`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `donortobloodbank`  AS SELECT `donationtobank`.`BloodBankId` AS `BloodBankId`, `donationtobank`.`DonorId` AS `DonorId`, `donationtobank`.`DateDonated` AS `DateDonated`, `donationtobank`.`QuantityDonated` AS `QuantityDonated`, `bloodbank`.`BloodBankName` AS `BloodBankName`, `donor`.`DonorName` AS `DonorName` FROM ((`donor` join `bloodbank`) join `donationtobank`) WHERE `donationtobank`.`BloodBankId` = `bloodbank`.`BloodBankId` AND `donationtobank`.`DonorId` = `donor`.`DonorId``DonorId`  ;

-- --------------------------------------------------------

--
-- Structure for view `totalbloods`
--
DROP TABLE IF EXISTS `totalbloods`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `totalbloods`  AS SELECT sum(case when `bloodstock`.`BloodGroup` = 'O+' then `bloodstock`.`Quantity` else 0 end) AS `Oplus`, sum(case when `bloodstock`.`BloodGroup` = 'O-' then `bloodstock`.`Quantity` else 0 end) AS `Ominus`, sum(case when `bloodstock`.`BloodGroup` = 'A+' then `bloodstock`.`Quantity` else 0 end) AS `Aplus`, sum(case when `bloodstock`.`BloodGroup` = 'A-' then `bloodstock`.`Quantity` else 0 end) AS `Aminus`, sum(case when `bloodstock`.`BloodGroup` = 'B+' then `bloodstock`.`Quantity` else 0 end) AS `Bplus`, sum(case when `bloodstock`.`BloodGroup` = 'B-' then `bloodstock`.`Quantity` else 0 end) AS `Bminus`, sum(case when `bloodstock`.`BloodGroup` = 'AB+' then `bloodstock`.`Quantity` else 0 end) AS `ABplus`, sum(case when `bloodstock`.`BloodGroup` = 'AB-' then `bloodstock`.`Quantity` else 0 end) AS `ABminus`, `bloodstock`.`BloodBankID` AS `BloodBankId` FROM `bloodstock` GROUP BY `bloodstock`.`BloodBankID``BloodBankID`  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `adminLogin`
--
ALTER TABLE `adminLogin`
  ADD PRIMARY KEY (`adminId`);

--
-- Indexes for table `BloodBank`
--
ALTER TABLE `BloodBank`
  ADD PRIMARY KEY (`BloodBankId`);

--
-- Indexes for table `BloodStock`
--
ALTER TABLE `BloodStock`
  ADD PRIMARY KEY (`BloodId`),
  ADD KEY `DonorFK` (`DonorID`),
  ADD KEY `BloodBankFK` (`BloodBankID`);

--
-- Indexes for table `DonationHistory`
--
ALTER TABLE `DonationHistory`
  ADD PRIMARY KEY (`HistoryId`),
  ADD KEY `BloodBankId` (`BloodBankId`),
  ADD KEY `PatientId` (`PatientId`),
  ADD KEY `FK3` (`DonorId`);

--
-- Indexes for table `DonationToBank`
--
ALTER TABLE `DonationToBank`
  ADD PRIMARY KEY (`DonationId`),
  ADD KEY `BloodBankId` (`BloodBankId`),
  ADD KEY `DonorId` (`DonorId`);

--
-- Indexes for table `Donor`
--
ALTER TABLE `Donor`
  ADD PRIMARY KEY (`DonorId`);

--
-- Indexes for table `GiveToPatient`
--
ALTER TABLE `GiveToPatient`
  ADD PRIMARY KEY (`RecieveId`),
  ADD KEY `BloodBankId` (`BloodBankId`),
  ADD KEY `PatientId` (`PatientId`);

--
-- Indexes for table `Patient`
--
ALTER TABLE `Patient`
  ADD PRIMARY KEY (`PatientId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `adminLogin`
--
ALTER TABLE `adminLogin`
  MODIFY `adminId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `BloodBank`
--
ALTER TABLE `BloodBank`
  MODIFY `BloodBankId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `BloodStock`
--
ALTER TABLE `BloodStock`
  MODIFY `BloodId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `DonationHistory`
--
ALTER TABLE `DonationHistory`
  MODIFY `HistoryId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `DonationToBank`
--
ALTER TABLE `DonationToBank`
  MODIFY `DonationId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `Donor`
--
ALTER TABLE `Donor`
  MODIFY `DonorId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `GiveToPatient`
--
ALTER TABLE `GiveToPatient`
  MODIFY `RecieveId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `Patient`
--
ALTER TABLE `Patient`
  MODIFY `PatientId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `BloodStock`
--
ALTER TABLE `BloodStock`
  ADD CONSTRAINT `BloodBankFK` FOREIGN KEY (`BloodBankID`) REFERENCES `BloodBank` (`BloodBankId`),
  ADD CONSTRAINT `DonorFK` FOREIGN KEY (`DonorID`) REFERENCES `Donor` (`DonorId`);

--
-- Constraints for table `DonationHistory`
--
ALTER TABLE `DonationHistory`
  ADD CONSTRAINT `FK3` FOREIGN KEY (`DonorId`) REFERENCES `Donor` (`DonorId`),
  ADD CONSTRAINT `donationhistory_ibfk_1` FOREIGN KEY (`BloodBankId`) REFERENCES `BloodBank` (`BloodBankId`),
  ADD CONSTRAINT `donationhistory_ibfk_2` FOREIGN KEY (`PatientId`) REFERENCES `Patient` (`PatientId`);

--
-- Constraints for table `DonationToBank`
--
ALTER TABLE `DonationToBank`
  ADD CONSTRAINT `donationtobank_ibfk_1` FOREIGN KEY (`BloodBankId`) REFERENCES `BloodBank` (`BloodBankId`),
  ADD CONSTRAINT `donationtobank_ibfk_2` FOREIGN KEY (`DonorId`) REFERENCES `Donor` (`DonorId`);

--
-- Constraints for table `GiveToPatient`
--
ALTER TABLE `GiveToPatient`
  ADD CONSTRAINT `givetopatient_ibfk_1` FOREIGN KEY (`BloodBankId`) REFERENCES `BloodBank` (`BloodBankId`),
  ADD CONSTRAINT `givetopatient_ibfk_2` FOREIGN KEY (`PatientId`) REFERENCES `Patient` (`PatientId`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
