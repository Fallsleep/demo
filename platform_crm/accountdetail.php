<?php 

include 'DB/DB_CONNECT.php';

if(isset($_POST["submit"])) {
  if($_POST["action"] == "search_acc"){
		if(!(empty($_POST["name"]) && empty($_POST["type"]) 
			&& empty($_POST["platform"]) && empty($_POST["ac"]) 
			//&& empty($_POST["pw"]) 
			&& empty($_POST["link"]) && empty($_POST["contract"]) 
			&& empty($_POST["trade_item"]) && empty($_POST["eur_dps"]) 
			&& empty($_POST["gold_dps"])&& empty($_POST["min"]) && empty($_POST["max"])
			&& empty($_POST["currency"]) && empty($_POST["remarks"])
				) ){
			$names = mb_split("/([\s,\.\/\'\";!@#\$%^\&\*，。！￥…（）])+/",$_POST["name"]);		//string
			$type = $_POST["type"];		//string 
			$platform = $_POST["platform"];
			$acs = mb_split("/([\s,\.\/\'\";!@#\$%^\&\*，。！￥…（）])+/",$_POST["ac"]);//账号
			//$pws = mb_split("/([\s,\.\/\'\";!@#\$%\^\&*，。！￥…（）])+/",$_POST["pw"]);//密碼
			$links = mb_split("/([\s,\.\/\'\";!@#\$%\^\&*，。！￥…（）])+/",$_POST["link"]);
			$contract = $_POST["contract"];		//tinyint 通过单选框获取
			if(isset($_POST["trade_item"])){$trade_items = $_POST["trade_item"];}	//string 可能是含有0-2个元素的数组，通过复选框获取
			$eur_dpss = mb_split("/([\s,\.\/\'\";!@#\$%^\&\*，。！￥…（）])+/",$_POST["eur_dps"]);			//int
     	$gold_dpss = mb_split("/([\s,\.\/\'\";!@#\$%^\&\*，。！￥…（）])+/",$_POST["gold_dps"]);		//int
			$mins = mb_split("/([\s,\.\/\'\";!@#\$%^\&\*，。！￥…（）])+/",$_POST["min"]);							//int
			$maxs = mb_split("/([\s,\.\/\'\";!@#\$%^\&\*，。！￥…（）])+/",$_POST["max"]);							//int
			$currencys = mb_split("/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/",$_POST["currency"]);
			$remarkss = mb_split("/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/",$_POST["remarks"]);
						
			$where = '1=0';
			//帳號
			foreach($acs as $key){
					if($key){
						$where .= " OR ac like ('%".$key."%')";
					}
			}
			//帳戶取得方法
			if(!empty($acs[0]) && !empty($links[0])){
				$where .= ' AND';
				$where .= " link like ('%".$links[0]."%')";
				$links = array_slice($links,1);			
				foreach($links as $key){
					if($key){
						$where .= " OR link like ('%".$key."%')";
					}
				}
			}
			else{
				foreach($links as $key){
					if($key){
						$where .= " OR link like ('%".$key."%')";
					}
				}			
			}
			//歐羅每手按金
			if(!(empty($acs[0]) && empty($links[0])) && !empty($eur_dpss[0])){
				if(preg_match("/^\d*$/",$eur_dpss[0])){
					$where .= ' AND';
					$where .= " eur_dpss like ('%".$eur_dpss[0]."%')";
					$eur_dpss = array_slice($eur_dpss,1);		
				}	
				foreach($eur_dpss as $key){
					if($key){
						if(preg_match("/^\d*$/",$key)){
							$where .= " OR eur_dps like ('%".$key."%')";
						}else{
							echo '<script>alert("請輸入正確的值！");</script>';//中文容易出乱码，IE中如果不是自动选择编码而是gb2312的话
							exit();
						}
					}
				}
			}
			else{
				foreach($eur_dpss as $key){
					if($key){
						if(preg_match("/^\d*$/",$key)){
							$where .= " OR eur_dps like ('%".$key."%')";
						}else{
							echo '<script>alert("請輸入正確的值！");</script>';//中文容易出乱码，IE中如果不是自动选择编码而是gb2312的话
							exit();
						}
					}
				}		
			}
			//金每手按金				
			if(!(empty($acs[0]) && empty($links[0]) && empty($eur_dpss[0])) && !empty($gold_dpss[0])){
				if(preg_match("/^\d*$/",$gold_dpss[0])){
					$where .= ' AND';
					$where .= " gold_dps like ('%".$gold_dpss[0]."%')";
					$gold_dpss = array_slice($gold_dpss,1);		
				}	
				foreach($gold_dpss as $key){
					if($key){
						if(preg_match("/^\d*$/",$key)){
							$where .= " OR gold_dps like ('%".$key."%')";
						}else{
							echo '<script>alert("請輸入正確的值！");</script>';//中文容易出乱码，IE中如果不是自动选择编码而是gb2312的话
							exit();
						}
					}
				}
			}
			else{
				foreach($gold_dpss as $key){
					if($key){
						if(preg_match("/^\d*$/",$key)){
							$where .= " OR gold_dps like ('%".$key."%')";
						}else{
							echo '<script>alert("請輸入正確的值！");</script>';//中文容易出乱码，IE中如果不是自动选择编码而是gb2312的话
							exit();
						}
					}
				}	
			}
			//最少手數
			if(!(empty($acs[0]) && empty($links[0]) && empty($eur_dpss[0])
				&& empty($gold_dpss[0])) && !empty($mins[0])){
				if(preg_match("/^\d*$/",$mins[0])){
					$where .= ' AND';
					$where .= " min like ('%".$mins[0]."%')";
					$mins = array_slice($mins,1);		
				}	
				foreach($mins as $key){
					if($key){
						if(preg_match("/^\d*$/",$key)){
							$where .= " OR min like ('%".$key."%')";
						}else{
							echo '<script>alert("請輸入正確的值！");</script>';//中文容易出乱码，IE中如果不是自动选择编码而是gb2312的话
							exit();
						}
					}
				}
			}
			else{
				foreach($mins as $key){
					if($key){
						if(preg_match("/^\d*$/",$key)){
							$where .= " OR min like ('%".$key."%')";
						}else{
							echo '<script>alert("請輸入正確的值！");</script>';//中文容易出乱码，IE中如果不是自动选择编码而是gb2312的话
							exit();
						}
					}
				}	
			}
			//最多手數
			if(!(empty($acs[0]) && empty($links[0]) && empty($eur_dpss[0])
				&& empty($gold_dpss[0]) && empty($mins[0])) && !empty($maxs[0])){
				if(preg_match("/^\d*$/",$maxs[0])){
					$where .= ' AND';
					$where .= " max like ('%".$maxs[0]."%')";
					$maxs = array_slice($maxs,1);		
				}	
				foreach($maxs as $key){
					if($key){
						if(preg_match("/^\d*$/",$key)){
							$where .= " OR max like ('%".$key."%')";
						}else{
							echo '<script>alert("請輸入正確的值！");</script>';//中文容易出乱码，IE中如果不是自动选择编码而是gb2312的话
							exit();
						}
					}
				}
			}
			else{
				foreach($maxs as $key){
					if($key){
						if(preg_match("/^\d*$/",$key)){
							$where .= " OR max like ('%".$key."%')";
						}else{
							echo '<script>alert("請輸入正確的值！");</script>';//中文容易出乱码，IE中如果不是自动选择编码而是gb2312的话
							exit();
						}
					}
				}	
			}
			//結算貨幣
			if(!(empty($acs[0]) && empty($links[0]) && empty($eur_dpss[0]) 
				&& empty($gold_dpss[0]) && empty($mins[0]) && empty($maxs[0]))
				&& !empty($currencys[0])){
				$where .= ' AND';
				$where .= " currency like ('%".$currencys[0]."%')";
				$currencys = array_slice($currencys,1);
				foreach($currencys as $key){
					if($key){
						$where .= " OR currency like ('%".$key."%')";
					}
				}
			}
			else{
				foreach($currencys as $key){
					if($key){
						$where .= " OR currency like ('%".$key."%')";
					}
				}
			}
			//備註
			if(!(empty($acs[0]) && empty($links[0]) && empty($eur_dpss[0])
				&& empty($gold_dpss[0]) && empty($mins[0]) && empty($maxs[0])
				&& empty($currencys[0])) && !empty($remarkss[0])){
				$where .= ' AND';
				$where .= " remarks like ('%".$remarkss[0]."%')";
				$remarkss = array_slice($remarkss,1);
				foreach($remarkss as $key){
					if($key){
						$where .= " OR remarks like ('%".$key."%')";
					}
				}
			}
			else{
				foreach($remarkss as $key){
					if($key){
						$where .= " OR remarks like ('%".$key."%')";
					}
				}
			}

			//名称
			$subwhere = '1=0';
			foreach($names as $key){
						if($key){
							$subwhere .= " OR name like ('%".$key."%')";
						}
			}
			if($subwhere != '1=0'){
				if($where =='1=0'){
					$where = " a.cid in (SELECT id FROM crm_customers  WHERE ".$subwhere." AND deleted = 0)";
				}else{
					$where .= " AND a.cid in (SELECT id FROM crm_customers  WHERE ".$subwhere." AND deleted = 0)";
				}
			}
			//帳戶類型
			if($where !='1=0'){
				$where .= " AND type = '".$type."'";
			}else{
				$where .= " OR type = '".$type."'";
			}
			
			//平台名稱
			$where .= " AND platform = '".$platform."'";

			//已簽約
			$where .= " AND contract = '".$contract."'";
			//可交易項目
			if(isset($trade_items)){
				$num = count($trade_items);
				switch($num){
					case 1:
						$where .= " AND trade_item ='".$trade_items[0]."'";
						break;
					case 2:
						$where .= " AND trade_item ='both'";
						break;
				}
			}
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
				<p class="section-header">查詢帳戶結果</p>
				<table>
					<tr><th>公司名稱</th>
						<th>帳戶類型</th>
						<th>平台名稱</th>
						<th>帳號</th>
						<th>密碼</th>
						<th>帳戶取得方法</th>
						<th>已簽約</th>
						<th>可交易項目</th>
						<th>歐羅每手按金</th>
						<th>金每手按金</th>
						<th>最少手數</th>
						<th>最多手數</th>
						<th>結算貨幣</th>
						<th>備註</th>
						<!--  <th>操作</th> -->
					</tr>
					<?php
					if(isset($_GET["kw"])){$where =$_GET["kw"]; }
					if(isset($where)){
						//echo $where;
						//$select_sql = "SELECT * FROM crm_accounts WHERE ".$where;
						if(isset($_GET["id"]) && !empty($_GET["id"])){
							$select_sql = "SELECT * FROM crm_accounts WHERE cid = " . $_GET["id"] . " AND deleted = 0";
							$page_sql = "SELECT COUNT(*) count FROM crm_accounts WHERE cid = " . $_GET["id"] . " AND deleted = 0";
						} else {
							$select_sql = "SELECT c.id, c.name, a.* FROM crm_customers c, crm_accounts a WHERE ".$where." AND c.id=a.cid AND a.deleted = 0";
							$page_sql = "SELECT COUNT(*) count FROM crm_customers c, crm_accounts a WHERE ".$where." AND c.id=a.cid AND a.deleted = 0";
						}
						
						$page = isset($_GET['apage'])?$_GET['apage']:1;
						if($presult = mysqli_query($con, $page_sql)){
							$prow = mysqli_fetch_assoc($presult);
							$count = $prow["count"];
							mysqli_free_result($presult);
							if($count){
								$getpageinfo = page($page, $count, "apage", $where);
								$select_sql .= $getpageinfo['sqllimit'];
								if ($result = mysqli_query($con, $select_sql)) {
									while($row = mysqli_fetch_assoc($result)){
										switch ($row["trade_item"]) {
											case "eur":  $trade_item = "歐羅"; break;
											case "gold": $trade_item = "金"; break;
											case "both": $trade_item = "歐羅/金"; break;
										} 
					?>
					    <tr><td><a href="accounts.php?id=<?=$row["cid"]?>"><?=$row["name"]?></a></td>
						<td><?=$row["type"]?$row["type"]:'-'?></td>
						<td><?=$row["platform"]?$row["platform"]:'-'?>平台</td>
						<td><?=$row["ac"]?$row["ac"]:'-'?></td>
						<td><?=$row["pw"]?$row["pw"]:'-'?></td>
						<td><?=$row["link"]?$row["link"]:'-'?></td>
						<td><?=$row["contract"]?'是':'否'?>
						<!--  <td><?=$row["contract"]?$row["contract"]:'-'?></td> -->
						<td><?=$trade_item?></td>
						<!-- <td><?=$row["trade_item"]?$row["trade_item"]:'-'?></td> -->
						<td><?=$row["eur_dps"]?$row["eur_dps"]:'-'?></td>
						<td><?=$row["gold_dps"]?$row["gold_dps"]:'-'?></td>
						<td><?=$row["min"]?$row["min"]:'-'?></td>
						<td><?=$row["max"]?$row["max"]:'-'?></td>
						<td><?=$row["currency"]?$row["currency"]:'-'?></td>
						<td><?=$row["remarks"]?$row["remarks"]:'-'?></td>
						<!--  
						<td><input type="button" value="編輯" onclick="location.href='editaccount.php?id=<?php echo $row["id"];?>'" />
						<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>" 
						      onsubmit="return confirm('確認刪除帳戶 <?=$row["name"]?> ?');">
								<input type="hidden" name="cid" value="<?=$row["id"]?>">
								<input type="submit" name="submit" value="刪除">
								<input type="hidden" name="action" value="del_acc">
							</form>
						</td>
						-->
					</tr>		

					<?php
									}
								}
								mysqli_free_result($result);
							}
							else{
								echo "没有相关帳戶!";//}
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