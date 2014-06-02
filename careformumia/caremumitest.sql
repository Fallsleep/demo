-- phpMyAdmin SQL Dump
-- version 3.5.2.2
-- http://www.phpmyadmin.net
--
-- 主机: 127.0.0.1
-- 生成日期: 2014 年 06 月 02 日 11:55
-- 服务器版本: 5.5.27
-- PHP 版本: 5.4.7

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 数据库: `caremumitest`
--
CREATE DATABASE `caremumitest` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `caremumitest`;

-- --------------------------------------------------------

--
-- 表的结构 `cfm_additional_services`
--

CREATE TABLE IF NOT EXISTS `cfm_additional_services` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `worker_id` int(11) unsigned NOT NULL,
  `service_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `test_idx` (`service_id`),
  KEY `work_additional_service_idx` (`worker_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=37 ;

--
-- 转存表中的数据 `cfm_additional_services`
--

INSERT INTO `cfm_additional_services` (`id`, `worker_id`, `service_id`) VALUES
(4, 2, 2),
(33, 1, 2),
(34, 1, 4),
(35, 1, 5),
(36, 3, 3);

-- --------------------------------------------------------

--
-- 表的结构 `cfm_avail_districts`
--

CREATE TABLE IF NOT EXISTS `cfm_avail_districts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `worker_id` int(11) unsigned NOT NULL,
  `district_id` int(11) unsigned NOT NULL,
  `tran_fee` tinyint(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(10) unsigned NOT NULL DEFAULT '0',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `worker_avail_district_idx` (`worker_id`),
  KEY `district_avail_district_idx` (`district_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=52 ;

--
-- 转存表中的数据 `cfm_avail_districts`
--

