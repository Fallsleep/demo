<?php
/**
 *
 * PHP 5
 *
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link          http://cakephp.org CakePHP(tm) Project
 * @package       app.View.Layouts
 * @since         CakePHP(tm) v 0.10.0.1076
 * @license       MIT License (http://www.opensource.org/licenses/mit-license.php)
 */

$cakeDescription = __d('cake_dev', 'Care for Mumi');
?>
<!DOCTYPE html>
<html>
<head>
	<?php echo $this->Html->charset(); ?>
	<title>
		<?php echo $cakeDescription ?>:
		<?php echo $title_for_layout; ?>
	</title>
	<?php
		echo $this->Html->meta('icon');
		echo $this->Html->script('https://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js');
		echo $this->Html->css('cake.generic');
		
		echo $this->Html->script('jquery.min');
		echo $this->Html->script('common');
		echo $this->Html->css('common');

		echo $this->fetch('meta');
		echo $this->fetch('css');
		echo $this->fetch('script');
	?>

</head>
<body>
	<div id="container">
		<div id="header">
			<?php if (isset($this->Session->read('Auth.User')['id'])) { 
				$url = explode("/", trim($_SERVER['REQUEST_URI'], '/')); ?>
				<ul>
					<li 
					<?php
					var_dump(count($url));
					if ($url[1] == 'workers' || $url[1] == 'edu_backgrounds' || ($url[1] == 'schedules' && !(count($url) > 2 && $url[2] == 'listAllLocked'))) {
						echo 'class="current"';
					} 
					?>
					><?php echo $this->Html->link('陪月員', array('controller' => 'workers', 'action' => 'index')); ?></li>
					<li 
					<?php
					if ($url[1] == 'jobs') {
						echo 'class="current"';
					}
					?>
					><?php echo $this->Html->link('工作', array('controller' => 'jobs', 'action' => 'index')); ?></li>
					<li 
					<?php
					if ((count($url) > 2) && ($url[2] == 'listAllLocked')) {
						echo 'class="current"';
					}
					?>
					><?php echo $this->Html->link('已鎖定陪月員列表', array('controller' => 'schedules', 'action' => 'listAllLocked')); ?></li>
					<li style="float: right;"><?php echo $this->Html->link('登出', array('controller' => 'users', 'action' => 'logout')); ?></li>
				</ul>	
			<?php } else { echo $cakeDescription; } ?>
		</div>	
		<?php 
			if (isset($this->Session->read('Auth.User')['id'])){
				echo '<div id="content">';
			}else {
				echo '<div id="logincontent">';
			}
		?>	
		<?php // echo $this->Session->flash(); ?>
		<?php echo $this->fetch('content'); ?>
		</div>
		<!--
		<div id="footer">
			<?php echo $this->Html->link(
					$this->Html->image('cake.power.gif', array('alt' => $cakeDescription, 'border' => '0')),
					'http://www.careformumi.com.hk/',
					array('target' => '_blank', 'escape' => false)
				);
			?>
		</div>-->
	</div>
	<?php echo $this->element('sql_dump'); ?>
</body>
</html>
