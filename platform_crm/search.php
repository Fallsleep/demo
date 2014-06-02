<?php 
include 'DB/DB_CONNECT.php';
?>

<html>
<head>
	<?php include 'head.php'; ?>
   <script>
	$(document).ready(function(){
		$('.new-form').hide();
		$('.section-header').click(function(){
			$('#' + $(this).attr('id') + '-form').toggle('slow');
		});
	});
	</script>

</head>
<body>
	<div id="container">
	<?php include 'menu.php'; ?>
	    <div id="content">	    
		<br>
		<p class="section-header expandable" id="new-cus">新增客戶</p>		
		<div class="new-form" id="new-cus-form">
		<form method="post" action="customer.php"> 
				   公司名稱: <input type="text" name="name"><br>
				   地址: <input type="text" name="address"><br>
				   網址: <input type="text" name="website"><br>
				   聯絡電話: <input type="text" name="phone"><br>
				   電郵: <input type="text" name="email"><br>
				   傳真: <input type="text" name="fax"><br>
				   負責人: <input type="text" name="pic"><br>
				 QQ/SKYPE: <input type="text" name="im"><br>
				 <input type="submit" name="submit" value="提交"><br>
				 <input type="hidden" name="action" value="new_cust">
		</form>
		</div>
		</div><br>
		
		<div id="content">
		<p class="section-header expandable" id="search-cus">查詢客戶</p>
		<div class="new-form" id="search-cus-form">
		<form method="post" action="customerdetail.php">
				   公司名稱: <input type="text" name="name"><br>
				   地址: <input type="text" name="address"><br>
				   網址: <input type="text" name="website"><br>
				   聯絡電話: <input type="text" name="phone"><br>
				   電郵: <input type="text" name="email"><br>
				   傳真: <input type="text" name="fax"><br>
				   負責人: <input type="text" name="pic"><br>
				 QQ/SKYPE: <input type="text" name="im"><br>
				 <input type="submit" name="submit" value="提交"><br>
				 <input type="hidden" name="action" value="search_cust">
		</form>
		</div>
		</div><br>
		
		
		<div id="content">
		<p class="section-header expandable" id="search-acc">查詢帳戶</p>
		<div class="new-form" id="search-acc-form">
		<form method="post" action="accountdetail.php">
						公司名稱: <input type="text" name="name"><br>
						帳戶類型: <input type="radio" name="type" value="Demo" checked>Demo <input type="radio" name="type" value="Real">Real<br>
						平台名稱: <input type="radio" name="platform" value="JAVA" checked>JAVA平台 <input type="radio" name="platform" value="WEB">WEB平台 <input type="radio" name="platform" value="MT4">MT4平台<br>
						帳號: <input type="text" name="ac"><br>
						<!--  密碼: <input type="text" name="pw"><br> -->
						帳戶取得方法: <input type="text" name="link"><br>
						已簽約: <input type="radio" name="contract" value="1" checked>是 <input type="radio" name="contract" value="0">否<br>
						可交易項目: <input type="checkbox" name="trade_item[]" value="eur" checked>歐羅 <input type="checkbox" name="trade_item[]" value="gold">金<br>					
						歐羅每手按金: <input type="text" name="eur_dps"><br>
						金每手按金: <input type="text" name="gold_dps"><br>
						最少手數: <input type="text" name="min"><br>
						最多手數: <input type="text" name="max"><br>
						結算貨幣: <input type="text" name="currency"><br>			
						備註: <textarea rows="4" cols="25" name="remarks"></textarea><br>			
						<input type="submit" name="submit" value="提交"><br>
						<input type="hidden" name="action" value="search_acc">
					</form>
				</div>
				</div>
</div>	                            
</body>
</html>

<?php
include 'DB/DB_DISCONNECT.php';
?>