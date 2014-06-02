<?php
include 'DB/DB_CONNECT.php';
function page($page, $total, $ptype, $pagesize = 10, $pagelen = 5){
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
			$pagecode.="<a href=\"{$phpfile}&$ptype=1\"><<</a><span>&nbsp;</span>";//第一页
			$pagecode.="<a href=\"{$phpfile}&$ptype=".($page-1)."\"><</a><span>&nbsp;</span>";//上一页
		}else{
			$pagecode.="<a href=\"{$phpfile}?$ptype=1\"><<</a><span>&nbsp;</span>";//第一页
			$pagecode.="<a href=\"{$phpfile}?$ptype=".($page-1)."\"><</a><span>&nbsp;</span>";//上一页
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
				$pagecode.="<a href=\"{$phpfile}&$ptype={$i}\">$i</a><span>&nbsp;</span>";
			}else{
				$pagecode.="<a href=\"{$phpfile}?$ptype={$i}\">$i</a><span>&nbsp;</span>";
			}
		}
	}
	if($page!=$pages){
		if($_SERVER["QUERY_STRING"]){
			$pagecode.="<a href=\"{$phpfile}&$ptype=".($page+1)."\">></a><span>&nbsp;</span>";//下一页
			$pagecode.="<a href=\"{$phpfile}&$ptype={$pages}\">>></a>";//最后一页
		}else{
			$pagecode.="<a href=\"{$phpfile}?$ptype=".($page+1)."\">></a><span>&nbsp;</span>";//下一页
			$pagecode.="<a href=\"{$phpfile}?$ptype={$pages}\">>></a>";//最后一页
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
					<?php
						if(isset($_GET["id"]) && !empty($_GET["id"])){
							$ac_sql = "SELECT DISTINCT a.ac, a.platform, a.type FROM crm_transactions t, crm_accounts a WHERE cid = " . $_GET["id"] . " AND (a.ac, a.platform, a.type) NOT IN (SELECT a.ac, a.platform, a.type FROM crm_transactions t, crm_accounts a WHERE a.id = t.aid AND t.follow = '0000-00-00' AND a.deleted = 0 AND t.deleted = 0) AND a.deleted = 0";
						} else {
							$ac_sql = "SELECT DISTINCT a.ac, a.platform, a.type FROM crm_transactions t, crm_accounts a WHERE (a.ac, a.platform, a.type) NOT IN (SELECT a.ac, a.platform, a.type FROM crm_transactions t, crm_accounts a WHERE a.id = t.aid AND t.follow = '0000-00-00' AND a.deleted = 0 AND t.deleted = 0) AND a.deleted = 0";						
						}
					?>
				   <br>	
				<p class="section-header" ><font color="#FF0000">以下帳戶跟進過期</font></p>			
				<div>
				<table>
				
					<tr><th>公司名稱</th>
						<th>帳戶</th>
						<th>聯絡日期/時間</th>
						<th>內容</th>
						<th>對口人聯絡方式</th>
						<th>下次跟進時間</th>
						<th>附件</th>
						<th>操盤員</th>
						<th>歐羅差價</th>
						<th>金差價</th>
						<th>是否要每次調教手數</th>
						<th>是否有等候批示</th>
						<th>可否LOCK倉</th>
						<th>按金</th>
						<th>可否溝貨</th>
						<th>CUT倉%</th>
						<th>歐羅評分</th>
						<th>金評分</th>
						<th>備註</th>
						<!--  <th>操作</th> -->
					</tr>
					<?php
						$outtime_sql = "SELECT a.cid, a.ac, a.platform, a.type, c.name, t.* FROM crm_transactions t, crm_accounts a, crm_customers c WHERE a.id = t.aid AND a.cid = c.id AND t.follow < NOW() AND t.follow <> '1970-01-01' AND (a.ac, a.platform, a.type) IN (".$ac_sql.") AND a.deleted = 0 AND t.deleted = 0 ORDER BY t.follow,a.platform, a.type, a.ac  ";
						$page_sql = "SELECT COUNT(*) count FROM crm_transactions t, crm_accounts a, crm_customers c WHERE a.id = t.aid AND a.cid = c.id AND t.follow < NOW() AND t.follow <> '1970-01-01' AND (a.ac, a.platform, a.type) IN (".$ac_sql.") AND a.deleted = 0 AND t.deleted = 0 ORDER BY t.follow,a.platform, a.type, a.ac  ";
						$page = isset($_GET['opage'])?$_GET['opage']:1;
						if($presult = mysqli_query($con, $page_sql)){
							$prow = mysqli_fetch_assoc($presult);
							$count = $prow["count"];
							mysqli_free_result($presult);
							if($count){
								$getpageinfo = page($page, $count, "opage");
								$outtime_sql .= $getpageinfo['sqllimit'];
								if ($result = mysqli_query($con, $outtime_sql)) {
									while($row = mysqli_fetch_assoc($result)){
		                $t_time = date('Y-m-d H:i', strtotime($row["t_time"]));
		                $follow = date('Y-m-d H:i', strtotime($row["follow"]));
					?>
						<tr><td><a href="accounts.php?id=<?=$row["cid"]?>"><?=$row["name"]?></a></td>
						<td><?=$row["platform"]?>/<?=$row["type"]?>/<?=$row["ac"]?></td>
						<td><?=$t_time?></td>
						<td><?=$row["content"]?$row["content"]:'-'?></td>
						<td><?=$row["contact"]?$row["contact"]:'-'?></td>
						<td><?=$follow?></td>
						<td><?=$row["attachment"]?'有':'沒有'?></td>
						<td><?=$row["agent"]?$row["agent"]:'-'?></td>
						<td><?=$row["eur_diff"]?$row["eur_diff"]:'-'?></td>
						<td><?=$row["gold_diff"]?$row["gold_diff"]:"-"?></td>
						<td><?=$row["tune"]?'是':'否'?></td>
						<td><?=$row["approval"]?></td>
						<td><?=$row["lockable"]?'可':'否'?></td>
						<td><?=$row["deposit"]?></td>
						<td><?=$row["dilute"]?'可':'否'?></td>
						<td><?=$row["cut_p"]?>%</td>
						<td><?=$row["eur_rate"]?$row["eur_rate"] . '/10':'-'?></td>
						<td><?=$row["gold_rate"]?$row["gold_rate"] . '/10':'-'?></td>
						<td><?=$row["remarks"]?$row["remarks"]:'-'?></td>
						<!-- 
						<td><input type="button" value="編輯" onclick="location.href='edittran.php?id=<?php echo $row["id"];?>'" />
							<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>" 
								onsubmit="return confirm('確認刪除 <?=$ac?> 在 <?=$t_time?> 的跟進?');">
								<input type="hidden" name="tid" value="<?=$row["id"]?>">
								<input type="submit" name="submit" value="刪除">
								<input type="hidden" name="action" value="del_trans">
							</form>
						</td>
						 -->
					</tr>		
					<?php
									}
									mysqli_free_result($result);
								}
							}
						}
					?>
				</table>
				</div>
					<?php
					if(isset($count) && $count){echo $getpageinfo['pagecode'];}
					?>	
				<br>
				<br>

				<p class="section-header">以下帳戶急需跟進</p>
				<div>
				<table>
						<tr><th>公司名稱</th>
						<th>帳戶</th>
						<th>聯絡日期/時間</th>
						<th>內容</th>
						<th>對口人聯絡方式</th>
						<th>下次跟進時間</th>
						<th>附件</th>
						<th>操盤員</th>
						<th>歐羅差價</th>
						<th>金差價</th>
						<th>是否要每次調教手數</th>
						<th>是否有等候批示</th>
						<th>可否LOCK倉</th>
						<th>按金</th>
						<th>可否溝貨</th>
						<th>CUT倉%</th>
						<th>歐羅評分</th>
						<th>金評分</th>
						<th>備註</th>
						<!--  <th>操作</th> -->
					</tr>
					<?php
					 	$select_sql = "SELECT a.cid, c.name,a.ac, a.platform, a.type, t.*, min(t.follow) FROM crm_transactions t, crm_accounts a, crm_customers c WHERE a.id = t.aid AND a.cid = c.id AND t.follow >= NOW() AND t.follow <> '1970-01-01' AND t.follow <> '0000-00-00' AND (a.ac, a.platform, a.type) IN (".$ac_sql.") AND a.deleted = 0 AND t.deleted = 0 GROUP BY a.platform, a.type, a.ac ORDER BY t.follow ";
						$page_sql = "SELECT COUNT(*) count FROM crm_transactions t, crm_accounts a, crm_customers c WHERE a.id = t.aid AND a.cid = c.id AND t.follow >= NOW() AND t.follow <> '1970-01-01' AND t.follow <> '0000-00-00' AND (a.ac, a.platform, a.type) IN (".$ac_sql.") AND a.deleted = 0 AND t.deleted = 0 GROUP BY a.platform, a.type, a.ac ORDER BY t.follow ";
						$page = isset($_GET['spage'])?$_GET['spage']:1;
						if($presult = mysqli_query($con, $page_sql)){
							$sprow = mysqli_fetch_assoc($presult);
							$scount = $sprow["count"];
							mysqli_free_result($presult);
							if($scount){
								$getspageinfo = page($page, $scount, "spage");
								$select_sql .= $getspageinfo['sqllimit'];
								if ($result = mysqli_query($con, $select_sql)) {
									if(mysqli_num_rows($result)){
										while($row = mysqli_fetch_assoc($result)){
		                  $t_time = date('Y-m-d H:i', strtotime($row["t_time"]));
											$follow = date('Y-m-d H:i', strtotime($row["follow"]));
					?>
						<tr><td><a href="accounts.php?id=<?=$row["cid"]?>"><?=$row["name"]?></a></td>
						<td><?=$row["platform"]?>/<?=$row["type"]?>/<?=$row["ac"]?></td>
						<td><?=$t_time?></td>
						<td><?=$row["content"]?$row["content"]:'-'?></td>
						<td><?=$row["contact"]?$row["contact"]:'-'?></td>
						<td><?=$follow?></td>
						<td><?=$row["attachment"]?'有':'沒有'?></td>
						<td><?=$row["agent"]?$row["agent"]:'-'?></td>
						<td><?=$row["eur_diff"]?$row["eur_diff"]:'-'?></td>
						<td><?=$row["gold_diff"]?$row["gold_diff"]:"-"?></td>
						<td><?=$row["tune"]?'是':'否'?></td>
						<td><?=$row["approval"]?></td>
						<td><?=$row["lockable"]?'可':'否'?></td>
						<td><?=$row["deposit"]?></td>
						<td><?=$row["dilute"]?'可':'否'?></td>
						<td><?=$row["cut_p"]?>%</td>
						<td><?=$row["eur_rate"]?$row["eur_rate"] . '/10':'-'?></td>
						<td><?=$row["gold_rate"]?$row["gold_rate"] . '/10':'-'?></td>
						<td><?=$row["remarks"]?$row["remarks"]:'-'?></td>
						<!--  
						<td><input type="button" value="編輯" onclick="location.href='edittran.php?id=<?php echo $row["id"];?>'" />
							<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>" 
								onsubmit="return confirm('確認刪除 <?=$ac?> 在 <?=$t_time?> 的跟進?');">
								<input type="hidden" name="tid" value="<?=$row["id"]?>">
								<input type="submit" name="submit" value="刪除">
								<input type="hidden" name="action" value="del_trans">
							</form>
						</td>
						-->
					</tr>		
					<?php
											}
										}
									mysqli_free_result($result);
								}
							}
						}
					?>	
				</table>
				</div>				
					<?php
					if(isset($scount) && $scount){echo $getspageinfo['pagecode'];}
					?>			
		
</div><br><br>
</body>
</html>
<?php
include 'DB/DB_DISCONNECT.php';
?>