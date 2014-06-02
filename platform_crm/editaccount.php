<?php
include 'DB/DB_CONNECT.php';

$row="";
if(isset($_GET["id"]))
{
	$select_sql = "SELECT * FROM crm_accounts where id=".$_GET["id"];
	$result = mysqli_query($con, $select_sql);
	$row = mysqli_fetch_assoc($result);
}
?>

<html>
<head>
	<?php include 'head.php';?>
</head>
<body>
	<div id="container">
		<?php include 'menu.php';?>
		<div id="content">
			<div>
				<p class="section-header expandable" id="new-acc">編輯帳戶</p>
				<div class="new-form" id="new-acc-form">
					<form method="post" action="<?php echo htmlentities("accounts.php");?>?id=<?php echo $row['cid'];?>">

					<!--
						公司名稱: <select name="cid">
						<?php
							$customers_sql = "SELECT id, name FROM crm_customers";
							if($result2 = mysqli_query($con, $customers_sql))
							{
								while($row2 = mysqli_fetch_assoc($result2))
								{
						?>
							<option value="<?php echo $row2['id'];?>" 
							<?php
								if($row2['id']===$row['cid'])
								{
							?>
							selected="selected"
							<?php }?>
							><?php echo $row2["name"];?></option>
						<?php	
								}
								mysqli_free_result($result2);
							}
						?>
						</select><br>
						-->
						帳戶類型: <input type="radio" name="type" value="Demo" <?php if($row['type']=="Demo") {?>checked="checked"<?php }?> />Demo 
						<input type="radio" name="type" value="Real" <?php if($row['type']=="Real") {?>checked="checked"<?php }?> />Real<br>
						平台名稱: <input type="radio" name="platform" value="JAVA" <?php if($row['platform']=="JAVA") {?>checked="checked"<?php }?> />JAVA平台 
						<input type="radio" name="platform" value="WEB" <?php if($row['platform']=="WEB") {?>checked="checked"<?php }?> />WEB平台 
						<input type="radio" name="platform" value="MT4" <?php if($row['platform']=="MT4") {?>checked="checked"<?php }?> />MT4平台<br>
						帳號: <input type="text" name="ac" value="<?php echo $row['ac'];?>" /><br>
						密碼: <input type="text" name="pw" value="<?php echo $row['pw'];?>" /><br>
						帳戶取得方法: <input type="text" name="link" value="<?php echo $row['link'];?>" /><br>
						已簽約: <input type="radio" name="contract" value="1" <?php if($row['contract']==1) {?>checked="checked"<?php }?> />是 
						<input type="radio" name="contract" value="0" <?php if($row['contract']==0) {?>checked="checked"<?php }?> />否<br>
						可交易項目: <input type="checkbox" name="trade_item[]" value="eur" <?php if($row['trade_item']=="eur" || $row['trade_item']=="both") {?>checked="checked"<?php }?> />歐羅 
						<input type="checkbox" name="trade_item[]" value="gold" <?php if($row['trade_item']=="gold" || $row['trade_item']=="both") {?>checked="checked"<?php }?> />金<br>					
						<div id="eur-dps">歐羅每手按金: <input type="text" name="eur_dps" value="<?php echo $row['eur_dps'];?>" /></div>
						<div id="gold-dps">金每手按金: <input type="text" name="gold_dps" value="<?php echo $row['gold_dps'];?>" /></div>
						最少手數: <input type="text" name="min" value="<?php echo $row['min'];?>" /><br>
						最多手數: <input type="text" name="max" value="<?php echo $row['max'];?>" /><br>
						結算貨幣: <input type="text" name="currency" value="<?php echo $row['currency'];?>" /><br>			
						備註: <textarea rows="4" cols="25" name="remarks"><?php echo $row['remarks'];?></textarea><br>			
						<input type="submit" name="submit" value="提交" /><br>
						<input type="hidden" name="aid" value="<?php echo $row['id'];?>" />
						<input type="hidden" name="action" value="edit_acc" />
					</form>
				</div>
			</div>
		</div>
	</div>
</body>
</html>
<?php
include 'DB/DB_DISCONNECT.php';
?>