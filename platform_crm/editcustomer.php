<?php
include 'DB/DB_CONNECT.php';

$row="";
if(isset($_GET["id"]))
{
	$select_sql = "SELECT * FROM crm_customers where id=".$_GET["id"];
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
				<p class="section-header">編輯客戶</p>
				<form method="post" action="<?php echo htmlentities("customer.php")?>">
					<input type="hidden" name="id" value="<?php echo $row['id'];?>" /><br>
				   公司名稱: <input type="text" name="name" value="<?php echo $row['name'];?>" /><br>
				   地址: <input type="text" name="address" value="<?php echo $row['address'];?>" /><br>
				   網址: <input type="text" name="website" value="<?php echo $row['website'];?>" /><br>
				   聯絡電話: <input type="text" name="phone" value="<?php echo $row['phone'];?>" /><br>
				   電郵: <input type="text" name="email" value="<?php echo $row['email'];?>" /><br>
				   傳真: <input type="text" name="fax" value="<?php echo $row['fax'];?>" /><br>
				   負責人: <input type="text" name="pic" value="<?php echo $row['pic'];?>" /><br>
				   QQ/SKYPE: <input type="text" name="im" value="<?php echo $row['im'];?>" /><br>				   
				   <input type="submit" name="submit" value="提交" /><br>
				   <input type="hidden" name="action" value="edit_cust">
				</form>
			</div>
		</div>
	</div>
</body>
</html>
<?php
include 'DB/DB_DISCONNECT.php';
?>