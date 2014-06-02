<?php
include 'DB/DB_CONNECT.php';

$row="";
$cid="";
if(isset($_GET["id"]))
{
	$select_sql = "SELECT * FROM crm_transactions where id=".$_GET["id"];
	$result = mysqli_query($con, $select_sql);
	$row = mysqli_fetch_assoc($result);
	
	$select_sql2 = "SELECT cid, platform, type, ac FROM crm_accounts where id=".$row['aid'];
	$result2 = mysqli_query($con, $select_sql2);
	$row2 = mysqli_fetch_assoc($result2);
	$cid=$row2['cid'];
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
				<p class="section-header expandable" id="new-trans">編輯跟進</p>
				<div class="new-form" id="new-trans-form">
					<form method="post" action="<?php echo htmlentities("accounts.php");?>?id=<?php echo $cid;?>">
					 	帳戶:<?php echo $row2["platform"]?>/<?php echo $row2["type"]?>/<?php echo $row2["ac"]?>
						<!-- 帳戶: <select name="aid" id="aid">
						<?php
							$customers_sql = "SELECT a.id, c.name, platform, type, ac FROM crm_accounts a,crm_customers c where a.cid=c.id order by c.id,a.cid";
							if($result3 = mysqli_query($con, $customers_sql))
							{
								while($row3 = mysqli_fetch_assoc($result3))
								{
						?>
							<option value="<?php echo $row3['id'];?>"
							<?php
								if($row3['id']===$row['id'])
								{
							?>
							selected="selected"
							<?php }?>
							>
							<?php echo $row3["name"];?>---<?php echo $row3["platform"]?>/<?php echo $row3["type"]?>/<?php echo $row3["ac"]?>
							</option>
						<?php	
								}
								mysqli_free_result($result3);
							}
						?>-->
						<br>
						聯絡日期/時間: <input type="text" name="t_time" value="<?php echo $row['t_time'];?>" /><br>
						內容: <textarea rows="4" cols="25" name="content"><?php echo $row['content'];?></textarea><br>
						對口人聯絡方式: <input type="text" name="contact" value="<?php echo $row['contact'];?>" /><br>
						下次跟進時間: <input type="text" name="follow" value="<?php echo $row['follow'];?>" /><br>
						附件: <input type="radio" name="attachment" value="1" <?php if($row['attachment']==1) {?>checked="checked"<?php }?> />有 
							  <input type="radio" name="attachment" value="0" <?php if($row['attachment']==0) {?>checked="checked"<?php }?> />沒有<br>
						操盤員: <input type="text" name="agent" value="<?php echo $row['agent'];?>" /><br>
						歐羅差價: <input type="text" name="eur_diff" value="<?php echo $row['eur_diff'];?>" /><br>
						金差價: <input type="text" name="gold_diff" value="<?php echo $row['gold_diff'];?>" /><br>
						是否要每次調教手數: <input type="radio" name="tune" value="1" <?php if($row['tune']==1) {?>checked="checked"<?php }?> />是 
										   <input type="radio" name="tune" value="0" <?php if($row['tune']==0) {?>checked="checked"<?php }?> />否<br>
						是否有等候批示: <input type="radio" name="approval" value="always" <?php if($row['approval']=="always") {?>checked="checked"<?php }?> />經常有 
									   <input type="radio" name="approval" value="often" <?php if($row['approval']=="often") {?>checked="checked"<?php }?> />間中有 
									   <input type="radio" name="approval" value="no" <?php if($row['approval']=="no") {?>checked="checked"<?php }?> />無 <br>
						可否LOCK倉: <input type="radio" name="lockable" value="1" <?php if($row['lockable']==1) {?>checked="checked"<?php }?> />可 
								   <input type="radio" name="lockable" value="0" <?php if($row['lockable']==0) {?>checked="checked"<?php }?> />否<br>
						按金: <input type="text" name="deposit" value="<?php echo $row['deposit'];?>" /><br>
						可否溝貨: <input type="radio" name="dilute" value="1" <?php if($row['dilute']==1) {?>checked="checked"<?php }?> />可 
								<input type="radio" name="dilute" value="0" <?php if($row['dilute']==0) {?>checked="checked"<?php }?> />否<br>
						CUT倉%: <input type="text" name="cut_p" value="<?php echo $row['cut_p'];?>" />%<br>
						歐羅評分:　<?php for($i=0;$i<=10;$i++){ ?><input type="radio" name="eur_rate" value="<?php echo $i;?>" <?php if($row['eur_rate']==$i) {?>checked="checked"<?php }?>><?php echo $i;?><?php } ?><br>
						金評分:　<?php for($i=0;$i<=10;$i++){ ?><input type="radio" name="gold_rate" value="<?php echo $i;?>" <?php if($row['gold_rate']==$i) {?>checked="checked"<?php }?>><?php echo $i;?><?php } ?><br>
						備註: <textarea rows="4" cols="25" name="remarks"><?php echo $row['remarks'];?></textarea><br>		
						<input type="submit" name="submit" value="提交"><br>
						<input type="hidden" name="tid" value="<?php echo $row['id'];?>" />
						<input type="hidden" name="action" value="edit_trans" />
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