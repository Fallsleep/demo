<?php
include 'DB/DB_CONNECT.php';
if(isset($_POST["submit"])) {
	if($_POST["action"] == "new_cust"){
		$name = str_replace(' ','',$_POST["name"]);
		$address = str_replace(' ','',$_POST["address"]);
		$website = str_replace(' ','',$_POST["website"]);
		$phone = str_replace(' ','',$_POST["phone"]);
		$email = str_replace(' ','',$_POST["email"]);
		$fax = str_replace(' ','',$_POST["fax"]);
		$pic = str_replace(' ','',$_POST["pic"]);
		$im = str_replace(' ','',$_POST["im"]);
		
		$insert_sql = "INSERT INTO crm_customers (name, address, website, phone, email, fax, pic, im) VALUES ('$name', '$address', '$website', '$phone', '$email', '$fax', '$pic', '$im')";
		if (!mysqli_query($con,$insert_sql)){ die('Error: ' . mysqli_error($con));	}
	}elseif($_POST["action"] == "edit_cust"){
		$id = $_POST["id"];
		$name = str_replace(' ','',$_POST["name"]);
		$address = str_replace(' ','',$_POST["address"]);
		$website = str_replace(' ','',$_POST["website"]);
		$phone = str_replace(' ','',$_POST["phone"]);
		$email = str_replace(' ','',$_POST["email"]);
		$fax = str_replace(' ','',$_POST["fax"]);
		$pic = str_replace(' ','',$_POST["pic"]);
		$im = str_replace(' ','',$_POST["im"]);
		
		$update_sql = "update crm_customers set name='$name',address='$address',website='$website',phone='$phone',email='$email',fax='$fax',pic='$pic',im='$im' where id=$id";
		
		if (!mysqli_query($con,$update_sql)){ die('Error: ' . mysqli_error($con));	} // else { echo "<script language = javascript> alert('編輯成功！');</script>"; }
	}elseif($_POST["action"] == "del_cust"){
		$delete_sql = "UPDATE crm_customers c, crm_accounts a, crm_transactions t SET c.deleted = 1, a.deleted = 1, t.deleted = 1 WHERE c.id = a.cid AND a.id = t.aid AND c.id = " . $_POST["cid"];		
		if (!mysqli_query($con,$delete_sql)){ die('Error: ' . mysqli_error($con));	}
	}
}
?>
<html>
<head>
	<?php include 'head.php'; ?>
</head>
<body>
	<div id="container">
		<?php include 'menu.php'; ?>
		<div id="content">
			<div>
				<p class="section-header">現有客戶</p>
				<table id="customers">
					<tr><th>公司名稱</th><th>地址</th><th>網址</th><th>聯絡電話</th><th>電郵</th><th>傳真</th><th>負責人</th><th>QQ/SKYPE</th><th>編輯/刪除</th></tr>
					<?php
					$select_sql = "SELECT * FROM crm_customers WHERE deleted = 0";
					if ($result = mysqli_query($con, $select_sql)) {
						while ($row = mysqli_fetch_assoc($result)) {
					?>
					<tr><td><a href="accounts.php?id=<?=$row["id"]?>"><?=$row["name"]?></a></td><td><?=$row["address"]?$row["address"]:'-'?></td>
						<td><?=$row["website"]?$row["website"]:'-'?></td><td><?=$row["phone"]?$row["phone"]:'-'?></td><td><?=$row["email"]?$row["email"]:'-'?></td>
						<td><?=$row["fax"]?$row["fax"]:'-'?></td><td><?=$row["pic"]?$row["pic"]:'-'?></td><td><?=$row["im"]?$row["im"]:'-'?></td>
						<td><input type="button" value="編輯" onclick="location.href='editcustomer.php?id=<?php echo $row["id"];?>'" />
							<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>" 
								onsubmit="return confirm('確認刪除客戶 <?=$row["name"]?> ?');">
								<input type="hidden" name="cid" value="<?=$row["id"]?>">
								<input type="submit" name="submit" value="刪除">
								<input type="hidden" name="action" value="del_cust">
							</form>
						</td>
					</tr>		
					<?php
						}
						mysqli_free_result($result);
					}
					?>
				</table>
			</div>
			<div>
				<p class="section-header">新增客戶</p>
				<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?>">
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
		</div>
	</div>
</body>
</html>
<?php
include 'DB/DB_DISCONNECT.php';
?>