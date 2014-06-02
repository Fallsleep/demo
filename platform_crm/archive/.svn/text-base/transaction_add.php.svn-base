<?php
include 'DB/DB_CONNECT.php';
if(isset($_POST['submit'])) 
{	
	$aid = $_POST["aid"];
	$t_time = $_POST["t_time"];
	$content = str_replace(' ','',$_POST["content"]);
	$contact = str_replace(' ','',$_POST["contact"]);
	$follow = $_POST["follow"];
	$attachment = $_POST["attachment"];
	$agent = str_replace(' ','',$_POST["agent"]);
	$eur_diff = str_replace(' ','',!empty($_POST["eur_diff"])?$_POST["eur_diff"]:0);
	$gold_diff = str_replace(' ','',!empty($_POST["gold_diff"])?$_POST["gold_diff"]:0);
	$tune = $_POST["tune"];
	$approval = $_POST["approval"];
	$lockable = $_POST["lockable"];
	$deposit = str_replace(' ','',$_POST["deposit"]);
	$dilute = $_POST["dilute"];
	$cut_p = str_replace(' ','',$_POST["cut_p"]);
	$eur_rate = $_POST["eur_rate"];
	$gold_rate = $_POST["gold_rate"];
	$remarks = str_replace(' ','',$_POST["remarks"]);
	
	$insert_sql = "INSERT INTO crm_transactions (aid, t_time, content, contact, follow, attachment, agent, eur_diff, gold_diff, tune, approval, lockable, deposit, dilute, cut_p, eur_rate, gold_rate, remarks) 
					VALUES ('$aid', '$t_time', '$content', '$contact', '$follow', '$attachment', '$agent', '$eur_diff', '$gold_diff', '$tune', '$approval', '$lockable', '$deposit', '$dilute', '$cut_p', '$eur_rate', '$gold_rate', '$remarks')";
	
	if (!mysqli_query($con,$insert_sql)){ die('Error: ' . mysqli_error($con));	}
}
?>
<html>
<head>
	<?php include 'head.php'; ?>
	</script>
</head>
<body>
	<div id="container">
		<?php include 'menu.php'; ?>
		<div id="content">
			<div>				
				<p class="section-header">新增跟進</p>
				<form method="post" action="transactions.php<?php if(isset($_GET["cid"]) && !empty($_GET["cid"])){ ?>?id=<?=$_GET['cid']?><?php } ?>">				
					<?php
					if(isset($_GET["aid"]) && !empty($_GET["aid"])){
						$account_sql = "SELECT c.name, a.platform, a.type, a.ac, a.trade_item FROM crm_customers c, crm_accounts a WHERE c.id = a.cid AND a.id = " . $_GET["aid"];
						if($account = mysqli_query($con, $account_sql)){
							$row = mysqli_fetch_assoc($account);
							if(!isset($row)){ header( 'Location: transactions.php' ) ; };
					?>
					<script>
					if()
					</script>
					公司名稱: <?=$row["name"]?><br>
					平台名稱: <?=$row["platform"]?>平台<br>
					帳戶類型: <?=$row["type"]?><br>
					帳號: <?=$row["ac"]?><br>
					<?php
							mysqli_free_result($account);
						}
					}
					?>
					聯絡日期/時間: <input type="datetime-local" name="t_time"><br>
					內容: <textarea rows="4" cols="25" name="content"></textarea><br>
					對口人聯絡方式: <input type="text" name="contact"><br>
					下次跟進時間: <input type="datetime-local" name="follow"><br>
					附件: <input type="radio" name="attachment" value="1" checked>有 <input type="radio" name="attachment" value="0">沒有<br>
					操盤員: <input type="text" name="agent"><br>
					<div class="eur">歐羅差價: <input type="text" name="eur_diff"><br></div>
					<div class="gold">金差價: <input type="text" name="gold_diff"><br></div>
					是否要每次調教手數: <input type="radio" name="tune" value="1" checked>是 <input type="radio" name="tune" value="0">否<br>
					是否有等候批示: <input type="radio" name="approval" value="always" checked>經常有 <input type="radio" name="approval" value="often">間中有 
										<input type="radio" name="approval" value="no">無 <br>
					可否LOCK倉: <input type="radio" name="lockable" value="1" checked>可 <input type="radio" name="lockable" value="0">否<br>
					按金: <input type="text" name="deposit"><br>
					可否溝貨: <input type="radio" name="dilute" value="1" checked>可 <input type="radio" name="dilute" value="0">否<br>
					CUT倉%: <input type="text" name="cut_p">%<br>
					<div class="eur">歐羅評分:　<input type="radio" name="eur_rate" value="0" checked>0 <?php for($i=1;$i<=10;$i++){ ?><input type="radio" name="eur_rate" value="<?=$i?>"><?=$i?> <?php } ?><br></div>
					<div class="gold">金評分:　<input type="radio" name="gold_rate" value="0" checked>0 <?php for($i=1;$i<=10;$i++){ ?><input type="radio" name="gold_rate" value="<?=$i?>"><?=$i?> <?php } ?><br></div>
					備註: <textarea rows="4" cols="25" name="remarks"></textarea><br>			
					<input type="submit" name="submit" value="提交"><br>
				</form>
			</div>
		</div>
	</div>
</body>
</html>
<?php
include 'DB/DB_DISCONNECT.php';
?>