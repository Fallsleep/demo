<?php
include 'DB/DB_CONNECT.php';
if(isset($_POST['submit'])) {	
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
				<?php
				if(isset($_GET["id"]) && !empty($_GET["id"])){
					$customer_sql = "SELECT name, address, website, phone FROM crm_customers WHERE id = " . $_GET["id"];
					if($customer = mysqli_query($con, $customer_sql)){
						$row = mysqli_fetch_assoc($customer);
						if(!isset($row)){ header( 'Location: transactions.php' ) ; };
				?>
				<h3>公司名稱: <?=$row["name"]?></h3>
				<h3>地址: <?=$row["address"]?></h3>
				<h3>網址: <?=$row["website"]?></h3>
				<h3>聯絡電話: <?=$row["phone"]?></h3>
				<?php
						mysqli_free_result($customer);
					}
				}
				?>
			</div>
			<div>
				<p class="section-header">現有跟進<?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?> (所有客戶)<?php } ?></p>
				<table>
					<tr><?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?><th>公司名稱</th><?php } ?>
						<th>帳戶</th><th>聯絡日期/時間</th><th>內容</th><th>對口人聯絡方式</th><th>下次跟進時間</th><th>附件</th><th>操盤員</th>
						<th>歐羅差價</th><th>金差價</th><th>是否要每次調教手數</th><th>是否有等候批示</th><th>可否LOCK倉</th><th>按金</th><th>可否溝貨</th><th>CUT倉%</th>
						<th>歐羅評分</th><th>金評分</th><th>備註</th>
					</tr>
					<?php
					if(isset($_GET["id"]) && !empty($_GET["id"])){
						$accounts_sql = "SELECT a.platform, a.type, a.ac, t.* FROM crm_accounts a, crm_transactions t WHERE a.cid = " . $_GET["id"] . " AND a.id = t.aid";
					} else {
						$accounts_sql = "SELECT c.id, c.name, a.cid, a.platform, a.type, a.ac, t.* FROM crm_customers c, crm_accounts a, crm_transactions t WHERE c.id = a.cid AND a.id = t.aid";
					}
					if($result = mysqli_query($con, $accounts_sql)){
						while($row = mysqli_fetch_assoc($result)){
							switch ($row["approval"]) {
								case "always": $approval = "經常有"; break;
								case "often": $approval = "間中有"; break;
								case "no": $approval = "無"; break;
							}
					?>
					<tr><?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?><td><a href="transactions.php?id=<?=$row['cid']?>"><?=$row["name"]?></a></td><?php } ?>
						<td><?=$row["platform"]?>/<?=$row["type"]?>/<?=$row["ac"]?></td><td><?=$row["t_time"]?></td><td><?=$row["content"]?></td><td><?=$row["contact"]?></td>
						<td><?=$row["follow"]?></td><td><?=$row["attachment"]?'有':'沒有'?></td><td><?=$row["agent"]?></td><td><?=$row["eur_diff"]?$row["eur_diff"]:'-'?></td>
						<td><?=$row["gold_diff"]?$row["gold_diff"]:"-"?></td><td><?=$row["tune"]?'是':'否'?></td><td><?=$approval?></td><td><?=$row["lockable"]?'可':'否'?></td>
						<td><?=$row["deposit"]?></td><td><?=$row["dilute"]?'可':'否'?></td><td><?=$row["cut_p"]?>%</td><td><?=$row["eur_rate"]?$row["eur_rate"] . '/10':'-'?></td>
						<td><?=$row["gold_rate"]?$row["gold_rate"] . '/10':'-'?></td><td><?=$row["remarks"]?$row["remarks"]:'-'?></td></tr>		
					<?php
						}
						mysqli_free_result($result);
					}
					?>
				</table>
			</div>
			<div>
				<p class="section-header">新增跟進</p>
				<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>">
					帳戶: <select name="aid" id="aid">
					<?php
						if(!isset($_GET["id"]) || empty($_GET["id"])){
							$customers_sql = "SELECT c.name, a.id, a.platform, a.type, a.ac FROM crm_customers c, crm_accounts a WHERE c.id = a.cid";
						} else {
							$customers_sql = "SELECT id, platform, type, ac FROM crm_accounts WHERE cid=" . $_GET['id'];
						}
						if($result = mysqli_query($con, $customers_sql)){
							while($row = mysqli_fetch_assoc($result)){
					?>
						<option value="<?=$row['id']?>"><?php if(!isset($_GET["id"]) || empty($_GET["id"])){ echo $row["name"]; ?>---<?php } ?><?=$row["platform"]?>/<?=$row["type"]?>/<?=$row["ac"]?></option>
					<?php	
							}
							mysqli_free_result($result);
						}
					?>
					</select><br>
					聯絡日期/時間: <input type="datetime-local" name="t_time"><br>
					內容: <textarea rows="4" cols="25" name="content"></textarea><br>
					對口人聯絡方式: <input type="text" name="contact"><br>
					下次跟進時間: <input type="datetime-local" name="follow"><br>
					附件: <input type="radio" name="attachment" value="1" checked>有 <input type="radio" name="attachment" value="0">沒有<br>
					操盤員: <input type="text" name="agent"><br>
					歐羅差價: <input type="text" name="eur_diff"><br>
					金差價: <input type="text" name="gold_diff"><br>
					是否要每次調教手數: <input type="radio" name="tune" value="1" checked>是 <input type="radio" name="tune" value="0">否<br>
					是否有等候批示: <input type="radio" name="approval" value="always" checked>經常有 <input type="radio" name="approval" value="often">間中有 
										<input type="radio" name="approval" value="no">無 <br>
					可否LOCK倉: <input type="radio" name="lockable" value="1" checked>可 <input type="radio" name="lockable" value="0">否<br>
					按金: <input type="text" name="deposit"><br>
					可否溝貨: <input type="radio" name="dilute" value="1" checked>可 <input type="radio" name="dilute" value="0">否<br>
					CUT倉%: <input type="text" name="cut_p">%<br>
					歐羅評分:　<input type="radio" name="eur_rate" value="0" checked>0 <?php for($i=1;$i<=10;$i++){ ?><input type="radio" name="eur_rate" value="<?=$i?>"><?=$i?> <?php } ?><br>
					金評分:　<input type="radio" name="gold_rate" value="0" checked>0 <?php for($i=1;$i<=10;$i++){ ?><input type="radio" name="gold_rate" value="<?=$i?>"><?=$i?> <?php } ?><br>
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