-- phpMyAdmin SQL Dump
-- version 3.5.6
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2013 年 06 月 27 日 13:39
-- 服务器版本: 5.1.63-log
-- PHP 版本: 5.3.5

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 数据库: `assetexchange`
--
CREATE DATABASE `assetexchange` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `assetexchange`;

DELIMITER $$
--
-- 存储过程
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ax_send_tran_msg`()
SP:BEGIN
	DECLARE l_t_id				INT(11);
	DECLARE l_t_subject		TEXT;
	DECLARE l_t_body		TEXT;
	
	DECLARE l_subject		TEXT;
	DECLARE l_body			TEXT;

	DECLARE l_tran_id		INT(11);
	DECLARE l_type			TEXT;
	DECLARE l_sell_user_id	INT(11);
	DECLARE l_buy_user_id	INT(11);
	DECLARE l_asset_id		INT(11);
	DECLARE l_volume		INT(11);
	DECLARE l_close_price	DOUBLE;
	DECLARE l_sell_price		DOUBLE;
	DECLARE l_close_time	DATETIME;
	DECLARE l_symbol		VARCHAR(45);
	DECLARE l_name			VARCHAR(45);
	DECLARE l_spread			DOUBLE;

	DECLARE l_locked			TINYINT(1);

	DECLARE no_more_rows BOOLEAN;

	DECLARE trans_cur CURSOR FOR
		select o.id, o.type, o.sell_user_id, o.buy_user_id, o.asset_id, o.volume, o.close_time, o.close_price, o.sell_price, a.symbol, a.name, a.spread
		from `assetexchange`.`ax_transactions` o, `assetexchange`.`ax_assets` a
		where o.sent_msg = 0 and a.id = o.asset_id and o.type in ('S', 'B') and o.sell_user_id is not null order by o.close_time;
	declare continue handler for not found 
		SET no_more_rows := TRUE;  
	declare exit handler for SQLEXCEPTION
	BEGIN
		ROLLBACK;
		UPDATE ax_job_lock SET message_lock = 0 where message_lock = 1;
		COMMIT;
        CLOSE trans_cur;
	END;

	SET no_more_rows := FALSE;  
	
	UPDATE ax_job_lock SET message_lock = 1 where message_lock = 0;
	SELECT ROW_COUNT() into l_locked;

	IF l_locked = 0 THEN
		LEAVE SP;
	END IF;
        
        OPEN trans_cur;
        
	select id, subject, body into l_t_id, l_t_subject, l_t_body from ax_message_templates where name = '交易成功';

	START TRANSACTION;
	SET autocommit=0;

	read_loop: LOOP
		FETCH trans_cur INTO  l_tran_id, l_type, l_sell_user_id, l_buy_user_id, l_asset_id, l_volume, l_close_time, l_close_price, l_sell_price, l_symbol, l_name, l_spread;
		
		IF no_more_rows THEN
			LEAVE read_loop;
		END IF;
 
		SET l_subject := REPLACE(l_t_subject, '{SYMBOL}', l_symbol);
		SET l_body := l_t_body;
		SET l_body := REPLACE(l_body, '{ACTION}', '買入');
		SET l_body := REPLACE(l_body, '{TRAN_DATE}', l_close_time);
		SET l_body := REPLACE(l_body, '{SYMBOL}', l_symbol);
		SET l_body := REPLACE(l_body, '{ASSET_NAME}', l_name);
		SET l_body := REPLACE(l_body, '{PRICE}', l_close_price);
		SET l_body := REPLACE(l_body, '{VOLUME}', l_volume);
                SET l_body := REPLACE(l_body, '{SPREAD}', l_spread);
		SET l_body := REPLACE(l_body, '{TOTAL}', (l_close_price + l_spread) * l_volume);

		INSERT INTO ax_messages (user_id, message_template_id, subject, body, type, status, email, sent_at, created, created_by, modified, modified_by)
		VALUE (l_buy_user_id, l_t_id, l_subject, l_body, 'N', 'N', null, null, NOW(), l_buy_user_id, NOW(), l_buy_user_id);

		SET l_body := l_t_body;
		SET l_body := REPLACE(l_body, '{ACTION}', '賣出');
		SET l_body := REPLACE(l_body, '{TRAN_DATE}', l_close_time);
		SET l_body := REPLACE(l_body, '{SYMBOL}', l_symbol);
		SET l_body := REPLACE(l_body, '{ASSET_NAME}', l_name);
		SET l_body := REPLACE(l_body, '{PRICE}', l_sell_price);
		SET l_body := REPLACE(l_body, '{VOLUME}', l_volume);
                SET l_body := REPLACE(l_body, '{SPREAD}', l_spread);
		SET l_body := REPLACE(l_body, '{TOTAL}', (l_sell_price - l_spread) * l_volume);

		INSERT INTO ax_messages (user_id, message_template_id, subject, body, type, status, email, sent_at, created, created_by, modified, modified_by)
		VALUE (l_sell_user_id, l_t_id, l_subject, l_body, 'N', 'N', null, null, NOW(), l_sell_user_id, NOW(), l_sell_user_id);

		UPDATE ax_transactions SET sent_msg = 1 WHERE id = l_tran_id;
                
		COMMIT;
	END LOOP read_loop;

	UPDATE ax_job_lock SET message_lock = 0 where message_lock = 1;
	COMMIT;

	CLOSE trans_cur;
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ax_trade_matching`()
SP:BEGIN
	DECLARE l_open_id       INT(11);
	DECLARE l_asset_id      	INT(11);
	DECLARE l_type      		VARCHAR(2);
	DECLARE l_spread    		DOUBLE;
	DECLARE l_user_id		INT(11);
	DECLARE l_volume		INT(11);
	DECLARE l_fulfil_volume INT(11);
	DECLARE l_open_price	DOUBLE;
	DECLARE l_locked			TINYINT(1);
        DECLARE l_msg	TEXT;
	
	DECLARE no_more_rows BOOLEAN;

	DECLARE opens_cur CURSOR FOR
		select o.id, o.asset_id, o.type, a.spread, o.user_id, o.volume, o.fulfil_volume, o.open_price 
		from `assetexchange`.`ax_opens` o, `assetexchange`.`ax_assets` a 
		where o.asset_id = a.id and ran_match = 0 and o.status = 'A' order by o.created;

	declare continue handler for not found 
		SET no_more_rows := TRUE;  
	declare exit handler for SQLEXCEPTION
	BEGIN
		ROLLBACK;
                insert into ax_trade_match_log (message, status) values ('End trade matching', 'F');
		UPDATE ax_job_lock SET trade_matching_lock = 0 where trade_matching_lock = 1;
		COMMIT;
                CLOSE opens_cur;
	END;

	SET no_more_rows := FALSE;  
	
	UPDATE ax_job_lock SET trade_matching_lock = 1 where trade_matching_lock = 0;
	SELECT ROW_COUNT() into l_locked;

	IF l_locked = 0 THEN
		LEAVE SP;
	END IF;

	OPEN opens_cur;
        
	START TRANSACTION;
	SET autocommit=0;

	read_loop: LOOP
		FETCH opens_cur INTO  l_open_id, l_asset_id, l_type, l_spread, l_user_id, l_volume, l_fulfil_volume, l_open_price;
		
		IF no_more_rows THEN
			LEAVE read_loop;
		END IF;
                
		IF l_type = 'B' THEN
			CALL ax_trade_match_open(l_open_id, l_asset_id, 'S', l_spread, l_user_id, l_volume, l_fulfil_volume, l_open_price);
		ELSE
			CALL ax_trade_match_open(l_open_id, l_asset_id, 'B', l_spread, l_user_id, l_volume, l_fulfil_volume, l_open_price);
		END IF;

		UPDATE ax_opens SET ran_match = 1 WHERE id = l_open_id;
                
                COMMIT;
	END LOOP read_loop;

	UPDATE ax_job_lock SET trade_matching_lock = 0 where trade_matching_lock = 1;
	COMMIT;

	CLOSE opens_cur;

	

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ax_trade_match_open`(IN `p_open_id` INT(11), IN `p_asset_id` INT(11), IN `p_type` VARCHAR(2), IN `p_spread` DOUBLE, IN `p_user_id` INT(11), IN `p_volume` INT(11), IN `p_fulfil_volume` INT(11), IN `p_open_price` DOUBLE)
BEGIN
	DECLARE l_open_id       INT(11);
	-- DECLARE l_asset_id      	INT(11);
	-- DECLARE l_type      		VARCHAR(2);
	-- DECLARE l_spread    		DOUBLE;
	DECLARE l_user_id		INT(11);
	DECLARE l_volume		INT(11);
	DECLARE l_fulfil_volume INT(11);
	DECLARE l_open_price	DOUBLE;

	DECLARE no_more_o_rows BOOLEAN;
	DECLARE l_complete BOOLEAN;

	DECLARE l_req_vol		INT(11);
	DECLARE l_avail_vol		INT(11);
	DECLARE l_finished_vol	INT(11);

	DECLARE openss_cur CURSOR FOR
		select o.id, o.user_id, o.volume, o.fulfil_volume, o.open_price 
		from `assetexchange`.`ax_opens` o
		where o.asset_id = p_asset_id and o.type = p_type and o.status = 'A' and o.ran_match = 1 
			and not(o.user_id =  p_user_id) and ((p_type = 'S' and o.open_price <= p_open_price) or (p_type = 'B' and o.open_price >= p_open_price))
		order by open_price, open_time;

	declare continue handler for not found 
		SET no_more_o_rows := TRUE;  

	SET no_more_o_rows := FALSE;  
	SET l_complete := FALSE;
	SET l_finished_vol := 0;
	
-- SELECT concat('START trade_match_open | ',p_open_id, '|',p_asset_id, '|',p_type, '|',p_spread, '|',p_user_id, '|',p_volume, '|',p_fulfil_volume, '|',p_open_price) ;
	OPEN openss_cur;

	SET l_req_vol := p_volume - p_fulfil_volume;

-- SELECT concat('START trade_match_open | ',l_req_vol) ;

	read_o_loop: LOOP
		FETCH openss_cur INTO  l_open_id, l_user_id, l_volume, l_fulfil_volume, l_open_price;
		
-- SELECT concat('loop | ');

		IF no_more_o_rows THEN
			LEAVE read_o_loop;
		END IF;
		
		IF p_type = 'S' THEN
			SET l_avail_vol = l_volume - l_fulfil_volume;

			IF l_req_vol <= l_avail_vol THEN
				-- finish buyer open
				UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_req_vol, status = 'F', close_time = NOW(), modified = NOW(), modified_by = p_user_id where id = p_open_id;

				IF l_req_vol = l_avail_vol THEN
					UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_req_vol, status = 'F', close_time = NOW(), modified = NOW(), modified_by = l_user_id where id = l_open_id;
				ELSE
					UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_req_vol, modified = NOW(), modified_by = l_user_id where id = l_open_id;
				END IF;

				INSERT INTO ax_transactions (`type`,`sell_user_id`,`buy_user_id`,`sell_open_id`,`buy_open_id`,`asset_id`,`volume`,`close_time`,
																`close_price`,`sell_price`,`service_fee`,`comment`,`created`,`created_by`,`modified`,`modified_by`)
				VALUES ('B', l_user_id, p_user_id, l_open_id, p_open_id, p_asset_id, l_req_vol, NOW(), 
								p_open_price, l_open_price, l_req_vol * p_spread, null, NOW(), p_user_id, NOW(), p_user_id);
				UPDATE ax_users SET balance = balance - (l_req_vol * (p_open_price + p_spread)), modified = NOW(), modified_by = p_user_id where id = p_user_id;
				UPDATE ax_users SET balance = balance + (l_req_vol * (l_open_price - p_spread)), modified = NOW(), modified_by = l_user_id where id = l_user_id;

				CALL ax_trade_to_user_asset(p_user_id, l_user_id, p_asset_id, l_req_vol, p_open_price, l_open_price);

				SET l_complete := TRUE;

				LEAVE read_o_loop;
			ELSE
				SET l_req_vol = l_req_vol - l_avail_vol;
				SET l_finished_vol = l_finished_vol + l_avail_vol;

				-- finish seller open
				UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_avail_vol, status = 'F', close_time = NOW(), modified = NOW(), modified_by = l_user_id where id = l_open_id;

				INSERT INTO ax_transactions (`type`,`sell_user_id`,`buy_user_id`,`sell_open_id`,`buy_open_id`,`asset_id`,`volume`,`close_time`,
																`close_price`,`sell_price`,`service_fee`,`comment`,`created`,`created_by`,`modified`,`modified_by`)
				VALUES ('B', l_user_id, p_user_id, l_open_id, p_open_id, p_asset_id, l_avail_vol, NOW(), 
								p_open_price, l_open_price, l_avail_vol * p_spread, null, NOW(), p_user_id, NOW(), p_user_id);
                                                                
				UPDATE ax_users SET balance = balance - (l_avail_vol * (p_open_price + p_spread)), modified = NOW(), modified_by = p_user_id where id = p_user_id;
				UPDATE ax_users SET balance = balance + (l_avail_vol * (l_open_price - p_spread)), modified = NOW(), modified_by = l_user_id where id = l_user_id;

				CALL ax_trade_to_user_asset(p_user_id, l_user_id, p_asset_id, l_avail_vol, p_open_price, l_open_price);
			END IF;
		ELSE
			SET l_avail_vol = l_volume - l_fulfil_volume;

			IF l_req_vol <= l_avail_vol THEN
				-- finish seller open
				UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_req_vol, status = 'F', close_time = NOW(), modified = NOW(), modified_by = p_user_id where id = p_open_id;

				IF l_req_vol = l_avail_vol THEN
					UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_req_vol, status = 'F', close_time = NOW(), modified = NOW(), modified_by = l_user_id where id = l_open_id;
				ELSE
					UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_req_vol, modified = NOW(), modified_by = l_user_id where id = l_open_id;
				END IF;

				INSERT INTO ax_transactions (`type`,`sell_user_id`,`buy_user_id`,`sell_open_id`,`buy_open_id`,`asset_id`,`volume`,`close_time`,
																`close_price`,`sell_price`,`service_fee`,`comment`,`created`,`created_by`,`modified`,`modified_by`)
				VALUES ('S', p_user_id, l_user_id, p_open_id, l_open_id, p_asset_id, l_req_vol, NOW(), 
								l_open_price, p_open_price, l_req_vol * p_spread, null, NOW(), p_user_id, NOW(), p_user_id);
                                                                
				UPDATE ax_users SET balance = balance - (l_req_vol * (l_open_price + p_spread)), modified = NOW(), modified_by = l_user_id where id = l_user_id;
				UPDATE ax_users SET balance = balance + (l_req_vol * (p_open_price - p_spread)), modified = NOW(), modified_by = p_user_id where id = p_user_id;

				CALL ax_trade_to_user_asset(l_user_id, p_user_id, p_asset_id, l_req_vol, l_open_price, p_open_price);

				SET l_complete := TRUE;

				LEAVE read_o_loop;
			ELSE
				SET l_req_vol = l_req_vol - l_avail_vol;
				SET l_finished_vol = l_finished_vol + l_avail_vol;
				
				-- finish buyer open
				UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_avail_vol, status = 'F', close_time = NOW(), modified = NOW(), modified_by = l_user_id where id = l_open_id;

				INSERT INTO ax_transactions (`type`,`sell_user_id`,`buy_user_id`,`sell_open_id`,`buy_open_id`,`asset_id`,`volume`,`close_time`,
																`close_price`,`sell_price`,`service_fee`,`comment`,`created`,`created_by`,`modified`,`modified_by`)
				VALUES ('S', p_user_id, l_user_id, p_open_id, l_open_id, p_asset_id, l_avail_vol, NOW(), 
								l_open_price, p_open_price, l_avail_vol * p_spread, null, NOW(), p_user_id, NOW(), p_user_id);
                                                                
				UPDATE ax_users SET balance = balance - (l_avail_vol * (l_open_price + p_spread)), modified = NOW(), modified_by = l_user_id where id = l_user_id;
				UPDATE ax_users SET balance = balance + (l_avail_vol * (p_open_price - p_spread)), modified = NOW(), modified_by = p_user_id where id = p_user_id;

				CALL ax_trade_to_user_asset(l_user_id, p_user_id, p_asset_id, l_avail_vol, l_open_price, p_open_price);
			END IF;
		END IF;
	END LOOP read_o_loop;

	IF NOT l_complete THEN
		IF l_finished_vol > 0 THEN
			UPDATE ax_opens SET fulfil_volume = fulfil_volume + l_finished_vol, modified = NOW(), modified_by = p_user_id where id = p_open_id;
		END IF;		
	END IF;

	CLOSE openss_cur;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ax_trade_to_user_asset`(IN p_buy_id INT(11), IN p_sell_id INT(11), IN p_asset_id INT(11),
					IN p_volume INT(11), IN p_buy_price DOUBLE, IN p_sell_price DOUBLE)
BEGIN
	DECLARE l_count INT;

	SELECT count(*) into l_count from ax_user_assets where user_id = p_buy_id and asset_id = p_asset_id;

	IF l_count > 0 THEN
		UPDATE ax_user_assets set average_price = ((average_price * volume) + (p_buy_price * p_volume))/(volume + p_volume),
			volume = volume + p_volume, modified_by = p_buy_id
		where user_id = p_buy_id and asset_id = p_asset_id;
	ELSE
		INSERT INTO `assetexchange`.`ax_user_assets` (`user_id`,`asset_id`,`volume`,`average_price`,`status`,`created`,`created_by`,`modified`,`modified_by`)
		VALUES (p_buy_id, p_asset_id, p_volume, p_buy_price, 'A', NOW(), p_buy_id, NOW(), p_buy_id);
	END IF;

	UPDATE ax_user_assets set	volume = volume - p_volume, modified_by = p_sell_id
		where user_id = p_sell_id and asset_id = p_asset_id;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- 表的结构 `ax_asset_imgs`
--