INSERT INTO `cfm_avail_districts` (`id`, `worker_id`, `district_id`, `tran_fee`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(4, 2, 18, 1, '0000-00-00 00:00:00', 0, '0000-00-00 00:00:00', 0),
(30, 3, 15, 0, '2013-05-03 11:17:33', 0, '2013-05-03 11:17:33', 0),
(31, 3, 16, 0, '2013-05-03 11:17:33', 0, '2013-05-03 11:17:33', 0),
(32, 3, 17, 1, '2013-05-03 11:17:33', 0, '2013-05-03 11:17:33', 0),
(33, 3, 18, 0, '2013-05-03 11:17:33', 0, '2013-05-03 11:17:33', 0),
(48, 1, 1, 0, '2013-05-10 12:59:34', 0, '2013-05-10 12:59:34', 0),
(49, 1, 2, 1, '2013-05-10 12:59:34', 0, '2013-05-10 12:59:34', 0),
(50, 1, 3, 1, '2013-05-10 12:59:34', 0, '2013-05-10 12:59:34', 0),
(51, 1, 4, 0, '2013-05-10 12:59:34', 0, '2013-05-10 12:59:34', 0);

-- --------------------------------------------------------

--
-- 表的结构 `cfm_districts`
--

CREATE TABLE IF NOT EXISTS `cfm_districts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `district_name` varchar(100) NOT NULL,
  `region` varchar(2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=19 ;

--
-- 转存表中的数据 `cfm_districts`
--

INSERT INTO `cfm_districts` (`id`, `district_name`, `region`) VALUES
(1, '離島區', 'NT'),
(2, '葵青區', 'NT'),
(3, '北區', 'NT'),
(4, '西貢區', 'NT'),
(5, '沙田區', 'NT'),
(6, '大埔區', 'NT'),
(7, '荃灣區', 'NT'),
(8, '屯門區', 'NT'),
(9, '元朗區', 'NT'),
(10, '九龍城區', 'KL'),
(11, '觀塘區', 'KL'),
(12, '深水埗區', 'KL'),
(13, '黃大仙區', 'KL'),
(14, '油尖旺區', 'KL'),
(15, '中西區', 'HK'),
(16, '東區', 'HK'),
(17, '南區', 'HK'),
(18, '灣仔區', 'HK');

-- --------------------------------------------------------

--
-- 表的结构 `cfm_edu_backgrounds`
--

CREATE TABLE IF NOT EXISTS `cfm_edu_backgrounds` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `worker_id` int(11) unsigned NOT NULL,
  `award_date` date NOT NULL,
  `award_type` varchar(20) NOT NULL,
  `award_title` varchar(255) NOT NULL,
  `remark` text NOT NULL,
  `img` varchar(255) DEFAULT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(10) unsigned NOT NULL DEFAULT '0',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `test_idx` (`worker_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=24 ;

--
-- 转存表中的数据 `cfm_edu_backgrounds`
--

INSERT INTO `cfm_edu_backgrounds` (`id`, `worker_id`, `award_date`, `award_type`, `award_title`, `remark`, `img`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 1, '2011-08-18', '類別一一一', '主題一', '一二三四', '', '2013-04-26 11:42:33', 1234567890, '2013-05-06 13:02:28', 963852741),
(2, 2, '2000-04-26', '類別二', '主題二', '123', '', '2013-04-26 15:59:00', 123456789, '2013-05-08 16:52:00', 1),
(3, 1, '2005-09-05', '類別二', '主題二', 'qwerty', '', '2013-04-26 18:17:51', 1234567890, '0000-00-00 00:00:00', 0),
(4, 1, '2005-02-16', '類別三', '主題三', '7890a', '', '2013-04-29 13:53:30', 13457890, '2013-05-02 18:48:01', 0),
(5, 2, '2010-04-02', '類別三', '主題二', '1324654', '', '2013-04-30 16:15:32', 1234567890, '0000-00-00 00:00:00', 0),
(6, 1, '2013-01-01', 'test1', 'test test1', 'adfadsdf', 'img/uploads/51823e40cd933_20130502182152_test.png', '2013-05-02 18:14:22', 0, '2013-05-02 18:57:08', 0),
(16, 3, '2009-03-05', '123', '主題一', '123', NULL, '2013-05-08 15:25:04', 1, '0000-00-00 00:00:00', 0),
(18, 2, '2012-03-02', '123', '主題一', '123', NULL, '2013-05-08 15:30:34', 1, '0000-00-00 00:00:00', 0),
(19, 2, '2009-03-04', '類別三', '主題二', '123', NULL, '2013-05-08 15:41:29', 1, '2013-05-08 15:46:21', 1),
(20, 1, '2011-04-15', '123', '主題二', '123', NULL, '2013-05-08 16:41:44', 1, '0000-00-00 00:00:00', 0),
(21, 1, '1999-02-16', '類別一一一', '12312', '123', NULL, '2013-05-08 16:41:58', 1, '0000-00-00 00:00:00', 0),
(22, 1, '1997-01-14', '123', '123', '123', NULL, '2013-05-08 16:48:47', 1, '0000-00-00 00:00:00', 0),
(23, 2, '1997-03-15', '類別一一一', '主題二', '87', NULL, '2013-05-08 16:50:35', 1, '0000-00-00 00:00:00', 0);

-- --------------------------------------------------------

--
-- 表的结构 `cfm_jobs`
--

CREATE TABLE IF NOT EXISTS `cfm_jobs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) unsigned NOT NULL,
  `mother_chi_name` varchar(255) DEFAULT NULL,
  `mother_eng_name` varchar(255) DEFAULT NULL,
  `mother_mobile` varchar(50) NOT NULL,
  `mother_contact` varchar(50) DEFAULT NULL,
  `district_id` int(11) unsigned NOT NULL,
  `work_address` varchar(255) DEFAULT NULL,
  `mother_age` int(3) NOT NULL DEFAULT '0',
  `birth_method` varchar(2) NOT NULL DEFAULT 'N',
  `milk_type` varchar(2) NOT NULL DEFAULT 'H',
  `hostipal` varchar(255) DEFAULT NULL,
  `expected_ddate` date DEFAULT '0000-00-00',
  `delivery_date` date DEFAULT '0000-00-00',
  `num_of_child` int(3) NOT NULL DEFAULT '0',
  `have_servant` tinyint(1) NOT NULL DEFAULT '0',
  `have_pet` tinyint(1) NOT NULL DEFAULT '0',
  `work_days` int(2) unsigned NOT NULL,
  `work_hours` int(2) unsigned NOT NULL,
  `wage` int(1) unsigned NOT NULL,
  `cantonese` int(1) unsigned NOT NULL,
  `mandarin` int(1) unsigned NOT NULL,
  `english` int(1) unsigned NOT NULL,
  `japanese` int(1) unsigned NOT NULL,
  `year_exp` int(1) unsigned NOT NULL,
  `age` int(1) unsigned NOT NULL,
  `work_start` date DEFAULT '0000-00-00',
  `work_end` date DEFAULT '0000-00-00',
  `status` varchar(2) NOT NULL,
  `remark` mediumtext,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(10) unsigned NOT NULL DEFAULT '0',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(10) unsigned NOT NULL DEFAULT '0',
  `extend` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- 转存表中的数据 `cfm_jobs`
--

INSERT INTO `cfm_jobs` (`id`, `customer_id`, `mother_chi_name`, `mother_eng_name`, `mother_mobile`, `mother_contact`, `district_id`, `work_address`, `mother_age`, `birth_method`, `milk_type`, `hostipal`, `expected_ddate`, `delivery_date`, `num_of_child`, `have_servant`, `have_pet`, `work_days`, `work_hours`, `wage`, `cantonese`, `mandarin`, `english`, `japanese`, `year_exp`, `age`, `work_start`, `work_end`, `status`, `remark`, `created`, `created_by`, `modified`, `modified_by`, `extend`) VALUES
(1, 12312321, '陳月霞', 'Alice', '23123132', '21231231', 11, '九龍灣', 25, 'N', '0', '', '2013-01-10', '2013-03-05', 1, 1, 1, 0, 8, 10000, 1, 0, 1, 0, 2, 0, '2013-01-01', '2013-11-08', 'P', '123123', '2013-04-30 11:45:00', 67575, '2013-05-09 16:12:15', 1, 0),
(2, 342342342, '張曉曉', 'Amy', '23123132', '342342', 10, '土瓜灣', 26, 'P', '1', '', '2012-04-05', '2012-05-05', 2, 0, 0, 45, 10, 12001, 2, 1, 1, 0, 5, 41, '2013-01-06', '2013-12-13', 'P', '', '2013-04-30 12:16:00', 324324, '0000-00-00 00:00:00', 0, 0),
(3, 123456789, '', '', '12345678', '', 1, '', 34, 'N', '0', '', NULL, NULL, 1, 0, 0, 90, 12, 16001, 1, 2, 2, 1, 7, 31, NULL, NULL, 'P', '', '2013-05-06 11:41:45', 1234567890, '0000-00-00 00:00:00', 0, 0);

-- --------------------------------------------------------

--
-- 表的结构 `cfm_requested_services`
--

CREATE TABLE IF NOT EXISTS `cfm_requested_services` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int(11) unsigned NOT NULL,
  `service_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `job_id` (`job_id`),
  KEY `fk_service_requested_service_idx` (`service_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=26 ;

--
-- 转存表中的数据 `cfm_requested_services`
--

INSERT INTO `cfm_requested_services` (`id`, `job_id`, `service_id`) VALUES
(22, 1, 1),
(23, 1, 2),
(24, 1, 3),
(25, 1, 4);

-- --------------------------------------------------------

--
-- 表的结构 `cfm_schedules`
--

CREATE TABLE IF NOT EXISTS `cfm_schedules` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `worker_id` int(11) unsigned NOT NULL,
  `job_id` int(11) unsigned DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` varchar(20) NOT NULL,
  `temp_lock_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `remark` text NOT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(10) unsigned NOT NULL DEFAULT '0',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_worker_schedule_idx` (`worker_id`),
  KEY `fk_job_schedule_idx` (`job_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

--
-- 转存表中的数据 `cfm_schedules`
--

INSERT INTO `cfm_schedules` (`id`, `worker_id`, `job_id`, `start_date`, `end_date`, `status`, `temp_lock_time`, `remark`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 1, NULL, '2013-04-27', '2013-04-30', 'B', '0000-00-00 00:00:00', '離港數', '2013-04-27 12:20:01', 1234567890, '2013-05-06 13:06:21', 12345),
(3, 1, NULL, '2013-05-14', '2013-05-15', 'B', '0000-00-00 00:00:00', '123456', '2013-04-27 13:07:50', 12345, '2013-05-06 13:13:02', 12345),
(4, 1, NULL, '2013-12-01', '2013-12-02', 'B', '0000-00-00 00:00:00', '1234', '2013-05-03 18:33:57', 12345, '0000-00-00 00:00:00', 0),
(5, 1, NULL, '2013-11-01', '2013-11-02', 'B', '0000-00-00 00:00:00', '1234567890', '2013-05-03 18:37:42', 12345, '0000-00-00 00:00:00', 0),
(6, 1, NULL, '2013-08-17', '2013-09-04', 'B', '0000-00-00 00:00:00', '123123', '2013-05-03 18:46:28', 12345, '2013-05-06 13:17:16', 12345),
(7, 2, NULL, '2013-03-04', '2013-03-17', 'B', '0000-00-00 00:00:00', '123', '2013-05-08 15:42:51', 1, '0000-00-00 00:00:00', 0),
(8, 1, NULL, '2014-02-02', '2014-02-03', 'B', '0000-00-00 00:00:00', '123', '2013-05-08 16:58:20', 1, '0000-00-00 00:00:00', 0);

-- --------------------------------------------------------

--
-- 表的结构 `cfm_services`
--

CREATE TABLE IF NOT EXISTS `cfm_services` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `service_name` varchar(50) NOT NULL,
  `service_desc` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

--
-- 转存表中的数据 `cfm_services`
--

INSERT INTO `cfm_services` (`id`, `service_name`, `service_desc`) VALUES
(1, '吸塵', NULL),
(2, '拖地', NULL),
(3, '先開衣機洗客人衣物', NULL),
(4, '掛浪客人衣物', NULL),
(5, '洗厠所', NULL);

-- --------------------------------------------------------

--
-- 表的结构 `cfm_users`
--

CREATE TABLE IF NOT EXISTS `cfm_users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- 转存表中的数据 `cfm_users`
--

INSERT INTO `cfm_users` (`id`, `username`, `password`, `role`, `created`, `modified`) VALUES
(1, 'admin', '9a01571c2f967ffa7572bd7665f5931ffa4a5a11', 'admin', '2013-05-08 12:00:40', '2013-05-08 12:00:40');

-- --------------------------------------------------------

--
-- 表的结构 `cfm_workers`
--

CREATE TABLE IF NOT EXISTS `cfm_workers` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `worker_no` varchar(20) DEFAULT NULL,
  `chi_name` varchar(100) NOT NULL DEFAULT '',
  `eng_first_name` varchar(100) DEFAULT NULL,
  `eng_last_name` varchar(100) DEFAULT NULL,
  `mobile` varchar(50) NOT NULL,
  `contact_other` varchar(50) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `mariage_status` varchar(2) NOT NULL DEFAULT 'S',
  `comments` mediumtext,
  `bank_name` varchar(255) DEFAULT NULL,
  `bank_account` varchar(255) DEFAULT NULL,
  `cantonese` varchar(1) NOT NULL DEFAULT 'N',
  `mandarin` varchar(1) NOT NULL DEFAULT 'N',
  `english` varchar(1) NOT NULL DEFAULT 'N',
  `japanese` varchar(1) NOT NULL DEFAULT 'N',
  `accept_twins` tinyint(1) NOT NULL DEFAULT '0',
  `accept8` tinyint(1) NOT NULL DEFAULT '0',
  `wage8` varchar(20) NOT NULL DEFAULT '0',
  `accept10` tinyint(1) NOT NULL DEFAULT '0',
  `wage10` varchar(20) NOT NULL DEFAULT '0',
  `accept12` tinyint(1) NOT NULL DEFAULT '0',
  `wage12` varchar(20) NOT NULL DEFAULT '0',
  `accept24` tinyint(1) NOT NULL DEFAULT '0',
  `wage24` varchar(20) NOT NULL DEFAULT '0',
  `year_exp` decimal(5,2) NOT NULL DEFAULT '0.00',
  `status` varchar(2) NOT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(10) unsigned NOT NULL DEFAULT '0',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=11 ;

--
-- 转存表中的数据 `cfm_workers`
--

INSERT INTO `cfm_workers` (`id`, `worker_no`, `chi_name`, `eng_first_name`, `eng_last_name`, `mobile`, `contact_other`, `address`, `date_of_birth`, `mariage_status`, `comments`, `bank_name`, `bank_account`, `cantonese`, `mandarin`, `english`, `japanese`, `accept_twins`, `accept8`, `wage8`, `accept10`, `wage10`, `accept12`, `wage12`, `accept24`, `wage24`, `year_exp`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, '12345', '陳文', 'Man', 'Chan', '98765432', '23456789', '香港九龍九龍灣', '1966-01-23', 'S', '好', 'HSBC', '123-4-56789', '2', '2', '2', '2', 1, 1, '10000', 1, '12000', 1, '14000', 1, '18000', 10.00, 'A', '2012-04-04 00:00:00', 123, '2013-05-08 17:10:58', 1234567890),
(2, '12346', '陳小雯', '', '', '65432198', '', '', NULL, 'S', '', '', '', '1', '1', '1', '2', 1, 1, '9000', 1, '800', 0, '0', 0, '0', 1.00, 'A', '2013-04-25 15:34:00', 4294967295, '2013-04-26 16:01:00', 0),
(3, '12312321', '王小姐', 'Alice', 'Wang', '2312312423', '', '', '2000-02-04', 'D', '43242423432423', '', '', '0', '0', '0', '0', 1, 1, '8500', 0, '0', 0, '0', 0, '0', 1.00, 'IA', '2013-04-26 17:09:00', 11, '2013-05-08 17:12:03', 234234234),
(8, '12347', '陳文', 'Man', '', '98765123', '', '', NULL, 'M', '', '', '', '2', '1', '1', '1', 1, 1, '10500', 0, '0', 1, '12345', 0, '0', 2.00, 'A', '2013-05-06 11:22:35', 1234567890, '0000-00-00 00:00:00', 0),
(9, '12348', '李大', '', '', '65432789', '', '', NULL, 'S', '', '', '', '1', '1', '1', '1', 0, 1, '12345', 1, '13456', 0, '0', 0, '0', 4.00, 'IA', '2013-05-06 13:46:13', 1234567890, '0000-00-00 00:00:00', 0),
(10, '12349', '王文', 'Man', 'WONG', '65432123', '23456789', '', '1979-02-18', 'M', '', '', '', '2', '2', '2', '2', 1, 1, '11000', 1, '12313', 0, '0', 0, '0', 12.00, 'A', '2013-05-08 15:43:31', 1, '0000-00-00 00:00:00', 0);

--
-- 限制导出的表
--

--
-- 限制表 `cfm_additional_services`
--
ALTER TABLE `cfm_additional_services`
  ADD CONSTRAINT `fk_service_additional_service` FOREIGN KEY (`service_id`) REFERENCES `cfm_services` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_work_additional_service` FOREIGN KEY (`worker_id`) REFERENCES `cfm_workers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `cfm_avail_districts`
--
ALTER TABLE `cfm_avail_districts`
  ADD CONSTRAINT `district_avail_district` FOREIGN KEY (`district_id`) REFERENCES `cfm_districts` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `worker_avail_district` FOREIGN KEY (`worker_id`) REFERENCES `cfm_workers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `cfm_edu_backgrounds`
--
ALTER TABLE `cfm_edu_backgrounds`
  ADD CONSTRAINT `fk_worker_edu_background` FOREIGN KEY (`worker_id`) REFERENCES `cfm_workers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `cfm_requested_services`
--
ALTER TABLE `cfm_requested_services`
  ADD CONSTRAINT `fk_service_requested_service` FOREIGN KEY (`service_id`) REFERENCES `cfm_services` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_job_requested_service` FOREIGN KEY (`job_id`) REFERENCES `cfm_jobs` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `cfm_schedules`
--
ALTER TABLE `cfm_schedules`
  ADD CONSTRAINT `fk_worker_schedule` FOREIGN KEY (`worker_id`) REFERENCES `cfm_workers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_job_schedule` FOREIGN KEY (`job_id`) REFERENCES `cfm_jobs` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
