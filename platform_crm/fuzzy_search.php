<!--
2013-05-03 21:01
2013-05-03 21:27
两处改动
一处是60行附近地址网址等的内层去掉了if...else结构，只保留if字句的内容，细思一下能够得到相同的结果，属于干了多余的事情；
另一处是“搜索结果”、“没有找到相关结果”两个内容的处理，240行附近
这个也是很蛋疼的事情，之前只用了if(isset($search_result_sql))来判断$search_result_sql这个查询结果是否存在，
存在的话则输出各个条目，不存在则显示“没有找到相关结果”，但是在没有进行任何搜索的时候是不会有$search_result_sql，
所以页面一打开就显示了“没有找到相关结果”，显然是不对的，然后我就想着，是否应该是返回结果不为空才进行输出，为空则
显示“没有找到相关结果”，就找到了mysqli_num_rows()一个函数，会判断$search_result_sql有多少行，然后我就把之前的
if(isset($search_result_sql))改成了if(mysqli_num_rows($search_result_sql))，结果刷新页面后发现

Notice: Undefined variable: search_result_sql in D:\xampp\htdocs\crm\fuzzy_search_final.php on line 241

Warning: mysqli_num_rows() expects parameter 1 to be mysqli_result, null given in D:\xampp\htdocs\crm\fuzzy_search_final.php on line 241

然后发现应该先判断$search_result_sql是否存在，存在了才需要继续进行，否则就啥都不干，于是内存的else就跟
if(mysqli_num_rows($search_result_sql))匹配了；
再然后又发现文本框都是空的时候点提交按钮还是会显示“没有找到相关结果”，于是想到在54行附近引入$isemptysearch = 1;
如果是空关键字就为1，非空则为0，这样就能在if(mysqli_num_rows($search_result_sql))的else函数中进一步处理结果了

-->

