<?php 

include 'DB/DB_CONNECT.php';

if(isset($_POST["submit"])) {
  if($_POST["action"] == "search_cust"){
  	//$isemptysearch = 1;	
		if(!( empty($_POST["name"]) && empty($_POST["address"]) && empty($_POST["website"]) &&
			empty($_POST["phone"]) && empty($_POST["email"]) && empty($_POST["fax"]) &&
			empty($_POST["pic"]) && empty($_POST["im"]) ) ){
			//$isemptysearch = 0;			
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
				empty($phones[0]) && empty($emails[0]) && empty($faxs[0])) &&
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

			//$search_sql = "SELECT * FROM crm_customers WHERE ".$where."";
			//if (!($search_result_sql = mysqli_query($con,$search_sql))){ die('Error: ' . mysqli_error($con));	}
			//echo $where.'1<br>';
		}
	}
}
function page($page, $total, $ptype, $kw, $pagesize = 10, $pagelen = 5){
	if($_SERVER["QUERY_STRING"]){
		$str = '/(?:^'.$ptype.'=\d+&)|(?:'.$ptype.'=\d+$)|(?:kw=\S+&)|(?:kw=\S+$)/';
		$_SERVER["QUERY_STRING"] = preg_replace($str, '', $_SERVER["QUERY_STRING"]);
		if($_SERVER["QUERY_STRING"]){
			$phpfile = $_SERVER['PHP_SELF'].'?'.$_SERVER["QUERY_STRING"];
		}else{
			$phpfile = $_SERVER['PHP_SELF'];
		}
	}else{
		$phpfile = $_SERVER['PHP_SELF'];
	}
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
	$pagecode.="<span>$page/$pages</span><span>&nbsp;&nbsp;</span>";
	
	//如果是第一页，则不显示第一页和上一页的连接
	if($page!=1){
		if($_SERVER["QUERY_STRING"]){
			$pagecode.="<a href=\"{$phpfile}&$ptype=1&kw=".$kw."\"><<</a><span>&nbsp;</span>";//第一页
			$pagecode.="<a href=\"{$phpfile}&$ptype=".($page-1)."&kw=".$kw."\"><</a><span>&nbsp;</span>";//上一页
		}else{
			$pagecode.="<a href=\"{$phpfile}?$ptype=1&kw=".$kw."\"><<</a><span>&nbsp;</span>";//第一页
			$pagecode.="<a href=\"{$phpfile}?$ptype=".($page-1)."&kw=".$kw."\"><</a><span>&nbsp;</span>";//上一页
		}
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
			$pagecode.='<span>'.$i.'</span><span>&nbsp;</span>';
		} else {
			if($_SERVER["QUERY_STRING"]){
				$pagecode.="<a href=\"{$phpfile}&$ptype={$i}&kw=".$kw."\">$i</a><span>&nbsp;</span>";
			}else{
				$pagecode.="<a href=\"{$phpfile}?$ptype={$i}&kw=".$kw."\">$i</a><span>&nbsp;</span>";
			}
		}
	}
	if($page!=$pages){
		if($_SERVER["QUERY_STRING"]){
			$pagecode.="<a href=\"{$phpfile}&$ptype=".($page+1)."&kw=".$kw."\">></a><span>&nbsp;</span>";//下一页
			$pagecode.="<a href=\"{$phpfile}&$ptype={$pages}&kw=".$kw."\">>></a>";//最后一页
		}else{
			$pagecode.="<a href=\"{$phpfile}?$ptype=".($page+1)."&kw=".$kw."\">></a><span>&nbsp;</span>";//下一页
			$pagecode.="<a href=\"{$phpfile}?$ptype={$pages}&kw=".$kw."\">>></a>";//最后一页
		}
		
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
               
               
               <div>
				<p class="section-header">查詢客戶結果</p>
				<table id="customers">
					<tr><th>公司名稱</th>
					    <th>地址</th>
					    <th>網址</th>
					    <th>聯絡電話</th>
					    <th>電郵</th>
					    <th>傳真</th>
					    <th>負責人</th>
					    <th>QQ/SKYPE</th>
					    <!-- <th>操作</th> -->
					    
					    </tr>
					<?php
					if(isset($_GET["kw"])){$where =$_GET["kw"]; }
					if(isset($where)){
						//echo $where;
						$select_sql = "SELECT * FROM crm_customers WHERE ".$where;//貌似后面的.""可以去掉
						$page_sql = "SELECT COUNT(*) count FROM crm_customers WHERE ".$where;
						$page = isset($_GET['cpage'])?$_GET['cpage']:1;
						if($presult = mysqli_query($con, $page_sql)){
							$prow = mysqli_fetch_assoc($presult);
							$count = $prow["count"];
							mysqli_free_result($presult);
							if($count){
								$getpageinfo = page($page, $count, "cpage", $where);
								$select_sql .= $getpageinfo['sqllimit'];						
								if ($result = mysqli_query($con, $select_sql)) {
									if(mysqli_num_rows($result)){
										while ($row = mysqli_fetch_assoc($result)) {
					?>
					<tr><td><a href="accounts.php?id=<?=$row["id"]?>"><?=$row["name"]?></a></td>
					<td><?=$row["address"]?$row["address"]:'-'?></td>
					<td><?=$row["website"]?$row["website"]:'-'?></td>
					<td><?=$row["phone"]?$row["phone"]:'-'?></td>
					<td><?=$row["email"]?$row["email"]:'-'?></td>
					<td><?=$row["fax"]?$row["fax"]:'-'?></td>
					<td><?=$row["pic"]?$row["pic"]:'-'?></td>
					<td><?=$row["im"]?$row["im"]:'-'?></td>
					<!-- 
					<td>
					<input type="button" value="編輯" onclick="location.href='editcustomer.php?id=<?php echo $row["id"];?>'" />
					<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>" 
					onsubmit="return confirm('確認刪除客戶 <?=$row["name"]?> ?');">
					<input type="hidden" name="cid" value="<?=$row["id"]?>">
					<input type="submit" name="submit" value="刪除">
					<input type="hidden" name="action" value="del_cust">
					</form> 
					</td>
					-->
					</tr>		
					<?php
										}
									}
									mysqli_free_result($result);
								}
							}else{
								echo "没有相关客戶!";//}
							}
						}
					}
					?>
				</table>
			</div>
					<?php
					if(isset($count) && $count){echo $getpageinfo['pagecode'];}
					?>				
</div>
</body>
</html>

<?php
include 'DB/DB_DISCONNECT.php';
?>