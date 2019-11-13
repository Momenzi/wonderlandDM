-- phpMyAdmin SQL Dump
-- version 4.0.4
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Sep 19, 2013 at 08:09 PM
-- Server version: 5.5.32
-- PHP Version: 5.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `re`
--
CREATE DATABASE IF NOT EXISTS `re` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `re`;

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE IF NOT EXISTS `accounts` (
  `UserID` int(20) NOT NULL AUTO_INCREMENT,
  `Username` varchar(40) NOT NULL,
  `Password` varchar(100) NOT NULL,
  `Admin` int(20) NOT NULL,
  `Score` int(20) NOT NULL,
  `Money` int(20) NOT NULL,
  `Kills` int(20) NOT NULL,
  `Deaths` int(20) NOT NULL,
  `Muted` int(20) NOT NULL,
  `Skin` int(20) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`UserID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE IF NOT EXISTS `bans` (
  `BanID` int(20) NOT NULL AUTO_INCREMENT,
  `Username` varchar(40) NOT NULL,
  `UserIP` varchar(40) NOT NULL,
  `Admin` varchar(40) NOT NULL,
  `AdminIP` varchar(40) NOT NULL,
  `Time` varchar(40) NOT NULL,
  `Minutes` int(20) NOT NULL,
  `Hours` int(20) NOT NULL,
  `Days` int(20) NOT NULL,
  `Reason` varchar(150) NOT NULL,
  `Unix` int(20) NOT NULL,
  PRIMARY KEY (`BanID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `chatlog`
--

CREATE TABLE IF NOT EXISTS `chatlog` (
  `ChatID` int(20) NOT NULL AUTO_INCREMENT,
  `Username` varchar(40) NOT NULL,
  `UserIP` varchar(40) NOT NULL,
  `Result` varchar(250) NOT NULL,
  PRIMARY KEY (`ChatID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `connections`
--

CREATE TABLE IF NOT EXISTS `connections` (
  `ConnectionID` int(20) NOT NULL AUTO_INCREMENT,
  `Username` varchar(20) NOT NULL,
  `UserIP` varchar(20) NOT NULL,
  `Type` varchar(60) NOT NULL,
  `Success` varchar(20) NOT NULL,
  PRIMARY KEY (`ConnectionID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `passwords`
--

CREATE TABLE IF NOT EXISTS `passwords` (
  `PasswordID` int(20) NOT NULL AUTO_INCREMENT,
  `Information` varchar(100) NOT NULL,
  `Result` varchar(100) NOT NULL,
  PRIMARY KEY (`PasswordID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `passwords`
--

INSERT INTO `passwords` (`PasswordID`, `Information`, `Result`) VALUES
(1, 'AdminLevel1', 'ChangeMe1'),
(2, 'AdminLevel2', 'ChangeMe2'),
(3, 'AdminLevel3', 'ChangeMe3'),
(4, 'AdminLevel4', 'ChangeMe4'),
(5, 'AdminLevel5', 'ChangeMe5'),
(6, 'AdminLevel6', 'ChangeMe6'),
(7, 'AdminLevel7', 'ChangeMe7');

-- --------------------------------------------------------

--
-- Table structure for table `pmlog`
--

CREATE TABLE IF NOT EXISTS `pmlog` (
  `LogID` int(11) NOT NULL AUTO_INCREMENT,
  `Time` datetime NOT NULL,
  `Username` varchar(40) NOT NULL,
  `UserIP` varchar(40) NOT NULL,
  `Receiver` varchar(40) NOT NULL,
  `ReceiverIP` varchar(40) NOT NULL,
  `Result` varchar(250) NOT NULL,
  PRIMARY KEY (`LogID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