<?php
include 'DB/DB_CONNECT.php';
header("Content-Type:text/html;charset=utf-8");
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
	}elseif($_POST["action"] == "search_cust"){
		$isemptysearch = 1;
		if(!( empty($_POST["name"]) && empty($_POST["address"]) && empty($_POST["website"]) &&
			empty($_POST["phone"]) && empty($_POST["email"]) && empty($_POST["fax"]) &&
			empty($_POST["pic"]) && empty($_POST["im"]) ) ){
			$isemptysearch = 0;			
			$names = mb_split("/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/",$_POST["name"]);
			$addresss = mb_split("/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/",$_POST["address"]);
			$websites = mb_split("/([\s,\.\/\'\";!@#\$%^\&\*，。！￥…（）])+/",$_POST["website"]);
			$phones = mb_split("/([\s,\.\/\'\";!@#\$%\^\&*，。！￥…（）])+/",$_POST["phone"]);
			$emails = mb_split("/([\s,\.\/\'\";!@#\$%\^\&*，。！￥…（）])+/",$_POST["email"]);
			$faxs = mb_split("/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/",$_POST["fax"]);
			$pics = mb_split("/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/",$_POST["pic"]);
			$ims = mb_split("/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/",$_POST["im"]);
			
			$where = '1=0';
			//名称
			foreach($names as $key){
						if($key){
							$where .= " OR name like ('%".$key."%')";
						}
			}
			
			//地址
			if(!empty($names[0]) && !empty($addresss[0])){
				$where .= ' AND';
				$where .= " address like ('%".$addresss[0]."%')";
				$addresss = array_slice($addresss,1);			
				foreach($addresss as $key){
							if($key){
								$where .= " OR address like ('%".$key."%')";
							}
				}
			}
			else{
					foreach($addresss as $key){
								if($key){
									$where .= " OR address like ('%".$key."%')";
								}
					}			
			}
			//网址
			if(!(empty($names[0]) && empty($addresss[0])) && !empty($websites[0])){
				$where .= ' AND';
				$where .= " website like ('%".$websites[0]."%')";
				$websites = array_slice($websites,1);			
				foreach($websites as $key){
							if($key){
								$where .= " OR website like ('%".$key."%')";
							}
				}
			}
			else{
					foreach($websites as $key){
								if($key){
									$where .= " OR website like ('%".$key."%')";
								}
					}			
			}
			//电话
			if(!(empty($names[0]) && empty($addresss[0]) && empty($websites[0])) && !empty($phones[0])){
				$where .= ' AND';
				$where .= " phone like ('%".$phones[0]."%')";
				$phones = array_slice($phones,1);			
				foreach($phones as $key){
							if($key){
								$where .= " OR phone like ('%".$key."%')";
							}
				}
			}
			else{
					foreach($phones as $key){
								if($key){
									$where .= " OR phone like ('%".$key."%')";
								}
					}			
			}
			//电子邮件
			if(!(empty($names[0]) && empty($addresss[0]) && empty($websites[0]) &&
				empty($phones[0])) &&	!empty($emails[0])){
				$where .= ' AND';
				$where .= " email like ('%".$emails[0]."%')";
				$emails = array_slice($emails,1);			
				foreach($emails as $key){
							if($key){
								$where .= " OR email like ('%".$key."%')";
							}
					}
			}
			else{
					foreach($emails as $key){
								if($key){
									$where .= " OR email like ('%".$key."%')";
								}
					}			
			}
			//传真
			if(!(empty($names[0]) && empty($addresss[0]) && empty($websites[0]) &&
				empty($phones[0]) &&	empty($emails[0])) && !empty($faxs[0])){
				$where .= ' AND';
				$where .= " fax like ('%".$faxs[0]."%')";
				$faxs = array_slice($faxs,1);			
				foreach($faxs as $key){
							if($key){
								$where .= " OR fax like ('%".$key."%')";
							}
				}
			}
			else{
					foreach($faxs as $key){
								if($key){
									$where .= " OR fax like ('%".$key."%')";
								}
					}			
			}
			//负责人
			if(!(empty($names[0]) && empty($addresss[0]) && empty($websites[0]) &&
				empty($phones[0]) &&	empty($emails[0]) && empty($faxs[0])) &&
				!empty($pics[0])){
			$where .= ' AND';
				$where .= " pic like ('%".$pics[0]."%')";
				$pics = array_slice($pics,1);			
				foreach($pics as $key){
							if($key){
								$where .= " OR pic like ('%".$key."%')";
							}
				}
			}
			else{
					foreach($pics as $key){
								if($key){
									$where .= " OR pic like ('%".$key."%')";
								}
					}			
			}
			//QQ/SKYPE
			if(!(empty($names[0]) && empty($addresss[0]) && empty($websites[0]) &&
				empty($phones[0]) &&	empty($emails[0]) && empty($faxs[0]) &&
				empty($pics[0])) && !empty($ims[0])){
				$where .= ' AND';
				$where .= " im like ('%".$ims[0]."%')";
				$ims = array_slice($ims,1);			
				foreach($ims as $key){
							if($key){
								$where .= " OR im like ('%".$key."%')";
							}
				}
			}
			else{
					foreach($ims as $key){
								if($key){
									$where .= " OR im like ('%".$key."%')";
								}
					}			
			}
	
			$search_sql = "SELECT * FROM crm_customers WHERE ".$where."";
			if (!($search_result_sql = mysqli_query($con,$search_sql))){ die('Error: ' . mysqli_error($con));	}
			echo $search_sql;
		}
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
					<?php
					if(isset($search_result_sql)){
						if(mysqli_num_rows($search_result_sql)){
					?>
				<p class="section-header">搜索结果这个也是简体</p>
				<table id="searchresult">
					<tr><th>公司名稱</th><th>地址</th><th>網址</th><th>聯絡電話</th><th>電郵</th><th>傳真</th><th>負責人</th><th>QQ/SKYPE</th><th>編輯/刪除</th></tr>
					<?php
							while ($row = mysqli_fetch_assoc($search_result_sql)) {
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
						}
						else{
							if(!$isemptysearch){
					?>
					<tr >没有找到相关结果这个是简体</tr>
					<?php
							}
						}
						mysqli_free_result($search_result_sql);
					}
					?>
				</table>
			</div>
			<div>
				<p class="section-header">搜索</p>
				<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?>" >
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
		</div>
	</div>
</body>
</html>
<?php
include 'DB/DB_DISCONNECT.php';
?>