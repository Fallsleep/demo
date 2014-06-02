<div id="menu">
	<ul>
		<?php 
			$current = explode('/', $_SERVER['PHP_SELF']); 
			$current = $current[sizeof($current)-1];
		?>
		<li><a href="followup.php" class="<?=$current=='followup.php'?'current':''?>">需要跟進</a></li>
		<li><a href="search.php" class="<?=$current=='search.php'?'current':''?>">信息檢索</a></li>
		<li><a href="customer.php" class="<?=$current=='customer.php'?'current':''?>">客戶列表</a></li>
		<li><a href="accounts.php" class="<?=$current=='accounts.php'?'current':''?>">帳戶列表</a></li>
		
	</ul>
</div>