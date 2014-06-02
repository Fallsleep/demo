-- phpMyAdmin SQL Dump
-- version 3.5.2.2
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 24, 2013 at 11:48 AM
-- Server version: 5.5.27
-- PHP Version: 5.4.7

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `crm`
--
CREATE DATABASE `crm` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `crm`;

-- --------------------------------------------------------

--
-- Table structure for table `crm_accounts`
--

CREATE TABLE IF NOT EXISTS `crm_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `platform` varchar(4) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `type` varchar(4) NOT NULL,
  `ac` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `pw` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `link` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `contract` tinyint(1) NOT NULL,
  `trade_item` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `eur_dps` int(11) NOT NULL,
  `gold_dps` int(11) NOT NULL,
  `min` int(11) NOT NULL,
  `max` int(11) NOT NULL,
  `currency` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `remarks` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=21 ;

--
-- Dumping data for table `crm_accounts`
--

INSERT INTO `crm_accounts` (`id`, `cid`, `platform`, `type`, `ac`, `pw`, `link`, `contract`, `trade_item`, `eur_dps`, `gold_dps`, `min`, `max`, `currency`, `remarks`, `deleted`) VALUES
(1, 1, 'MT4', 'Demo', 'D2561540', '210541656', 'http://www.panda.com', 1, 'eur', 1000000000, 0, 10, 100, '美金', '星期一', 0),
(4, 1, 'JAVA', 'Demo', 'D2589630', '123456', 'http://www.panda.com', 0, 'gold', 0, 150000000, 5, 500, '港元', '有', 0),
(5, 2, 'WEB', 'Real', 'D2589345', '1234567890', 'http://www.john.com', 0, 'gold', 0, 250000000, 20, 30, '人民幣', '電話', 0),
(6, 3, 'MT4', 'Real', 'D2589612', '789456', 'http://www.doe.com', 1, 'both', 10000000, 10000000, 6, 20, '人民幣', '左邊', 0),
(7, 5, 'MT4', 'Demo', 'D2589134', 'qwerty', 'http://www.doe.com', 0, 'eur', 2000000, 0, 10, 25, '人民幣', '右邊', 0),
(9, 2, 'JAVA', 'Demo', 'D2589630', 'qwerty', 'http://www.doe.com', 1, 'eur', 1234567, 0, 10, 50, '港元', '', 0),
(10, 5, 'JAVA', 'Demo', 'D2589630', '123456', 'http://www.panda.com', 0, 'gold', 0, 12345678, 10, 50, '港元', '', 0),
(11, 5, 'JAVA', 'Demo', 'D2581234', '1234567890', 'http://www.panda.com', 0, 'eur', 1234567, 0, 10, 50, '港元', '', 0),
(12, 2, 'WEB', 'Real', 'D2589345', '123456', 'http://www.doe.com', 0, 'gold', 0, 12345678, 10, 50, '港元', '', 0),
(13, 3, 'JAVA', 'Demo', 'D2589345', 'qwerty', 'http://www.panda.com', 0, 'eur', 1234567, 0, 10, 50, '港元', '', 0),
(14, 7, 'JAVA', 'Demo', 'D2589630', '1234567890', 'http://www.panda.com', 0, 'both', 1234567, 12345678, 10, 50, '港元', '', 0),
(15, 4, 'JAVA', 'Demo', 'D2581234', '123456', 'http://www.doe.com', 1, 'eur', 1234567, 0, 10, 50, '港元', '', 0),
(16, 5, 'JAVA', 'Demo', 'D2589630', '1234567890', 'http://www.doe.com', 0, 'eur', 1234567, 0, 10, 50, '港元', '', 0),
(17, 7, 'JAVA', 'Demo', 'D2589630', '1234567890', 'http://www.panda.com', 1, 'gold', 12345678, 0, 10, 50, '港元', '', 0),
(18, 6, 'WEB', 'Real', 'D2589345', '1234567890', 'http://www.doe.com', 1, 'gold', 0, 12345678, 10, 50, '港元', '', 0),
(20, 1, 'WEB', 'Real', 'D2589630', '123456', 'http://www.panda.com', 0, 'both', 1234567, 12345678, 10, 50, '港元', '123456', 0);

-- --------------------------------------------------------

--
-- Table structure for table `crm_customers`
--

CREATE TABLE IF NOT EXISTS `crm_customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `website` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `phone` int(11) NOT NULL,
  `email` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `fax` int(11) NOT NULL,
  `pic` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `im` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `crm_customers`
--

