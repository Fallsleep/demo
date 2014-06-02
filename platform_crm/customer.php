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
		$delete_sql = "UPDATE crm_customers c SET c.deleted = 1 WHERE c.id = " . $_POST["cid"];
		if (!mysqli_query($con,$delete_sql)){ die('Error: ' . mysqli_error($con)); }
		$delete_sql = "UPDATE crm_customers c, crm_accounts a SET a.deleted = 1 WHERE c.id = a.cid AND c.id = " . $_POST["cid"];
		if (!mysqli_query($con,$delete_sql)){ die('Error: ' . mysqli_error($con)); }
		$delete_sql = "UPDATE crm_customers c, crm_accounts a, crm_transactions t SET t.deleted = 1 WHERE c.id = a.cid AND a.id = t.aid AND c.id = " . $_POST["cid"];		
		if (!mysqli_query($con,$delete_sql)){ die('Error: ' . mysqli_error($con));	}
	}
}


    //分頁顯示
    function page($page, $total, $pagesize = 10, $pagelen = 5){//每頁十條
	$phpfile = htmlentities($_SERVER['PHP_SELF']);
	$pagecode = "";//HTML代码
	$page = intval($page);
	
	$total = intval($total);
	if(!$total) return array();	
	$pages = ceil($total/$pagesize);
	
	if($page < 1) $page = 1;
	if($page > $pages) $page = $pages;
	
	$offset = ($page - 1) * $pagesize;
	
	$init = 1;
	$max = $pages;
	$pagelen = ($pagelen % 2)?$pagelen:($pagelen + 1);//判断页码个数是奇是偶，偶则+1
	$pageoffset = ($pagelen-1)/2;//页码左右偏移量
	
	
	//生成HTML代码
	$pagecode='<div class="page">';
	$pagecode.="<span>$page/$pages</span><span>&nbsp;&nbsp;&nbsp;&nbsp;</span>";
	
	//如果是第一页，则不显示第一页和上一页的连接
	if($page!=1){
	$pagecode.="<a href=\"{$phpfile}?page=1\"><<</a><span>&nbsp;&nbsp;</span>";//第一页
	$pagecode.="<a href=\"{$phpfile}?page=".($page-1)."\"><</a><span>&nbsp;&nbsp;</span>";//上一页
	}
	//分页数大于页码个数时可以偏移
	if($pages>$pagelen){
		//如果当前页小于等于左偏移
		if($page<=$pageoffset){
			$init = 1;
			$max = $pagelen;
		}else{//如果当前页大于左偏移
			//如果当前页码右偏移超出最大分页数
			if($page+$pageoffset>=$pages+1){
				$init = $pages-$pagelen+1;
			}else{
				//左右偏移都存在时的计算
				$init = $page-$pageoffset;
				$max = $page+$pageoffset;
			}
		}
	}
	
	//生成html
	for($i=$init;$i<=$max;$i++){
		if($i==$page){//当前页只输出文字不实用链接
			$pagecode.='<span>'.$i.'</span><span>&nbsp;&nbsp;</span>';
		} else {
			$pagecode.="<a href=\"{$phpfile}?page={$i}\">$i</a><span>&nbsp;</span>";
		}
	}
	if($page!=$pages){
		$pagecode.="<a href=\"{$phpfile}?page=".($page+1)."\">></a><span>&nbsp;&nbsp;</span>";//下一页
		$pagecode.="<a href=\"{$phpfile}?page={$pages}\">>></a>";//最后一页
	}
	$pagecode.='</div>';
	return array('pagecode'=>$pagecode,'sqllimit'=>' limit '.$offset.','.$pagesize);
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
			<br>
			<div>
				<p class="section-header">現有客戶</p>
				<table id="customers">
					<tr><th>公司名稱</th><th>地址</th><th>網址</th><th>聯絡電話</th><th>電郵</th><th>傳真</th><th>負責人</th><th>QQ/SKYPE</th><th>操作</th></tr>
					<?php
					$page = isset($_GET['page'])?$_GET['page']:1;
					$presult = mysqli_query($con, "SELECT COUNT(*) count FROM crm_customers WHERE deleted = 0");
					$prow = mysqli_fetch_assoc($presult);
					$count = $prow["count"];
					mysqli_free_result($presult);
					$select_sql = "SELECT * FROM crm_customers WHERE deleted = 0";
					$getpageinfo = page($page, $count);
					$select_sql .= $getpageinfo['sqllimit'];
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
			<?php
			echo $getpageinfo['pagecode'];
			?>
</div>
</div><br><br>
</body>
</html>
<?php
include 'DB/DB_DISCONNECT.php';
?>