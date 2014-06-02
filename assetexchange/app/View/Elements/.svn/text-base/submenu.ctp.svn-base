<?php
if ($sub == 'ah'){
	$unread = $this->requestAction('Messages/getUnreadCount');
}

$menus = array('ah' => array('Account' => array('帳戶資訊', array('controller' => 'users', 'action' => 'home')),
							'Open' => array('交易狀況', array('controller' => 'opens', 'action' => 'index')),
		                    'Transaction' => array('交易記錄', array('controller' => 'transactions', 'action'=>'history')),
							'Mail' => array('消息 ('.(isset($unread)?$unread:0).')', array('controller' => 'messages', 'action'=>'index'))),
			  'admin' => array('Assets' => array('物業管理', array('controller' => 'assets', 'action' => 'admin_index')),
			  					'Users' => array('用戶管理', array('controller' => 'users', 'action' => 'admin_index')))
			  );
?>

<div id="body_sub_menu">
	<?php 
		foreach($menus[$sub] as $menu){
			//var_dump($key);
			//var_dump($value);
			echo $this->Html->link($menu[0], $menu[1]) . ' | ';
		}	
	?>
</div>