CREATE TABLE IF NOT EXISTS `ax_asset_imgs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `path` varchar(255) NOT NULL,
  `is_cover` tinyint(1) NOT NULL DEFAULT '0',
  `asset_id` int(10) unsigned NOT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(11) unsigned NOT NULL,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_img_asset_idx` (`asset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=54 ;

--
-- 转存表中的数据 `ax_asset_imgs`
--

INSERT INTO `ax_asset_imgs` (`id`, `path`, `is_cover`, `asset_id`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(22, 'uploads/51be7f79ee67e_20130617111609_Chrysanthemum.jpg', 1, 21, '2013-06-17 11:16:10', 91285, '2013-06-17 11:16:10', 91285),
(23, 'uploads/51be8190e5016_20130617112504_Desert.jpg', 1, 19, '2013-06-17 11:25:04', 91285, '2013-06-17 11:25:04', 91285),
(24, 'uploads/51be81db006a4_20130617112619_Tulips.jpg', 1, 20, '2013-06-17 11:26:19', 91285, '2013-06-17 11:26:19', 91285),
(25, 'uploads/51be826db1706_20130617112845_Hydrangeas.jpg', 1, 22, '2013-06-17 11:28:45', 91285, '2013-06-17 11:28:45', 91285),
(26, 'uploads/51be830767337_20130617113119_Koala.jpg', 1, 23, '2013-06-17 11:31:19', 91285, '2013-06-17 11:31:19', 91285),
(27, 'uploads/51be83f663fa7_20130617113518_Jellyfish.jpg', 1, 24, '2013-06-17 11:35:18', 91285, '2013-06-17 11:35:18', 91285),
(28, 'uploads/51be8506f3e66_20130617113950_Lighthouse.jpg', 1, 25, '2013-06-17 11:39:51', 91285, '2013-06-17 11:39:51', 91285),
(29, 'uploads/51be8646e3a3c_20130617114510_Desert.jpg', 1, 26, '2013-06-17 11:45:10', 91285, '2013-06-17 11:45:10', 91285),
(30, 'uploads/51be86dbb7344_20130617114739_Penguins.jpg', 1, 27, '2013-06-17 11:47:39', 91285, '2013-06-17 11:47:39', 91285),
(31, 'uploads/51be876a1ef6c_20130617115002_Hydrangeas.jpg', 1, 28, '2013-06-17 11:50:02', 91285, '2013-06-17 11:50:02', 91285),
(32, 'uploads/51be886f24df9_20130617115423_Chrysanthemum.jpg', 1, 29, '2013-06-17 11:54:23', 91285, '2013-06-17 11:54:23', 91285),
(33, 'uploads/51be8a01f090f_20130617120105_Jellyfish.jpg', 1, 30, '2013-06-17 12:01:06', 91285, '2013-06-17 12:01:06', 91285),
(34, 'uploads/51be9049ee906_20130617122753_Hydrangeas.jpg', 1, 31, '2013-06-17 12:27:54', 91285, '2013-06-17 12:27:54', 91285),
(35, 'uploads/51be90a8e75b1_20130617122928_Jellyfish.jpg', 1, 32, '2013-06-17 12:29:28', 91285, '2013-06-17 12:29:28', 91285),
(36, 'uploads/51be910890cf7_20130617123104_Koala.jpg', 1, 33, '2013-06-17 12:31:04', 91285, '2013-06-17 12:31:04', 91285),
(37, 'uploads/51be9171d1334_20130617123249_Lighthouse.jpg', 1, 34, '2013-06-17 12:32:49', 91285, '2013-06-17 12:32:49', 91285),
(38, 'uploads/51be91d51f285_20130617123429_Penguins.jpg', 1, 35, '2013-06-17 12:34:29', 91285, '2013-06-17 12:34:29', 91285),
(39, 'uploads/51be928d63b06_20130617123733_Tulips.jpg', 1, 36, '2013-06-17 12:37:33', 91285, '2013-06-17 12:37:33', 91285),
(40, 'uploads/51be93495a2db_20130617124041_Chrysanthemum.jpg', 1, 37, '2013-06-17 12:40:41', 91285, '2013-06-17 12:40:41', 91285),
(41, 'uploads/51be9425a0c53_20130617124421_Desert.jpg', 1, 38, '2013-06-17 12:44:21', 91285, '2013-06-17 12:44:21', 91285),
(42, 'uploads/51be95b94c8dd_20130617125105_Hydrangeas.jpg', 1, 39, '2013-06-17 12:51:05', 91285, '2013-06-17 12:51:05', 91285),
(43, 'uploads/51be9a1d18a26_20130617130949_Hydrangeas.jpg', 1, 40, '2013-06-17 13:09:49', 91285, '2013-06-17 13:09:49', 91285),
(44, 'uploads/51be9ac15f275_20130617131233_Desert.jpg', 1, 41, '2013-06-17 13:12:33', 91285, '2013-06-17 13:12:33', 91285),
(45, 'uploads/51be9c48d1350_20130617131904_Koala.jpg', 1, 43, '2013-06-17 13:19:04', 91285, '2013-06-17 13:19:04', 91285),
(46, 'uploads/51be9cc51e457_20130617132109_Tulips.jpg', 1, 44, '2013-06-17 13:21:09', 91285, '2013-06-17 13:21:09', 91285),
(47, 'uploads/51be9d6528ce4_20130617132349_Penguins.jpg', 1, 45, '2013-06-17 13:23:49', 91285, '2013-06-17 13:23:49', 91285),
(48, 'uploads/51be9db022f4f_20130617132504_Jellyfish.jpg', 1, 46, '2013-06-17 13:25:04', 91285, '2013-06-17 13:25:04', 91285),
(49, 'uploads/51be9e351fd31_20130617132717_Lighthouse.jpg', 1, 47, '2013-06-17 13:27:17', 91285, '2013-06-17 13:27:17', 91285),
(50, 'uploads/51be9edbdf6ae_20130617133003_Hydrangeas.jpg', 1, 48, '2013-06-17 13:30:03', 91285, '2013-06-17 13:30:03', 91285),
(51, 'uploads/51be9f4ac15b7_20130617133154_Penguins.jpg', 1, 49, '2013-06-17 13:31:54', 91285, '2013-06-17 13:31:54', 91285),
(52, 'uploads/51be9fd6aca0b_20130617133414_Koala.jpg', 1, 50, '2013-06-17 13:34:14', 91285, '2013-06-17 13:34:14', 91285),
(53, '', 0, 51, '2013-06-18 22:24:12', 0, '2013-06-18 22:24:12', 0);

-- --------------------------------------------------------

--
-- 表的结构 `ax_assets`
--

CREATE TABLE IF NOT EXISTS `ax_assets` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `symbol` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `type` varchar(20) NOT NULL,
  `status` varchar(2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `district_id` int(11) unsigned NOT NULL,
  `location` text,
  `size` decimal(10,0) DEFAULT NULL,
  `rent` decimal(10,0) DEFAULT NULL,
  `has_rent` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `buy_date` date NOT NULL,
  `sell_date` date DEFAULT NULL,
  `open_date` date NOT NULL,
  `close_date` date NOT NULL,
  `buy_price` decimal(10,0) DEFAULT NULL,
  `available_share` int(12) NOT NULL DEFAULT '0',
  `sold_share` int(12) NOT NULL DEFAULT '0',
  `expected_interest` double DEFAULT NULL,
  `share_per_lot` int(12) unsigned NOT NULL,
  `start_price` double NOT NULL DEFAULT '0',
  `spread` double NOT NULL DEFAULT '0',
  `service_fee` double DEFAULT NULL,
  `service_fee_type` varchar(2) DEFAULT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(11) unsigned NOT NULL,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `symbol_UNIQUE` (`symbol`),
  KEY `fd_idx` (`district_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=52 ;

--
-- 转存表中的数据 `ax_assets`
--

INSERT INTO `ax_assets` (`id`, `symbol`, `name`, `type`, `status`, `description`, `address`, `district_id`, `location`, `size`, `rent`, `has_rent`, `buy_date`, `sell_date`, `open_date`, `close_date`, `buy_price`, `available_share`, `sold_share`, `expected_interest`, `share_per_lot`, `start_price`, `spread`, `service_fee`, `service_fee_type`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(19, 'HMT001', '典雅大廈 ', '0', 'A', '高層開洋有露台', '', 12, 'https://maps.google.com.hk/maps?f=d&amp;source=s_d&amp;saddr=%E5%85%B8%E9%9B%85%E5%A4%A7%E5%BB%88,+%E6%A2%AD%E6%A4%8F%E9%81%9315%E8%99%9F&amp;daddr=&amp;hl=zh-TW&amp;geocode=CWAA-xmTH7k5FdSQVAEdASzOBik7b4FfzwAENDEYpnswQImWwA&amp;sll=22.319312,114.174975&amp;sspn=0.009121,0.016512&amp;brcurrent=3,0x340400c97460743b:0x250031a9a89d1992,0,0x3404009533f68457:0x7af391a82a888312&amp;mra=prev&amp;ie=UTF8&amp;t=m&amp;ll=22.319312,114.174975&amp;spn=0.009121,0.016512&amp;output=embed', '426', '14000', 0, '2012-01-01', '2023-02-01', '2012-01-19', '2019-01-01', '4000000', 4000000, 4000000, 0.05, 1, 1, 0.01, NULL, '', '2013-06-17 11:07:47', 0, '2013-06-25 18:43:52', 91285),
(20, 'HMT002', '維景灣畔', '0', 'A', '', '', 1, 'https://maps.google.com/maps?f=q&amp;source=embed&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%B0%86%E5%86%9B%E6%BE%B3%E7%B6%AD%E6%99%AF%E7%81%A3%E7%95%94&amp;aq=0&amp;oq=%E7%B6%AD%E6%99%AF%E7%81%A3%E7%95%94&amp;sll=22.303024,114.253703&amp;sspn=0.002496,0.005284&amp;ie=UTF8&amp;hq=%E9%A6%99%E6%B8%AF%E5%B0%86%E5%86%9B%E6%BE%B3%E7%B6%AD%E6%99%AF%E7%81%A3%E7%95%94&amp;t=m&amp;cid=317470921869485156&amp;hnear=&amp;ll=22.302835,114.253178&amp;spn=0.004765,0.006866&amp;z=17&amp;output=embed', '546', '13400', 0, '2012-01-01', '2020-01-01', '2012-02-01', '2012-03-01', '4000000', 4200000, 4200000, 0.05, 1, 1, 0.01, NULL, '', '2013-06-17 11:09:57', 0, '2013-06-26 11:50:02', 91285),
(21, 'HMT003', '雍雅軒', '0', 'A', '物業設施: 53/F空中旋轉健身室、‧Noble House宴會廳匯聚國際名牌用料、泳池 + 按摩池、保齡球場、兒童玩樂專區、平台花園、天台花園、閱讀專區、多用途房 ...', '和宜合道 ', 2, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%91%B5%E6%B6%8C%E9%9B%8D%E9%9B%85%E8%BB%921%E5%BA%A7&amp;aq=2&amp;oq=%E9%A6%99%E6%B8%AF%E8%91%B5%E6%B6%8C%E9%9B%8D%E9%9B%85%E8%BB%92&amp;sll=22.365986,114.136748&amp;sspn=0.002495,0.005284&amp;ie=UTF8&amp;hq=&amp;hnear=%E9%A6%99%E6%B8%AF%E5%92%8C%E5%AE%9C%E5%90%88%E9%81%9333%E8%99%9F%E9%9B%8D%E9%9B%85%E8%BD%A91%E5%BA%A7&amp;t=m&amp;ll=22.366095,114.136738&amp;spn=0.002381,0.003433&amp;z=18&amp;iwloc=A&amp;output=embed', '474', '15000', 1, '2012-03-04', NULL, '2013-06-04', '2013-07-15', '4530000', 4530000, 4530000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:16:10', 0, '2013-06-26 11:55:14', 91285),
(22, 'HMT004', '宏龍工業大廈', '1', 'A', '', '龍德街11號 ', 7, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%8D%83%E6%B9%BE%E5%AE%8F%E9%BE%8D%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;aq=0&amp;oq=%E5%AE%8F%E9%BE%8D%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;sll=22.36612,114.137118&amp;sspn=0.002495,0.005284&amp;ie=UTF8&amp;hq=%E5%AE%8F%E9%BE%8D%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;hnear=%E9%A6%99%E6%B8%AF%E8%8D%83%E6%B9%BE&amp;t=m&amp;ll=22.365237,114.117308&amp;spn=0.0381,0.054932&amp;z=14&amp;output=embed', '456', '20000', 0, '2007-04-06', NULL, '2013-06-11', '2013-11-14', '330000', 330000, 330000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:28:45', 0, '2013-06-26 11:57:48', 91285),
(23, 'HMT005', '興盛工業大廈', '1', 'A', '', '', 6, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%8D%83%E6%B9%BE%E8%88%88%E7%9B%9B%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;aq=1&amp;oq=%E8%88%88%E7%9B%9B%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;sll=22.365148,114.117436&amp;sspn=0.004991,0.010568&amp;ie=UTF8&amp;hq=%E8%88%88%E7%9B%9B%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;hnear=%E9%A6%99%E6%B8%AF%E8%8D%83%E6%B9%BE&amp;t=m&amp;ll=22.365416,114.116364&amp;spn=0.009525,0.013733&amp;z=16&amp;iwloc=A&amp;output=embed', '789', '40000', 0, '2008-04-03', NULL, '2013-06-11', '2013-10-16', '6000000', 6000000, 6000000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:31:19', 0, '2013-06-26 12:00:03', 91285),
(24, 'HMT006', '貴盛工業大廈', '1', 'A', '靚裝修，商務中心', '', 18, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%91%B5%E6%B6%8C%E8%B2%B4%E7%9B%9B%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88%E4%B8%80%E6%9C%9F&amp;aq=2&amp;oq=%E8%B2%B4%E7%9B%9B%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;sll=22.365063,114.117088&amp;sspn=0.002495,0.005284&amp;ie=UTF8&amp;hq=%E8%B2%B4%E7%9B%9B%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88%E4%B8%80%E6%9C%9F&amp;hnear=%E9%A6%99%E6%B8%AF%E8%91%B5%E6%B6%8C&amp;t=m&amp;ll=22.364364,114.133787&amp;spn=0.004762,0.006866&amp;z=17&amp;output=embed', '534', '34000', 1, '2007-03-04', NULL, '2013-06-02', '2013-12-07', '560000', 560000, 560000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:35:18', 0, '2013-06-26 12:03:14', 91285),
(25, 'HMT007', '有線電視大樓', '1', 'A', '罕有海景 特高樓底  半倉半寫, 可自用或投資', '', 5, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%8D%83%E6%B9%BE%E6%B5%B7%E7%9B%9B%E8%B7%AF%E6%9C%89%E7%B7%9A%E9%9B%BB%E8%A6%96%E5%A4%A7%E6%A8%93&amp;aq=&amp;sll=22.373164,114.108247&amp;sspn=0.002495,0.005284&amp;ie=UTF8&amp;hq=%E6%9C%89%E7%B7%9A%E9%9B%BB%E8%A6%96%E5%A4%A7%E6%A8%93&amp;hnear=%E9%A6%99%E6%B8%AF%E6%B5%B7%E7%9B%9B%E8%B7%AF&amp;t=m&amp;ll=22.372544,114.107265&amp;spn=0.002381,0.003433&amp;z=18&amp;output=embed', '350', '17000', 0, '2007-02-13', NULL, '2013-07-11', '2013-10-16', '5230000', 5230000, 5230000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:39:51', 0, '2013-06-26 12:05:15', 91285),
(26, 'HMT008', '嘉力工業中心', '1', 'A', '投資自用首選  管理完善', '白田霸街5-21號 ', 8, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%8D%83%E6%B9%BE%E5%98%89%E5%8A%9B%E5%B7%A5%E6%A5%AD%E4%B8%AD%E5%BF%83&amp;aq=0&amp;oq=%E5%98%89%E5%8A%9B%E5%B7%A5%E6%A5%AD%E4%B8%AD%E5%BF%83&amp;sll=22.372926,114.108269&amp;sspn=0.002495,0.005284&amp;ie=UTF8&amp;hq=&amp;hnear=%E9%A6%99%E6%B8%AF%E7%99%BD%E7%94%B0%E5%A3%A9%E8%A1%975-21%E8%99%9F%E5%98%89%E5%8A%9B%E5%B7%A5%E4%B8%9A%E4%B8%AD%E5%BF%83&amp;t=m&amp;ll=22.374901,114.108821&amp;spn=0.004762,0.006866&amp;z=17&amp;iwloc=A&amp;output=embed', '397', '16500', 1, '1999-04-04', NULL, '2013-07-05', '2013-09-05', '3680000', 3680000, 3680000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:45:10', 0, '2013-06-26 12:07:48', 91285),
(27, 'HMT009', '力堅工業大廈', '1', 'A', '寫裝,鄰近港鐵站,步行只需2分', '', 9, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E7%81%AB%E7%82%AD%E5%8A%9B%E5%A0%85%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;aq=0&amp;oq=%E5%8A%9B%E5%A0%85%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;sll=22.374618,114.109122&amp;sspn=0.002495,0.005284&amp;ie=UTF8&amp;hq=%E5%8A%9B%E5%A0%85%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;hnear=%E9%A6%99%E6%B8%AF%E7%81%AB%E7%82%AD&amp;t=m&amp;ll=22.396611,114.197667&amp;spn=0.002381,0.003433&amp;z=18&amp;iwloc=A&amp;output=embed', '453', '15500', 1, '2008-08-16', NULL, '2013-08-25', '2013-11-15', '4120000', 4120000, 4120000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:47:39', 0, '2013-06-26 12:09:37', 91285),
(28, 'HMT010', '好景工業大廈', '1', 'A', '', '', 5, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%A7%82%E5%A1%98%E5%8C%BA%E5%A5%BD%E6%99%AF%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;aq=2&amp;oq=%E5%A5%BD%E6%99%AF%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;sll=22.396621,114.197672&amp;sspn=0.001247,0.002642&amp;ie=UTF8&amp;hq=%E5%A5%BD%E6%99%AF%E5%B7%A5%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;hnear=%E9%A6%99%E6%B8%AF%E8%A7%82%E5%A1%98%E5%8C%BA&amp;t=m&amp;ll=22.315495,114.216351&amp;spn=0.002382,0.003433&amp;z=18&amp;iwloc=A&amp;output=embed', '564', '17800', 1, '2006-10-17', NULL, '2013-09-16', '2013-12-31', '5000000', 5000000, 5000000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:50:02', 0, '2013-06-26 12:11:15', 91285),
(29, 'HMT011', '栢麗廣場', '2', 'A', '', '', 10, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%B1%AF%E9%97%A8%E6%A0%A2%E9%BA%97%E5%BB%A3%E5%A0%B4&amp;aq=0&amp;oq=%E6%A0%A2%E9%BA%97%E5%BB%A3%E5%A0%B4&amp;sll=22.315441,114.217086&amp;sspn=0.002496,0.005284&amp;ie=UTF8&amp;hq=%E6%A0%A2%E9%BA%97%E5%BB%A3%E5%A0%B4&amp;hnear=%E9%A6%99%E6%B8%AF%E5%B1%AF%E9%97%A8&amp;t=m&amp;ll=22.390873,113.976996&amp;spn=0.009523,0.013733&amp;z=16&amp;output=embed', '678', '26900', 1, '2013-01-10', NULL, '2013-07-26', '2013-11-16', '5880000', 5880000, 5880000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 11:54:23', 0, '2013-06-26 12:15:25', 91285),
(30, 'HMT012', '建邦商業大廈', '2', 'A', '', '', 17, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E4%BD%90%E6%95%A6%E5%BB%BA%E9%82%A6%E5%95%86%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;aq=0&amp;oq=%E5%BB%BA%E9%82%A6%E5%95%86%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;sll=22.390947,113.978031&amp;sspn=0.002495,0.005284&amp;ie=UTF8&amp;hq=&amp;hnear=%E9%A6%99%E6%B8%AF%E6%B8%A1%E8%88%B9%E8%A1%9738%E8%99%9F%E5%BB%BA%E9%82%A6%E5%95%86%E4%B8%9A%E5%A4%A7%E5%8E%A6&amp;t=m&amp;ll=22.307738,114.16769&amp;spn=0.004764,0.006866&amp;z=17&amp;iwloc=A&amp;output=embed', '543', '24560', 0, '2007-06-03', NULL, '2013-05-05', '2013-12-06', '478000', 478000, 478000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:01:06', 0, '2013-06-26 12:17:35', 91285),
(31, 'HMT013', '亞洲貿易中心', '2', 'A', '業主自讓 , 全城最平即走', '', 3, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%91%B5%E6%B6%8C%E4%BA%9E%E6%B4%B2%E8%B2%BF%E6%98%93%E4%B8%AD%E5%BF%83&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E4%BA%9E%E6%B4%B2%E8%B2%BF%E6%98%93%E4%B8%AD%E5%BF%83&amp;sll=22.307341,114.167803&amp;sspn=0.002496,0.005284&amp;ie=UTF8&amp;hq=%E4%BA%9E%E6%B4%B2%E8%B2%BF%E6%98%93%E4%B8%AD%E5%BF%83&amp;hnear=%E9%A6%99%E6%B8%AF%E8%91%B5%E6%B6%8C&amp;t=m&amp;ll=22.370734,114.137113&amp;spn=0.004762,0.006866&amp;z=17&amp;output=embed', '454', '18000', 0, '2013-06-09', NULL, '2013-07-05', '2014-10-27', '4540000', 4540000, 4540000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:27:54', 0, '2013-06-26 12:19:34', 91285),
(32, 'HMT014', '華寶商業大廈', '2', 'A', '', '', 15, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%8C%97%E8%A7%92%E8%8F%AF%E5%AF%B6%E5%95%86%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E8%8F%AF%E5%AF%B6%E5%95%86%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;sll=22.370545,114.13677&amp;sspn=0.002495,0.005284&amp;ie=UTF8&amp;hq=%E8%8F%AF%E5%AF%B6%E5%95%86%E6%A5%AD%E5%A4%A7%E5%BB%88&amp;hnear=%E9%A6%99%E6%B8%AF%E5%8C%97%E8%A7%92&amp;t=m&amp;ll=22.292104,114.201186&amp;spn=0.004765,0.006866&amp;z=17&amp;output=embed', '789', '34000', 1, '2009-04-22', NULL, '2013-07-30', '2014-01-01', '6780000', 6780000, 6780000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:29:28', 0, '2013-06-26 12:20:44', 91285),
(33, 'HMT015', '香港商業中心', '2', 'A', '', '', 14, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%A5%BF%E7%8E%AF%E9%A6%99%E6%B8%AF%E5%95%86%E6%A5%AD%E4%B8%AD%E5%BF%83&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E5%95%86%E6%A5%AD%E4%B8%AD%E5%BF%83&amp;sll=22.292094,114.201808&amp;sspn=0.002497,0.005284&amp;ie=UTF8&amp;hq=%E5%95%86%E6%A5%AD%E4%B8%AD%E5%BF%83&amp;hnear=%E9%A6%99%E6%B8%AF%E8%A5%BF%E7%8E%AF&amp;t=m&amp;fll=22.287243,114.136298&amp;fspn=0.001248,0.002642&amp;st=109146043351405611748&amp;rq=1&amp;ev=zi&amp;split=1&amp;ll=22.287166,114.136099&amp;spn=0.002383,0.003433&amp;z=18&amp;output=embed', '487', '18000', 1, '2005-10-14', NULL, '2013-09-18', '2013-12-19', '5340000', 5340000, 5340000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:31:04', 0, '2013-06-26 12:22:42', 91285),
(34, 'HMT016', '錦豐園', '0', 'A', '', '', 18, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E8%8D%83%E6%B9%BE%E9%8C%A6%E8%B1%90%E5%9C%92&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E9%8C%A6%E8%B1%90%E5%9C%92&amp;sll=22.287243,114.136298&amp;sspn=0.001248,0.002642&amp;ie=UTF8&amp;hq=%E9%8C%A6%E8%B1%90%E5%9C%92&amp;hnear=%E9%A6%99%E6%B8%AF%E8%8D%83%E6%B9%BE&amp;t=m&amp;ll=22.375704,114.107673&amp;spn=0.004762,0.006866&amp;z=17&amp;output=embed', '560', '20000', 1, '2010-09-28', NULL, '2013-04-14', '1913-12-31', '6000000', 6000000, 6000000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:32:49', 0, '2013-06-26 12:23:50', 91285),
(35, 'HMT017', '威豪花園', '0', 'A', '', '', 13, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E7%89%9B%E6%B1%A0%E6%B9%BE%E5%A8%81%E8%B1%AA%E8%8A%B1%E5%9C%92&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E5%A8%81%E8%B1%AA%E8%8A%B1%E5%9C%92&amp;sll=22.376121,114.108478&amp;sspn=0.00499,0.010568&amp;ie=UTF8&amp;hq=%E5%A8%81%E8%B1%AA%E8%8A%B1%E5%9C%92&amp;hnear=%E9%A6%99%E6%B8%AF%E7%89%9B%E6%B1%A0%E6%B9%BE&amp;t=m&amp;ll=22.336937,114.208953&amp;spn=0.004763,0.006866&amp;z=17&amp;iwloc=A&amp;output=embed', '670', '24000', 0, '2007-03-22', NULL, '2013-06-01', '2013-10-01', '7000000', 7000000, 7000000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:34:29', 0, '2013-06-26 12:24:54', 91285),
(36, 'HMT018', '御‧豪門', '0', 'A', '~~極筍豪宅.東南全海~~', '', 2, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E4%B9%9D%E9%BE%99%E5%9F%8E%E5%BE%A1%E8%B1%AA%E9%96%80&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E5%BE%A1%E2%80%A7%E8%B1%AA%E9%96%80&amp;sll=22.336917,114.209093&amp;sspn=0.002496,0.005284&amp;ie=UTF8&amp;hq=&amp;hnear=%E9%A6%99%E6%B8%AF%E6%B2%99%E5%9F%94%E9%81%9383%E8%99%9F%E5%BE%A1%E8%B1%AA%E9%97%A8&amp;t=m&amp;ll=22.330864,114.192452&amp;spn=0.009527,0.013733&amp;z=16&amp;output=embed', '566', '30000', 1, '2008-07-29', NULL, '2013-08-17', '2013-11-17', '6700000', 6700000, 6700000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:37:33', 0, '2013-06-26 12:28:45', 91285),
(37, 'HMT019', '陽光廣場', '0', 'A', '', '', 11, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E7%BA%A2%E7%A3%A1%E9%99%BD%E5%85%89%E5%BB%A3%E5%A0%B41%E5%BA%A7&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E9%99%BD%E5%85%89%E5%BB%A3%E5%A0%B4&amp;sll=22.330735,114.193043&amp;sspn=0.002496,0.005284&amp;ie=UTF8&amp;hq=%E9%99%BD%E5%85%89%E5%BB%A3%E5%A0%B41%E5%BA%A7&amp;hnear=%E9%A6%99%E6%B8%AF%E7%BA%A2%E7%A3%A1&amp;t=m&amp;ll=22.311351,114.189985&amp;spn=0.002382,0.003433&amp;z=18&amp;output=embed', '565', '20000', 1, '2006-09-28', NULL, '2013-06-14', '2013-12-30', '5300000', 5300000, 5300000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:40:41', 0, '2013-06-26 12:29:54', 91285),
(38, 'HMT020', '翔龍灣', '0', 'A', '', '', 10, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%9C%9F%E7%93%9C%E6%B9%BE%E7%BF%94%E9%BE%8D%E7%81%A3&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E7%BF%94%E9%BE%8D%E7%81%A3&amp;sll=22.311495,114.189497&amp;sspn=0.002496,0.005284&amp;ie=UTF8&amp;hq=%E9%A6%99%E6%B8%AF%E5%9C%9F%E7%93%9C%E6%B9%BE%E7%BF%94%E9%BE%8D%E7%81%A3&amp;t=m&amp;ll=22.319192,114.19301&amp;spn=0.009528,0.013733&amp;z=16&amp;iwloc=A&amp;output=embed', '570', '21000', 1, '2009-09-11', NULL, '2013-08-17', '2013-11-24', '5345000', 5345000, 5345000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:44:21', 0, '2013-06-26 12:31:04', 91285),
(39, 'HMT021', '美怡大廈', '3', 'A', '', '', 17, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%9C%9F%E7%93%9C%E6%B9%BE%E7%BE%8E%E6%80%A1%E5%A4%A7%E5%BB%88&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E7%BE%8E%E6%80%A1%E5%A4%A7%E5%BB%88&amp;sll=22.318617,114.195317&amp;sspn=0.004992,0.010568&amp;ie=UTF8&amp;hq=%E7%BE%8E%E6%80%A1%E5%A4%A7%E5%BB%88&amp;hnear=%E9%A6%99%E6%B8%AF%E5%9C%9F%E7%93%9C%E6%B9%BE&amp;t=m&amp;ll=22.319446,114.186723&amp;spn=0.002382,0.003433&amp;z=18&amp;output=embed', '450', '18000', 1, '2013-01-17', NULL, '2013-08-28', '2013-09-19', '4540000', 4540000, 4540000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 12:51:05', 0, '2013-06-26 12:32:18', 91285),
(40, 'HMT022', '美雅洋樓', '3', 'A', '', '', 4, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%9C%9F%E7%93%9C%E6%B9%BE%E7%BE%8E%E9%9B%85%E6%B4%8B%E6%A8%93&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E7%BE%8E%E9%9B%85%E6%B4%8B%E6%A8%93&amp;sll=22.319428,114.187348&amp;sspn=0.001248,0.002642&amp;ie=UTF8&amp;hq=%E7%BE%8E%E9%9B%85%E6%B4%8B%E6%A8%93&amp;hnear=%E9%A6%99%E6%B8%AF%E5%9C%9F%E7%93%9C%E6%B9%BE&amp;t=m&amp;ll=22.318527,114.188493&amp;spn=0.002382,0.003433&amp;z=18&amp;iwloc=A&amp;output=embed', '345', '12000', 0, '2000-02-16', NULL, '2013-08-24', '2013-12-28', '4500000', 4500000, 4500000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:09:49', 0, '2013-06-26 12:33:17', 91285),
(41, 'HMT023', '仁厚大廈', '3', 'A', '中層清靜, 鄰近地鐵 ', '', 1, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E4%BB%81%E5%8E%9A%E5%A4%A7%E5%BB%88&amp;aq=&amp;sll=37.0625,-95.677068&amp;sspn=34.999041,86.572266&amp;ie=UTF8&amp;hq=%E4%BB%81%E5%8E%9A%E5%A4%A7%E5%BB%88&amp;hnear=%E9%A6%99%E6%B8%AF&amp;t=m&amp;ll=22.316096,114.217644&amp;spn=0.019057,0.027466&amp;z=15&amp;output=embed', '368', '13500', 0, '2009-07-17', NULL, '2013-04-18', '2013-07-30', '4300000', 4300000, 4300000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:12:33', 0, '2013-06-26 12:35:34', 91285),
(43, 'HMT024', '富安大廈', '3', 'A', '', '', 1, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E7%89%9B%E5%A4%B4%E8%A7%92%E5%AF%8C%E5%AE%89%E5%A4%A7%E5%BB%88&amp;aq=0&amp;oq=%E9%A6%99%E6%B8%AF%E5%AF%8C%E5%AE%89%E5%A4%A7%E5%BB%88&amp;sll=22.315808,114.218212&amp;sspn=0.004992,0.010568&amp;ie=UTF8&amp;hq=%E7%89%9B%E5%A4%B4%E8%A7%92%E5%AF%8C%E5%AE%89%E5%A4%A7%E5%BB%88&amp;hnear=%E9%A6%99%E6%B8%AF&amp;t=m&amp;ll=22.312205,114.220734&amp;spn=0.004764,0.006866&amp;z=17&amp;output=embed', '234', '8000', 1, '2012-02-16', NULL, '2013-03-17', '2013-08-18', '2500000', 2500000, 2500000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:19:04', 0, '2013-06-26 12:36:38', 91285),
(44, 'HMT025', '首都廣場', '3', 'A', '', '', 11, 'http://ditu.google.cn/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E9%A6%96%E9%83%BD%E5%BB%A3%E5%A0%B4&amp;aq=&amp;sll=35.86166,104.195397&amp;sspn=36.760658,86.572266&amp;brcurrent=3,0x31508e64e5c642c1:0x951daa7c349f366f,0%3B5,0,0&amp;ie=UTF8&amp;hq=%E9%A6%96%E9%83%BD%E5%BB%A3%E5%A0%B4&amp;hnear=%E9%A6%99%E6%B8%AF&amp;t=m&amp;fll=22.29947,114.169664&amp;fspn=0.005172,0.010568&amp;st=105250506097979753968&amp;rq=1&amp;ev=zi&amp;split=1&amp;ll=22.301068,114.16842&amp;spn=0.009529,0.013733&amp;z=16&amp;output=embed', '430', '14000', 1, '2003-03-17', NULL, '2013-05-26', '2013-09-19', '4500000', 4500000, 4500000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:21:09', 0, '2013-06-26 12:41:32', 91285),
(45, 'HMT026', '雍翠豪園', '4', 'A', '', '', 16, 'http://ditu.google.cn/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%85%83%E6%9C%97%E9%9B%8D%E7%BF%A0%E8%B1%AA%E5%9C%92&amp;aq=0&amp;oq=%E9%9B%8D%E7%BF%A0%E8%B1%AA%E5%9C%92&amp;sll=22.299103,114.173505&amp;sspn=0.005172,0.010568&amp;brcurrent=3,0x31508e64e5c642c1:0x951daa7c349f366f,0%3B5,0,0&amp;ie=UTF8&amp;hq=%E9%9B%8D%E7%BF%A0%E8%B1%AA%E5%9C%92&amp;hnear=%E9%A6%99%E6%B8%AF%E5%85%83%E6%9C%97&amp;t=m&amp;ll=22.441515,114.03255&amp;spn=0.00952,0.013733&amp;z=16&amp;iwloc=A&amp;output=embed', NULL, '1500', 1, '2008-02-17', NULL, '2013-05-19', '2013-07-26', '800000', 800000, 800000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:23:49', 0, '2013-06-26 13:01:57', 91285),
(46, 'HMT027', '富豪花園', '4', 'A', '', '', 8, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E6%B2%99%E7%94%B0%E5%A4%A7%E6%B6%8C%E6%A1%A5%E8%B7%AF%E5%AF%8C%E8%B1%AA%E8%8A%B1%E5%9C%92&amp;aq=1&amp;oq=%E5%AF%8C%E8%B1%AA%E8%8A%B1%E5%9C%92&amp;sll=22.270194,114.186745&amp;sspn=0.079905,0.169086&amp;ie=UTF8&amp;hq=%E9%A6%99%E6%B8%AF%E6%B2%99%E7%94%B0%E5%A4%A7%E6%B6%8C%E6%A1%A5%E8%B7%AF%E5%AF%8C%E8%B1%AA%E8%8A%B1%E5%9C%92&amp;hnear=&amp;radius=15000&amp;t=m&amp;ll=22.384048,114.197903&amp;spn=0.004762,0.006866&amp;z=17&amp;output=embed', NULL, '2300', 1, '2011-03-03', NULL, '2013-06-23', '2013-07-09', '1200000', 1200000, 1200000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:25:04', 0, '2013-06-26 13:03:59', 91285),
(47, 'HMT028', ' 	維港灣', '4', 'A', '', '', 14, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%A4%A7%E8%A7%92%E5%92%80%E7%B6%AD%E6%B8%AF%E7%81%A3&amp;aq=0&amp;oq=%E7%B6%AD%E6%B8%AF%E7%81%A3&amp;sll=22.384057,114.198686&amp;sspn=0.00499,0.010568&amp;ie=UTF8&amp;hq=%E9%A6%99%E6%B8%AF%E5%A4%A7%E8%A7%92%E5%92%80%E7%B6%AD%E6%B8%AF%E7%81%A3&amp;t=m&amp;ll=22.31821,114.15723&amp;spn=0.002382,0.003433&amp;z=18&amp;iwloc=A&amp;output=embed', NULL, '3300', 0, '2012-03-17', NULL, '2013-06-19', '2013-08-10', '1000000', 1000000, 1000000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:27:17', 0, '2013-06-26 13:05:01', 91285),
(48, 'HMT029', '加州花園', '4', 'A', '', '', 12, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E6%96%B0%E7%94%B0%E5%8A%A0%E5%B7%9E%E8%8A%B1%E5%9C%92&amp;aq=0&amp;oq=%E5%8A%A0%E5%B7%9E%E8%8A%B1%E5%9C%92&amp;sll=22.318389,114.157627&amp;sspn=0.002496,0.005284&amp;ie=UTF8&amp;hq=%E5%8A%A0%E5%B7%9E%E8%8A%B1%E5%9C%92&amp;hnear=%E9%A6%99%E6%B8%AF%E6%96%B0%E7%94%B0&amp;t=m&amp;ll=22.486542,114.053584&amp;spn=0.002379,0.003433&amp;z=18&amp;output=embed', NULL, '2500', 1, '2001-07-17', NULL, '2013-06-06', '2013-07-24', '980000', 980000, 980000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:30:03', 0, '2013-06-26 13:06:11', 91285),
(49, 'HMT030', '金獅花園', '4', 'A', '', '', 12, 'https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=zh-CN&amp;geocode=&amp;q=%E9%A6%99%E6%B8%AF%E5%A4%A7%E5%9B%B4%E9%87%91%E7%8D%85%E8%8A%B1%E5%9C%92%E7%AC%AC%E4%B8%80%E6%9C%9F&amp;aq=1&amp;oq=%E9%A6%99%E6%B8%AF%E9%87%91%E7%8D%85%E8%8A%B1%E5%9C%92&amp;sll=22.486483,114.05956&amp;sspn=0.002493,0.005284&amp;ie=UTF8&amp;hq=%E9%87%91%E7%8D%85%E8%8A%B1%E5%9C%92%E7%AC%AC%E4%B8%80%E6%9C%9F&amp;hnear=%E9%A6%99%E6%B8%AF%E5%A4%A7%E5%9B%B4&amp;t=m&amp;ll=22.369186,114.183805&amp;spn=0.004762,0.006866&amp;z=17&amp;output=embed', NULL, '2200', 0, '2011-02-18', NULL, '2013-03-16', '2013-09-29', '940000', 940000, 940000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:31:54', 0, '2013-06-26 13:07:26', 91285),
(50, 'HMT031', '豐隆工業大廈', '1', 'A', '', '', 11, 'https://maps.google.com.hk/maps?f=d&amp;source=s_d&amp;saddr=%E8%B1%90%E9%9A%86%E5%B7%A5%E6%A5%AD%E4%B8%AD%E5%BF%83,+%E5%AE%8F%E5%85%89%E9%81%934%E8%99%9F&amp;daddr=&amp;hl=zh-TW&amp;geocode=CXOye7fUf3y1Ff-XVAEdLqfOBilDpfvKMwEENDHHSg5_xfqiBA&amp;sll=22.320231,114.190742&amp;sspn=0.036484,0.066047&amp;brcurrent=3,0x340400d4376c85e1:0xcab6faa04b58a8a7,0&amp;mra=prev&amp;ie=UTF8&amp;ll=22.320231,114.190742&amp;spn=0.036484,0.066047&amp;t=m&amp;output=embed', NULL, '1900', 1, '2010-01-16', NULL, '2013-09-18', '2013-12-19', '1000000', 1000000, 1000000, NULL, 1, 1, 0.01, NULL, '', '2013-06-17 13:34:14', 0, '2013-06-25 18:46:31', 91285),
(51, 'HMT032', '西貢江海樓', '0', 'A', '西貢住宅', '', 4, '', '600', NULL, 0, '2012-02-23', NULL, '2013-05-26', '2020-06-26', '2300000', 2300000, 10000, 0.05, 1, 1, 0.01, NULL, '', '2013-06-18 22:24:12', 0, '2013-06-24 17:35:37', 91285);

-- --------------------------------------------------------

--
-- 表的结构 `ax_districts`
--

CREATE TABLE IF NOT EXISTS `ax_districts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `district_name` varchar(100) NOT NULL,
  `region` varchar(2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=19 ;

--
-- 转存表中的数据 `ax_districts`
--

INSERT INTO `ax_districts` (`id`, `district_name`, `region`) VALUES
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
-- 表的结构 `ax_job_lock`
--

CREATE TABLE IF NOT EXISTS `ax_job_lock` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `trade_matching_lock` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `message_lock` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- 转存表中的数据 `ax_job_lock`
--

INSERT INTO `ax_job_lock` (`id`, `trade_matching_lock`, `message_lock`) VALUES
(1, 0, 0);

-- --------------------------------------------------------

--
-- 表的结构 `ax_message_templates`
--

CREATE TABLE IF NOT EXISTS `ax_message_templates` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `type` varchar(2) NOT NULL,
  `status` varchar(2) NOT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(11) unsigned NOT NULL,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- 转存表中的数据 `ax_message_templates`
--

INSERT INTO `ax_message_templates` (`id`, `name`, `subject`, `body`, `type`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(3, '交易成功', '交易成功 {SYMBOL}', '交易成功<BR><BR>操作 : {ACTION}<BR>交易日期 : {TRAN_DATE}<BR>商品編號 : {SYMBOL}<BR>商品名稱 : {ASSET_NAME}<BR>價錢 : {PRICE}<BR>股數 : {VOLUME}<BR>差價 : {SPREAD}<BR>總金額 : {TOTAL}', 'N', 'N', '2013-06-17 00:00:00', 91285, '2013-06-17 00:00:00', 91285);

-- --------------------------------------------------------

--
-- 表的结构 `ax_messages`
--

CREATE TABLE IF NOT EXISTS `ax_messages` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `message_template_id` int(11) unsigned NOT NULL,
  `subject` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `type` varchar(2) NOT NULL,
  `status` varchar(2) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(11) unsigned NOT NULL,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_message_user_idx` (`user_id`),
  KEY `fk_template_message_idx` (`message_template_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=273 ;

--
-- 转存表中的数据 `ax_messages`
--

INSERT INTO `ax_messages` (`id`, `user_id`, `message_template_id`, `subject`, `body`, `type`, `status`, `email`, `sent_at`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 991285119, 3, '交易成功 HMT020', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:10:22<BR>商品編號 : HMT020<BR>商品名稱 : 翔龍灣<BR>價錢 : 1.2<BR>股數 : 10000<BR>總金額 : 12000', 'N', 'N', NULL, NULL, '2013-06-18 20:10:22', 991285119, '2013-06-18 20:10:22', 991285119),
(2, 3888, 3, '交易成功 HMT020', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:10:22<BR>商品編號 : HMT020<BR>商品名稱 : 翔龍灣<BR>價錢 : 1.1<BR>股數 : 10000<BR>總金額 : 11000', 'N', 'N', NULL, NULL, '2013-06-18 20:10:22', 991285119, '2013-06-18 20:10:22', 991285119),
(3, 991285119, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:10:34<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.2<BR>股數 : 100000<BR>總金額 : 120000', 'N', 'N', NULL, NULL, '2013-06-18 20:10:34', 991285119, '2013-06-18 20:10:34', 991285119),
(4, 3888, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:10:34<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.1<BR>股數 : 100000<BR>總金額 : 110000', 'N', 'N', NULL, NULL, '2013-06-18 20:10:34', 991285119, '2013-06-18 20:10:34', 991285119),
(5, 991285119, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:10:46<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 1.2<BR>股數 : 100000<BR>總金額 : 120000', 'N', 'N', NULL, NULL, '2013-06-18 20:10:46', 991285119, '2013-06-18 20:10:46', 991285119),
(6, 3888, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:10:46<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 1.1<BR>股數 : 100000<BR>總金額 : 110000', 'N', 'N', NULL, NULL, '2013-06-18 20:10:46', 991285119, '2013-06-18 20:10:46', 991285119),
(7, 991285119, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:10:56<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1.2<BR>股數 : 10000<BR>總金額 : 12000', 'N', 'N', NULL, NULL, '2013-06-18 20:10:56', 991285119, '2013-06-18 20:10:56', 991285119),
(8, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:10:56<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1.1<BR>股數 : 10000<BR>總金額 : 11000', 'N', 'N', NULL, NULL, '2013-06-18 20:10:56', 991285119, '2013-06-18 20:10:56', 991285119),
(9, 991285118, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:11:30<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 1.2<BR>股數 : 100000<BR>總金額 : 120000', 'N', 'N', NULL, NULL, '2013-06-18 20:11:30', 991285118, '2013-06-18 20:11:30', 991285118),
(10, 3888, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:11:30<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 1.1<BR>股數 : 100000<BR>總金額 : 110000', 'N', 'N', NULL, NULL, '2013-06-18 20:11:30', 991285118, '2013-06-18 20:11:30', 991285118),
(11, 991285118, 3, '交易成功 HMT018', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:11:42<BR>商品編號 : HMT018<BR>商品名稱 : 御‧豪門<BR>價錢 : 1.2<BR>股數 : 15000<BR>總金額 : 18000', 'N', 'N', NULL, NULL, '2013-06-18 20:11:42', 991285118, '2013-06-18 20:11:42', 991285118),
(12, 3888, 3, '交易成功 HMT018', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:11:42<BR>商品編號 : HMT018<BR>商品名稱 : 御‧豪門<BR>價錢 : 1.1<BR>股數 : 15000<BR>總金額 : 16500', 'N', 'N', NULL, NULL, '2013-06-18 20:11:42', 991285118, '2013-06-18 20:11:42', 991285118),
(13, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:12:54<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.3<BR>股數 : 20000<BR>總金額 : 26000', 'N', 'R', NULL, NULL, '2013-06-18 20:12:54', 991285122, '2013-06-18 20:12:54', 991285122),
(14, 3888, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:12:54<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.1<BR>股數 : 20000<BR>總金額 : 22000', 'N', 'N', NULL, NULL, '2013-06-18 20:12:54', 991285122, '2013-06-18 20:12:54', 991285122),
(15, 991285119, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:19:34<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.1<BR>股數 : 100000<BR>總金額 : 210000', 'N', 'N', NULL, NULL, '2013-06-18 20:19:34', 991285119, '2013-06-18 20:19:34', 991285119),
(16, 3888, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:19:34<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 1.1<BR>股數 : 100000<BR>總金額 : 110000', 'N', 'N', NULL, NULL, '2013-06-18 20:19:34', 991285119, '2013-06-18 20:19:34', 991285119),
(17, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:22:46<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.3<BR>股數 : 10000<BR>總金額 : 13000', 'N', 'R', NULL, NULL, '2013-06-18 20:22:46', 991285122, '2013-06-18 20:22:46', 991285122),
(18, 3888, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:22:46<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.1<BR>股數 : 10000<BR>總金額 : 11000', 'N', 'N', NULL, NULL, '2013-06-18 20:22:46', 991285122, '2013-06-18 20:22:46', 991285122),
(19, 991285122, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:28:43<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.3<BR>股數 : 10000<BR>總金額 : 23000', 'N', 'N', NULL, NULL, '2013-06-18 20:28:43', 991285122, '2013-06-18 20:28:43', 991285122),
(20, 991285118, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:28:43<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 1.4<BR>股數 : 10000<BR>總金額 : 14000', 'N', 'N', NULL, NULL, '2013-06-18 20:28:43', 991285122, '2013-06-18 20:28:43', 991285122),
(21, 991285122, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:42:54<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.2<BR>股數 : 5000<BR>總金額 : 6000', 'N', 'N', NULL, NULL, '2013-06-18 20:42:54', 991285122, '2013-06-18 20:42:54', 991285122),
(22, 3888, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:42:54<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.1<BR>股數 : 5000<BR>總金額 : 5500', 'N', 'N', NULL, NULL, '2013-06-18 20:42:54', 991285122, '2013-06-18 20:42:54', 991285122),
(23, 991285122, 3, '交易成功 HMT031', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:43:38<BR>商品編號 : HMT031<BR>商品名稱 : 豐隆工業大廈<BR>價錢 : 1.2<BR>股數 : 10000<BR>總金額 : 12000', 'N', 'N', NULL, NULL, '2013-06-18 20:43:38', 991285122, '2013-06-18 20:43:38', 991285122),
(24, 3888, 3, '交易成功 HMT031', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:43:38<BR>商品編號 : HMT031<BR>商品名稱 : 豐隆工業大廈<BR>價錢 : 1.1<BR>股數 : 10000<BR>總金額 : 11000', 'N', 'N', NULL, NULL, '2013-06-18 20:43:38', 991285122, '2013-06-18 20:43:38', 991285122),
(25, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:44:19<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.6<BR>股數 : 10000<BR>總金額 : 16000', 'N', 'N', NULL, NULL, '2013-06-18 20:44:19', 991285118, '2013-06-18 20:44:19', 991285118),
(26, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:44:19<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.35<BR>股數 : 10000<BR>總金額 : 13500', 'N', 'N', NULL, NULL, '2013-06-18 20:44:19', 991285118, '2013-06-18 20:44:19', 991285118),
(27, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:44:19<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.6<BR>股數 : 10000<BR>總金額 : 16000', 'N', 'N', NULL, NULL, '2013-06-18 20:44:19', 991285118, '2013-06-18 20:44:19', 991285118),
(28, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:44:20<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.4<BR>股數 : 10000<BR>總金額 : 14000', 'N', 'N', NULL, NULL, '2013-06-18 20:44:20', 991285118, '2013-06-18 20:44:20', 991285118),
(29, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:45:12<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.6<BR>股數 : 80000<BR>總金額 : 128000', 'N', 'N', NULL, NULL, '2013-06-18 20:45:12', 991285119, '2013-06-18 20:45:12', 991285119),
(30, 991285119, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:45:12<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.5<BR>股數 : 80000<BR>總金額 : 120000', 'N', 'N', NULL, NULL, '2013-06-18 20:45:12', 991285119, '2013-06-18 20:45:12', 991285119),
(31, 991285119, 3, '交易成功 HMT027', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:51:21<BR>商品編號 : HMT027<BR>商品名稱 : 富豪花園<BR>價錢 : 1.2<BR>股數 : 5000<BR>總金額 : 6000', 'N', 'N', NULL, NULL, '2013-06-18 20:51:21', 991285119, '2013-06-18 20:51:21', 991285119),
(32, 3888, 3, '交易成功 HMT027', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:51:21<BR>商品編號 : HMT027<BR>商品名稱 : 富豪花園<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5000', 'N', 'N', NULL, NULL, '2013-06-18 20:51:21', 991285119, '2013-06-18 20:51:21', 991285119),
(33, 991285122, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 20:53:32<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 3<BR>股數 : 10000<BR>總金額 : 30000', 'N', 'N', NULL, NULL, '2013-06-18 20:53:32', 991285122, '2013-06-18 20:53:32', 991285122),
(34, 3888, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 20:53:32<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2<BR>股數 : 10000<BR>總金額 : 20000', 'N', 'N', NULL, NULL, '2013-06-18 20:53:32', 991285122, '2013-06-18 20:53:32', 991285122),
(35, 991285124, 3, '交易成功 HMT031', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:10:25<BR>商品編號 : HMT031<BR>商品名稱 : 豐隆工業大廈<BR>價錢 : 1.3<BR>股數 : 5000<BR>總金額 : 6500', 'N', 'N', NULL, NULL, '2013-06-18 21:10:25', 991285124, '2013-06-18 21:10:25', 991285124),
(36, 3888, 3, '交易成功 HMT031', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:10:26<BR>商品編號 : HMT031<BR>商品名稱 : 豐隆工業大廈<BR>價錢 : 1.05<BR>股數 : 5000<BR>總金額 : 5250', 'N', 'N', NULL, NULL, '2013-06-18 21:10:26', 991285124, '2013-06-18 21:10:26', 991285124),
(37, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:13:05<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 2.1<BR>股數 : 10000<BR>總金額 : 21000', 'N', 'N', NULL, NULL, '2013-06-18 21:13:05', 991285118, '2013-06-18 21:13:05', 991285118),
(38, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:13:05<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.5<BR>股數 : 10000<BR>總金額 : 15000', 'N', 'N', NULL, NULL, '2013-06-18 21:13:05', 991285118, '2013-06-18 21:13:05', 991285118),
(39, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:15:56<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 2.5<BR>股數 : 10000<BR>總金額 : 25000', 'N', 'N', NULL, NULL, '2013-06-18 21:15:56', 991285118, '2013-06-18 21:15:56', 991285118),
(40, 991285119, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:15:56<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.6<BR>股數 : 10000<BR>總金額 : 16000', 'N', 'N', NULL, NULL, '2013-06-18 21:15:56', 991285118, '2013-06-18 21:15:56', 991285118),
(41, 991285122, 3, '交易成功 HMT012', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:15:58<BR>商品編號 : HMT012<BR>商品名稱 : 建邦商業大廈<BR>價錢 : 1.1<BR>股數 : 5000<BR>總金額 : 5500', 'N', 'N', NULL, NULL, '2013-06-18 21:15:58', 991285122, '2013-06-18 21:15:58', 991285122),
(42, 3888, 3, '交易成功 HMT012', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:15:58<BR>商品編號 : HMT012<BR>商品名稱 : 建邦商業大廈<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5000', 'N', 'N', NULL, NULL, '2013-06-18 21:15:58', 991285122, '2013-06-18 21:15:58', 991285122),
(43, 991285118, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:18:37<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.9<BR>股數 : 20000<BR>總金額 : 58000', 'N', 'N', NULL, NULL, '2013-06-18 21:18:37', 991285118, '2013-06-18 21:18:37', 991285118),
(44, 991285119, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:18:37<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.5<BR>股數 : 20000<BR>總金額 : 50000', 'N', 'N', NULL, NULL, '2013-06-18 21:18:37', 991285118, '2013-06-18 21:18:37', 991285118),
(45, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:19:16<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 3<BR>股數 : 10000<BR>總金額 : 30000', 'N', 'N', NULL, NULL, '2013-06-18 21:19:16', 991285118, '2013-06-18 21:19:16', 991285118),
(46, 991285119, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:19:16<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 1.6<BR>股數 : 10000<BR>總金額 : 16000', 'N', 'N', NULL, NULL, '2013-06-18 21:19:16', 991285118, '2013-06-18 21:19:16', 991285118),
(47, 991285122, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:19:43<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.8<BR>股數 : 10000<BR>總金額 : 28000', 'N', 'N', NULL, NULL, '2013-06-18 21:19:43', 991285122, '2013-06-18 21:19:43', 991285122),
(48, 991285119, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:19:43<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.5<BR>股數 : 10000<BR>總金額 : 25000', 'N', 'N', NULL, NULL, '2013-06-18 21:19:43', 991285122, '2013-06-18 21:19:43', 991285122),
(49, 991285122, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:21:13<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.6<BR>股數 : 10000<BR>總金額 : 26000', 'N', 'N', NULL, NULL, '2013-06-18 21:21:13', 991285122, '2013-06-18 21:21:13', 991285122),
(50, 991285119, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:21:13<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.5<BR>股數 : 10000<BR>總金額 : 25000', 'N', 'N', NULL, NULL, '2013-06-18 21:21:13', 991285122, '2013-06-18 21:21:13', 991285122),
(51, 991285122, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:24:38<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 3<BR>股數 : 10000<BR>總金額 : 30000', 'N', 'N', NULL, NULL, '2013-06-18 21:24:38', 991285122, '2013-06-18 21:24:38', 991285122),
(52, 991285119, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:24:38<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.5<BR>股數 : 10000<BR>總金額 : 25000', 'N', 'N', NULL, NULL, '2013-06-18 21:24:38', 991285122, '2013-06-18 21:24:38', 991285122),
(53, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:26:38<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 3.1<BR>股數 : 20000<BR>總金額 : 62000', 'N', 'N', NULL, NULL, '2013-06-18 21:26:38', 991285124, '2013-06-18 21:26:38', 991285124),
(54, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:26:38<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 2.5<BR>股數 : 20000<BR>總金額 : 50000', 'N', 'N', NULL, NULL, '2013-06-18 21:26:38', 991285124, '2013-06-18 21:26:38', 991285124),
(55, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:26:38<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 3.1<BR>股數 : 10000<BR>總金額 : 31000', 'N', 'N', NULL, NULL, '2013-06-18 21:26:38', 991285124, '2013-06-18 21:26:38', 991285124),
(56, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:26:39<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 2.6<BR>股數 : 10000<BR>總金額 : 26000', 'N', 'N', NULL, NULL, '2013-06-18 21:26:39', 991285124, '2013-06-18 21:26:39', 991285124),
(57, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:26:39<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 3.1<BR>股數 : 70000<BR>總金額 : 217000', 'N', 'N', NULL, NULL, '2013-06-18 21:26:39', 991285124, '2013-06-18 21:26:39', 991285124),
(58, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:26:39<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 3<BR>股數 : 70000<BR>總金額 : 210000', 'N', 'N', NULL, NULL, '2013-06-18 21:26:39', 991285124, '2013-06-18 21:26:39', 991285124),
(59, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:27:22<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 4<BR>股數 : 10000<BR>總金額 : 40000', 'N', 'N', NULL, NULL, '2013-06-18 21:27:22', 991285124, '2013-06-18 21:27:22', 991285124),
(60, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:27:22<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 3<BR>股數 : 10000<BR>總金額 : 30000', 'N', 'N', NULL, NULL, '2013-06-18 21:27:22', 991285124, '2013-06-18 21:27:22', 991285124),
(61, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:27:45<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 4.2<BR>股數 : 10000<BR>總金額 : 42000', 'N', 'N', NULL, NULL, '2013-06-18 21:27:45', 991285124, '2013-06-18 21:27:45', 991285124),
(62, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:27:45<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 3<BR>股數 : 10000<BR>總金額 : 30000', 'N', 'N', NULL, NULL, '2013-06-18 21:27:45', 991285124, '2013-06-18 21:27:45', 991285124),
(63, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:29:33<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 4.5<BR>股數 : 10000<BR>總金額 : 45000', 'N', 'N', NULL, NULL, '2013-06-18 21:29:33', 991285122, '2013-06-18 21:29:33', 991285122),
(64, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:29:33<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 4<BR>股數 : 10000<BR>總金額 : 40000', 'N', 'N', NULL, NULL, '2013-06-18 21:29:33', 991285122, '2013-06-18 21:29:33', 991285122),
(65, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:34:18<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 5<BR>股數 : 10000<BR>總金額 : 50000', 'N', 'N', NULL, NULL, '2013-06-18 21:34:18', 991285122, '2013-06-18 21:34:18', 991285122),
(66, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:34:18<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 4.7<BR>股數 : 10000<BR>總金額 : 47000', 'N', 'N', NULL, NULL, '2013-06-18 21:34:18', 991285122, '2013-06-18 21:34:18', 991285122),
(67, 991285122, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:34:56<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 3.3<BR>股數 : 10000<BR>總金額 : 33000', 'N', 'N', NULL, NULL, '2013-06-18 21:34:56', 991285122, '2013-06-18 21:34:56', 991285122),
(68, 991285119, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:34:56<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.5<BR>股數 : 10000<BR>總金額 : 25000', 'N', 'N', NULL, NULL, '2013-06-18 21:34:56', 991285122, '2013-06-18 21:34:56', 991285122),
(69, 991285122, 3, '交易成功 HMT031', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:35:28<BR>商品編號 : HMT031<BR>商品名稱 : 豐隆工業大廈<BR>價錢 : 1.5<BR>股數 : 5000<BR>總金額 : 7500', 'N', 'N', NULL, NULL, '2013-06-18 21:35:28', 991285122, '2013-06-18 21:35:28', 991285122),
(70, 991285124, 3, '交易成功 HMT031', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:35:28<BR>商品編號 : HMT031<BR>商品名稱 : 豐隆工業大廈<BR>價錢 : 1.4<BR>股數 : 5000<BR>總金額 : 7000', 'N', 'N', NULL, NULL, '2013-06-18 21:35:28', 991285122, '2013-06-18 21:35:28', 991285122),
(71, 991285122, 3, '交易成功 HMT025', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:43:01<BR>商品編號 : HMT025<BR>商品名稱 : 首都廣場<BR>價錢 : 1.1<BR>股數 : 10000<BR>總金額 : 11000', 'N', 'N', NULL, NULL, '2013-06-18 21:43:01', 991285122, '2013-06-18 21:43:01', 991285122),
(72, 3888, 3, '交易成功 HMT025', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:43:01<BR>商品編號 : HMT025<BR>商品名稱 : 首都廣場<BR>價錢 : 1<BR>股數 : 10000<BR>總金額 : 10000', 'N', 'N', NULL, NULL, '2013-06-18 21:43:01', 991285122, '2013-06-18 21:43:01', 991285122),
(73, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:43:25<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 5.1<BR>股數 : 80000<BR>總金額 : 408000', 'N', 'N', NULL, NULL, '2013-06-18 21:43:25', 991285118, '2013-06-18 21:43:25', 991285118),
(74, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:43:25<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 5<BR>股數 : 80000<BR>總金額 : 400000', 'N', 'N', NULL, NULL, '2013-06-18 21:43:25', 991285118, '2013-06-18 21:43:25', 991285118),
(75, 991285122, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:43:49<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 10<BR>股數 : 5000<BR>總金額 : 50000', 'N', 'N', NULL, NULL, '2013-06-18 21:43:49', 991285122, '2013-06-18 21:43:49', 991285122),
(76, 3888, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:43:49<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5000', 'N', 'N', NULL, NULL, '2013-06-18 21:43:49', 991285122, '2013-06-18 21:43:49', 991285122),
(77, 991285122, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:44:31<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 10<BR>股數 : 5000<BR>總金額 : 50000', 'N', 'N', NULL, NULL, '2013-06-18 21:44:31', 991285122, '2013-06-18 21:44:31', 991285122),
(78, 3888, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:44:31<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5000', 'N', 'N', NULL, NULL, '2013-06-18 21:44:31', 991285122, '2013-06-18 21:44:31', 991285122),
(79, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:45:14<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 6<BR>股數 : 60000<BR>總金額 : 360000', 'N', 'N', NULL, NULL, '2013-06-18 21:45:14', 991285124, '2013-06-18 21:45:14', 991285124),
(80, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:45:14<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 5.5<BR>股數 : 60000<BR>總金額 : 330000', 'N', 'N', NULL, NULL, '2013-06-18 21:45:14', 991285124, '2013-06-18 21:45:14', 991285124),
(81, 991285122, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:46:37<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 10<BR>股數 : 5000<BR>總金額 : 50000', 'N', 'N', NULL, NULL, '2013-06-18 21:46:37', 3888, '2013-06-18 21:46:37', 3888),
(82, 3888, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:46:37<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 9<BR>股數 : 5000<BR>總金額 : 45000', 'N', 'N', NULL, NULL, '2013-06-18 21:46:37', 3888, '2013-06-18 21:46:37', 3888),
(83, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:47:05<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 6.5<BR>股數 : 10000<BR>總金額 : 65000', 'N', 'N', NULL, NULL, '2013-06-18 21:47:05', 991285124, '2013-06-18 21:47:05', 991285124),
(84, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:47:05<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 5<BR>股數 : 10000<BR>總金額 : 50000', 'N', 'N', NULL, NULL, '2013-06-18 21:47:05', 991285124, '2013-06-18 21:47:05', 991285124),
(85, 991285122, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:47:59<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 11<BR>股數 : 5000<BR>總金額 : 55000', 'N', 'N', NULL, NULL, '2013-06-18 21:47:59', 991285122, '2013-06-18 21:47:59', 991285122),
(86, 3888, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:47:59<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 9<BR>股數 : 5000<BR>總金額 : 45000', 'N', 'N', NULL, NULL, '2013-06-18 21:47:59', 991285122, '2013-06-18 21:47:59', 991285122),
(87, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:49:09<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 8<BR>股數 : 10000<BR>總金額 : 80000', 'N', 'N', NULL, NULL, '2013-06-18 21:49:09', 991285124, '2013-06-18 21:49:09', 991285124),
(88, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:49:09<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 6.4<BR>股數 : 10000<BR>總金額 : 64000', 'N', 'N', NULL, NULL, '2013-06-18 21:49:09', 991285124, '2013-06-18 21:49:09', 991285124),
(89, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 21:57:30<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 12<BR>股數 : 10000<BR>總金額 : 120000', 'N', 'N', NULL, NULL, '2013-06-18 21:57:30', 991285118, '2013-06-18 21:57:30', 991285118),
(90, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 21:57:30<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 6.2<BR>股數 : 10000<BR>總金額 : 62000', 'N', 'N', NULL, NULL, '2013-06-18 21:57:30', 991285118, '2013-06-18 21:57:30', 991285118),
(91, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:00:10<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 20<BR>股數 : 10000<BR>總金額 : 200000', 'N', 'N', NULL, NULL, '2013-06-18 22:00:10', 991285118, '2013-06-18 22:00:10', 991285118),
(92, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:00:10<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 6.2<BR>股數 : 10000<BR>總金額 : 62000', 'N', 'N', NULL, NULL, '2013-06-18 22:00:10', 991285118, '2013-06-18 22:00:10', 991285118),
(93, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:03:26<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 21<BR>股數 : 10000<BR>總金額 : 210000', 'N', 'N', NULL, NULL, '2013-06-18 22:03:26', 991285124, '2013-06-18 22:03:26', 991285124),
(94, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:03:26<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 20<BR>股數 : 10000<BR>總金額 : 200000', 'N', 'N', NULL, NULL, '2013-06-18 22:03:26', 991285124, '2013-06-18 22:03:26', 991285124),
(95, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:05:31<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 24<BR>股數 : 10000<BR>總金額 : 240000', 'N', 'N', NULL, NULL, '2013-06-18 22:05:31', 991285124, '2013-06-18 22:05:31', 991285124),
(96, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:05:31<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 23<BR>股數 : 10000<BR>總金額 : 230000', 'N', 'N', NULL, NULL, '2013-06-18 22:05:31', 991285124, '2013-06-18 22:05:31', 991285124),
(97, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:07:22<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 24<BR>股數 : 10000<BR>總金額 : 240000', 'N', 'N', NULL, NULL, '2013-06-18 22:07:22', 991285124, '2013-06-18 22:07:22', 991285124),
(98, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:07:22<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 23.5<BR>股數 : 10000<BR>總金額 : 235000', 'N', 'N', NULL, NULL, '2013-06-18 22:07:22', 991285124, '2013-06-18 22:07:22', 991285124),
(99, 991285119, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:12:39<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 3<BR>股數 : 10000<BR>總金額 : 30000', 'N', 'N', NULL, NULL, '2013-06-18 22:12:39', 991285119, '2013-06-18 22:12:39', 991285119),
(100, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:12:39<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 10000<BR>總金額 : 10000', 'N', 'N', NULL, NULL, '2013-06-18 22:12:39', 991285119, '2013-06-18 22:12:39', 991285119),
(101, 991285119, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:13:57<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 4<BR>股數 : 10000<BR>總金額 : 40000', 'N', 'N', NULL, NULL, '2013-06-18 22:13:57', 991285119, '2013-06-18 22:13:57', 991285119),
(102, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:13:57<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 10000<BR>總金額 : 10000', 'N', 'N', NULL, NULL, '2013-06-18 22:13:57', 991285119, '2013-06-18 22:13:57', 991285119),
(103, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:14:44<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 21<BR>股數 : 10000<BR>總金額 : 210000', 'N', 'N', NULL, NULL, '2013-06-18 22:14:44', 991285118, '2013-06-18 22:14:44', 991285118),
(104, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:14:44<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 20<BR>股數 : 10000<BR>總金額 : 200000', 'N', 'N', NULL, NULL, '2013-06-18 22:14:44', 991285118, '2013-06-18 22:14:44', 991285118),
(105, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:17:20<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 20<BR>股數 : 10000<BR>總金額 : 200000', 'N', 'N', NULL, NULL, '2013-06-18 22:17:20', 991285118, '2013-06-18 22:17:20', 991285118),
(106, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:17:20<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 19<BR>股數 : 10000<BR>總金額 : 190000', 'N', 'N', NULL, NULL, '2013-06-18 22:17:20', 991285118, '2013-06-18 22:17:20', 991285118),
(107, 991285118, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:19:24<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 21<BR>股數 : 10000<BR>總金額 : 210000', 'N', 'N', NULL, NULL, '2013-06-18 22:19:24', 991285118, '2013-06-18 22:19:24', 991285118),
(108, 991285124, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:19:24<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 20.5<BR>股數 : 10000<BR>總金額 : 205000', 'N', 'N', NULL, NULL, '2013-06-18 22:19:24', 991285118, '2013-06-18 22:19:24', 991285118),
(109, 991285124, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:21:15<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 3.4<BR>股數 : 50000<BR>總金額 : 170000', 'N', 'N', NULL, NULL, '2013-06-18 22:21:15', 991285124, '2013-06-18 22:21:15', 991285124),
(110, 991285118, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:21:15<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 2.5<BR>股數 : 50000<BR>總金額 : 125000', 'N', 'N', NULL, NULL, '2013-06-18 22:21:15', 991285124, '2013-06-18 22:21:15', 991285124),
(111, 991285118, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:22:49<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 5<BR>股數 : 10000<BR>總金額 : 50000', 'N', 'N', NULL, NULL, '2013-06-18 22:22:49', 991285118, '2013-06-18 22:22:49', 991285118),
(112, 991285122, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:22:49<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 3<BR>股數 : 10000<BR>總金額 : 30000', 'N', 'N', NULL, NULL, '2013-06-18 22:22:49', 991285118, '2013-06-18 22:22:49', 991285118),
(113, 991285118, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:23:15<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 8<BR>股數 : 10000<BR>總金額 : 80000', 'N', 'N', NULL, NULL, '2013-06-18 22:23:15', 991285118, '2013-06-18 22:23:15', 991285118),
(114, 991285122, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:23:15<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 3<BR>股數 : 10000<BR>總金額 : 30000', 'N', 'N', NULL, NULL, '2013-06-18 22:23:15', 991285118, '2013-06-18 22:23:15', 991285118),
(115, 991285124, 3, '交易成功 HMT018', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-18 22:26:42<BR>商品編號 : HMT018<BR>商品名稱 : 御‧豪門<BR>價錢 : 1.6<BR>股數 : 15000<BR>總金額 : 24000', 'N', 'N', NULL, NULL, '2013-06-18 22:26:42', 991285124, '2013-06-18 22:26:42', 991285124),
(116, 991285118, 3, '交易成功 HMT018', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-18 22:26:42<BR>商品編號 : HMT018<BR>商品名稱 : 御‧豪門<BR>價錢 : 1.5<BR>股數 : 15000<BR>總金額 : 22500', 'N', 'N', NULL, NULL, '2013-06-18 22:26:42', 991285124, '2013-06-18 22:26:42', 991285124),
(117, 991285122, 3, '交易成功 HMT023', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 01:43:26<BR>商品編號 : HMT023<BR>商品名稱 : 仁厚大廈<BR>價錢 : 1.1<BR>股數 : 10000<BR>總金額 : 11000', 'N', 'N', NULL, NULL, '2013-06-19 01:43:26', 991285122, '2013-06-19 01:43:26', 991285122),
(118, 3888, 3, '交易成功 HMT023', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 01:43:26<BR>商品編號 : HMT023<BR>商品名稱 : 仁厚大廈<BR>價錢 : 1<BR>股數 : 10000<BR>總金額 : 10000', 'N', 'N', NULL, NULL, '2013-06-19 01:43:26', 991285122, '2013-06-19 01:43:26', 991285122),
(119, 991285122, 3, '交易成功 HMT019', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 01:43:51<BR>商品編號 : HMT019<BR>商品名稱 : 陽光廣場<BR>價錢 : 1.1<BR>股數 : 5000<BR>總金額 : 5500', 'N', 'N', NULL, NULL, '2013-06-19 01:43:51', 991285122, '2013-06-19 01:43:51', 991285122),
(120, 3888, 3, '交易成功 HMT019', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 01:43:51<BR>商品編號 : HMT019<BR>商品名稱 : 陽光廣場<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5000', 'N', 'N', NULL, NULL, '2013-06-19 01:43:51', 991285122, '2013-06-19 01:43:51', 991285122),
(121, 991285122, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 01:45:37<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1.05<BR>股數 : 5000<BR>總金額 : 5250', 'N', 'N', NULL, NULL, '2013-06-19 01:45:37', 991285122, '2013-06-19 01:45:37', 991285122),
(122, 3888, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 01:45:37<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5000', 'N', 'N', NULL, NULL, '2013-06-19 01:45:37', 991285122, '2013-06-19 01:45:37', 991285122),
(123, 991285122, 3, '交易成功 HMT017', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 01:46:04<BR>商品編號 : HMT017<BR>商品名稱 : 威豪花園<BR>價錢 : 1.1<BR>股數 : 5000<BR>總金額 : 5500', 'N', 'N', NULL, NULL, '2013-06-19 01:46:04', 991285122, '2013-06-19 01:46:04', 991285122),
(124, 3888, 3, '交易成功 HMT017', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 01:46:04<BR>商品編號 : HMT017<BR>商品名稱 : 威豪花園<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5000', 'N', 'N', NULL, NULL, '2013-06-19 01:46:04', 991285122, '2013-06-19 01:46:04', 991285122),
(125, 991285122, 3, '交易成功 HMT005', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 01:47:03<BR>商品編號 : HMT005<BR>商品名稱 : 興盛工業大廈<BR>價錢 : 1.2<BR>股數 : 10000<BR>總金額 : 12000', 'N', 'N', NULL, NULL, '2013-06-19 01:47:03', 991285122, '2013-06-19 01:47:03', 991285122),
(126, 3888, 3, '交易成功 HMT005', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 01:47:03<BR>商品編號 : HMT005<BR>商品名稱 : 興盛工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>總金額 : 10000', 'N', 'N', NULL, NULL, '2013-06-19 01:47:03', 991285122, '2013-06-19 01:47:03', 991285122),
(127, 991285122, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 01:47:38<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1.7<BR>股數 : 5000<BR>總金額 : 8500', 'N', 'N', NULL, NULL, '2013-06-19 01:47:38', 991285122, '2013-06-19 01:47:38', 991285122),
(128, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 01:47:39<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5000', 'N', 'N', NULL, NULL, '2013-06-19 01:47:39', 991285122, '2013-06-19 01:47:39', 991285122),
(129, 991285122, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 01:59:32<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1.1<BR>股數 : 1000000<BR>總金額 : 1100000', 'N', 'N', NULL, NULL, '2013-06-19 01:59:32', 991285122, '2013-06-19 01:59:32', 991285122),
(130, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 01:59:32<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 1000000<BR>總金額 : 1000000', 'N', 'N', NULL, NULL, '2013-06-19 01:59:32', 991285122, '2013-06-19 01:59:32', 991285122),
(131, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 02:02:46<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 0.96<BR>股數 : 50000<BR>總金額 : 48000', 'N', 'N', NULL, NULL, '2013-06-19 02:02:46', 991285122, '2013-06-19 02:02:46', 991285122),
(132, 3888, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 02:02:46<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 0.95<BR>股數 : 50000<BR>總金額 : 47500', 'N', 'N', NULL, NULL, '2013-06-19 02:02:46', 991285122, '2013-06-19 02:02:46', 991285122),
(133, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 02:03:33<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 0.98<BR>股數 : 450000<BR>總金額 : 441000', 'N', 'R', NULL, NULL, '2013-06-19 02:03:33', 991285122, '2013-06-19 02:03:33', 991285122),
(134, 3888, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 02:03:33<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 0.95<BR>股數 : 450000<BR>總金額 : 427500', 'N', 'N', NULL, NULL, '2013-06-19 02:03:33', 991285122, '2013-06-19 02:03:33', 991285122),
(135, 16513, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 16:25:30<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1.5<BR>股數 : 5000<BR>總金額 : 7550', 'N', 'N', NULL, NULL, '2013-06-19 17:28:38', 16513, '2013-06-19 17:28:38', 16513),
(136, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 16:25:30<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 4950', 'N', 'N', NULL, NULL, '2013-06-19 17:28:38', 3888, '2013-06-19 17:28:38', 3888),
(137, 991285120, 3, '交易成功 HMT017', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 17:02:45<BR>商品編號 : HMT017<BR>商品名稱 : 威豪花園<BR>價錢 : 1.1<BR>股數 : 10000<BR>總金額 : 11100', 'N', 'N', NULL, NULL, '2013-06-19 17:28:38', 991285120, '2013-06-19 17:28:38', 991285120),
(138, 3888, 3, '交易成功 HMT017', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 17:02:45<BR>商品編號 : HMT017<BR>商品名稱 : 威豪花園<BR>價錢 : 1<BR>股數 : 10000<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-19 17:28:38', 3888, '2013-06-19 17:28:38', 3888),
(139, 991285120, 3, '交易成功 HMT014', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 17:04:15<BR>商品編號 : HMT014<BR>商品名稱 : 華寶商業大廈<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 5050', 'N', 'N', NULL, NULL, '2013-06-19 17:28:38', 991285120, '2013-06-19 17:28:38', 991285120),
(140, 3888, 3, '交易成功 HMT014', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 17:04:15<BR>商品編號 : HMT014<BR>商品名稱 : 華寶商業大廈<BR>價錢 : 1<BR>股數 : 5000<BR>總金額 : 4950', 'N', 'N', NULL, NULL, '2013-06-19 17:28:38', 3888, '2013-06-19 17:28:38', 3888),
(141, 991285120, 3, '交易成功 HMT024', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 17:05:00<BR>商品編號 : HMT024<BR>商品名稱 : 富安大廈<BR>價錢 : 1<BR>股數 : 15000<BR>總金額 : 15150', 'N', 'N', NULL, NULL, '2013-06-19 17:28:38', 991285120, '2013-06-19 17:28:38', 991285120),
(142, 3888, 3, '交易成功 HMT024', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 17:05:00<BR>商品編號 : HMT024<BR>商品名稱 : 富安大廈<BR>價錢 : 1<BR>股數 : 15000<BR>總金額 : 14850', 'N', 'N', NULL, NULL, '2013-06-19 17:28:38', 3888, '2013-06-19 17:28:38', 3888),
(143, 991285120, 3, '交易成功 HMT008', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 22:06:10<BR>商品編號 : HMT008<BR>商品名稱 : 嘉力工業中心<BR>價錢 : 1.2<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 12100', 'N', 'N', NULL, NULL, '2013-06-19 22:06:38', 991285120, '2013-06-19 22:06:38', 991285120),
(144, 3888, 3, '交易成功 HMT008', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 22:06:10<BR>商品編號 : HMT008<BR>商品名稱 : 嘉力工業中心<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-19 22:06:38', 3888, '2013-06-19 22:06:38', 3888),
(145, 991285120, 3, '交易成功 HMT022', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-19 23:42:50<BR>商品編號 : HMT022<BR>商品名稱 : 美雅洋樓<BR>價錢 : 1<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 5050', 'N', 'R', NULL, NULL, '2013-06-19 23:43:38', 991285120, '2013-06-19 23:43:38', 991285120),
(146, 3888, 3, '交易成功 HMT022', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-19 23:42:50<BR>商品編號 : HMT022<BR>商品名稱 : 美雅洋樓<BR>價錢 : 1<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 4950', 'N', 'R', NULL, NULL, '2013-06-19 23:43:38', 3888, '2013-06-19 23:43:38', 3888),
(147, 91285, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 15:59:15<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'R', NULL, NULL, '2013-06-21 15:59:38', 91285, '2013-06-21 15:59:38', 91285),
(148, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 15:59:15<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'R', NULL, NULL, '2013-06-21 15:59:38', 3888, '2013-06-21 15:59:38', 3888),
(149, 91285, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 15:59:45<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 2<BR>股數 : 2000<BR>差價 : 0.01<BR>總金額 : 4020', 'N', 'R', NULL, NULL, '2013-06-21 16:00:38', 91285, '2013-06-21 16:00:38', 91285),
(150, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 15:59:45<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 2<BR>股數 : 2000<BR>差價 : 0.01<BR>總金額 : 3980', 'N', 'R', NULL, NULL, '2013-06-21 16:00:39', 991285122, '2013-06-21 16:00:39', 991285122),
(151, 991285122, 3, '交易成功 HMT029', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:12:10<BR>商品編號 : HMT029<BR>商品名稱 : 加州花園<BR>價錢 : 1.1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 11100', 'N', 'R', NULL, NULL, '2013-06-21 21:12:38', 991285122, '2013-06-21 21:12:38', 991285122),
(152, 3888, 3, '交易成功 HMT029', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:12:10<BR>商品編號 : HMT029<BR>商品名稱 : 加州花園<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'R', NULL, NULL, '2013-06-21 21:12:38', 3888, '2013-06-21 21:12:38', 3888),
(153, 991285120, 3, '交易成功 HMT025', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:23:55<BR>商品編號 : HMT025<BR>商品名稱 : 首都廣場<BR>價錢 : 1.5<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 15100', 'N', 'N', NULL, NULL, '2013-06-21 21:24:38', 991285120, '2013-06-21 21:24:38', 991285120),
(154, 991285122, 3, '交易成功 HMT025', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:23:55<BR>商品編號 : HMT025<BR>商品名稱 : 首都廣場<BR>價錢 : 1.5<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 14900', 'N', 'N', NULL, NULL, '2013-06-21 21:24:38', 991285122, '2013-06-21 21:24:38', 991285122),
(155, 991285120, 3, '交易成功 HMT020', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:29:20<BR>商品編號 : HMT020<BR>商品名稱 : 翔龍灣<BR>價錢 : 1.2<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 12100', 'N', 'N', NULL, NULL, '2013-06-21 21:29:38', 991285120, '2013-06-21 21:29:38', 991285120),
(156, 991285119, 3, '交易成功 HMT020', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:29:20<BR>商品編號 : HMT020<BR>商品名稱 : 翔龍灣<BR>價錢 : 1.1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10900', 'N', 'R', NULL, NULL, '2013-06-21 21:29:38', 991285119, '2013-06-21 21:29:38', 991285119);
INSERT INTO `ax_messages` (`id`, `user_id`, `message_template_id`, `subject`, `body`, `type`, `status`, `email`, `sent_at`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(157, 991285119, 3, '交易成功 HMT029', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:34:50<BR>商品編號 : HMT029<BR>商品名稱 : 加州花園<BR>價錢 : 5<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 25050', 'N', 'N', NULL, NULL, '2013-06-21 21:35:38', 991285119, '2013-06-21 21:35:38', 991285119),
(158, 991285122, 3, '交易成功 HMT029', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:34:50<BR>商品編號 : HMT029<BR>商品名稱 : 加州花園<BR>價錢 : 1.5<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 7450', 'N', 'N', NULL, NULL, '2013-06-21 21:35:38', 991285122, '2013-06-21 21:35:38', 991285122),
(159, 991285120, 3, '交易成功 HMT026', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:42:05<BR>商品編號 : HMT026<BR>商品名稱 : 雍翠豪園<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-21 21:42:38', 991285120, '2013-06-21 21:42:38', 991285120),
(160, 3888, 3, '交易成功 HMT026', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:42:05<BR>商品編號 : HMT026<BR>商品名稱 : 雍翠豪園<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-21 21:42:38', 3888, '2013-06-21 21:42:38', 3888),
(161, 991285120, 3, '交易成功 HMT030', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:47:00<BR>商品編號 : HMT030<BR>商品名稱 : 金獅花園<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-21 21:47:38', 991285120, '2013-06-21 21:47:38', 991285120),
(162, 3888, 3, '交易成功 HMT030', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:47:00<BR>商品編號 : HMT030<BR>商品名稱 : 金獅花園<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-21 21:47:38', 3888, '2013-06-21 21:47:38', 3888),
(163, 991285120, 3, '交易成功 HMT027', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:47:35<BR>商品編號 : HMT027<BR>商品名稱 : 富豪花園<BR>價錢 : 1.5<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 7550', 'N', 'N', NULL, NULL, '2013-06-21 21:47:38', 991285120, '2013-06-21 21:47:38', 991285120),
(164, 991285119, 3, '交易成功 HMT027', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:47:35<BR>商品編號 : HMT027<BR>商品名稱 : 富豪花園<BR>價錢 : 1.5<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 7450', 'N', 'N', NULL, NULL, '2013-06-21 21:47:38', 991285119, '2013-06-21 21:47:38', 991285119),
(165, 991285120, 3, '交易成功 HMT009', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:50:05<BR>商品編號 : HMT009<BR>商品名稱 : 力堅工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-21 21:50:38', 991285120, '2013-06-21 21:50:38', 991285120),
(166, 3888, 3, '交易成功 HMT009', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:50:05<BR>商品編號 : HMT009<BR>商品名稱 : 力堅工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-21 21:50:38', 3888, '2013-06-21 21:50:38', 3888),
(167, 991285120, 3, '交易成功 HMT011', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:51:00<BR>商品編號 : HMT011<BR>商品名稱 : 栢麗廣場<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-21 21:51:38', 991285120, '2013-06-21 21:51:38', 991285120),
(168, 3888, 3, '交易成功 HMT011', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:51:00<BR>商品編號 : HMT011<BR>商品名稱 : 栢麗廣場<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-21 21:51:38', 3888, '2013-06-21 21:51:38', 3888),
(169, 991285120, 3, '交易成功 HMT028', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:54:55<BR>商品編號 : HMT028<BR>商品名稱 :  	維港灣<BR>價錢 : 1<BR>股數 : 15000<BR>差價 : 0.01<BR>總金額 : 15150', 'N', 'N', NULL, NULL, '2013-06-21 21:55:38', 991285120, '2013-06-21 21:55:38', 991285120),
(170, 3888, 3, '交易成功 HMT028', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:54:55<BR>商品編號 : HMT028<BR>商品名稱 :  	維港灣<BR>價錢 : 1<BR>股數 : 15000<BR>差價 : 0.01<BR>總金額 : 14850', 'N', 'N', NULL, NULL, '2013-06-21 21:55:38', 3888, '2013-06-21 21:55:38', 3888),
(171, 991285120, 3, '交易成功 HMT013', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:56:50<BR>商品編號 : HMT013<BR>商品名稱 : 亞洲貿易中心<BR>價錢 : 1<BR>股數 : 50000<BR>差價 : 0.01<BR>總金額 : 50500', 'N', 'N', NULL, NULL, '2013-06-21 21:57:38', 991285120, '2013-06-21 21:57:38', 991285120),
(172, 3888, 3, '交易成功 HMT013', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:56:50<BR>商品編號 : HMT013<BR>商品名稱 : 亞洲貿易中心<BR>價錢 : 1<BR>股數 : 50000<BR>差價 : 0.01<BR>總金額 : 49500', 'N', 'N', NULL, NULL, '2013-06-21 21:57:38', 3888, '2013-06-21 21:57:38', 3888),
(173, 991285120, 3, '交易成功 HMT013', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 21:56:50<BR>商品編號 : HMT013<BR>商品名稱 : 亞洲貿易中心<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-21 21:57:38', 991285120, '2013-06-21 21:57:38', 991285120),
(174, 3888, 3, '交易成功 HMT013', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 21:56:50<BR>商品編號 : HMT013<BR>商品名稱 : 亞洲貿易中心<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-21 21:57:38', 3888, '2013-06-21 21:57:38', 3888),
(175, 991285120, 3, '交易成功 HMT006', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 22:10:20<BR>商品編號 : HMT006<BR>商品名稱 : 貴盛工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-21 22:10:38', 991285120, '2013-06-21 22:10:38', 991285120),
(176, 3888, 3, '交易成功 HMT006', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 22:10:20<BR>商品編號 : HMT006<BR>商品名稱 : 貴盛工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-21 22:10:38', 3888, '2013-06-21 22:10:38', 3888),
(177, 991285120, 3, '交易成功 HMT016', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 22:13:20<BR>商品編號 : HMT016<BR>商品名稱 : 錦豐園<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-21 22:13:38', 991285120, '2013-06-21 22:13:38', 991285120),
(178, 3888, 3, '交易成功 HMT016', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 22:13:20<BR>商品編號 : HMT016<BR>商品名稱 : 錦豐園<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-21 22:13:38', 3888, '2013-06-21 22:13:38', 3888),
(179, 991285120, 3, '交易成功 HMT010', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 22:14:05<BR>商品編號 : HMT010<BR>商品名稱 : 好景工業大廈<BR>價錢 : 1<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 5050', 'N', 'N', NULL, NULL, '2013-06-21 22:14:38', 991285120, '2013-06-21 22:14:38', 991285120),
(180, 3888, 3, '交易成功 HMT010', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 22:14:05<BR>商品編號 : HMT010<BR>商品名稱 : 好景工業大廈<BR>價錢 : 1<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 4950', 'N', 'N', NULL, NULL, '2013-06-21 22:14:38', 3888, '2013-06-21 22:14:38', 3888),
(181, 991285120, 3, '交易成功 HMT012', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 22:15:45<BR>商品編號 : HMT012<BR>商品名稱 : 建邦商業大廈<BR>價錢 : 1.2<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 6050', 'N', 'R', NULL, NULL, '2013-06-21 22:16:38', 991285120, '2013-06-21 22:16:38', 991285120),
(182, 991285122, 3, '交易成功 HMT012', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 22:15:45<BR>商品編號 : HMT012<BR>商品名稱 : 建邦商業大廈<BR>價錢 : 1.2<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 5950', 'N', 'N', NULL, NULL, '2013-06-21 22:16:38', 991285122, '2013-06-21 22:16:38', 991285122),
(183, 991285120, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 22:16:30<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 99999<BR>差價 : 0.01<BR>總金額 : 100998.99', 'N', 'N', NULL, NULL, '2013-06-21 22:16:38', 991285120, '2013-06-21 22:16:38', 991285120),
(184, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 22:16:30<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 99999<BR>差價 : 0.01<BR>總金額 : 98999.01', 'N', 'N', NULL, NULL, '2013-06-21 22:16:38', 3888, '2013-06-21 22:16:38', 3888),
(185, 991285120, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 22:43:00<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.05<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 5300', 'N', 'R', NULL, NULL, '2013-06-21 22:43:38', 991285120, '2013-06-21 22:43:38', 991285120),
(186, 3888, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 22:43:00<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.05<BR>股數 : 5000<BR>差價 : 0.01<BR>總金額 : 5200', 'N', 'N', NULL, NULL, '2013-06-21 22:43:38', 3888, '2013-06-21 22:43:38', 3888),
(187, 991285120, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-21 22:44:05<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1.1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 11100', 'N', 'R', NULL, NULL, '2013-06-21 22:44:38', 991285120, '2013-06-21 22:44:38', 991285120),
(188, 3888, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-21 22:44:05<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'N', NULL, NULL, '2013-06-21 22:44:38', 3888, '2013-06-21 22:44:38', 3888),
(189, 991285122, 3, '交易成功 HMT005', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-24 13:25:10<BR>商品編號 : HMT005<BR>商品名稱 : 興盛工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-24 13:25:38', 991285122, '2013-06-24 13:25:38', 991285122),
(190, 3888, 3, '交易成功 HMT005', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-24 13:25:10<BR>商品編號 : HMT005<BR>商品名稱 : 興盛工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'R', NULL, NULL, '2013-06-24 13:25:38', 3888, '2013-06-24 13:25:38', 3888),
(191, 991285122, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-24 14:12:15<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-24 17:06:38', 991285122, '2013-06-24 17:06:38', 991285122),
(192, 3888, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-24 14:12:15<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'R', NULL, NULL, '2013-06-24 17:06:38', 3888, '2013-06-24 17:06:38', 3888),
(193, 991285122, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-24 14:12:20<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 10100', 'N', 'N', NULL, NULL, '2013-06-24 17:06:38', 991285122, '2013-06-24 17:06:38', 991285122),
(194, 3888, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-24 14:12:20<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 9900', 'N', 'R', NULL, NULL, '2013-06-24 17:06:38', 3888, '2013-06-24 17:06:38', 3888),
(231, 16513, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-24 17:45:00<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 2<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 20100', 'N', 'N', NULL, NULL, '2013-06-24 17:50:38', 16513, '2013-06-24 17:50:38', 16513),
(232, 991285122, 3, '交易成功 HMT001', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-24 17:45:00<BR>商品編號 : HMT001<BR>商品名稱 : 典雅大廈 <BR>價錢 : 2<BR>股數 : 10000<BR>差價 : 0.01<BR>總金額 : 19900', 'N', 'N', NULL, NULL, '2013-06-24 17:50:38', 991285122, '2013-06-24 17:50:38', 991285122),
(233, 991285122, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-24 23:55:15<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 15<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 15010', 'N', 'N', NULL, NULL, '2013-06-24 23:55:38', 991285122, '2013-06-24 23:55:38', 991285122),
(234, 3888, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-24 23:55:15<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 9<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 8990', 'N', 'R', NULL, NULL, '2013-06-24 23:55:38', 3888, '2013-06-24 23:55:38', 3888),
(235, 91285, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:22:35<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 8.5<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 8510', 'N', 'N', NULL, NULL, '2013-06-25 10:22:38', 91285, '2013-06-25 10:22:38', 91285),
(236, 991285118, 3, '交易成功 HMT002', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:22:35<BR>商品編號 : HMT002<BR>商品名稱 : 維景灣畔<BR>價錢 : 3<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 2990', 'N', 'N', NULL, NULL, '2013-06-25 10:22:38', 991285118, '2013-06-25 10:22:38', 991285118),
(237, 91285, 3, '交易成功 HMT023', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:34:50<BR>商品編號 : HMT023<BR>商品名稱 : 仁厚大廈<BR>價錢 : 2<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 2010', 'N', 'N', NULL, NULL, '2013-06-25 10:35:38', 91285, '2013-06-25 10:35:38', 91285),
(238, 991285122, 3, '交易成功 HMT023', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:34:50<BR>商品編號 : HMT023<BR>商品名稱 : 仁厚大廈<BR>價錢 : 2<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1990', 'N', 'N', NULL, NULL, '2013-06-25 10:35:38', 991285122, '2013-06-25 10:35:38', 991285122),
(239, 91285, 3, '交易成功 HMT019', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:36:20<BR>商品編號 : HMT019<BR>商品名稱 : 陽光廣場<BR>價錢 : 1.5<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1510', 'N', 'N', NULL, NULL, '2013-06-25 10:36:38', 91285, '2013-06-25 10:36:38', 91285),
(240, 991285122, 3, '交易成功 HMT019', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:36:20<BR>商品編號 : HMT019<BR>商品名稱 : 陽光廣場<BR>價錢 : 1.5<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1490', 'N', 'N', NULL, NULL, '2013-06-25 10:36:38', 991285122, '2013-06-25 10:36:38', 991285122),
(241, 91285, 3, '交易成功 HMT031', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:38:35<BR>商品編號 : HMT031<BR>商品名稱 : 豐隆工業大廈<BR>價錢 : 2<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 2010', 'N', 'N', NULL, NULL, '2013-06-25 10:38:38', 91285, '2013-06-25 10:38:38', 91285),
(242, 991285122, 3, '交易成功 HMT031', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:38:35<BR>商品編號 : HMT031<BR>商品名稱 : 豐隆工業大廈<BR>價錢 : 2<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1990', 'N', 'N', NULL, NULL, '2013-06-25 10:38:38', 991285122, '2013-06-25 10:38:38', 991285122),
(243, 91285, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:39:55<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'N', NULL, NULL, '2013-06-25 10:40:38', 91285, '2013-06-25 10:40:38', 91285),
(244, 3888, 3, '交易成功 HMT003', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:39:55<BR>商品編號 : HMT003<BR>商品名稱 : 雍雅軒<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'N', NULL, NULL, '2013-06-25 10:40:38', 3888, '2013-06-25 10:40:38', 3888),
(245, 91285, 3, '交易成功 HMT006', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:41:40<BR>商品編號 : HMT006<BR>商品名稱 : 貴盛工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'N', NULL, NULL, '2013-06-25 10:42:38', 91285, '2013-06-25 10:42:38', 91285),
(246, 3888, 3, '交易成功 HMT006', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:41:40<BR>商品編號 : HMT006<BR>商品名稱 : 貴盛工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'N', NULL, NULL, '2013-06-25 10:42:38', 3888, '2013-06-25 10:42:38', 3888),
(247, 91285, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:42:35<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.5<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1510', 'N', 'N', NULL, NULL, '2013-06-25 10:42:38', 91285, '2013-06-25 10:42:38', 91285),
(248, 991285122, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:42:35<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.5<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1490', 'N', 'N', NULL, NULL, '2013-06-25 10:42:38', 991285122, '2013-06-25 10:42:38', 991285122),
(249, 91285, 3, '交易成功 HMT017', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:45:25<BR>商品編號 : HMT017<BR>商品名稱 : 威豪花園<BR>價錢 : 1.1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1110', 'N', 'N', NULL, NULL, '2013-06-25 10:45:38', 91285, '2013-06-25 10:45:38', 91285),
(250, 991285120, 3, '交易成功 HMT017', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:45:25<BR>商品編號 : HMT017<BR>商品名稱 : 威豪花園<BR>價錢 : 1.1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1090', 'N', 'N', NULL, NULL, '2013-06-25 10:45:38', 991285120, '2013-06-25 10:45:38', 991285120),
(251, 91285, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 10:46:20<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'N', NULL, NULL, '2013-06-25 10:46:38', 91285, '2013-06-25 10:46:38', 91285),
(252, 3888, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 10:46:20<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'N', NULL, NULL, '2013-06-25 10:46:38', 3888, '2013-06-25 10:46:38', 3888),
(253, 91285, 3, '交易成功 HMT018', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:03:40<BR>商品編號 : HMT018<BR>商品名稱 : 御‧豪門<BR>價錢 : 1.8<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1810', 'N', 'N', NULL, NULL, '2013-06-25 11:04:38', 91285, '2013-06-25 11:04:38', 91285),
(254, 991285124, 3, '交易成功 HMT018', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:03:40<BR>商品編號 : HMT018<BR>商品名稱 : 御‧豪門<BR>價錢 : 1.8<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1790', 'N', 'N', NULL, NULL, '2013-06-25 11:04:38', 991285124, '2013-06-25 11:04:38', 991285124),
(255, 91285, 3, '交易成功 HMT006', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:05:15<BR>商品編號 : HMT006<BR>商品名稱 : 貴盛工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'N', NULL, NULL, '2013-06-25 11:05:38', 91285, '2013-06-25 11:05:38', 91285),
(256, 3888, 3, '交易成功 HMT006', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:05:15<BR>商品編號 : HMT006<BR>商品名稱 : 貴盛工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'N', NULL, NULL, '2013-06-25 11:05:38', 3888, '2013-06-25 11:05:38', 3888),
(257, 91285, 3, '交易成功 HMT008', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:06:05<BR>商品編號 : HMT008<BR>商品名稱 : 嘉力工業中心<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'N', NULL, NULL, '2013-06-25 11:06:38', 91285, '2013-06-25 11:06:38', 91285),
(258, 3888, 3, '交易成功 HMT008', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:06:05<BR>商品編號 : HMT008<BR>商品名稱 : 嘉力工業中心<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'N', NULL, NULL, '2013-06-25 11:06:38', 3888, '2013-06-25 11:06:38', 3888),
(259, 91285, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:11:20<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 9<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 9010', 'N', 'N', NULL, NULL, '2013-06-25 11:11:38', 91285, '2013-06-25 11:11:38', 91285),
(260, 3888, 3, '交易成功 HMT021', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:11:20<BR>商品編號 : HMT021<BR>商品名稱 : 美怡大廈<BR>價錢 : 9<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 8990', 'N', 'N', NULL, NULL, '2013-06-25 11:11:38', 3888, '2013-06-25 11:11:38', 3888),
(261, 91285, 3, '交易成功 HMT005', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:12:45<BR>商品編號 : HMT005<BR>商品名稱 : 興盛工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'N', NULL, NULL, '2013-06-25 11:13:38', 91285, '2013-06-25 11:13:38', 91285),
(262, 3888, 3, '交易成功 HMT005', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:12:45<BR>商品編號 : HMT005<BR>商品名稱 : 興盛工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'N', NULL, NULL, '2013-06-25 11:13:38', 3888, '2013-06-25 11:13:38', 3888),
(263, 91285, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:13:55<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.5<BR>股數 : 2000<BR>差價 : 0.01<BR>總金額 : 3020', 'N', 'N', NULL, NULL, '2013-06-25 11:14:38', 91285, '2013-06-25 11:14:38', 91285),
(264, 991285122, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:13:55<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.5<BR>股數 : 2000<BR>差價 : 0.01<BR>總金額 : 2980', 'N', 'N', NULL, NULL, '2013-06-25 11:14:38', 991285122, '2013-06-25 11:14:38', 991285122),
(265, 91285, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:19:50<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'N', NULL, NULL, '2013-06-25 11:20:38', 91285, '2013-06-25 11:20:38', 91285),
(266, 3888, 3, '交易成功 HMT004', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:19:50<BR>商品編號 : HMT004<BR>商品名稱 : 宏龍工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'N', NULL, NULL, '2013-06-25 11:20:38', 3888, '2013-06-25 11:20:38', 3888),
(267, 91285, 3, '交易成功 HMT005', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:22:05<BR>商品編號 : HMT005<BR>商品名稱 : 興盛工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1010', 'N', 'N', NULL, NULL, '2013-06-25 11:22:38', 91285, '2013-06-25 11:22:38', 91285),
(268, 3888, 3, '交易成功 HMT005', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:22:05<BR>商品編號 : HMT005<BR>商品名稱 : 興盛工業大廈<BR>價錢 : 1<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 990', 'N', 'N', NULL, NULL, '2013-06-25 11:22:38', 3888, '2013-06-25 11:22:38', 3888),
(269, 91285, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:23:50<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.5<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1510', 'N', 'N', NULL, NULL, '2013-06-25 11:24:38', 91285, '2013-06-25 11:24:38', 91285),
(270, 991285122, 3, '交易成功 HMT015', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:23:50<BR>商品編號 : HMT015<BR>商品名稱 : 香港商業中心<BR>價錢 : 1.5<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1490', 'N', 'N', NULL, NULL, '2013-06-25 11:24:38', 991285122, '2013-06-25 11:24:38', 991285122),
(271, 91285, 3, '交易成功 HMT023', '交易成功<BR><BR>操作 : 買入<BR>交易日期 : 2013-06-25 11:27:45<BR>商品編號 : HMT023<BR>商品名稱 : 仁厚大廈<BR>價錢 : 2<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 2010', 'N', 'N', NULL, NULL, '2013-06-25 11:28:38', 91285, '2013-06-25 11:28:38', 91285),
(272, 991285122, 3, '交易成功 HMT023', '交易成功<BR><BR>操作 : 賣出<BR>交易日期 : 2013-06-25 11:27:45<BR>商品編號 : HMT023<BR>商品名稱 : 仁厚大廈<BR>價錢 : 2<BR>股數 : 1000<BR>差價 : 0.01<BR>總金額 : 1990', 'N', 'N', NULL, NULL, '2013-06-25 11:28:38', 991285122, '2013-06-25 11:28:38', 991285122);

-- --------------------------------------------------------

--
-- 替换视图以便查看 `ax_mt4_users`
--
CREATE TABLE IF NOT EXISTS `ax_mt4_users` (
`id` int(11)
,`name` char(128)
,`email` char(48)
);
-- --------------------------------------------------------

--
-- 表的结构 `ax_opens`
--

CREATE TABLE IF NOT EXISTS `ax_opens` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `type` varchar(2) NOT NULL,
  `asset_id` int(11) unsigned NOT NULL,
  `volume` int(11) unsigned NOT NULL,
  `open_price` double NOT NULL,
  `open_time` datetime NOT NULL,
  `close_time` datetime DEFAULT NULL,
  `fulfil_volume` int(11) unsigned NOT NULL DEFAULT '0',
  `status` varchar(2) NOT NULL DEFAULT 'A',
  `ran_match` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `comment` text,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(11) unsigned NOT NULL,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_open_idx` (`user_id`),
  KEY `idx_symbol` (`asset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=362 ;

--
-- 转存表中的数据 `ax_opens`
--

INSERT INTO `ax_opens` (`id`, `user_id`, `type`, `asset_id`, `volume`, `open_price`, `open_time`, `close_time`, `fulfil_volume`, `status`, `ran_match`, `comment`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 3888, 'S', 19, 120000, 1.1, '2013-06-18 19:41:43', NULL, 120000, 'F', 1, '', '2013-06-18 19:41:43', 3888, '2013-06-18 20:22:10', 3888),
(2, 3888, 'S', 20, 300000, 1.1, '2013-06-18 19:42:09', NULL, 300000, 'F', 1, 'ipo', '2013-06-18 19:42:09', 3888, '2013-06-18 20:25:44', 3888),
(3, 3888, 'S', 21, 10000, 1.1, '2013-06-18 19:43:26', NULL, 10000, 'F', 1, 'ipo', '2013-06-18 19:43:26', 3888, '2013-06-18 20:44:49', 3888),
(4, 3888, 'S', 22, 200000, 1.1, '2013-06-18 19:44:15', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:44:15', 3888, '2013-06-18 20:45:27', 3888),
(5, 3888, 'S', 23, 2000000, 1.1, '2013-06-18 19:44:45', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:44:45', 3888, '2013-06-18 20:45:04', 3888),
(6, 3888, 'S', 24, 200000, 1.1, '2013-06-18 19:45:25', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:45:25', 3888, '2013-06-18 20:45:36', 3888),
(7, 3888, 'S', 26, 20000, 1.1, '2013-06-18 19:47:10', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:47:10', 3888, '2013-06-18 20:45:44', 3888),
(8, 3888, 'S', 27, 10000, 1.1, '2013-06-18 19:47:37', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:47:37', 3888, '2013-06-18 20:45:55', 3888),
(9, 3888, 'S', 28, 5000, 1.1, '2013-06-18 19:47:59', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:47:59', 3888, '2013-06-18 20:46:03', 3888),
(10, 3888, 'S', 29, 10000, 1.1, '2013-06-18 19:48:26', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:48:26', 3888, '2013-06-18 20:46:13', 3888),
(11, 3888, 'S', 30, 5000, 1.1, '2013-06-18 19:48:45', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:48:45', 3888, '2013-06-18 20:46:22', 3888),
(12, 3888, 'S', 31, 50000, 1.1, '2013-06-18 19:49:07', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:49:07', 3888, '2013-06-18 20:46:30', 3888),
(13, 3888, 'S', 31, 10000, 1.1, '2013-06-18 19:49:30', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:49:30', 3888, '2013-06-18 20:46:40', 3888),
(14, 3888, 'S', 32, 5000, 1.1, '2013-06-18 19:49:50', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:49:50', 3888, '2013-06-18 20:46:49', 3888),
(15, 3888, 'S', 33, 5000, 1.1, '2013-06-18 19:50:14', NULL, 5000, 'F', 1, 'ipo', '2013-06-18 19:50:14', 3888, '2013-06-18 20:47:02', 3888),
(16, 3888, 'S', 34, 10000, 1.1, '2013-06-18 19:50:36', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:50:36', 3888, '2013-06-18 20:47:10', 3888),
(17, 3888, 'S', 35, 5000, 1.1, '2013-06-18 19:50:59', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:50:59', 3888, '2013-06-18 20:47:18', 3888),
(18, 3888, 'S', 35, 10000, 1.1, '2013-06-18 19:51:21', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:51:21', 3888, '2013-06-18 20:47:28', 3888),
(19, 3888, 'S', 36, 15000, 1.1, '2013-06-18 19:51:43', '2013-06-18 20:11:41', 15000, 'F', 1, 'ipo', '2013-06-18 19:51:43', 3888, '2013-06-18 19:51:43', 3888),
(20, 3888, 'S', 37, 5000, 1.1, '2013-06-18 19:52:02', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:52:02', 3888, '2013-06-18 20:47:36', 3888),
(21, 3888, 'S', 38, 10000, 1.1, '2013-06-18 19:52:22', '2013-06-18 20:10:21', 10000, 'F', 1, 'ipo', '2013-06-18 19:52:22', 3888, '2013-06-18 19:52:22', 3888),
(22, 3888, 'S', 39, 10000, 1.1, '2013-06-18 19:52:42', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:52:42', 3888, '2013-06-18 20:47:46', 3888),
(23, 3888, 'S', 40, 5000, 1.1, '2013-06-18 19:53:06', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:53:06', 3888, '2013-06-18 20:48:08', 3888),
(24, 3888, 'S', 41, 10000, 1.1, '2013-06-18 19:53:26', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:53:26', 3888, '2013-06-18 20:48:00', 3888),
(25, 3888, 'S', 43, 15000, 1.1, '2013-06-18 19:53:46', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:53:46', 3888, '2013-06-18 20:48:17', 3888),
(26, 3888, 'S', 44, 10000, 1.1, '2013-06-18 19:54:05', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:54:05', 3888, '2013-06-18 20:48:26', 3888),
(27, 3888, 'S', 45, 10000, 1.1, '2013-06-18 19:54:24', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:54:24', 3888, '2013-06-18 20:48:36', 3888),
(28, 3888, 'S', 47, 15000, 1.1, '2013-06-18 19:54:47', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:54:47', 3888, '2013-06-18 20:48:44', 3888),
(29, 3888, 'S', 48, 10000, 1.1, '2013-06-18 19:55:05', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:55:05', 3888, '2013-06-18 20:48:53', 3888),
(30, 3888, 'S', 49, 10000, 1.1, '2013-06-18 19:55:23', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:55:23', 3888, '2013-06-18 20:49:04', 3888),
(31, 3888, 'S', 50, 10000, 1.1, '2013-06-18 19:55:43', NULL, 10000, 'F', 1, 'ipo', '2013-06-18 19:55:43', 3888, '2013-06-18 20:49:16', 3888),
(32, 3888, 'S', 46, 5000, 1.1, '2013-06-18 19:56:31', NULL, 0, 'C', 1, 'ipo', '2013-06-18 19:56:31', 3888, '2013-06-18 20:49:26', 3888),
(33, 3888, 'B', 19, 10000, 0.9, '2013-06-18 19:58:30', NULL, 0, 'A', 1, '', '2013-06-18 19:58:30', 3888, '2013-06-18 19:58:30', 3888),
(34, 3888, 'B', 20, 10000, 0.9, '2013-06-18 19:58:57', NULL, 0, 'A', 1, '', '2013-06-18 19:58:57', 3888, '2013-06-18 19:58:57', 3888),
(35, 991285119, 'B', 38, 100000, 1, '2013-06-18 19:59:13', NULL, 0, 'C', 1, '', '2013-06-18 19:59:13', 991285119, '2013-06-18 20:10:21', 991285119),
(36, 3888, 'B', 21, 10000, 0.9, '2013-06-18 19:59:15', NULL, 0, 'A', 1, '', '2013-06-18 19:59:15', 3888, '2013-06-18 19:59:15', 3888),
(37, 991285119, 'B', 19, 100000, 0.9, '2013-06-18 20:03:01', NULL, 0, 'C', 1, '', '2013-06-18 20:03:01', 991285119, '2013-06-18 20:10:33', 991285119),
(38, 991285119, 'B', 20, 100000, 1.1, '2013-06-18 20:03:26', NULL, 0, 'C', 1, '', '2013-06-18 20:03:26', 991285119, '2013-06-18 20:10:45', 991285119),
(39, 991285119, 'B', 21, 10000, 1, '2013-06-18 20:04:06', NULL, 0, 'C', 1, '', '2013-06-18 20:04:06', 991285119, '2013-06-18 20:10:55', 991285119),
(40, 991285119, 'B', 43, 100000, 1, '2013-06-18 20:04:36', NULL, 0, 'C', 1, '', '2013-06-18 20:04:36', 991285119, '2013-06-18 20:10:10', 991285119),
(41, 991285118, 'B', 38, 50000, 1.1, '2013-06-18 20:10:08', NULL, 0, 'C', 1, '', '2013-06-18 20:10:08', 991285118, '2013-06-18 20:17:31', 991285118),
(42, 991285119, 'B', 38, 10000, 1.2, '2013-06-18 20:10:21', NULL, 10000, 'F', 1, '', '2013-06-18 20:10:21', 991285119, '2013-06-18 20:11:05', 991285119),
(43, 991285119, 'B', 19, 100000, 1.2, '2013-06-18 20:10:33', NULL, 100000, 'F', 1, '', '2013-06-18 20:10:33', 991285119, '2013-06-18 20:10:33', 991285119),
(44, 991285119, 'B', 20, 100000, 1.2, '2013-06-18 20:10:45', NULL, 100000, 'F', 1, '', '2013-06-18 20:10:45', 991285119, '2013-06-18 20:10:45', 991285119),
(45, 991285119, 'B', 21, 10000, 1.2, '2013-06-18 20:10:55', NULL, 10000, 'F', 1, '', '2013-06-18 20:10:55', 991285119, '2013-06-18 20:10:55', 991285119),
(46, 991285118, 'B', 47, 200000, 1.1, '2013-06-18 20:11:05', NULL, 0, 'C', 1, '', '2013-06-18 20:11:05', 991285118, '2013-06-18 20:37:36', 991285118),
(47, 991285118, 'B', 20, 100000, 1.2, '2013-06-18 20:11:29', NULL, 100000, 'F', 1, '', '2013-06-18 20:11:29', 991285118, '2013-06-18 20:11:29', 991285118),
(48, 991285118, 'B', 36, 15000, 1.2, '2013-06-18 20:11:41', NULL, 15000, 'F', 1, '', '2013-06-18 20:11:41', 991285118, '2013-06-18 20:37:55', 991285118),
(49, 991285119, 'B', 38, 5000, 2, '2013-06-18 20:12:40', NULL, 0, 'C', 1, '', '2013-06-18 20:12:40', 991285119, '2013-06-18 20:19:05', 991285119),
(50, 991285118, 'S', 20, 10000, 1.4, '2013-06-18 20:12:51', NULL, 10000, 'F', 1, '', '2013-06-18 20:12:51', 991285118, '2013-06-18 20:38:00', 991285118),
(51, 991285122, 'B', 19, 20000, 1.3, '2013-06-18 20:12:53', NULL, 20000, 'F', 1, '', '2013-06-18 20:12:53', 991285122, '2013-06-18 20:12:53', 991285122),
(52, 991285119, 'S', 38, 10000, 1.5, '2013-06-18 20:13:00', NULL, 0, 'C', 1, '', '2013-06-18 20:13:00', 991285119, '2013-06-18 20:19:07', 991285119),
(53, 991285119, 'S', 19, 10000, 1.3, '2013-06-18 20:14:57', NULL, 0, 'C', 1, '', '2013-06-18 20:14:57', 991285119, '2013-06-18 20:19:11', 991285119),
(54, 991285122, 'S', 19, 10000, 1.4, '2013-06-18 20:15:44', '2013-06-18 20:44:19', 10000, 'F', 1, '', '2013-06-18 20:15:44', 991285122, '2013-06-18 20:15:44', 991285122),
(55, 991285118, 'B', 38, 50000, 1.5, '2013-06-18 20:17:31', NULL, 0, 'C', 1, '', '2013-06-18 20:17:31', 991285118, '2013-06-18 20:39:00', 991285118),
(56, 991285119, 'B', 20, 100000, 2.1, '2013-06-18 20:19:33', NULL, 100000, 'F', 1, '', '2013-06-18 20:19:33', 991285119, '2013-06-18 20:19:33', 991285119),
(57, 991285119, 'S', 20, 200000, 1.9, '2013-06-18 20:20:10', NULL, 0, 'C', 1, '', '2013-06-18 20:20:10', 991285119, '2013-06-18 20:41:02', 991285119),
(58, 991285118, 'S', 36, 15000, 2, '2013-06-18 20:21:33', NULL, 0, 'C', 1, '', '2013-06-18 20:21:33', 991285118, '2013-06-18 21:05:10', 991285118),
(59, 3888, 'S', 19, 10000, 1.1, '2013-06-18 20:22:10', '2013-06-18 20:22:45', 10000, 'F', 1, '', '2013-06-18 20:22:10', 3888, '2013-06-18 20:22:10', 3888),
(60, 991285122, 'B', 19, 10000, 1.3, '2013-06-18 20:22:45', NULL, 10000, 'F', 1, '', '2013-06-18 20:22:45', 991285122, '2013-06-18 20:22:45', 991285122),
(61, 991285122, 'S', 19, 10000, 1.35, '2013-06-18 20:23:18', '2013-06-18 20:44:18', 10000, 'F', 1, '', '2013-06-18 20:23:18', 991285122, '2013-06-18 20:23:18', 991285122),
(62, 3888, 'S', 20, 10000, 2, '2013-06-18 20:25:44', '2013-06-18 20:53:31', 10000, 'F', 1, 'ipo', '2013-06-18 20:25:44', 3888, '2013-06-18 20:25:44', 3888),
(63, 991285122, 'B', 20, 10000, 2.3, '2013-06-18 20:28:43', NULL, 10000, 'F', 1, '', '2013-06-18 20:28:43', 991285122, '2013-06-18 20:28:43', 991285122),
(64, 991285118, 'S', 20, 90000, 2.3, '2013-06-18 20:38:39', NULL, 0, 'C', 1, '', '2013-06-18 20:38:39', 991285118, '2013-06-18 21:02:14', 991285118),
(65, 991285122, 'S', 20, 10000, 2.5, '2013-06-18 20:40:18', NULL, 0, 'C', 1, '', '2013-06-18 20:40:18', 991285122, '2013-06-18 20:54:37', 991285122),
(66, 991285122, 'B', 33, 200000, 1.1, '2013-06-18 20:41:19', NULL, 0, 'C', 1, '', '2013-06-18 20:41:19', 991285122, '2013-06-18 20:42:05', 991285122),
(67, 991285119, 'S', 20, 100000, 2.1, '2013-06-18 20:41:25', NULL, 0, 'C', 1, '', '2013-06-18 20:41:25', 991285119, '2013-06-18 20:48:35', 991285119),
(68, 991285122, 'B', 33, 5000, 1.1, '2013-06-18 20:42:05', NULL, 0, 'C', 1, '', '2013-06-18 20:42:05', 991285122, '2013-06-18 20:42:53', 991285122),
(69, 991285119, 'S', 20, 100000, 2.3, '2013-06-18 20:42:11', NULL, 0, 'C', 1, '', '2013-06-18 20:42:11', 991285119, '2013-06-18 20:48:24', 991285119),
(70, 991285119, 'S', 19, 100000, 1.6, '2013-06-18 20:42:53', NULL, 0, 'C', 1, '', '2013-06-18 20:42:53', 991285119, '2013-06-18 20:45:11', 991285119),
(71, 991285122, 'B', 33, 5000, 1.2, '2013-06-18 20:42:53', NULL, 5000, 'F', 1, '', '2013-06-18 20:42:53', 991285122, '2013-06-18 20:42:53', 991285122),
(72, 991285122, 'B', 50, 10000, 1.2, '2013-06-18 20:43:38', NULL, 10000, 'F', 1, '', '2013-06-18 20:43:38', 991285122, '2013-06-18 20:43:38', 991285122),
(73, 991285118, 'B', 19, 100000, 1.6, '2013-06-18 20:44:18', '2013-06-18 20:45:11', 100000, 'F', 1, '', '2013-06-18 20:44:18', 991285118, '2013-06-18 20:44:18', 991285118),
(74, 3888, 'S', 21, 1990000, 1, '2013-06-18 20:44:48', NULL, 1131999, 'A', 1, 'ipo', '2013-06-18 20:44:48', 3888, '2013-06-25 10:39:55', 3888),
(75, 3888, 'S', 23, 2000000, 1, '2013-06-18 20:45:04', NULL, 22000, 'A', 1, 'ipo', '2013-06-18 20:45:04', 3888, '2013-06-25 11:22:05', 3888),
(76, 991285119, 'S', 19, 80000, 1.5, '2013-06-18 20:45:11', NULL, 80000, 'F', 1, '', '2013-06-18 20:45:11', 991285119, '2013-06-18 20:50:38', 991285119),
(77, 3888, 'S', 22, 200000, 1, '2013-06-18 20:45:27', NULL, 37000, 'A', 1, 'ipo', '2013-06-18 20:45:27', 3888, '2013-06-25 11:19:50', 3888),
(78, 3888, 'S', 24, 200000, 1, '2013-06-18 20:45:36', NULL, 12000, 'A', 1, 'ipo', '2013-06-18 20:45:36', 3888, '2013-06-25 11:05:15', 3888),
(79, 3888, 'S', 26, 20000, 1, '2013-06-18 20:45:44', NULL, 11000, 'A', 1, 'ipo', '2013-06-18 20:45:44', 3888, '2013-06-25 11:06:05', 3888),
(80, 3888, 'S', 27, 10000, 1, '2013-06-18 20:45:55', '2013-06-21 21:50:05', 10000, 'F', 1, 'ipo', '2013-06-18 20:45:55', 3888, '2013-06-21 21:50:05', 3888),
(81, 3888, 'S', 28, 5000, 1, '2013-06-18 20:46:03', '2013-06-21 22:14:05', 5000, 'F', 1, 'ipo', '2013-06-18 20:46:03', 3888, '2013-06-21 22:14:05', 3888),
(82, 3888, 'S', 29, 10000, 1, '2013-06-18 20:46:13', '2013-06-21 21:51:00', 10000, 'F', 1, 'ipo', '2013-06-18 20:46:13', 3888, '2013-06-21 21:51:00', 3888),
(83, 991285118, 'B', 36, 20000, 1.2, '2013-06-18 20:46:17', NULL, 0, 'C', 1, '', '2013-06-18 20:46:17', 991285118, '2013-06-18 21:03:58', 991285118),
(84, 3888, 'S', 30, 5000, 1, '2013-06-18 20:46:22', '2013-06-18 21:15:58', 5000, 'F', 1, 'ipo', '2013-06-18 20:46:22', 3888, '2013-06-18 20:46:22', 3888),
(85, 3888, 'S', 31, 50000, 1, '2013-06-18 20:46:30', '2013-06-21 21:56:50', 50000, 'F', 1, 'ipo', '2013-06-18 20:46:30', 3888, '2013-06-21 21:56:50', 3888),
(86, 3888, 'S', 31, 10000, 1, '2013-06-18 20:46:40', '2013-06-21 21:56:50', 10000, 'F', 1, 'ipo', '2013-06-18 20:46:40', 3888, '2013-06-21 21:56:50', 3888),
(87, 3888, 'S', 32, 5000, 1, '2013-06-18 20:46:49', '2013-06-19 17:04:15', 5000, 'F', 1, 'ipo', '2013-06-18 20:46:49', 3888, '2013-06-19 17:04:15', 3888),
(88, 991285118, 'B', 36, 150000, 1.2, '2013-06-18 20:46:51', NULL, 0, 'C', 1, '', '2013-06-18 20:46:51', 991285118, '2013-06-18 21:04:55', 991285118),
(89, 3888, 'S', 33, 5000, 1.05, '2013-06-18 20:47:02', '2013-06-21 22:43:00', 5000, 'F', 1, 'ipo', '2013-06-18 20:47:02', 3888, '2013-06-21 22:43:00', 3888),
(90, 3888, 'S', 34, 10000, 1, '2013-06-18 20:47:10', '2013-06-21 22:13:20', 10000, 'F', 1, 'ipo', '2013-06-18 20:47:10', 3888, '2013-06-21 22:13:20', 3888),
(91, 3888, 'S', 35, 5000, 1, '2013-06-18 20:47:18', '2013-06-19 01:46:03', 5000, 'F', 1, 'ipo', '2013-06-18 20:47:18', 3888, '2013-06-18 20:47:18', 3888),
(92, 3888, 'S', 35, 10000, 1, '2013-06-18 20:47:28', '2013-06-19 17:02:45', 10000, 'F', 1, 'ipo', '2013-06-18 20:47:28', 3888, '2013-06-19 17:02:45', 3888),
(93, 3888, 'S', 37, 5000, 1, '2013-06-18 20:47:36', '2013-06-19 01:43:50', 5000, 'F', 1, 'ipo', '2013-06-18 20:47:36', 3888, '2013-06-18 20:47:36', 3888),
(94, 3888, 'S', 39, 10000, 1, '2013-06-18 20:47:46', '2013-06-18 21:44:30', 10000, 'F', 1, 'ipo', '2013-06-18 20:47:46', 3888, '2013-06-18 20:47:46', 3888),
(95, 3888, 'S', 41, 10000, 1, '2013-06-18 20:48:00', '2013-06-19 01:43:25', 10000, 'F', 1, 'ipo', '2013-06-18 20:48:00', 3888, '2013-06-18 20:48:00', 3888),
(96, 3888, 'S', 40, 5000, 1, '2013-06-18 20:48:08', '2013-06-19 23:42:50', 5000, 'F', 1, 'ipo', '2013-06-18 20:48:08', 3888, '2013-06-19 23:42:50', 3888),
(97, 3888, 'S', 43, 15000, 1, '2013-06-18 20:48:17', '2013-06-19 17:05:00', 15000, 'F', 1, 'ipo', '2013-06-18 20:48:17', 3888, '2013-06-19 17:05:00', 3888),
(98, 991285119, 'S', 20, 100000, 2, '2013-06-18 20:48:24', NULL, 0, 'C', 1, '', '2013-06-18 20:48:24', 991285119, '2013-06-18 20:53:31', 991285119),
(99, 3888, 'S', 44, 10000, 1, '2013-06-18 20:48:26', '2013-06-18 21:43:00', 10000, 'F', 1, 'ipo', '2013-06-18 20:48:26', 3888, '2013-06-18 20:48:26', 3888),
(100, 991285119, 'S', 20, 100000, 2, '2013-06-18 20:48:34', NULL, 0, 'C', 1, '', '2013-06-18 20:48:34', 991285119, '2013-06-18 20:53:34', 991285119),
(101, 3888, 'S', 45, 10000, 1, '2013-06-18 20:48:36', '2013-06-21 21:42:05', 10000, 'F', 1, 'ipo', '2013-06-18 20:48:36', 3888, '2013-06-21 21:42:05', 3888),
(102, 3888, 'S', 47, 15000, 1, '2013-06-18 20:48:44', '2013-06-21 21:54:55', 15000, 'F', 1, 'ipo', '2013-06-18 20:48:44', 3888, '2013-06-21 21:54:55', 3888),
(103, 3888, 'S', 48, 10000, 1, '2013-06-18 20:48:53', '2013-06-21 21:12:10', 10000, 'F', 1, 'ipo', '2013-06-18 20:48:53', 3888, '2013-06-21 21:12:10', 3888),
(104, 3888, 'S', 49, 10000, 1, '2013-06-18 20:49:04', '2013-06-21 21:47:00', 10000, 'F', 1, 'ipo', '2013-06-18 20:49:04', 3888, '2013-06-21 21:47:00', 3888),
(105, 3888, 'S', 50, 5000, 1.05, '2013-06-18 20:49:16', '2013-06-18 21:10:25', 5000, 'F', 1, 'ipo', '2013-06-18 20:49:16', 3888, '2013-06-18 20:49:16', 3888),
(106, 3888, 'S', 46, 5000, 1, '2013-06-18 20:49:26', '2013-06-18 20:51:20', 5000, 'F', 1, 'ipo', '2013-06-18 20:49:26', 3888, '2013-06-18 20:49:26', 3888),
(107, 991285119, 'S', 19, 20000, 1.5, '2013-06-18 20:50:38', NULL, 0, 'C', 1, '', '2013-06-18 20:50:38', 991285119, '2013-06-18 20:53:36', 991285119),
(108, 991285119, 'B', 46, 5000, 1.2, '2013-06-18 20:51:20', NULL, 5000, 'F', 1, '', '2013-06-18 20:51:20', 991285119, '2013-06-18 20:53:39', 991285119),
(109, 991285122, 'B', 20, 10000, 3, '2013-06-18 20:53:31', NULL, 10000, 'F', 1, '', '2013-06-18 20:53:31', 991285122, '2013-06-18 20:53:31', 991285122),
(110, 991285119, 'S', 20, 200000, 2, '2013-06-18 20:54:03', NULL, 0, 'C', 1, '', '2013-06-18 20:54:03', 991285119, '2013-06-18 20:54:46', 991285119),
(111, 991285122, 'S', 20, 10000, 3, '2013-06-18 20:54:37', NULL, 0, 'C', 1, '', '2013-06-18 20:54:37', 991285122, '2013-06-18 21:25:32', 991285122),
(112, 991285119, 'S', 20, 60000, 2.5, '2013-06-18 20:54:46', NULL, 60000, 'F', 1, '', '2013-06-18 20:54:46', 991285119, '2013-06-18 22:10:09', 991285119),
(113, 991285122, 'S', 19, 10000, 1.5, '2013-06-18 20:58:18', '2013-06-18 21:13:04', 10000, 'F', 1, '', '2013-06-18 20:58:18', 991285122, '2013-06-18 20:58:18', 991285122),
(114, 991285118, 'S', 19, 100000, 1.5, '2013-06-18 21:01:24', NULL, 0, 'C', 1, '', '2013-06-18 21:01:24', 991285118, '2013-06-18 21:05:04', 991285118),
(115, 991285122, 'B', 36, 5000, 1.5, '2013-06-18 21:04:20', NULL, 0, 'A', 1, '', '2013-06-18 21:04:20', 991285122, '2013-06-18 21:04:20', 991285122),
(116, 991285118, 'S', 20, 90000, 3, '2013-06-18 21:07:50', NULL, 0, 'C', 1, '', '2013-06-18 21:07:50', 991285118, '2013-06-18 22:12:34', 991285118),
(117, 991285118, 'S', 36, 15000, 1.5, '2013-06-18 21:08:57', '2013-06-18 22:26:41', 15000, 'F', 1, '', '2013-06-18 21:08:57', 991285118, '2013-06-18 21:08:57', 991285118),
(118, 991285118, 'S', 19, 100000, 2, '2013-06-18 21:09:15', NULL, 0, 'C', 1, '', '2013-06-18 21:09:15', 991285118, '2013-06-18 21:14:19', 991285118),
(119, 991285124, 'B', 50, 5000, 1.3, '2013-06-18 21:10:25', NULL, 5000, 'F', 1, '', '2013-06-18 21:10:25', 991285124, '2013-06-18 21:10:25', 991285124),
(120, 991285119, 'S', 19, 20000, 1.6, '2013-06-18 21:12:40', '2013-06-18 21:19:15', 20000, 'F', 1, '', '2013-06-18 21:12:40', 991285119, '2013-06-18 21:12:40', 991285119),
(121, 991285119, 'S', 38, 10000, 1.5, '2013-06-18 21:13:02', NULL, 0, 'C', 1, '', '2013-06-18 21:13:02', 991285119, '2013-06-21 21:28:44', 991285119),
(122, 991285118, 'B', 19, 10000, 2.1, '2013-06-18 21:13:04', NULL, 10000, 'F', 1, '', '2013-06-18 21:13:04', 991285118, '2013-06-18 21:13:04', 991285118),
(123, 991285119, 'S', 21, 10000, 2, '2013-06-18 21:13:26', NULL, 0, 'C', 1, '', '2013-06-18 21:13:26', 991285119, '2013-06-18 22:14:57', 991285119),
(124, 991285119, 'S', 46, 5000, 2, '2013-06-18 21:13:43', NULL, 0, 'C', 1, '', '2013-06-18 21:13:43', 991285119, '2013-06-21 21:28:49', 991285119),
(125, 991285118, 'S', 19, 100000, 1.8, '2013-06-18 21:14:19', NULL, 0, 'C', 1, '', '2013-06-18 21:14:19', 991285118, '2013-06-18 21:17:21', 991285118),
(126, 991285119, 'B', 27, 100000, 1, '2013-06-18 21:14:30', NULL, 0, 'C', 1, '', '2013-06-18 21:14:30', 991285119, '2013-06-21 21:28:52', 991285119),
(127, 991285122, 'B', 20, 10000, 2.3, '2013-06-18 21:14:53', NULL, 0, 'C', 1, '', '2013-06-18 21:14:53', 991285122, '2013-06-18 21:26:00', 991285122),
(128, 991285118, 'S', 19, 10000, 2.5, '2013-06-18 21:15:00', NULL, 0, 'C', 1, '', '2013-06-18 21:15:00', 991285118, '2013-06-18 21:15:38', 991285118),
(129, 991285119, 'B', 26, 40000, 1, '2013-06-18 21:15:24', NULL, 0, 'C', 1, '', '2013-06-18 21:15:24', 991285119, '2013-06-18 22:10:32', 991285119),
(130, 991285118, 'B', 19, 10000, 2.5, '2013-06-18 21:15:55', NULL, 10000, 'F', 1, '', '2013-06-18 21:15:55', 991285118, '2013-06-18 21:15:55', 991285118),
(131, 991285122, 'B', 30, 50000, 1.1, '2013-06-18 21:15:57', NULL, 5000, 'A', 1, '', '2013-06-18 21:15:57', 991285122, '2013-06-18 21:15:57', 991285122),
(132, 991285118, 'S', 19, 20000, 2.5, '2013-06-18 21:17:51', '2013-06-18 21:26:37', 20000, 'F', 1, '', '2013-06-18 21:17:51', 991285118, '2013-06-18 21:17:51', 991285118),
(133, 991285118, 'B', 20, 20000, 2.9, '2013-06-18 21:18:36', NULL, 20000, 'F', 1, '', '2013-06-18 21:18:36', 991285118, '2013-06-18 21:18:36', 991285118),
(134, 991285122, 'S', 30, 5000, 1.2, '2013-06-18 21:18:38', '2013-06-21 22:15:45', 5000, 'F', 1, '', '2013-06-18 21:18:38', 991285122, '2013-06-21 22:15:45', 991285122),
(135, 991285118, 'B', 19, 10000, 3, '2013-06-18 21:19:15', NULL, 10000, 'F', 1, '', '2013-06-18 21:19:15', 991285118, '2013-06-18 21:19:15', 991285118),
(136, 991285118, 'B', 19, 10000, 3, '2013-06-18 21:19:17', NULL, 0, 'C', 1, '', '2013-06-18 21:19:17', 991285118, '2013-06-18 21:44:34', 991285118),
(137, 991285118, 'S', 19, 10000, 2.6, '2013-06-18 21:19:23', '2013-06-18 21:26:38', 10000, 'F', 1, '', '2013-06-18 21:19:23', 991285118, '2013-06-18 21:19:23', 991285118),
(138, 991285122, 'B', 20, 10000, 2.8, '2013-06-18 21:19:42', NULL, 10000, 'F', 1, '', '2013-06-18 21:19:42', 991285122, '2013-06-18 21:19:42', 991285122),
(139, 991285118, 'B', 35, 5000, 0.9, '2013-06-18 21:20:23', NULL, 0, 'C', 1, '', '2013-06-18 21:20:23', 991285118, '2013-06-18 21:59:00', 991285118),
(140, 991285122, 'B', 20, 10000, 2.6, '2013-06-18 21:21:12', NULL, 10000, 'F', 1, '', '2013-06-18 21:21:12', 991285122, '2013-06-18 21:21:12', 991285122),
(141, 991285118, 'S', 19, 10000, 4, '2013-06-18 21:23:29', '2013-06-18 21:29:32', 10000, 'F', 1, '', '2013-06-18 21:23:29', 991285118, '2013-06-18 21:23:29', 991285118),
(142, 991285118, 'S', 19, 90000, 3, '2013-06-18 21:23:56', '2013-06-18 21:27:44', 90000, 'F', 1, '', '2013-06-18 21:23:56', 991285118, '2013-06-18 21:23:56', 991285118),
(143, 991285122, 'B', 20, 10000, 3, '2013-06-18 21:24:37', NULL, 10000, 'F', 1, '', '2013-06-18 21:24:37', 991285122, '2013-06-18 21:24:37', 991285122),
(144, 991285122, 'S', 20, 10000, 3, '2013-06-18 21:25:32', NULL, 0, 'C', 1, '', '2013-06-18 21:25:32', 991285122, '2013-06-18 21:26:19', 991285122),
(145, 991285124, 'B', 19, 100000, 3.1, '2013-06-18 21:26:37', NULL, 100000, 'F', 1, '', '2013-06-18 21:26:37', 991285124, '2013-06-18 21:26:37', 991285124),
(146, 991285122, 'S', 20, 20000, 3, '2013-06-18 21:26:42', NULL, 20000, 'F', 1, '', '2013-06-18 21:26:42', 991285122, '2013-06-19 01:18:40', 991285122),
(147, 991285124, 'B', 19, 10000, 4, '2013-06-18 21:27:21', NULL, 10000, 'F', 1, '', '2013-06-18 21:27:21', 991285124, '2013-06-18 21:27:21', 991285124),
(148, 991285122, 'S', 50, 10000, 1.3, '2013-06-18 21:27:42', NULL, 0, 'C', 1, '', '2013-06-18 21:27:42', 991285122, '2013-06-18 21:36:10', 991285122),
(149, 991285124, 'B', 19, 10000, 4.2, '2013-06-18 21:27:44', NULL, 10000, 'F', 1, '', '2013-06-18 21:27:44', 991285124, '2013-06-18 21:27:44', 991285124),
(150, 991285122, 'B', 19, 10000, 4, '2013-06-18 21:29:05', NULL, 0, 'C', 1, '', '2013-06-18 21:29:05', 991285122, '2013-06-18 21:29:32', 991285122),
(151, 991285122, 'B', 19, 10000, 4.5, '2013-06-18 21:29:32', NULL, 10000, 'F', 1, '', '2013-06-18 21:29:32', 991285122, '2013-06-18 21:29:32', 991285122),
(152, 991285124, 'B', 19, 10000, 5, '2013-06-18 21:29:43', '2013-06-18 21:34:17', 10000, 'F', 1, '', '2013-06-18 21:29:43', 991285124, '2013-06-18 21:29:43', 991285124),
(153, 991285124, 'B', 19, 10000, 5, '2013-06-18 21:30:18', NULL, 0, 'C', 1, '', '2013-06-18 21:30:18', 991285124, '2013-06-18 21:39:58', 991285124),
(154, 991285124, 'S', 50, 5000, 1.4, '2013-06-18 21:30:36', '2013-06-18 21:35:27', 5000, 'F', 1, '', '2013-06-18 21:30:36', 991285124, '2013-06-18 21:30:36', 991285124),
(155, 991285124, 'S', 19, 120000, 4, '2013-06-18 21:30:41', NULL, 0, 'C', 1, '', '2013-06-18 21:30:41', 991285124, '2013-06-18 21:39:34', 991285124),
(156, 991285122, 'S', 19, 10000, 4.7, '2013-06-18 21:34:17', NULL, 10000, 'F', 1, '', '2013-06-18 21:34:17', 991285122, '2013-06-18 21:34:17', 991285122),
(157, 991285122, 'B', 20, 10000, 3.3, '2013-06-18 21:34:55', NULL, 10000, 'F', 1, '', '2013-06-18 21:34:55', 991285122, '2013-06-18 21:34:55', 991285122),
(158, 991285122, 'B', 50, 10000, 1.5, '2013-06-18 21:35:27', NULL, 5000, 'A', 1, '', '2013-06-18 21:35:27', 991285122, '2013-06-18 21:35:27', 991285122),
(159, 991285122, 'S', 50, 10000, 2, '2013-06-18 21:36:10', NULL, 1000, 'A', 1, '', '2013-06-18 21:36:10', 991285122, '2013-06-25 10:38:35', 991285122),
(160, 991285124, 'S', 19, 120000, 3.5, '2013-06-18 21:39:34', NULL, 0, 'C', 1, '', '2013-06-18 21:39:34', 991285124, '2013-06-18 21:42:25', 991285124),
(161, 991285124, 'B', 19, 10000, 3.5, '2013-06-18 21:39:58', NULL, 0, 'C', 1, '', '2013-06-18 21:39:58', 991285124, '2013-06-18 21:40:35', 991285124),
(162, 991285124, 'B', 19, 10000, 3.3, '2013-06-18 21:40:35', NULL, 0, 'C', 1, '', '2013-06-18 21:40:35', 991285124, '2013-06-18 21:40:46', 991285124),
(163, 991285124, 'S', 19, 80000, 5, '2013-06-18 21:42:25', NULL, 80000, 'F', 1, '', '2013-06-18 21:42:25', 991285124, '2013-06-18 21:46:21', 991285124),
(164, 991285122, 'B', 44, 15000, 1.1, '2013-06-18 21:43:00', NULL, 10000, 'A', 1, '', '2013-06-18 21:43:00', 991285122, '2013-06-18 21:43:00', 991285122),
(165, 991285118, 'B', 19, 80000, 5.1, '2013-06-18 21:43:25', NULL, 80000, 'F', 1, '', '2013-06-18 21:43:25', 991285118, '2013-06-18 21:43:25', 991285118),
(166, 991285122, 'B', 39, 5000, 10, '2013-06-18 21:43:48', NULL, 5000, 'F', 1, '', '2013-06-18 21:43:48', 991285122, '2013-06-18 21:43:48', 991285122),
(167, 991285118, 'S', 19, 60000, 5.5, '2013-06-18 21:43:58', NULL, 60000, 'F', 1, '', '2013-06-18 21:43:58', 991285118, '2013-06-18 21:45:51', 991285118),
(168, 991285122, 'B', 39, 10000, 10, '2013-06-18 21:44:30', '2013-06-18 21:46:36', 10000, 'F', 1, '', '2013-06-18 21:44:30', 991285122, '2013-06-18 21:44:30', 991285122),
(169, 991285122, 'S', 39, 10000, 12, '2013-06-18 21:45:04', NULL, 0, 'A', 1, '', '2013-06-18 21:45:04', 991285122, '2013-06-18 21:45:04', 991285122),
(170, 991285124, 'B', 19, 60000, 6, '2013-06-18 21:45:13', NULL, 60000, 'F', 1, '', '2013-06-18 21:45:13', 991285124, '2013-06-18 21:45:13', 991285124),
(171, 991285118, 'S', 19, 10000, 5, '2013-06-18 21:45:51', NULL, 10000, 'F', 1, '', '2013-06-18 21:45:51', 991285118, '2013-06-18 21:47:21', 991285118),
(172, 3888, 'S', 39, 2000000, 9, '2013-06-18 21:46:36', NULL, 12000, 'A', 1, '', '2013-06-18 21:46:36', 3888, '2013-06-25 11:11:20', 3888),
(173, 991285124, 'B', 19, 10000, 6.5, '2013-06-18 21:47:05', NULL, 10000, 'F', 1, '', '2013-06-18 21:47:05', 991285124, '2013-06-18 21:47:05', 991285124),
(174, 991285118, 'S', 19, 10000, 5.5, '2013-06-18 21:47:21', NULL, 0, 'C', 1, '', '2013-06-18 21:47:21', 991285118, '2013-06-18 21:59:34', 991285118),
(175, 991285122, 'B', 39, 5000, 11, '2013-06-18 21:47:58', NULL, 5000, 'F', 1, '', '2013-06-18 21:47:58', 991285122, '2013-06-18 21:47:58', 991285122),
(176, 991285118, 'B', 19, 10000, 8, '2013-06-18 21:48:22', '2013-06-18 21:49:08', 10000, 'F', 1, '', '2013-06-18 21:48:22', 991285118, '2013-06-18 21:48:22', 991285118),
(177, 991285122, 'S', 39, 5000, 13, '2013-06-18 21:48:35', NULL, 0, 'A', 1, '', '2013-06-18 21:48:35', 991285122, '2013-06-18 21:48:35', 991285122),
(178, 991285124, 'S', 19, 10000, 6.4, '2013-06-18 21:49:08', NULL, 10000, 'F', 1, '', '2013-06-18 21:49:08', 991285124, '2013-06-18 21:49:30', 991285124),
(179, 991285124, 'S', 19, 20000, 6.2, '2013-06-18 21:49:30', NULL, 20000, 'F', 1, '', '2013-06-18 21:49:30', 991285124, '2013-06-18 22:02:02', 991285124),
(180, 991285118, 'B', 19, 10000, 6.1, '2013-06-18 21:49:57', NULL, 0, 'C', 1, '', '2013-06-18 21:49:57', 991285118, '2013-06-18 21:59:10', 991285118),
(181, 991285118, 'S', 19, 10000, 8, '2013-06-18 21:55:18', NULL, 0, 'C', 1, '', '2013-06-18 21:55:18', 991285118, '2013-06-18 21:59:37', 991285118),
(182, 991285118, 'S', 20, 20000, 3.3, '2013-06-18 21:56:30', NULL, 0, 'C', 1, '', '2013-06-18 21:56:30', 991285118, '2013-06-18 21:58:52', 991285118),
(183, 991285118, 'B', 37, 50000, 1, '2013-06-18 21:57:13', NULL, 0, 'C', 1, '', '2013-06-18 21:57:13', 991285118, '2013-06-18 21:58:44', 991285118),
(184, 991285118, 'B', 19, 10000, 12, '2013-06-18 21:57:29', NULL, 10000, 'F', 1, '', '2013-06-18 21:57:29', 991285118, '2013-06-18 21:57:29', 991285118),
(185, 991285118, 'S', 19, 10000, 20, '2013-06-18 21:57:51', NULL, 0, 'C', 1, '', '2013-06-18 21:57:51', 991285118, '2013-06-18 21:59:44', 991285118),
(186, 991285118, 'B', 19, 10000, 20, '2013-06-18 22:00:09', NULL, 10000, 'F', 1, '', '2013-06-18 22:00:09', 991285118, '2013-06-18 22:00:09', 991285118),
(187, 991285124, 'B', 19, 10000, 21, '2013-06-18 22:00:31', NULL, 0, 'C', 1, '', '2013-06-18 22:00:31', 991285124, '2013-06-18 22:02:07', 991285124),
(188, 991285118, 'S', 19, 20000, 22.5, '2013-06-18 22:01:32', NULL, 0, 'C', 1, '', '2013-06-18 22:01:32', 991285118, '2013-06-18 22:05:54', 991285118),
(189, 991285118, 'S', 19, 10000, 20, '2013-06-18 22:02:57', '2013-06-18 22:03:25', 10000, 'F', 1, '', '2013-06-18 22:02:57', 991285118, '2013-06-18 22:02:57', 991285118),
(190, 991285124, 'B', 19, 10000, 21, '2013-06-18 22:03:25', NULL, 10000, 'F', 1, '', '2013-06-18 22:03:25', 991285124, '2013-06-18 22:03:25', 991285124),
(191, 991285124, 'S', 19, 50000, 25, '2013-06-18 22:04:12', NULL, 0, 'C', 1, '', '2013-06-18 22:04:12', 991285124, '2013-06-18 22:05:30', 991285124),
(192, 991285118, 'B', 19, 10000, 24, '2013-06-18 22:04:57', '2013-06-18 22:05:30', 10000, 'F', 1, '', '2013-06-18 22:04:57', 991285118, '2013-06-18 22:04:57', 991285118),
(193, 991285124, 'S', 19, 10000, 23, '2013-06-18 22:05:29', NULL, 10000, 'F', 1, '', '2013-06-18 22:05:29', 991285124, '2013-06-18 22:14:13', 991285124),
(194, 991285118, 'S', 19, 10000, 23.5, '2013-06-18 22:06:25', NULL, 10000, 'F', 1, '', '2013-06-18 22:06:25', 991285118, '2013-06-18 22:07:48', 991285118),
(195, 991285124, 'B', 19, 10000, 24, '2013-06-18 22:07:21', NULL, 10000, 'F', 1, '', '2013-06-18 22:07:21', 991285124, '2013-06-18 22:07:21', 991285124),
(196, 991285118, 'S', 19, 30000, 22, '2013-06-18 22:07:47', NULL, 0, 'C', 1, '', '2013-06-18 22:07:47', 991285118, '2013-06-18 22:08:21', 991285118),
(197, 991285118, 'S', 19, 30000, 18, '2013-06-18 22:08:21', NULL, 0, 'C', 1, '', '2013-06-18 22:08:21', 991285118, '2013-06-18 22:08:46', 991285118),
(198, 991285118, 'S', 19, 10000, 20, '2013-06-18 22:08:46', NULL, 0, 'C', 1, '', '2013-06-18 22:08:46', 991285118, '2013-06-18 22:09:30', 991285118),
(199, 991285119, 'S', 20, 140000, 3, '2013-06-18 22:10:09', NULL, 0, 'C', 1, '', '2013-06-18 22:10:09', 991285119, '2013-06-19 00:06:36', 991285119),
(200, 991285118, 'S', 20, 50000, 2.5, '2013-06-18 22:12:34', NULL, 50000, 'F', 1, '', '2013-06-18 22:12:34', 991285118, '2013-06-18 22:21:53', 991285118),
(201, 991285119, 'B', 21, 10000, 3, '2013-06-18 22:12:38', NULL, 10000, 'F', 1, '', '2013-06-18 22:12:38', 991285119, '2013-06-18 22:12:38', 991285119),
(202, 991285119, 'B', 21, 10000, 4, '2013-06-18 22:13:56', NULL, 10000, 'F', 1, '', '2013-06-18 22:13:56', 991285119, '2013-06-18 22:13:56', 991285119),
(203, 991285124, 'S', 19, 10000, 20, '2013-06-18 22:14:13', '2013-06-18 22:14:43', 10000, 'F', 1, '', '2013-06-18 22:14:13', 991285124, '2013-06-18 22:14:13', 991285124),
(204, 991285118, 'B', 19, 10000, 21, '2013-06-18 22:14:43', NULL, 10000, 'F', 1, '', '2013-06-18 22:14:43', 991285118, '2013-06-18 22:14:43', 991285118),
(205, 991285119, 'S', 21, 10000, 100, '2013-06-18 22:14:57', NULL, 0, 'C', 1, '', '2013-06-18 22:14:57', 991285119, '2013-06-18 22:16:11', 991285119),
(206, 991285119, 'S', 21, 20000, 3.5, '2013-06-18 22:15:20', NULL, 0, 'C', 1, '', '2013-06-18 22:15:20', 991285119, '2013-06-21 21:28:55', 991285119),
(207, 991285119, 'S', 21, 10000, 1, '2013-06-18 22:16:11', NULL, 0, 'C', 1, '', '2013-06-18 22:16:11', 991285119, '2013-06-18 22:16:23', 991285119),
(208, 991285118, 'S', 19, 10000, 20, '2013-06-18 22:16:21', NULL, 0, 'C', 1, '', '2013-06-18 22:16:21', 991285118, '2013-06-18 22:17:19', 991285118),
(209, 991285119, 'S', 21, 10000, 3, '2013-06-18 22:16:23', NULL, 0, 'C', 1, '', '2013-06-18 22:16:23', 991285119, '2013-06-21 21:28:58', 991285119),
(210, 991285124, 'B', 19, 10000, 20, '2013-06-18 22:17:02', '2013-06-18 22:17:19', 10000, 'F', 1, '', '2013-06-18 22:17:02', 991285124, '2013-06-18 22:17:02', 991285124),
(211, 991285118, 'S', 19, 10000, 19, '2013-06-18 22:17:19', NULL, 10000, 'F', 1, '', '2013-06-18 22:17:19', 991285118, '2013-06-18 22:17:19', 991285118),
(212, 991285119, 'B', 44, 100000, 1.2, '2013-06-18 22:17:24', NULL, 0, 'C', 1, '', '2013-06-18 22:17:24', 991285119, '2013-06-21 21:29:03', 991285119),
(213, 991285124, 'S', 19, 10000, 21, '2013-06-18 22:18:23', NULL, 0, 'C', 1, '', '2013-06-18 22:18:23', 991285124, '2013-06-18 22:19:16', 991285124),
(214, 991285124, 'S', 19, 10000, 20.5, '2013-06-18 22:19:16', '2013-06-18 22:19:23', 10000, 'F', 1, '', '2013-06-18 22:19:16', 991285124, '2013-06-18 22:19:16', 991285124),
(215, 991285118, 'B', 19, 10000, 21, '2013-06-18 22:19:23', NULL, 10000, 'F', 1, '', '2013-06-18 22:19:23', 991285118, '2013-06-18 22:19:23', 991285118),
(216, 991285124, 'B', 20, 50000, 3.4, '2013-06-18 22:21:14', NULL, 50000, 'F', 1, '', '2013-06-18 22:21:14', 991285124, '2013-06-18 22:21:14', 991285124),
(217, 991285118, 'S', 20, 40000, 3, '2013-06-18 22:21:52', NULL, 1000, 'A', 1, '', '2013-06-18 22:21:52', 991285118, '2013-06-25 10:22:35', 991285118),
(218, 991285118, 'B', 20, 10000, 5, '2013-06-18 22:22:48', NULL, 10000, 'F', 1, '', '2013-06-18 22:22:48', 991285118, '2013-06-18 22:22:48', 991285118),
(219, 991285118, 'B', 20, 10000, 8, '2013-06-18 22:23:14', NULL, 10000, 'F', 1, '', '2013-06-18 22:23:14', 991285118, '2013-06-18 22:23:14', 991285118),
(220, 991285124, 'B', 36, 15000, 1.6, '2013-06-18 22:26:41', NULL, 15000, 'F', 1, '', '2013-06-18 22:26:41', 991285124, '2013-06-18 22:26:41', 991285124),
(221, 991285118, 'S', 20, 40000, 8, '2013-06-18 22:30:06', NULL, 0, 'A', 1, '', '2013-06-18 22:30:06', 991285118, '2013-06-18 22:30:06', 991285118),
(222, 991285118, 'S', 19, 40000, 20, '2013-06-18 22:30:43', NULL, 0, 'A', 1, '', '2013-06-18 22:30:43', 991285118, '2013-06-18 22:30:43', 991285118),
(223, 991285124, 'S', 19, 40000, 12, '2013-06-18 22:31:51', NULL, 0, 'A', 1, '', '2013-06-18 22:31:51', 991285124, '2013-06-18 22:31:51', 991285124),
(224, 991285124, 'S', 19, 50000, 22, '2013-06-18 22:32:14', NULL, 0, 'A', 1, '', '2013-06-18 22:32:14', 991285124, '2013-06-18 22:32:14', 991285124),
(225, 991285124, 'S', 20, 30000, 4, '2013-06-18 22:32:39', NULL, 0, 'A', 1, '', '2013-06-18 22:32:39', 991285124, '2013-06-18 22:32:39', 991285124),
(226, 991285124, 'S', 20, 20000, 8, '2013-06-18 22:33:03', NULL, 0, 'A', 1, '', '2013-06-18 22:33:03', 991285124, '2013-06-18 22:33:03', 991285124),
(227, 991285124, 'S', 36, 15000, 1.8, '2013-06-18 22:33:26', NULL, 1000, 'A', 1, '', '2013-06-18 22:33:26', 991285124, '2013-06-25 11:03:40', 991285124),
(228, 991285119, 'S', 20, 140000, 7, '2013-06-19 00:06:36', NULL, 0, 'C', 1, '', '2013-06-19 00:06:36', 991285119, '2013-06-21 21:28:41', 991285119),
(229, 991285122, 'S', 20, 30000, 7, '2013-06-19 01:18:40', NULL, 0, 'A', 1, '', '2013-06-19 01:18:40', 991285122, '2013-06-19 01:18:40', 991285122),
(230, 3888, 'B', 51, 10000, 1.1, '2013-06-19 01:29:33', NULL, 0, 'A', 1, '', '2013-06-19 01:29:33', 3888, '2013-06-19 01:29:33', 3888),
(231, 991285122, 'B', 41, 10000, 1.1, '2013-06-19 01:43:25', NULL, 10000, 'F', 1, '', '2013-06-19 01:43:25', 991285122, '2013-06-19 01:43:25', 991285122),
(232, 991285122, 'B', 37, 15000, 1.1, '2013-06-19 01:43:50', NULL, 5000, 'A', 1, '', '2013-06-19 01:43:50', 991285122, '2013-06-19 01:43:50', 991285122),
(233, 991285122, 'B', 22, 10000, 1, '2013-06-19 01:44:24', '2013-06-24 14:12:15', 10000, 'F', 1, '', '2013-06-19 01:44:24', 991285122, '2013-06-24 14:12:15', 991285122),
(234, 991285122, 'B', 22, 10000, 1, '2013-06-19 01:44:58', '2013-06-24 14:12:20', 10000, 'F', 1, '', '2013-06-19 01:44:58', 991285122, '2013-06-24 14:12:20', 991285122),
(235, 991285122, 'B', 22, 5000, 1.05, '2013-06-19 01:45:35', NULL, 5000, 'F', 1, '', '2013-06-19 01:45:35', 991285122, '2013-06-19 01:45:35', 991285122),
(236, 991285122, 'B', 35, 5000, 1.1, '2013-06-19 01:46:03', NULL, 5000, 'F', 1, '', '2013-06-19 01:46:03', 991285122, '2013-06-19 01:46:03', 991285122),
(237, 991285122, 'B', 23, 10000, 1, '2013-06-19 01:46:36', '2013-06-24 13:25:10', 10000, 'F', 1, '', '2013-06-19 01:46:36', 991285122, '2013-06-24 13:25:10', 991285122),
(238, 991285122, 'B', 23, 10000, 1.2, '2013-06-19 01:47:01', NULL, 10000, 'F', 1, '', '2013-06-19 01:47:01', 991285122, '2013-06-19 01:47:01', 991285122),
(239, 991285122, 'B', 21, 5000, 1.7, '2013-06-19 01:47:37', NULL, 5000, 'F', 1, '', '2013-06-19 01:47:37', 991285122, '2013-06-19 01:47:37', 991285122),
(240, 991285122, 'B', 36, 10000, 1.3, '2013-06-19 01:48:43', NULL, 0, 'A', 1, '', '2013-06-19 01:48:43', 991285122, '2013-06-19 01:48:43', 991285122),
(241, 991285122, 'B', 50, 10000, 1, '2013-06-19 01:49:18', NULL, 0, 'A', 1, '', '2013-06-19 01:49:18', 991285122, '2013-06-19 01:49:18', 991285122),
(242, 991285122, 'B', 21, 1000000, 1, '2013-06-19 01:58:38', NULL, 0, 'C', 1, '', '2013-06-19 01:58:38', 991285122, '2013-06-19 01:59:31', 991285122),
(243, 991285122, 'B', 21, 1000000, 1.1, '2013-06-19 01:59:31', NULL, 1000000, 'F', 1, '', '2013-06-19 01:59:31', 991285122, '2013-06-19 01:59:31', 991285122),
(244, 3888, 'S', 19, 500000, 0.95, '2013-06-19 02:01:45', '2013-06-19 02:03:32', 500000, 'F', 1, '', '2013-06-19 02:01:45', 3888, '2013-06-19 02:01:45', 3888),
(245, 991285122, 'B', 19, 50000, 0.96, '2013-06-19 02:02:45', NULL, 50000, 'F', 1, '', '2013-06-19 02:02:45', 991285122, '2013-06-19 02:02:45', 991285122),
(246, 991285122, 'B', 19, 450000, 0.98, '2013-06-19 02:03:32', NULL, 450000, 'F', 1, '', '2013-06-19 02:03:32', 991285122, '2013-06-19 02:05:03', 991285122),
(247, 991285122, 'B', 19, 50000, 1, '2013-06-19 02:05:03', NULL, 0, 'A', 1, '', '2013-06-19 02:05:03', 991285122, '2013-06-19 02:05:03', 991285122),
(248, 991285122, 'S', 19, 500000, 2, '2013-06-19 02:07:56', NULL, 12000, 'A', 1, '', '2013-06-19 02:07:56', 991285122, '2013-06-24 17:45:00', 991285122),
(249, 991285122, 'B', 25, 10000, 1.2, '2013-06-19 02:12:33', NULL, 0, 'A', 1, '', '2013-06-19 02:12:33', 991285122, '2013-06-19 02:12:33', 991285122),
(250, 991285122, 'S', 33, 5000, 1.5, '2013-06-19 02:14:30', NULL, 4000, 'A', 1, '', '2013-06-19 02:14:30', 991285122, '2013-06-25 11:23:50', 991285122),
(251, 991285122, 'S', 44, 10000, 1.5, '2013-06-19 02:15:01', '2013-06-21 21:23:55', 10000, 'F', 1, '', '2013-06-19 02:15:01', 991285122, '2013-06-21 21:23:55', 991285122),
(252, 991285122, 'S', 41, 10000, 2, '2013-06-19 02:15:24', NULL, 2000, 'A', 1, '', '2013-06-19 02:15:24', 991285122, '2013-06-25 11:27:45', 991285122),
(253, 991285122, 'S', 37, 5000, 1.5, '2013-06-19 02:15:43', NULL, 1000, 'A', 1, '', '2013-06-19 02:15:43', 991285122, '2013-06-25 10:36:20', 991285122),
(254, 991285122, 'S', 22, 5000, 1.3, '2013-06-19 02:16:02', NULL, 0, 'A', 1, '', '2013-06-19 02:16:02', 991285122, '2013-06-19 02:16:02', 991285122),
(255, 991285122, 'S', 35, 5000, 1.5, '2013-06-19 02:16:28', NULL, 0, 'A', 1, '', '2013-06-19 02:16:28', 991285122, '2013-06-19 02:16:28', 991285122),
(256, 991285122, 'S', 23, 10000, 2.4, '2013-06-19 02:16:47', NULL, 0, 'A', 1, '', '2013-06-19 02:16:47', 991285122, '2013-06-19 02:16:47', 991285122),
(257, 991285122, 'S', 21, 1005000, 1.5, '2013-06-19 02:17:15', NULL, 0, 'A', 1, '', '2013-06-19 02:17:15', 991285122, '2013-06-19 02:17:15', 991285122),
(258, 16513, 'B', 21, 5000, 1.5, '2013-06-19 15:17:55', '2013-06-19 16:25:30', 5000, 'F', 1, '', '2013-06-19 15:17:55', 16513, '2013-06-19 16:25:30', 16513),
(259, 991285120, 'B', 41, 10000, 1, '2013-06-19 15:56:06', NULL, 0, 'A', 1, '', '2013-06-19 15:56:06', 991285120, '2013-06-19 15:56:06', 991285120),
(260, 991285120, 'B', 41, 5000, 1, '2013-06-19 15:56:47', NULL, 0, 'A', 1, '', '2013-06-19 15:56:47', 991285120, '2013-06-19 15:56:47', 991285120),
(261, 991285120, 'B', 25, 50000, 0.9, '2013-06-19 16:00:19', NULL, 0, 'A', 1, '', '2013-06-19 16:00:19', 991285120, '2013-06-19 16:00:19', 991285120),
(262, 991285120, 'B', 35, 50000, 1.1, '2013-06-19 17:03:05', NULL, 10000, 'A', 1, '', '2013-06-19 17:03:05', 991285120, '2013-06-19 17:02:45', 991285120),
(263, 991285120, 'B', 32, 25000, 1, '2013-06-19 17:04:36', NULL, 5000, 'A', 1, '', '2013-06-19 17:04:36', 991285120, '2013-06-19 17:04:15', 991285120),
(264, 991285120, 'B', 43, 30000, 1, '2013-06-19 17:05:21', NULL, 15000, 'A', 1, '', '2013-06-19 17:05:21', 991285120, '2013-06-19 17:05:00', 991285120),
(265, 991285120, 'B', 26, 10000, 1.2, '2013-06-19 22:06:29', '2013-06-19 22:06:10', 10000, 'F', 1, '', '2013-06-19 22:06:29', 991285120, '2013-06-19 22:06:10', 991285120),
(266, 991285120, 'B', 50, 500000, 1.5, '2013-06-19 22:07:51', NULL, 0, 'A', 1, '', '2013-06-19 22:07:51', 991285120, '2013-06-19 22:07:51', 991285120),
(267, 991285120, 'S', 35, 5000, 1.1, '2013-06-19 22:08:48', NULL, 1000, 'A', 1, '', '2013-06-19 22:08:48', 991285120, '2013-06-25 10:45:25', 991285120),
(268, 991285120, 'B', 38, 50000, 1.2, '2013-06-19 22:09:57', NULL, 10000, 'A', 1, '', '2013-06-19 22:09:57', 991285120, '2013-06-21 21:29:20', 991285120),
(269, 991285120, 'B', 40, 100000, 1, '2013-06-19 23:43:08', NULL, 5000, 'A', 1, '', '2013-06-19 23:43:08', 991285120, '2013-06-19 23:42:50', 991285120),
(270, 991285122, 'B', 50, 5000, 2, '2013-06-20 18:04:01', NULL, 0, 'A', 1, '', '2013-06-20 18:04:01', 991285122, '2013-06-20 18:04:01', 991285122),
(271, 91285, 'B', 21, 1000, 1, '2013-06-21 15:59:33', '2013-06-21 15:59:15', 1000, 'F', 1, '', '2013-06-21 15:59:33', 91285, '2013-06-21 15:59:15', 91285),
(272, 91285, 'B', 19, 2000, 2, '2013-06-21 16:00:06', '2013-06-21 15:59:45', 2000, 'F', 1, '', '2013-06-21 16:00:06', 91285, '2013-06-21 15:59:45', 91285),
(273, 991285122, 'B', 20, 5000, 0.9, '2013-06-21 21:11:11', NULL, 0, 'A', 1, '', '2013-06-21 21:11:11', 991285122, '2013-06-21 21:11:11', 991285122),
(274, 991285122, 'B', 48, 10000, 1.1, '2013-06-21 21:12:29', '2013-06-21 21:12:10', 10000, 'F', 1, '', '2013-06-21 21:12:29', 991285122, '2013-06-21 21:12:10', 991285122),
(275, 991285122, 'S', 48, 5000, 1.5, '2013-06-21 21:13:16', '2013-06-21 21:34:50', 5000, 'F', 1, '', '2013-06-21 21:13:16', 991285122, '2013-06-21 21:34:50', 991285122),
(276, 991285122, 'B', 36, 10000, 1.6, '2013-06-21 21:16:37', NULL, 0, 'A', 1, '', '2013-06-21 21:16:37', 991285122, '2013-06-21 21:16:37', 991285122),
(277, 991285120, 'B', 44, 10000, 1.5, '2013-06-21 21:24:13', '2013-06-21 21:23:55', 10000, 'F', 1, '', '2013-06-21 21:24:13', 991285120, '2013-06-21 21:23:55', 991285120),
(278, 991285120, 'B', 20, 10000, 1, '2013-06-21 21:27:37', NULL, 0, 'A', 1, '', '2013-06-21 21:27:37', 991285120, '2013-06-21 21:27:37', 991285120),
(279, 991285120, 'B', 39, 1, 0.1, '2013-06-21 21:28:50', NULL, 0, 'A', 1, '', '2013-06-21 21:28:50', 991285120, '2013-06-21 21:28:50', 991285120),
(280, 991285119, 'S', 38, 10000, 1.1, '2013-06-21 21:29:38', '2013-06-21 21:29:20', 10000, 'F', 1, '', '2013-06-21 21:29:38', 991285119, '2013-06-21 21:29:20', 991285119),
(281, 991285119, 'S', 20, 5, 140000, '2013-06-21 21:30:02', NULL, 0, 'A', 1, '', '2013-06-21 21:30:02', 991285119, '2013-06-21 21:30:02', 991285119),
(282, 991285119, 'S', 46, 5000, 1.5, '2013-06-21 21:30:51', '2013-06-21 21:47:35', 5000, 'F', 1, '', '2013-06-21 21:30:51', 991285119, '2013-06-21 21:47:35', 991285119),
(283, 991285120, 'B', 24, 1, 0.001, '2013-06-21 21:33:41', NULL, 0, 'A', 1, '', '2013-06-21 21:33:41', 991285120, '2013-06-21 21:33:41', 991285120),
(284, 991285119, 'B', 48, 10000, 5, '2013-06-21 21:35:09', NULL, 5000, 'A', 1, '', '2013-06-21 21:35:09', 991285119, '2013-06-21 21:34:50', 991285119),
(285, 991285120, 'S', 35, 500, 10, '2013-06-21 21:37:14', NULL, 0, 'A', 1, '', '2013-06-21 21:37:14', 991285120, '2013-06-21 21:37:14', 991285120),
(286, 991285120, 'S', 32, 500, 200, '2013-06-21 21:37:35', NULL, 0, 'A', 1, '', '2013-06-21 21:37:35', 991285120, '2013-06-21 21:37:35', 991285120),
(287, 991285120, 'S', 43, 5000, 238, '2013-06-21 21:37:56', NULL, 0, 'A', 1, '', '2013-06-21 21:37:56', 991285120, '2013-06-21 21:37:56', 991285120),
(288, 991285120, 'S', 26, 1500, 150, '2013-06-21 21:38:24', NULL, 0, 'A', 1, '', '2013-06-21 21:38:24', 991285120, '2013-06-21 21:38:24', 991285120),
(289, 991285120, 'S', 40, 2876, 2870, '2013-06-21 21:38:51', NULL, 0, 'A', 1, '', '2013-06-21 21:38:51', 991285120, '2013-06-21 21:38:51', 991285120),
(290, 991285120, 'S', 44, 500, 9999, '2013-06-21 21:39:24', NULL, 0, 'A', 1, '', '2013-06-21 21:39:24', 991285120, '2013-06-21 21:39:24', 991285120),
(291, 991285120, 'S', 38, 5001, 576, '2013-06-21 21:39:44', NULL, 0, 'A', 1, '', '2013-06-21 21:39:44', 991285120, '2013-06-21 21:39:44', 991285120),
(292, 991285120, 'B', 26, 50000, 0.02, '2013-06-21 21:40:10', NULL, 0, 'A', 1, '', '2013-06-21 21:40:10', 991285120, '2013-06-21 21:40:10', 991285120),
(293, 991285120, 'B', 51, 5000, 1, '2013-06-21 21:41:35', NULL, 0, 'A', 1, '', '2013-06-21 21:41:35', 991285120, '2013-06-21 21:41:35', 991285120),
(294, 991285120, 'B', 45, 49999, 1, '2013-06-21 21:42:24', NULL, 10000, 'A', 1, '', '2013-06-21 21:42:24', 991285120, '2013-06-21 21:42:05', 991285120),
(295, 991285119, 'B', 44, 100000, 1.5, '2013-06-21 21:42:41', NULL, 0, 'A', 1, '', '2013-06-21 21:42:41', 991285119, '2013-06-21 21:42:41', 991285119),
(296, 991285120, 'S', 45, 5438, 260, '2013-06-21 21:46:44', NULL, 0, 'A', 1, '', '2013-06-21 21:46:44', 991285120, '2013-06-21 21:46:44', 991285120),
(297, 991285120, 'B', 49, 10000, 1, '2013-06-21 21:47:17', '2013-06-21 21:47:00', 10000, 'F', 1, '', '2013-06-21 21:47:17', 991285120, '2013-06-21 21:47:00', 991285120),
(298, 991285120, 'B', 46, 50000, 1.5, '2013-06-21 21:47:53', NULL, 5000, 'A', 1, '', '2013-06-21 21:47:53', 991285120, '2013-06-21 21:47:35', 991285120),
(299, 991285120, 'S', 49, 5487, 888, '2013-06-21 21:48:17', NULL, 0, 'A', 1, '', '2013-06-21 21:48:17', 991285120, '2013-06-21 21:48:17', 991285120),
(300, 991285120, 'S', 46, 2547, 870, '2013-06-21 21:48:36', NULL, 0, 'A', 1, '', '2013-06-21 21:48:36', 991285120, '2013-06-21 21:48:36', 991285120),
(301, 991285120, 'B', 25, 5000, 1, '2013-06-21 21:49:30', NULL, 0, 'A', 1, '', '2013-06-21 21:49:30', 991285120, '2013-06-21 21:49:30', 991285120),
(302, 991285120, 'B', 27, 100000, 1, '2013-06-21 21:50:23', NULL, 10000, 'A', 1, '', '2013-06-21 21:50:23', 991285120, '2013-06-21 21:50:05', 991285120),
(303, 991285120, 'B', 29, 10000, 1, '2013-06-21 21:51:17', '2013-06-21 21:51:00', 10000, 'F', 1, '', '2013-06-21 21:51:17', 991285120, '2013-06-21 21:51:00', 991285120),
(304, 991285120, 'S', 29, 8888, 888, '2013-06-21 21:54:14', NULL, 0, 'A', 1, '', '2013-06-21 21:54:14', 991285120, '2013-06-21 21:54:14', 991285120),
(305, 991285120, 'S', 27, 8800, 1234, '2013-06-21 21:54:36', NULL, 0, 'A', 1, '', '2013-06-21 21:54:36', 991285120, '2013-06-21 21:54:36', 991285120),
(306, 991285120, 'B', 47, 100000, 1, '2013-06-21 21:55:16', NULL, 15000, 'A', 1, '', '2013-06-21 21:55:16', 991285120, '2013-06-21 21:54:55', 991285120),
(307, 991285120, 'S', 47, 10000, 800, '2013-06-21 21:56:04', NULL, 0, 'A', 1, '', '2013-06-21 21:56:04', 991285120, '2013-06-21 21:56:04', 991285120),
(308, 991285120, 'B', 31, 100000, 1, '2013-06-21 21:57:07', NULL, 60000, 'A', 1, '', '2013-06-21 21:57:07', 991285120, '2013-06-21 21:56:50', 991285120),
(309, 991285120, 'S', 31, 50000, 560, '2013-06-21 22:03:04', NULL, 0, 'A', 1, '', '2013-06-21 22:03:04', 991285120, '2013-06-21 22:03:04', 991285120),
(310, 991285120, 'S', 31, 8000, 560, '2013-06-21 22:05:12', NULL, 0, 'A', 1, '', '2013-06-21 22:05:12', 991285120, '2013-06-21 22:05:12', 991285120),
(311, 991285120, 'B', 24, 10000, 1, '2013-06-21 22:10:39', '2013-06-21 22:10:20', 10000, 'F', 1, '', '2013-06-21 22:10:39', 991285120, '2013-06-21 22:10:20', 991285120),
(312, 991285120, 'B', 24, 5000, 0.02, '2013-06-21 22:12:25', NULL, 0, 'A', 1, '', '2013-06-21 22:12:25', 991285120, '2013-06-21 22:12:25', 991285120),
(313, 991285120, 'B', 34, 100000, 1, '2013-06-21 22:13:37', NULL, 10000, 'A', 1, '', '2013-06-21 22:13:37', 991285120, '2013-06-21 22:13:20', 991285120),
(314, 991285120, 'B', 28, 100000, 1, '2013-06-21 22:14:23', NULL, 5000, 'A', 1, '', '2013-06-21 22:14:23', 991285120, '2013-06-21 22:14:05', 991285120),
(315, 991285120, 'B', 28, 100000, 1, '2013-06-21 22:14:36', NULL, 0, 'A', 1, '', '2013-06-21 22:14:36', 991285120, '2013-06-21 22:14:36', 991285120),
(316, 991285120, 'B', 30, 100000, 1.2, '2013-06-21 22:16:03', NULL, 5000, 'A', 1, '', '2013-06-21 22:16:03', 991285120, '2013-06-21 22:15:45', 991285120),
(317, 991285120, 'B', 21, 99999, 1, '2013-06-21 22:16:48', '2013-06-21 22:16:30', 99999, 'F', 1, '', '2013-06-21 22:16:48', 991285120, '2013-06-21 22:16:30', 991285120),
(318, 991285120, 'S', 34, 8000, 296, '2013-06-21 22:28:10', NULL, 0, 'A', 1, '', '2013-06-21 22:28:10', 991285120, '2013-06-21 22:28:10', 991285120),
(319, 991285120, 'S', 28, 4000, 390, '2013-06-21 22:28:37', NULL, 0, 'A', 1, '', '2013-06-21 22:28:37', 991285120, '2013-06-21 22:28:37', 991285120),
(320, 991285120, 'S', 30, 4000, 666, '2013-06-21 22:31:55', NULL, 0, 'A', 1, '', '2013-06-21 22:31:55', 991285120, '2013-06-21 22:31:55', 991285120),
(321, 991285120, 'B', 32, 1, 190, '2013-06-21 22:32:57', NULL, 0, 'A', 1, '', '2013-06-21 22:32:57', 991285120, '2013-06-21 22:32:57', 991285120),
(322, 991285120, 'B', 43, 1, 190, '2013-06-21 22:33:29', NULL, 0, 'A', 1, '', '2013-06-21 22:33:29', 991285120, '2013-06-21 22:33:29', 991285120),
(323, 991285120, 'B', 40, 1, 2800, '2013-06-21 22:34:12', NULL, 0, 'A', 1, '', '2013-06-21 22:34:12', 991285120, '2013-06-21 22:34:12', 991285120),
(324, 991285120, 'B', 29, 1, 750, '2013-06-21 22:39:22', NULL, 0, 'A', 1, '', '2013-06-21 22:39:22', 991285120, '2013-06-21 22:39:22', 991285120),
(325, 991285120, 'B', 24, 1, 0.01, '2013-06-21 22:40:41', NULL, 0, 'A', 1, '', '2013-06-21 22:40:41', 991285120, '2013-06-21 22:40:41', 991285120),
(326, 991285120, 'B', 33, 50000, 1.05, '2013-06-21 22:43:19', NULL, 5000, 'A', 1, '', '2013-06-21 22:43:19', 991285120, '2013-06-21 22:43:00', 991285120),
(327, 991285120, 'B', 22, 10000, 1.1, '2013-06-21 22:44:24', '2013-06-21 22:44:05', 10000, 'F', 1, '', '2013-06-21 22:44:24', 991285120, '2013-06-21 22:44:05', 991285120),
(328, 991285120, 'S', 21, 55555, 9999, '2013-06-21 22:45:11', NULL, 0, 'A', 1, '', '2013-06-21 22:45:11', 991285120, '2013-06-21 22:45:11', 991285120),
(329, 991285120, 'S', 24, 1000, 555, '2013-06-21 22:47:20', NULL, 0, 'A', 1, '', '2013-06-21 22:47:20', 991285120, '2013-06-21 22:47:20', 991285120),
(330, 991285120, 'B', 49, 1, 750, '2013-06-21 22:49:15', NULL, 0, 'A', 1, '', '2013-06-21 22:49:15', 991285120, '2013-06-21 22:49:15', 991285120);
INSERT INTO `ax_opens` (`id`, `user_id`, `type`, `asset_id`, `volume`, `open_price`, `open_time`, `close_time`, `fulfil_volume`, `status`, `ran_match`, `comment`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(331, 991285120, 'B', 51, 1, 888, '2013-06-21 23:01:44', NULL, 0, 'A', 1, '', '2013-06-21 23:01:44', 991285120, '2013-06-21 23:01:44', 991285120),
(332, 991285120, 'B', 34, 1, 296, '2013-06-21 23:03:27', NULL, 0, 'A', 1, '', '2013-06-21 23:03:27', 991285120, '2013-06-21 23:03:27', 991285120),
(333, 991285120, 'S', 21, 5000, 10000, '2013-06-21 23:08:31', NULL, 0, 'A', 1, '', '2013-06-21 23:08:31', 991285120, '2013-06-21 23:08:31', 991285120),
(334, 16513, 'B', 19, 10000, 2, '2013-06-24 17:45:20', '2013-06-24 17:45:00', 10000, 'F', 1, '', '2013-06-24 17:45:20', 16513, '2013-06-24 17:45:00', 16513),
(335, 991285122, 'B', 39, 1000, 15, '2013-06-24 23:55:37', '2013-06-24 23:55:15', 1000, 'F', 1, '', '2013-06-24 23:55:37', 991285122, '2013-06-24 23:55:15', 991285122),
(336, 91285, 'B', 20, 1000, 8.5, '2013-06-25 10:22:58', '2013-06-25 10:22:35', 1000, 'F', 1, '', '2013-06-25 10:22:58', 91285, '2013-06-25 10:22:35', 91285),
(337, 91285, 'B', 41, 1000, 1.12, '2013-06-25 10:25:35', NULL, 0, 'A', 1, '', '2013-06-25 10:25:35', 91285, '2013-06-25 10:25:35', 91285),
(338, 91285, 'S', 21, 1000, 1.1, '2013-06-25 10:29:25', NULL, 0, 'A', 1, '', '2013-06-25 10:29:25', 91285, '2013-06-25 10:29:25', 91285),
(339, 91285, 'B', 50, 1000, 1.5, '2013-06-25 10:30:54', NULL, 0, 'A', 1, '', '2013-06-25 10:30:54', 91285, '2013-06-25 10:30:54', 91285),
(340, 91285, 'B', 41, 1000, 2, '2013-06-25 10:35:13', '2013-06-25 10:34:50', 1000, 'F', 1, '', '2013-06-25 10:35:13', 91285, '2013-06-25 10:34:50', 91285),
(341, 91285, 'B', 37, 1000, 1.5, '2013-06-25 10:36:43', '2013-06-25 10:36:20', 1000, 'F', 1, '', '2013-06-25 10:36:43', 91285, '2013-06-25 10:36:20', 91285),
(342, 91285, 'B', 50, 1000, 2, '2013-06-25 10:38:58', '2013-06-25 10:38:35', 1000, 'F', 1, '', '2013-06-25 10:38:58', 91285, '2013-06-25 10:38:35', 91285),
(343, 91285, 'B', 21, 1000, 1, '2013-06-25 10:40:17', '2013-06-25 10:39:55', 1000, 'F', 1, '', '2013-06-25 10:40:17', 91285, '2013-06-25 10:39:55', 91285),
(344, 91285, 'B', 24, 1000, 1, '2013-06-25 10:42:02', '2013-06-25 10:41:40', 1000, 'F', 1, '', '2013-06-25 10:42:02', 91285, '2013-06-25 10:41:40', 91285),
(345, 91285, 'B', 33, 1000, 1.5, '2013-06-25 10:42:58', '2013-06-25 10:42:35', 1000, 'F', 1, '', '2013-06-25 10:42:58', 91285, '2013-06-25 10:42:35', 91285),
(346, 91285, 'B', 35, 1000, 1.1, '2013-06-25 10:45:47', '2013-06-25 10:45:25', 1000, 'F', 1, '', '2013-06-25 10:45:47', 91285, '2013-06-25 10:45:25', 91285),
(347, 91285, 'B', 22, 1000, 1, '2013-06-25 10:46:42', '2013-06-25 10:46:20', 1000, 'F', 1, '', '2013-06-25 10:46:42', 91285, '2013-06-25 10:46:20', 91285),
(348, 91285, 'B', 36, 1000, 1.8, '2013-06-25 11:04:03', '2013-06-25 11:03:40', 1000, 'F', 1, '', '2013-06-25 11:04:03', 91285, '2013-06-25 11:03:40', 91285),
(349, 91285, 'B', 24, 1000, 1, '2013-06-25 11:05:38', '2013-06-25 11:05:15', 1000, 'F', 1, '', '2013-06-25 11:05:38', 91285, '2013-06-25 11:05:15', 91285),
(350, 91285, 'B', 26, 1000, 1, '2013-06-25 11:06:27', '2013-06-25 11:06:05', 1000, 'F', 1, '', '2013-06-25 11:06:27', 91285, '2013-06-25 11:06:05', 91285),
(351, 91285, 'B', 51, 2000, 1, '2013-06-25 11:08:49', NULL, 0, 'A', 1, '', '2013-06-25 11:08:49', 91285, '2013-06-25 11:08:49', 91285),
(352, 91285, 'B', 39, 1000, 9, '2013-06-25 11:11:40', '2013-06-25 11:11:20', 1000, 'F', 1, '', '2013-06-25 11:11:40', 91285, '2013-06-25 11:11:20', 91285),
(353, 91285, 'B', 23, 1000, 1, '2013-06-25 11:13:09', '2013-06-25 11:12:45', 1000, 'F', 1, '', '2013-06-25 11:13:09', 91285, '2013-06-25 11:12:45', 91285),
(354, 91285, 'B', 33, 2000, 1.5, '2013-06-25 11:14:16', '2013-06-25 11:13:55', 2000, 'F', 1, '', '2013-06-25 11:14:16', 91285, '2013-06-25 11:13:55', 91285),
(355, 91285, 'B', 22, 1000, 1, '2013-06-25 11:20:10', '2013-06-25 11:19:50', 1000, 'F', 1, '', '2013-06-25 11:20:10', 91285, '2013-06-25 11:19:50', 91285),
(356, 91285, 'B', 23, 1000, 1, '2013-06-25 11:22:24', '2013-06-25 11:22:05', 1000, 'F', 1, '', '2013-06-25 11:22:24', 91285, '2013-06-25 11:22:05', 91285),
(357, 91285, 'B', 33, 1000, 1.5, '2013-06-25 11:24:12', '2013-06-25 11:23:50', 1000, 'F', 1, '', '2013-06-25 11:24:12', 91285, '2013-06-25 11:23:50', 91285),
(358, 91285, 'B', 41, 1000, 2, '2013-06-25 11:28:07', '2013-06-25 11:27:45', 1000, 'F', 1, '', '2013-06-25 11:28:07', 91285, '2013-06-25 11:27:45', 91285),
(359, 991285120, 'B', 34, 10, 290, '2013-06-26 21:44:10', NULL, 0, 'A', 1, '', '2013-06-26 21:44:10', 991285120, '2013-06-26 21:44:10', 991285120),
(360, 991285120, 'B', 29, 10, 750, '2013-06-26 21:44:34', NULL, 0, 'A', 1, '', '2013-06-26 21:44:34', 991285120, '2013-06-26 21:44:34', 991285120),
(361, 991285120, 'B', 40, 10, 1900, '2013-06-26 21:44:59', NULL, 0, 'A', 1, '', '2013-06-26 21:44:59', 991285120, '2013-06-26 21:44:59', 991285120);

-- --------------------------------------------------------

--
-- 表的结构 `ax_trade_match_log`
--

CREATE TABLE IF NOT EXISTS `ax_trade_match_log` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `message` text,
  `status` varchar(2) NOT NULL,
  `run_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `ax_transactions`
--

CREATE TABLE IF NOT EXISTS `ax_transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(2) NOT NULL,
  `sell_user_id` int(11) unsigned DEFAULT NULL,
  `buy_user_id` int(11) unsigned DEFAULT NULL,
  `sell_open_id` int(11) unsigned DEFAULT NULL,
  `buy_open_id` int(11) unsigned DEFAULT NULL,
  `asset_id` int(11) unsigned DEFAULT NULL,
  `volume` int(11) unsigned DEFAULT NULL,
  `close_time` datetime DEFAULT NULL,
  `close_price` double NOT NULL DEFAULT '0',
  `sell_price` double NOT NULL DEFAULT '0',
  `service_fee` double NOT NULL DEFAULT '0',
  `comment` text,
  `sent_msg` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(11) unsigned NOT NULL,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_buy_transaction_idx` (`buy_user_id`),
  KEY `fk_sell_transaction_idx` (`sell_user_id`),
  KEY `idx_symbol` (`asset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=139 ;

--
-- 转存表中的数据 `ax_transactions`
--

INSERT INTO `ax_transactions` (`id`, `type`, `sell_user_id`, `buy_user_id`, `sell_open_id`, `buy_open_id`, `asset_id`, `volume`, `close_time`, `close_price`, `sell_price`, `service_fee`, `comment`, `sent_msg`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 'B', 3888, 991285119, 21, 42, 38, 10000, '2013-06-18 20:10:22', 1.2, 1.1, 100, NULL, 1, '2013-06-18 20:10:22', 991285119, '2013-06-18 20:10:22', 991285119),
(2, 'B', 3888, 991285119, 1, 43, 19, 100000, '2013-06-18 20:10:34', 1.2, 1.1, 1000, NULL, 1, '2013-06-18 20:10:34', 991285119, '2013-06-18 20:10:34', 991285119),
(3, 'B', 3888, 991285119, 2, 44, 20, 100000, '2013-06-18 20:10:46', 1.2, 1.1, 1000, NULL, 1, '2013-06-18 20:10:46', 991285119, '2013-06-18 20:10:46', 991285119),
(4, 'B', 3888, 991285119, 3, 45, 21, 10000, '2013-06-18 20:10:55', 1.2, 1.1, 100, NULL, 1, '2013-06-18 20:10:55', 991285119, '2013-06-18 20:10:55', 991285119),
(5, 'B', 3888, 991285118, 2, 47, 20, 100000, '2013-06-18 20:11:29', 1.2, 1.1, 1000, NULL, 1, '2013-06-18 20:11:29', 991285118, '2013-06-18 20:11:29', 991285118),
(6, 'B', 3888, 991285118, 19, 48, 36, 15000, '2013-06-18 20:11:41', 1.2, 1.1, 150, NULL, 1, '2013-06-18 20:11:41', 991285118, '2013-06-18 20:11:41', 991285118),
(7, 'B', 3888, 991285122, 1, 51, 19, 20000, '2013-06-18 20:12:54', 1.3, 1.1, 200, NULL, 1, '2013-06-18 20:12:54', 991285122, '2013-06-18 20:12:54', 991285122),
(8, 'B', 3888, 991285119, 2, 56, 20, 100000, '2013-06-18 20:19:33', 2.1, 1.1, 1000, NULL, 1, '2013-06-18 20:19:33', 991285119, '2013-06-18 20:19:33', 991285119),
(9, 'B', 3888, 991285122, 59, 60, 19, 10000, '2013-06-18 20:22:45', 1.3, 1.1, 100, NULL, 1, '2013-06-18 20:22:45', 991285122, '2013-06-18 20:22:45', 991285122),
(10, 'B', 991285118, 991285122, 50, 63, 20, 10000, '2013-06-18 20:28:43', 2.3, 1.4, 100, NULL, 1, '2013-06-18 20:28:43', 991285122, '2013-06-18 20:28:43', 991285122),
(11, 'B', 3888, 991285122, 15, 71, 33, 5000, '2013-06-18 20:42:54', 1.2, 1.1, 50, NULL, 1, '2013-06-18 20:42:54', 991285122, '2013-06-18 20:42:54', 991285122),
(12, 'B', 3888, 991285122, 31, 72, 50, 10000, '2013-06-18 20:43:38', 1.2, 1.1, 100, NULL, 1, '2013-06-18 20:43:38', 991285122, '2013-06-18 20:43:38', 991285122),
(13, 'B', 991285122, 991285118, 61, 73, 19, 10000, '2013-06-18 20:44:18', 1.6, 1.35, 100, NULL, 1, '2013-06-18 20:44:18', 991285118, '2013-06-18 20:44:18', 991285118),
(14, 'B', 991285122, 991285118, 54, 73, 19, 10000, '2013-06-18 20:44:19', 1.6, 1.4, 100, NULL, 1, '2013-06-18 20:44:19', 991285118, '2013-06-18 20:44:19', 991285118),
(15, 'B', 991285119, 991285118, 76, 73, 19, 80000, '2013-06-18 20:45:11', 1.6, 1.5, 800, NULL, 1, '2013-06-18 20:45:11', 991285119, '2013-06-18 20:45:11', 991285119),
(16, 'B', 3888, 991285119, 106, 108, 46, 5000, '2013-06-18 20:51:20', 1.2, 1, 50, NULL, 1, '2013-06-18 20:51:20', 991285119, '2013-06-18 20:51:20', 991285119),
(17, 'B', 3888, 991285122, 62, 109, 20, 10000, '2013-06-18 20:53:31', 3, 2, 100, NULL, 1, '2013-06-18 20:53:31', 991285122, '2013-06-18 20:53:31', 991285122),
(18, 'B', 3888, 991285124, 105, 119, 50, 5000, '2013-06-18 21:10:25', 1.3, 1.05, 50, NULL, 1, '2013-06-18 21:10:25', 991285124, '2013-06-18 21:10:25', 991285124),
(19, 'B', 991285122, 991285118, 113, 122, 19, 10000, '2013-06-18 21:13:04', 2.1, 1.5, 100, NULL, 1, '2013-06-18 21:13:04', 991285118, '2013-06-18 21:13:04', 991285118),
(20, 'B', 991285119, 991285118, 120, 130, 19, 10000, '2013-06-18 21:15:55', 2.5, 1.6, 100, NULL, 1, '2013-06-18 21:15:55', 991285118, '2013-06-18 21:15:55', 991285118),
(21, 'B', 3888, 991285122, 84, 131, 30, 5000, '2013-06-18 21:15:58', 1.1, 1, 50, NULL, 1, '2013-06-18 21:15:58', 991285122, '2013-06-18 21:15:58', 991285122),
(22, 'B', 991285119, 991285118, 112, 133, 20, 20000, '2013-06-18 21:18:36', 2.9, 2.5, 200, NULL, 1, '2013-06-18 21:18:36', 991285118, '2013-06-18 21:18:36', 991285118),
(23, 'B', 991285119, 991285118, 120, 135, 19, 10000, '2013-06-18 21:19:15', 3, 1.6, 100, NULL, 1, '2013-06-18 21:19:15', 991285118, '2013-06-18 21:19:15', 991285118),
(24, 'B', 991285119, 991285122, 112, 138, 20, 10000, '2013-06-18 21:19:42', 2.8, 2.5, 100, NULL, 1, '2013-06-18 21:19:42', 991285122, '2013-06-18 21:19:42', 991285122),
(25, 'B', 991285119, 991285122, 112, 140, 20, 10000, '2013-06-18 21:21:12', 2.6, 2.5, 100, NULL, 1, '2013-06-18 21:21:12', 991285122, '2013-06-18 21:21:12', 991285122),
(26, 'B', 991285119, 991285122, 112, 143, 20, 10000, '2013-06-18 21:24:38', 3, 2.5, 100, NULL, 1, '2013-06-18 21:24:38', 991285122, '2013-06-18 21:24:38', 991285122),
(27, 'B', 991285118, 991285124, 132, 145, 19, 20000, '2013-06-18 21:26:37', 3.1, 2.5, 200, NULL, 1, '2013-06-18 21:26:37', 991285124, '2013-06-18 21:26:37', 991285124),
(28, 'B', 991285118, 991285124, 137, 145, 19, 10000, '2013-06-18 21:26:38', 3.1, 2.6, 100, NULL, 1, '2013-06-18 21:26:38', 991285124, '2013-06-18 21:26:38', 991285124),
(29, 'B', 991285118, 991285124, 142, 145, 19, 70000, '2013-06-18 21:26:39', 3.1, 3, 700, NULL, 1, '2013-06-18 21:26:39', 991285124, '2013-06-18 21:26:39', 991285124),
(30, 'B', 991285118, 991285124, 142, 147, 19, 10000, '2013-06-18 21:27:21', 4, 3, 100, NULL, 1, '2013-06-18 21:27:21', 991285124, '2013-06-18 21:27:21', 991285124),
(31, 'B', 991285118, 991285124, 142, 149, 19, 10000, '2013-06-18 21:27:44', 4.2, 3, 100, NULL, 1, '2013-06-18 21:27:44', 991285124, '2013-06-18 21:27:44', 991285124),
(32, 'B', 991285118, 991285122, 141, 151, 19, 10000, '2013-06-18 21:29:32', 4.5, 4, 100, NULL, 1, '2013-06-18 21:29:32', 991285122, '2013-06-18 21:29:32', 991285122),
(33, 'S', 991285122, 991285124, 156, 152, 19, 10000, '2013-06-18 21:34:17', 5, 4.7, 100, NULL, 1, '2013-06-18 21:34:17', 991285122, '2013-06-18 21:34:17', 991285122),
(34, 'B', 991285119, 991285122, 112, 157, 20, 10000, '2013-06-18 21:34:55', 3.3, 2.5, 100, NULL, 1, '2013-06-18 21:34:55', 991285122, '2013-06-18 21:34:55', 991285122),
(35, 'B', 991285124, 991285122, 154, 158, 50, 5000, '2013-06-18 21:35:27', 1.5, 1.4, 50, NULL, 1, '2013-06-18 21:35:27', 991285122, '2013-06-18 21:35:27', 991285122),
(36, 'B', 3888, 991285122, 99, 164, 44, 10000, '2013-06-18 21:43:00', 1.1, 1, 100, NULL, 1, '2013-06-18 21:43:00', 991285122, '2013-06-18 21:43:00', 991285122),
(37, 'B', 991285124, 991285118, 163, 165, 19, 80000, '2013-06-18 21:43:25', 5.1, 5, 800, NULL, 1, '2013-06-18 21:43:25', 991285118, '2013-06-18 21:43:25', 991285118),
(38, 'B', 3888, 991285122, 94, 166, 39, 5000, '2013-06-18 21:43:49', 10, 1, 50, NULL, 1, '2013-06-18 21:43:49', 991285122, '2013-06-18 21:43:49', 991285122),
(39, 'B', 3888, 991285122, 94, 168, 39, 5000, '2013-06-18 21:44:30', 10, 1, 50, NULL, 1, '2013-06-18 21:44:30', 991285122, '2013-06-18 21:44:30', 991285122),
(40, 'B', 991285118, 991285124, 167, 170, 19, 60000, '2013-06-18 21:45:13', 6, 5.5, 600, NULL, 1, '2013-06-18 21:45:13', 991285124, '2013-06-18 21:45:13', 991285124),
(41, 'B', 3888, 991285122, 172, 168, 39, 5000, '2013-06-18 21:46:36', 10, 9, 50, NULL, 1, '2013-06-18 21:46:36', 3888, '2013-06-18 21:46:36', 3888),
(42, 'B', 991285118, 991285124, 171, 173, 19, 10000, '2013-06-18 21:47:05', 6.5, 5, 100, NULL, 1, '2013-06-18 21:47:05', 991285124, '2013-06-18 21:47:05', 991285124),
(43, 'B', 3888, 991285122, 172, 175, 39, 5000, '2013-06-18 21:47:58', 11, 9, 50, NULL, 1, '2013-06-18 21:47:58', 991285122, '2013-06-18 21:47:58', 991285122),
(44, 'B', 991285124, 991285118, 178, 176, 19, 10000, '2013-06-18 21:49:09', 8, 6.4, 100, NULL, 1, '2013-06-18 21:49:09', 991285124, '2013-06-18 21:49:09', 991285124),
(45, 'B', 991285124, 991285118, 179, 184, 19, 10000, '2013-06-18 21:57:29', 12, 6.2, 100, NULL, 1, '2013-06-18 21:57:29', 991285118, '2013-06-18 21:57:29', 991285118),
(46, 'B', 991285124, 991285118, 179, 186, 19, 10000, '2013-06-18 22:00:09', 20, 6.2, 100, NULL, 1, '2013-06-18 22:00:09', 991285118, '2013-06-18 22:00:09', 991285118),
(47, 'B', 991285118, 991285124, 189, 190, 19, 10000, '2013-06-18 22:03:25', 21, 20, 100, NULL, 1, '2013-06-18 22:03:25', 991285124, '2013-06-18 22:03:25', 991285124),
(48, 'B', 991285124, 991285118, 193, 192, 19, 10000, '2013-06-18 22:05:30', 24, 23, 100, NULL, 1, '2013-06-18 22:05:30', 991285124, '2013-06-18 22:05:30', 991285124),
(49, 'B', 991285118, 991285124, 194, 195, 19, 10000, '2013-06-18 22:07:21', 24, 23.5, 100, NULL, 1, '2013-06-18 22:07:21', 991285124, '2013-06-18 22:07:21', 991285124),
(50, 'B', 3888, 991285119, 74, 201, 21, 10000, '2013-06-18 22:12:38', 3, 1, 100, NULL, 1, '2013-06-18 22:12:38', 991285119, '2013-06-18 22:12:38', 991285119),
(51, 'B', 3888, 991285119, 74, 202, 21, 10000, '2013-06-18 22:13:56', 4, 1, 100, NULL, 1, '2013-06-18 22:13:56', 991285119, '2013-06-18 22:13:56', 991285119),
(52, 'B', 991285124, 991285118, 203, 204, 19, 10000, '2013-06-18 22:14:43', 21, 20, 100, NULL, 1, '2013-06-18 22:14:43', 991285118, '2013-06-18 22:14:43', 991285118),
(53, 'S', 991285118, 991285124, 211, 210, 19, 10000, '2013-06-18 22:17:19', 20, 19, 100, NULL, 1, '2013-06-18 22:17:19', 991285118, '2013-06-18 22:17:19', 991285118),
(54, 'B', 991285124, 991285118, 214, 215, 19, 10000, '2013-06-18 22:19:23', 21, 20.5, 100, NULL, 1, '2013-06-18 22:19:23', 991285118, '2013-06-18 22:19:23', 991285118),
(55, 'B', 991285118, 991285124, 200, 216, 20, 50000, '2013-06-18 22:21:14', 3.4, 2.5, 500, NULL, 1, '2013-06-18 22:21:14', 991285124, '2013-06-18 22:21:14', 991285124),
(56, 'B', 991285122, 991285118, 146, 218, 20, 10000, '2013-06-18 22:22:48', 5, 3, 100, NULL, 1, '2013-06-18 22:22:48', 991285118, '2013-06-18 22:22:48', 991285118),
(57, 'B', 991285122, 991285118, 146, 219, 20, 10000, '2013-06-18 22:23:14', 8, 3, 100, NULL, 1, '2013-06-18 22:23:14', 991285118, '2013-06-18 22:23:14', 991285118),
(58, 'B', 991285118, 991285124, 117, 220, 36, 15000, '2013-06-18 22:26:41', 1.6, 1.5, 150, NULL, 1, '2013-06-18 22:26:41', 991285124, '2013-06-18 22:26:41', 991285124),
(59, 'D', NULL, 991285118, NULL, NULL, NULL, NULL, '2013-06-19 01:31:23', 1000000, 0, 0, '', 1, '2013-06-19 01:31:23', 91285, '2013-06-19 01:31:23', 91285),
(60, 'D', NULL, 991285119, NULL, NULL, NULL, NULL, '2013-06-19 01:31:39', 1000000, 0, 0, '', 1, '2013-06-19 01:31:39', 91285, '2013-06-19 01:31:39', 91285),
(61, 'D', NULL, 991285124, NULL, NULL, NULL, NULL, '2013-06-19 01:31:52', 1000000, 0, 0, '', 1, '2013-06-19 01:31:52', 91285, '2013-06-19 01:31:52', 91285),
(62, 'D', NULL, 991285122, NULL, NULL, NULL, NULL, '2013-06-19 01:34:57', 1000000, 0, 0, '', 1, '2013-06-19 01:34:57', 91285, '2013-06-19 01:34:57', 91285),
(63, 'D', NULL, 991285118, NULL, NULL, NULL, NULL, '2013-06-19 01:41:31', 1000000, 0, 0, '', 1, '2013-06-19 01:41:31', 91285, '2013-06-19 01:41:31', 91285),
(64, 'D', NULL, 991285119, NULL, NULL, NULL, NULL, '2013-06-19 01:41:36', 1000000, 0, 0, '', 1, '2013-06-19 01:41:36', 91285, '2013-06-19 01:41:36', 91285),
(65, 'D', NULL, 991285120, NULL, NULL, NULL, NULL, '2013-06-19 01:41:52', 2000000, 0, 0, '', 1, '2013-06-19 01:41:52', 91285, '2013-06-19 01:41:52', 91285),
(66, 'D', NULL, 991285122, NULL, NULL, NULL, NULL, '2013-06-19 01:41:59', 1000000, 0, 0, '', 1, '2013-06-19 01:41:59', 91285, '2013-06-19 01:41:59', 91285),
(67, 'D', NULL, 991285124, NULL, NULL, NULL, NULL, '2013-06-19 01:42:05', 1000000, 0, 0, '', 1, '2013-06-19 01:42:05', 91285, '2013-06-19 01:42:05', 91285),
(68, 'B', 3888, 991285122, 95, 231, 41, 10000, '2013-06-19 01:43:25', 1.1, 1, 100, NULL, 1, '2013-06-19 01:43:25', 991285122, '2013-06-19 01:43:25', 991285122),
(69, 'B', 3888, 991285122, 93, 232, 37, 5000, '2013-06-19 01:43:50', 1.1, 1, 50, NULL, 1, '2013-06-19 01:43:50', 991285122, '2013-06-19 01:43:50', 991285122),
(70, 'B', 3888, 991285122, 77, 235, 22, 5000, '2013-06-19 01:45:36', 1.05, 1, 50, NULL, 1, '2013-06-19 01:45:36', 991285122, '2013-06-19 01:45:36', 991285122),
(71, 'B', 3888, 991285122, 91, 236, 35, 5000, '2013-06-19 01:46:03', 1.1, 1, 50, NULL, 1, '2013-06-19 01:46:03', 991285122, '2013-06-19 01:46:03', 991285122),
(72, 'B', 3888, 991285122, 75, 238, 23, 10000, '2013-06-19 01:47:02', 1.2, 1, 100, NULL, 1, '2013-06-19 01:47:02', 991285122, '2013-06-19 01:47:02', 991285122),
(73, 'B', 3888, 991285122, 74, 239, 21, 5000, '2013-06-19 01:47:37', 1.7, 1, 50, NULL, 1, '2013-06-19 01:47:37', 991285122, '2013-06-19 01:47:37', 991285122),
(74, 'B', 3888, 991285122, 74, 243, 21, 1000000, '2013-06-19 01:59:31', 1.1, 1, 10000, NULL, 1, '2013-06-19 01:59:31', 991285122, '2013-06-19 01:59:31', 991285122),
(75, 'B', 3888, 991285122, 244, 245, 19, 50000, '2013-06-19 02:02:45', 0.96, 0.95, 500, NULL, 1, '2013-06-19 02:02:45', 991285122, '2013-06-19 02:02:45', 991285122),
(76, 'B', 3888, 991285122, 244, 246, 19, 450000, '2013-06-19 02:03:32', 0.98, 0.95, 4500, NULL, 1, '2013-06-19 02:03:32', 991285122, '2013-06-19 02:03:32', 991285122),
(77, 'D', NULL, 91285, NULL, NULL, NULL, NULL, '2013-06-19 13:14:31', 10000, 0, 0, '存款10000', 1, '2013-06-19 13:14:31', 91285, '2013-06-19 13:14:31', 91285),
(78, 'B', 3888, 16513, 74, 258, 21, 5000, '2013-06-19 16:25:30', 1.5, 1, 50, NULL, 1, '2013-06-19 16:25:30', 16513, '2013-06-19 16:25:30', 16513),
(79, 'B', 3888, 991285120, 92, 262, 35, 10000, '2013-06-19 17:02:45', 1.1, 1, 100, NULL, 1, '2013-06-19 17:02:45', 991285120, '2013-06-19 17:02:45', 991285120),
(80, 'B', 3888, 991285120, 87, 263, 32, 5000, '2013-06-19 17:04:15', 1, 1, 50, NULL, 1, '2013-06-19 17:04:15', 991285120, '2013-06-19 17:04:15', 991285120),
(81, 'B', 3888, 991285120, 97, 264, 43, 15000, '2013-06-19 17:05:00', 1, 1, 150, NULL, 1, '2013-06-19 17:05:00', 991285120, '2013-06-19 17:05:00', 991285120),
(82, 'B', 3888, 991285120, 79, 265, 26, 10000, '2013-06-19 22:06:10', 1.2, 1, 100, NULL, 1, '2013-06-19 22:06:10', 991285120, '2013-06-19 22:06:10', 991285120),
(83, 'B', 3888, 991285120, 96, 269, 40, 5000, '2013-06-19 23:42:50', 1, 1, 50, NULL, 1, '2013-06-19 23:42:50', 991285120, '2013-06-19 23:42:50', 991285120),
(84, 'B', 3888, 91285, 74, 271, 21, 1000, '2013-06-21 15:59:15', 1, 1, 10, NULL, 1, '2013-06-21 15:59:15', 91285, '2013-06-21 15:59:15', 91285),
(85, 'B', 991285122, 91285, 248, 272, 19, 2000, '2013-06-21 15:59:45', 2, 2, 20, NULL, 1, '2013-06-21 15:59:45', 91285, '2013-06-21 15:59:45', 91285),
(86, 'B', 3888, 991285122, 103, 274, 48, 10000, '2013-06-21 21:12:10', 1.1, 1, 100, NULL, 1, '2013-06-21 21:12:10', 991285122, '2013-06-21 21:12:10', 991285122),
(87, 'B', 991285122, 991285120, 251, 277, 44, 10000, '2013-06-21 21:23:55', 1.5, 1.5, 100, NULL, 1, '2013-06-21 21:23:55', 991285120, '2013-06-21 21:23:55', 991285120),
(88, 'S', 991285119, 991285120, 280, 268, 38, 10000, '2013-06-21 21:29:20', 1.2, 1.1, 100, NULL, 1, '2013-06-21 21:29:20', 991285119, '2013-06-21 21:29:20', 991285119),
(89, 'B', 991285122, 991285119, 275, 284, 48, 5000, '2013-06-21 21:34:50', 5, 1.5, 50, NULL, 1, '2013-06-21 21:34:50', 991285119, '2013-06-21 21:34:50', 991285119),
(90, 'B', 3888, 991285120, 101, 294, 45, 10000, '2013-06-21 21:42:05', 1, 1, 100, NULL, 1, '2013-06-21 21:42:05', 991285120, '2013-06-21 21:42:05', 991285120),
(91, 'B', 3888, 991285120, 104, 297, 49, 10000, '2013-06-21 21:47:00', 1, 1, 100, NULL, 1, '2013-06-21 21:47:00', 991285120, '2013-06-21 21:47:00', 991285120),
(92, 'B', 991285119, 991285120, 282, 298, 46, 5000, '2013-06-21 21:47:35', 1.5, 1.5, 50, NULL, 1, '2013-06-21 21:47:35', 991285120, '2013-06-21 21:47:35', 991285120),
(93, 'B', 3888, 991285120, 80, 302, 27, 10000, '2013-06-21 21:50:05', 1, 1, 100, NULL, 1, '2013-06-21 21:50:05', 991285120, '2013-06-21 21:50:05', 991285120),
(94, 'B', 3888, 991285120, 82, 303, 29, 10000, '2013-06-21 21:51:00', 1, 1, 100, NULL, 1, '2013-06-21 21:51:00', 991285120, '2013-06-21 21:51:00', 991285120),
(95, 'B', 3888, 991285120, 102, 306, 47, 15000, '2013-06-21 21:54:55', 1, 1, 150, NULL, 1, '2013-06-21 21:54:55', 991285120, '2013-06-21 21:54:55', 991285120),
(96, 'B', 3888, 991285120, 85, 308, 31, 50000, '2013-06-21 21:56:50', 1, 1, 500, NULL, 1, '2013-06-21 21:56:50', 991285120, '2013-06-21 21:56:50', 991285120),
(97, 'B', 3888, 991285120, 86, 308, 31, 10000, '2013-06-21 21:56:50', 1, 1, 100, NULL, 1, '2013-06-21 21:56:50', 991285120, '2013-06-21 21:56:50', 991285120),
(98, 'B', 3888, 991285120, 78, 311, 24, 10000, '2013-06-21 22:10:20', 1, 1, 100, NULL, 1, '2013-06-21 22:10:20', 991285120, '2013-06-21 22:10:20', 991285120),
(99, 'B', 3888, 991285120, 90, 313, 34, 10000, '2013-06-21 22:13:20', 1, 1, 100, NULL, 1, '2013-06-21 22:13:20', 991285120, '2013-06-21 22:13:20', 991285120),
(100, 'B', 3888, 991285120, 81, 314, 28, 5000, '2013-06-21 22:14:05', 1, 1, 50, NULL, 1, '2013-06-21 22:14:05', 991285120, '2013-06-21 22:14:05', 991285120),
(101, 'B', 991285122, 991285120, 134, 316, 30, 5000, '2013-06-21 22:15:45', 1.2, 1.2, 50, NULL, 1, '2013-06-21 22:15:45', 991285120, '2013-06-21 22:15:45', 991285120),
(102, 'B', 3888, 991285120, 74, 317, 21, 99999, '2013-06-21 22:16:30', 1, 1, 999.99, NULL, 1, '2013-06-21 22:16:30', 991285120, '2013-06-21 22:16:30', 991285120),
(103, 'B', 3888, 991285120, 89, 326, 33, 5000, '2013-06-21 22:43:00', 1.05, 1.05, 50, NULL, 1, '2013-06-21 22:43:00', 991285120, '2013-06-21 22:43:00', 991285120),
(104, 'B', 3888, 991285120, 77, 327, 22, 10000, '2013-06-21 22:44:05', 1.1, 1, 100, NULL, 1, '2013-06-21 22:44:05', 991285120, '2013-06-21 22:44:05', 991285120),
(105, 'B', 3888, 991285122, 75, 237, 23, 10000, '2013-06-24 13:25:10', 1, 1, 100, NULL, 1, '2013-06-24 13:25:10', 991285122, '2013-06-24 13:25:10', 991285122),
(107, 'B', 3888, 991285122, 77, 233, 22, 10000, '2013-06-24 14:12:15', 1, 1, 100, NULL, 1, '2013-06-24 14:12:15', 991285122, '2013-06-24 14:12:15', 991285122),
(108, 'B', 3888, 991285122, 77, 234, 22, 10000, '2013-06-24 14:12:20', 1, 1, 100, NULL, 1, '2013-06-24 14:12:20', 991285122, '2013-06-24 14:12:20', 991285122),
(117, 'B', NULL, 3888, NULL, NULL, 51, 10000, '2013-06-24 17:35:37', 1, 1, 0, NULL, 0, '2013-06-24 17:35:37', 91285, '2013-06-24 17:35:37', 91285),
(118, 'B', 991285122, 16513, 248, 334, 19, 10000, '2013-06-24 17:45:00', 2, 2, 100, NULL, 1, '2013-06-24 17:45:00', 16513, '2013-06-24 17:45:00', 16513),
(119, 'B', 3888, 991285122, 172, 335, 39, 1000, '2013-06-24 23:55:15', 15, 9, 10, NULL, 1, '2013-06-24 23:55:15', 991285122, '2013-06-24 23:55:15', 991285122),
(120, 'B', 991285118, 91285, 217, 336, 20, 1000, '2013-06-25 10:22:35', 8.5, 3, 10, NULL, 1, '2013-06-25 10:22:35', 91285, '2013-06-25 10:22:35', 91285),
(121, 'B', 991285122, 91285, 252, 340, 41, 1000, '2013-06-25 10:34:50', 2, 2, 10, NULL, 1, '2013-06-25 10:34:50', 91285, '2013-06-25 10:34:50', 91285),
(122, 'B', 991285122, 91285, 253, 341, 37, 1000, '2013-06-25 10:36:20', 1.5, 1.5, 10, NULL, 1, '2013-06-25 10:36:20', 91285, '2013-06-25 10:36:20', 91285),
(123, 'B', 991285122, 91285, 159, 342, 50, 1000, '2013-06-25 10:38:35', 2, 2, 10, NULL, 1, '2013-06-25 10:38:35', 91285, '2013-06-25 10:38:35', 91285),
(124, 'B', 3888, 91285, 74, 343, 21, 1000, '2013-06-25 10:39:55', 1, 1, 10, NULL, 1, '2013-06-25 10:39:55', 91285, '2013-06-25 10:39:55', 91285),
(125, 'B', 3888, 91285, 78, 344, 24, 1000, '2013-06-25 10:41:40', 1, 1, 10, NULL, 1, '2013-06-25 10:41:40', 91285, '2013-06-25 10:41:40', 91285),
(126, 'B', 991285122, 91285, 250, 345, 33, 1000, '2013-06-25 10:42:35', 1.5, 1.5, 10, NULL, 1, '2013-06-25 10:42:35', 91285, '2013-06-25 10:42:35', 91285),
(127, 'B', 991285120, 91285, 267, 346, 35, 1000, '2013-06-25 10:45:25', 1.1, 1.1, 10, NULL, 1, '2013-06-25 10:45:25', 91285, '2013-06-25 10:45:25', 91285),
(128, 'B', 3888, 91285, 77, 347, 22, 1000, '2013-06-25 10:46:20', 1, 1, 10, NULL, 1, '2013-06-25 10:46:20', 91285, '2013-06-25 10:46:20', 91285),
(129, 'B', 991285124, 91285, 227, 348, 36, 1000, '2013-06-25 11:03:40', 1.8, 1.8, 10, NULL, 1, '2013-06-25 11:03:40', 91285, '2013-06-25 11:03:40', 91285),
(130, 'B', 3888, 91285, 78, 349, 24, 1000, '2013-06-25 11:05:15', 1, 1, 10, NULL, 1, '2013-06-25 11:05:15', 91285, '2013-06-25 11:05:15', 91285),
(131, 'B', 3888, 91285, 79, 350, 26, 1000, '2013-06-25 11:06:05', 1, 1, 10, NULL, 1, '2013-06-25 11:06:05', 91285, '2013-06-25 11:06:05', 91285),
(132, 'B', 3888, 91285, 172, 352, 39, 1000, '2013-06-25 11:11:20', 9, 9, 10, NULL, 1, '2013-06-25 11:11:20', 91285, '2013-06-25 11:11:20', 91285),
(133, 'B', 3888, 91285, 75, 353, 23, 1000, '2013-06-25 11:12:45', 1, 1, 10, NULL, 1, '2013-06-25 11:12:45', 91285, '2013-06-25 11:12:45', 91285),
(134, 'B', 991285122, 91285, 250, 354, 33, 2000, '2013-06-25 11:13:55', 1.5, 1.5, 20, NULL, 1, '2013-06-25 11:13:55', 91285, '2013-06-25 11:13:55', 91285),
(135, 'B', 3888, 91285, 77, 355, 22, 1000, '2013-06-25 11:19:50', 1, 1, 10, NULL, 1, '2013-06-25 11:19:50', 91285, '2013-06-25 11:19:50', 91285),
(136, 'B', 3888, 91285, 75, 356, 23, 1000, '2013-06-25 11:22:05', 1, 1, 10, NULL, 1, '2013-06-25 11:22:05', 91285, '2013-06-25 11:22:05', 91285),
(137, 'B', 991285122, 91285, 250, 357, 33, 1000, '2013-06-25 11:23:50', 1.5, 1.5, 10, NULL, 1, '2013-06-25 11:23:50', 91285, '2013-06-25 11:23:50', 91285),
(138, 'B', 991285122, 91285, 252, 358, 41, 1000, '2013-06-25 11:27:45', 2, 2, 10, NULL, 1, '2013-06-25 11:27:45', 91285, '2013-06-25 11:27:45', 91285);

-- --------------------------------------------------------

--
-- 表的结构 `ax_user_assets`
--

CREATE TABLE IF NOT EXISTS `ax_user_assets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `asset_id` int(11) unsigned NOT NULL,
  `volume` int(11) unsigned NOT NULL,
  `average_price` double NOT NULL,
  `status` varchar(2) NOT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(11) unsigned NOT NULL,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_userasset_idx` (`user_id`),
  KEY `idx_symbol` (`asset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=96 ;

--
-- 转存表中的数据 `ax_user_assets`
--

INSERT INTO `ax_user_assets` (`id`, `user_id`, `asset_id`, `volume`, `average_price`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 3888, 19, 3372000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-24 17:31:16', 91285),
(2, 3888, 20, 3690000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285122),
(3, 3888, 21, 3388001, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(4, 3888, 22, 293000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(5, 3888, 23, 5978000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(6, 3888, 24, 548000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(7, 3888, 25, 5230000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(8, 3888, 26, 3669000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(9, 3888, 27, 4110000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(10, 3888, 28, 4995000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(11, 3888, 29, 5870000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(12, 3888, 30, 473000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285122),
(13, 3888, 31, 4480000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(14, 3888, 32, 6775000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(15, 3888, 33, 5330000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(16, 3888, 34, 5990000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(17, 3888, 35, 6985000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(18, 3888, 36, 6685000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285118),
(19, 3888, 37, 5295000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285122),
(20, 3888, 38, 5335000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285119),
(21, 3888, 39, 4518000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(22, 3888, 40, 4495000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(23, 3888, 41, 4290000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285122),
(24, 3888, 43, 2485000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(25, 3888, 44, 4490000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285122),
(26, 3888, 45, 790000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(27, 3888, 46, 1195000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285119),
(28, 3888, 47, 985000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(29, 3888, 48, 970000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(30, 3888, 49, 930000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 3888),
(31, 3888, 50, 985000, 1, 'A', '2013-06-18 19:31:41', 3888, '2013-06-18 19:31:41', 991285124),
(32, 991285119, 38, 0, 1.2, 'A', '2013-06-18 20:10:22', 991285119, '2013-06-18 20:10:22', 991285119),
(33, 991285119, 19, 0, 1.2, 'A', '2013-06-18 20:10:34', 991285119, '2013-06-18 20:10:34', 991285118),
(34, 991285119, 20, 140000, 1.65, 'A', '2013-06-18 20:10:46', 991285119, '2013-06-18 20:10:46', 991285122),
(35, 991285119, 21, 30000, 2.7333333333333, 'A', '2013-06-18 20:10:56', 991285119, '2013-06-18 20:10:56', 991285119),
(36, 991285118, 20, 79000, 2.7568181818182, 'A', '2013-06-18 20:11:30', 991285118, '2013-06-18 20:11:30', 991285118),
(37, 991285118, 36, 0, 1.2, 'A', '2013-06-18 20:11:42', 991285118, '2013-06-18 20:11:42', 991285124),
(38, 991285122, 19, 488000, 0.978, 'A', '2013-06-18 20:12:54', 991285122, '2013-06-18 20:12:54', 991285122),
(39, 991285122, 20, 40000, 2.8333333333333, 'A', '2013-06-18 20:28:43', 991285122, '2013-06-18 20:28:43', 991285118),
(40, 991285122, 33, 1000, 1.2, 'A', '2013-06-18 20:42:54', 991285122, '2013-06-18 20:42:54', 991285122),
(41, 991285122, 50, 14000, 1.3, 'A', '2013-06-18 20:43:38', 991285122, '2013-06-18 20:43:38', 991285122),
(42, 991285118, 19, 40000, 17.319140625, 'A', '2013-06-18 20:44:19', 991285118, '2013-06-18 20:44:19', 991285118),
(43, 991285119, 46, 0, 1.2, 'A', '2013-06-18 20:51:21', 991285119, '2013-06-18 20:51:21', 991285119),
(44, 991285124, 50, 0, 1.3, 'A', '2013-06-18 21:10:25', 991285124, '2013-06-18 21:10:25', 991285122),
(45, 991285122, 30, 0, 1.1, 'A', '2013-06-18 21:15:58', 991285122, '2013-06-18 21:15:58', 991285122),
(46, 991285124, 19, 90000, 9.475625, 'A', '2013-06-18 21:26:38', 991285124, '2013-06-18 21:26:38', 991285118),
(47, 991285122, 44, 0, 1.1, 'A', '2013-06-18 21:43:01', 991285122, '2013-06-18 21:43:01', 991285122),
(48, 991285122, 39, 21000, 10.4761904761905, 'A', '2013-06-18 21:43:49', 991285122, '2013-06-18 21:43:49', 991285122),
(49, 991285124, 20, 50000, 3.4, 'A', '2013-06-18 22:21:15', 991285124, '2013-06-18 22:21:15', 991285124),
(50, 991285124, 36, 14000, 1.6, 'A', '2013-06-18 22:26:42', 991285124, '2013-06-18 22:26:42', 991285124),
(51, 991285122, 41, 8000, 1.1, 'A', '2013-06-19 01:43:26', 991285122, '2013-06-19 01:43:26', 991285122),
(52, 991285122, 37, 4000, 1.1, 'A', '2013-06-19 01:43:51', 991285122, '2013-06-19 01:43:51', 991285122),
(53, 991285122, 22, 25000, 1.01, 'A', '2013-06-19 01:45:37', 991285122, '2013-06-19 01:45:37', 991285122),
(54, 991285122, 35, 5000, 1.1, 'A', '2013-06-19 01:46:04', 991285122, '2013-06-19 01:46:04', 991285122),
(55, 991285122, 23, 20000, 1.1, 'A', '2013-06-19 01:47:03', 991285122, '2013-06-19 01:47:03', 991285122),
(56, 991285122, 21, 1005000, 1.1029850746269, 'A', '2013-06-19 01:47:38', 991285122, '2013-06-19 01:47:38', 991285122),
(57, 16513, 21, 5000, 1.5, 'A', '2013-06-19 16:25:30', 16513, '2013-06-19 16:25:30', 16513),
(58, 991285120, 35, 9000, 1.1, 'A', '2013-06-19 17:02:45', 991285120, '2013-06-19 17:02:45', 991285120),
(59, 991285120, 32, 5000, 1, 'A', '2013-06-19 17:04:15', 991285120, '2013-06-19 17:04:15', 991285120),
(60, 991285120, 43, 15000, 1, 'A', '2013-06-19 17:05:00', 991285120, '2013-06-19 17:05:00', 991285120),
(61, 991285120, 26, 10000, 1.2, 'A', '2013-06-19 22:06:10', 991285120, '2013-06-19 22:06:10', 991285120),
(62, 991285120, 40, 5000, 1, 'A', '2013-06-19 23:42:50', 991285120, '2013-06-19 23:42:50', 991285120),
(63, 91285, 21, 2000, 1, 'A', '2013-06-21 15:59:15', 91285, '2013-06-21 15:59:15', 91285),
(64, 991285122, 48, 5000, 1.1, 'A', '2013-06-21 21:12:10', 991285122, '2013-06-21 21:12:10', 991285122),
(65, 991285120, 44, 10000, 1.5, 'A', '2013-06-21 21:23:55', 991285120, '2013-06-21 21:23:55', 991285120),
(66, 991285120, 38, 10000, 1.2, 'A', '2013-06-21 21:29:20', 991285120, '2013-06-21 21:29:20', 991285120),
(67, 991285119, 48, 5000, 5, 'A', '2013-06-21 21:34:50', 991285119, '2013-06-21 21:34:50', 991285119),
(68, 991285120, 45, 10000, 1, 'A', '2013-06-21 21:42:05', 991285120, '2013-06-21 21:42:05', 991285120),
(69, 991285120, 49, 10000, 1, 'A', '2013-06-21 21:47:00', 991285120, '2013-06-21 21:47:00', 991285120),
(70, 991285120, 46, 5000, 1.5, 'A', '2013-06-21 21:47:35', 991285120, '2013-06-21 21:47:35', 991285120),
(71, 991285120, 27, 10000, 1, 'A', '2013-06-21 21:50:05', 991285120, '2013-06-21 21:50:05', 991285120),
(72, 991285120, 29, 10000, 1, 'A', '2013-06-21 21:51:00', 991285120, '2013-06-21 21:51:00', 991285120),
(73, 991285120, 47, 15000, 1, 'A', '2013-06-21 21:54:55', 991285120, '2013-06-21 21:54:55', 991285120),
(74, 991285120, 31, 60000, 1, 'A', '2013-06-21 21:56:50', 991285120, '2013-06-21 21:56:50', 991285120),
(75, 991285120, 24, 10000, 1, 'A', '2013-06-21 22:10:20', 991285120, '2013-06-21 22:10:20', 991285120),
(76, 991285120, 34, 10000, 1, 'A', '2013-06-21 22:13:20', 991285120, '2013-06-21 22:13:20', 991285120),
(77, 991285120, 28, 5000, 1, 'A', '2013-06-21 22:14:05', 991285120, '2013-06-21 22:14:05', 991285120),
(78, 991285120, 30, 5000, 1.2, 'A', '2013-06-21 22:15:45', 991285120, '2013-06-21 22:15:45', 991285120),
(79, 991285120, 21, 99999, 1, 'A', '2013-06-21 22:16:30', 991285120, '2013-06-21 22:16:30', 991285120),
(80, 991285120, 33, 5000, 1.05, 'A', '2013-06-21 22:43:00', 991285120, '2013-06-21 22:43:00', 991285120),
(81, 991285120, 22, 10000, 1.1, 'A', '2013-06-21 22:44:05', 991285120, '2013-06-21 22:44:05', 991285120),
(82, 3888, 51, 10000, 1, 'A', '2013-06-24 17:35:37', 91285, '2013-06-24 17:35:37', 91285),
(83, 16513, 19, 10000, 2, 'A', '2013-06-24 17:45:00', 16513, '2013-06-24 17:45:00', 16513),
(84, 91285, 20, 1000, 8.5, 'A', '2013-06-25 10:22:35', 91285, '2013-06-25 10:22:35', 91285),
(85, 91285, 41, 2000, 2, 'A', '2013-06-25 10:34:50', 91285, '2013-06-25 10:34:50', 91285),
(86, 91285, 37, 1000, 1.5, 'A', '2013-06-25 10:36:20', 91285, '2013-06-25 10:36:20', 91285),
(87, 91285, 50, 1000, 2, 'A', '2013-06-25 10:38:35', 91285, '2013-06-25 10:38:35', 91285),
(88, 91285, 24, 2000, 1, 'A', '2013-06-25 10:41:40', 91285, '2013-06-25 10:41:40', 91285),
(89, 91285, 33, 4000, 1.5, 'A', '2013-06-25 10:42:35', 91285, '2013-06-25 10:42:35', 91285),
(90, 91285, 35, 1000, 1.1, 'A', '2013-06-25 10:45:25', 91285, '2013-06-25 10:45:25', 91285),
(91, 91285, 22, 2000, 1, 'A', '2013-06-25 10:46:20', 91285, '2013-06-25 10:46:20', 91285),
(92, 91285, 36, 1000, 1.8, 'A', '2013-06-25 11:03:40', 91285, '2013-06-25 11:03:40', 91285),
(93, 91285, 26, 1000, 1, 'A', '2013-06-25 11:06:05', 91285, '2013-06-25 11:06:05', 91285),
(94, 91285, 39, 1000, 9, 'A', '2013-06-25 11:11:20', 91285, '2013-06-25 11:11:20', 91285),
(95, 91285, 23, 2000, 1, 'A', '2013-06-25 11:12:45', 91285, '2013-06-25 11:12:45', 91285);

-- --------------------------------------------------------

--
-- 表的结构 `ax_user_favourites`
--

CREATE TABLE IF NOT EXISTS `ax_user_favourites` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `asset_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=19 ;

--
-- 转存表中的数据 `ax_user_favourites`
--

INSERT INTO `ax_user_favourites` (`id`, `user_id`, `asset_id`) VALUES
(1, 91285, 19),
(2, 91285, 20),
(3, 91285, 21),
(4, 91285, 22),
(5, 91285, 23),
(10, 91285, 24),
(11, 991285122, 19),
(13, 991285122, 21),
(14, 91285, 51),
(15, 991285118, 19),
(16, 991285122, 20),
(17, 991285122, 24),
(18, 991285122, 39);

-- --------------------------------------------------------

--
-- 表的结构 `ax_users`
--

CREATE TABLE IF NOT EXISTS `ax_users` (
  `id` int(11) unsigned NOT NULL,
  `group` varchar(45) NOT NULL,
  `balance` double NOT NULL DEFAULT '0',
  `status` varchar(2) NOT NULL DEFAULT 'A',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `created_by` int(11) unsigned NOT NULL,
  `modified_by` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `ax_users`
--

INSERT INTO `ax_users` (`id`, `group`, `balance`, `status`, `created`, `modified`, `created_by`, `modified_by`) VALUES
(3888, 'User', 764739.01, 'A', '2013-06-10 14:50:39', '2013-06-25 11:22:05', 0, 3888),
(16513, 'User', 472350, 'A', '2013-06-17 16:06:52', '2013-06-24 17:45:00', 16513, 16513),
(91285, 'Admin', 462870, 'A', '2013-05-30 04:37:25', '2013-06-25 11:27:45', 0, 91285),
(991285118, 'User', 2024990, 'A', '2013-06-13 13:17:29', '2013-06-25 10:22:35', 991285118, 991285118),
(991285119, 'User', 2245300, 'A', '2013-06-13 13:17:53', '2013-06-21 21:47:35', 991285119, 991285119),
(991285120, 'User', 2153041.01, 'A', '2013-06-13 13:18:51', '2013-06-25 10:45:25', 991285120, 991285120),
(991285122, 'User', 520940, 'A', '2013-05-30 05:02:11', '2013-06-25 11:27:45', 0, 991285122),
(991285124, 'User', 2014290, 'A', '2013-06-13 13:19:17', '2013-06-25 11:03:40', 991285124, 991285124);

-- --------------------------------------------------------

--
-- 视图结构 `ax_mt4_users`
--
DROP TABLE IF EXISTS `ax_mt4_users`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ax_mt4_users` AS select `mt4`.`mt4_users`.`LOGIN` AS `id`,`mt4`.`mt4_users`.`NAME` AS `name`,`mt4`.`mt4_users`.`EMAIL` AS `email` from `mt4`.`mt4_users`;

--
-- 限制导出的表
--

--
-- 限制表 `ax_asset_imgs`
--
ALTER TABLE `ax_asset_imgs`
  ADD CONSTRAINT `fk_img_asset` FOREIGN KEY (`asset_id`) REFERENCES `ax_assets` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `ax_assets`
--
ALTER TABLE `ax_assets`
  ADD CONSTRAINT `fk_district_asset` FOREIGN KEY (`district_id`) REFERENCES `ax_districts` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `ax_messages`
--
ALTER TABLE `ax_messages`
  ADD CONSTRAINT `fk_message_user` FOREIGN KEY (`user_id`) REFERENCES `ax_users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_template_message` FOREIGN KEY (`message_template_id`) REFERENCES `ax_message_templates` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `ax_opens`
--
ALTER TABLE `ax_opens`
  ADD CONSTRAINT `fk_asset_open` FOREIGN KEY (`asset_id`) REFERENCES `ax_assets` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_open` FOREIGN KEY (`user_id`) REFERENCES `ax_users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `ax_transactions`
--
ALTER TABLE `ax_transactions`
  ADD CONSTRAINT `fk_asset_transaction` FOREIGN KEY (`asset_id`) REFERENCES `ax_assets` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_buy_transaction` FOREIGN KEY (`buy_user_id`) REFERENCES `ax_users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_sell_transaction` FOREIGN KEY (`sell_user_id`) REFERENCES `ax_users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- 限制表 `ax_user_assets`
--
ALTER TABLE `ax_user_assets`
  ADD CONSTRAINT `fk_user_userasset` FOREIGN KEY (`user_id`) REFERENCES `ax_users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fl_asset_userasset` FOREIGN KEY (`asset_id`) REFERENCES `ax_assets` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

DELIMITER $$
--
-- 事件
--
CREATE EVENT `trade_matching` ON SCHEDULE EVERY 5 SECOND STARTS '2013-06-19 12:57:15' ON COMPLETION NOT PRESERVE ENABLE DO call ax_trade_matching()$$

CREATE EVENT `trade_message` ON SCHEDULE EVERY 1 MINUTE STARTS '2013-06-19 17:28:38' ON COMPLETION NOT PRESERVE ENABLE DO call ax_send_tran_msg$$

DELIMITER ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