INSERT INTO `crm_customers` (`id`, `name`, `address`, `website`, `phone`, `email`, `fax`, `pic`, `im`, `deleted`) VALUES
(1, '東北電氣發展股份有限公司', '沙田科學園科技大道東16號海濱大樓2座5樓', 'http://www.nee.com.hk', 27369488, 'admin@nee.com.hk', 27369499, 'NikiChan', '27369488@qq.com', 0),
(2, '東英金融投資有限公司', '中區康樂廣場8號交易廣場2期27樓', 'http://www.opfin.com.hk', 21350290, 'admin@opfin.com.hk', 21350210, 'Oppo Finder', '21350290@hotmail.com', 0),
(3, '林麥集團有限公司', '九龍灣展貿徑1號國際展貿中心1101-1108室', 'http://www.linmark.com', 27537373, 'web@linmark.com', 27537384, 'Land Mark', '27537373@gmail.com', 0),
(4, '金威資源控股有限公司', '金鐘金鐘道89號力寶中心第1座19樓1901-1906室', '', 21115666, '21115666@gmail.com', 21115777, '金威', '21115666@gmail.com', 0),
(5, '金寶通集團有限公司', '灣仔港灣道23號鷹君中心17樓', 'http://www.computime.com', 22600300, 'compu@time.com', 0, '港灣道', '', 0),
(6, '保輝企業有限公司', '荃灣荃運工業中心', '', 24980391, '', 0, '保輝', '24980391@qq.com', 0),
(7, '南海控股有限公司', '中區皇后大道中16-18號新世界大廈1座39樓', 'http://www.nanhaicorp.com', 25268022, 'hr@nanhaicorp.com', 25268034, '皇后', '', 0);

-- --------------------------------------------------------

--
-- Table structure for table `crm_test`
--

CREATE TABLE IF NOT EXISTS `crm_test` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CUSTOM_FIELD` varchar(256) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;

--
-- Dumping data for table `crm_test`
--

INSERT INTO `crm_test` (`ID`, `CUSTOM_FIELD`) VALUES
(1, '123'),
(2, '123456'),
(4, 'Array'),
(5, '{"Name":"John"}'),
(6, '{"Name":"John"}'),
(7, '{"FName":"John","LName":"Doe"}'),
(8, '{"Name":"John","":""}'),
(9, '{"FName":"John","LName":"Doe"}'),
(10, '{"FName":"John","LName":"Doe"}'),
(11, '{"Name":"John","":""}'),
(12, '{"FName":"John","LName":"Doe"}'),
(13, '{"Name":"John","":""}'),
(14, '{"Name":"John"}');

-- --------------------------------------------------------

--
-- Table structure for table `crm_transactions`
--

CREATE TABLE IF NOT EXISTS `crm_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `aid` int(11) NOT NULL,
  `t_time` datetime NOT NULL,
  `content` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `contact` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `follow` datetime NOT NULL,
  `attachment` tinyint(1) NOT NULL,
  `agent` int(5) NOT NULL,
  `eur_diff` float NOT NULL,
  `gold_diff` float NOT NULL,
  `tune` tinyint(1) NOT NULL,
  `approval` varchar(6) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `lockable` tinyint(1) NOT NULL,
  `deposit` int(11) NOT NULL,
  `dilute` int(11) NOT NULL,
  `cut_p` int(3) NOT NULL,
  `eur_rate` int(2) NOT NULL,
  `gold_rate` int(2) NOT NULL,
  `remarks` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=9 ;

--
-- Dumping data for table `crm_transactions`
--

INSERT INTO `crm_transactions` (`id`, `aid`, `t_time`, `content`, `contact`, `follow`, `attachment`, `agent`, `eur_diff`, `gold_diff`, `tune`, `approval`, `lockable`, `deposit`, `dilute`, `cut_p`, `eur_rate`, `gold_rate`, `remarks`, `deleted`) VALUES
(1, 1, '2013-02-20 19:03:01', '跟進內容', '電話', '2013-02-25 19:03:01', 0, 12345, 12345, 0, 1, 'always', 1, 100000, 1, 65, 7, 0, 'remarks', 0),
(2, 4, '2013-04-19 12:00:00', '跟進內容', 'QQ', '2013-04-24 12:00:00', 0, 12345, 0, 12345, 0, 'often', 0, 100000, 1, 50, 0, 6, 'remarks', 0),
(4, 1, '2013-04-19 12:00:00', '內容', 'SKYPE', '2013-04-26 12:00:00', 0, 14725, 1234.56, 0, 0, 'no', 0, 1234567, 0, 99, 8, 0, '', 0),
(6, 4, '2013-04-12 17:23:00', '內容', 'SKYPE', '2013-04-18 19:03:00', 1, 14725, 0, 1234.56, 0, 'often', 0, 1234567, 0, 99, 0, 8, '123', 0),
(7, 20, '2013-04-01 12:34:00', '1234', 'SKYPE', '2013-04-08 12:33:00', 1, 14725, 1234.56, 1234.56, 1, 'always', 1, 1234567, 1, 99, 10, 10, '', 0),
(8, 5, '2013-04-26 12:50:00', '123456', 'QQ', '2013-05-03 12:50:00', 0, 12378, 0, 123.78, 0, 'often', 0, 1234567, 0, 85, 0, 7, '---', 0);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
