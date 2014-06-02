<?php
include 'DB/DB_CONNECT.php';
if(isset($_POST["submit"])) {	
	if($_POST["action"] == "new_acc"){
		if(isset($_GET["id"]) && !empty($_GET["id"])){
			$cid = $_GET["id"];
		} else {
			$cid = $_POST["cid"];
		}
		$platform = $_POST["platform"];
		$type = $_POST["type"];
		$ac = str_replace(' ','',$_POST["ac"]);
		$pw = str_replace(' ','',$_POST["pw"]);
		$link = str_replace(' ','',$_POST["link"]);
		$contract = $_POST["contract"];
		if(!empty($_POST["trade_item"])){
			$item_cnt = 0;
			foreach($_POST["trade_item"] as $item) {
				$trade_item = $item;
				$item_cnt++;
			}		
			if($item_cnt == 2){ $trade_item = "both"; }
		}
		$eur_dps = str_replace(' ','',!empty($_POST["eur_dps"])?$_POST["eur_dps"]:0);
		$gold_dps = str_replace(' ','',!empty($_POST["gold_dps"])?$_POST["gold_dps"]:0);
		$min = str_replace(' ','',$_POST["min"]);
		$max = str_replace(' ','',$_POST["max"]);
		$currency = str_replace(' ','',$_POST["currency"]);
		$remarks = str_replace(' ','',$_POST["remarks"]);
		
		$insert_sql = "INSERT INTO crm_accounts (cid, platform, type, ac, pw, link, contract, trade_item, eur_dps, gold_dps, min, max, currency, remarks) 
						VALUES ('$cid', '$platform', '$type', '$ac', '$pw', '$link', '$contract', '$trade_item', '$eur_dps', '$gold_dps', '$min', '$max', '$currency', '$remarks')";
		if (!mysqli_query($con,$insert_sql)){ die('Error: ' . mysqli_error($con));	}
	}else if($_POST["action"] == "edit_acc"){
		$aid = $_POST["aid"];
		//$cid = $_POST["cid"];
		$platform = $_POST["platform"];
		$type = $_POST["type"];
		$ac = str_replace(' ','',$_POST["ac"]);
		$pw = str_replace(' ','',$_POST["pw"]);
		$link = str_replace(' ','',$_POST["link"]);
		$contract = $_POST["contract"];
		if(!empty($_POST["trade_item"]))
		{
			$item_cnt = 0;
			foreach($_POST["trade_item"] as $item)
			{
				$trade_item = $item;
				$item_cnt++;
			}		
			if($item_cnt == 2){ $trade_item = "both"; }
		}
		$eur_dps = str_replace(' ','',!empty($_POST["eur_dps"])?$_POST["eur_dps"]:0);
		$gold_dps = str_replace(' ','',!empty($_POST["gold_dps"])?$_POST["gold_dps"]:0);
		$min = str_replace(' ','',$_POST["min"]);
		$max = str_replace(' ','',$_POST["max"]);
		$currency = str_replace(' ','',$_POST["currency"]);
		$remarks = str_replace(' ','',$_POST["remarks"]);
		
		//$update_sql = "update crm_accounts set cid='$cid',platform='$platform',type='$type',ac='$ac',pw='$pw',link='$link',contract='$contract',trade_item='$trade_item',eur_dps='$eur_dps',gold_dps='$gold_dps',min='$min',max='$max',currency='$currency',remarks='$remarks' where id=$aid";
		$update_sql = "update crm_accounts set platform='$platform',type='$type',ac='$ac',pw='$pw',link='$link',contract='$contract',trade_item='$trade_item',eur_dps='$eur_dps',gold_dps='$gold_dps',min='$min',max='$max',currency='$currency',remarks='$remarks' where id=$aid";
		
		if (!mysqli_query($con,$update_sql)){ die('Error: ' . mysqli_error($con));	}//else{echo "<script language = javascript> alert('編輯成功！');</script>";}		
	}elseif($_POST["action"] == "del_acc"){
		$delete_sql = "UPDATE crm_accounts a, crm_transactions t SET a.deleted = 1, t.deleted = 1 WHERE a.id = t.aid AND a.id = " . $_POST["aid"];		
		if (!mysqli_query($con,$delete_sql)){ die('Error: ' . mysqli_error($con));	}
	}elseif($_POST["action"] == "new_trans"){
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
	}elseif($_POST["action"] == "edit_trans"){
		$tid = $_POST["tid"];
		//$aid = $_POST["aid"];
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
		
		//$update_sql = "update crm_transactions set aid='$aid',t_time='$t_time',content='$content',contact='$contact',follow='$follow',attachment='$attachment',agent='$agent',eur_diff='$eur_diff',gold_diff='$gold_diff',tune='$tune',approval='$approval',lockable='$lockable',deposit='$deposit',dilute='$dilute',cut_p='$cut_p',eur_rate='$eur_rate',gold_rate='$gold_rate',remarks='$remarks' where id=$tid";
		$update_sql = "update crm_transactions set t_time='$t_time',content='$content',contact='$contact',follow='$follow',attachment='$attachment',agent='$agent',eur_diff='$eur_diff',gold_diff='$gold_diff',tune='$tune',approval='$approval',lockable='$lockable',deposit='$deposit',dilute='$dilute',cut_p='$cut_p',eur_rate='$eur_rate',gold_rate='$gold_rate',remarks='$remarks' where id=$tid";
		
		if (!mysqli_query($con,$update_sql)){ die('Error: ' . mysqli_error($con));	}//else{echo "<script language = javascript> alert('編輯成功！');</script>";}
	}elseif($_POST["action"] == "del_trans"){
		$delete_sql = "UPDATE crm_transactions SET deleted = 1 WHERE id = " . $_POST["tid"];		
		if (!mysqli_query($con,$delete_sql)){ die('Error: ' . mysqli_error($con));	}
	}
}
    //分頁顯示
function page($page, $total, $ptype, $pagesize = 10, $pagelen = 5){
	if($_SERVER["QUERY_STRING"]){
		$str = '/(?:^'.$ptype.'=\d+&)|(?:'.$ptype.'=\d+$)/';
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
	<script>
	$(document).ready(function(){
		$('#gold-dps, .new-form').hide();
		$('input[name="trade_item[]"]').click(function(){
			if(!this.checked){
				$('input[name="' + $(this).val() + '-dps"]').val('');
			}
			$('#' + $(this).val() + '-dps').toggle(this.checked);
		});
		$('.section-header').click(function(){
			$('#' + $(this).attr('id') + '-form').toggle('slow');
		});
	});
	</script>
</head>
<body>
	<div id="container">
		<?php include 'menu.php'; ?>
		<div id="content">
		<br>
			<div>
				<?php
				if(isset($_GET["id"]) && !empty($_GET["id"])){
					$customer_sql = "SELECT * FROM crm_customers WHERE id = " . $_GET["id"];
					if($customer = mysqli_query($con, $customer_sql)){
						$row = mysqli_fetch_assoc($customer);
						if(!isset($row)){ header( 'Location: index.php' ) ; };
				?>
				<p class="section-header">帳戶詳情</p>
				<h4>公司名稱: <?=$row["name"]?></h4>
				<h4>地址: <?=$row["address"]?></h4>
				<h4>網址: <?=$row["website"]?$row["website"]:'-'?></h4>
				<h4>聯絡電話: <?=$row["phone"]?></h4>
				<h4>電郵: <?=$row["email"]?$row["email"]:'-'?></h4>
				<h4>傳真: <?=$row["fax"]?$row["fax"]:'-'?></h4>
				<h4>負責人: <?=$row["pic"]?></h4>
				<h4>QQ/SKYPE: <?=$row["im"]?$row["im"]:'-'?></h4>
				<?php
						mysqli_free_result($customer);
					}
				}
				?>
			</div><br>
			<div>
				<p class="section-header">現有帳戶<?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?> (所有客戶)<?php } ?></p>
				<table>
					<tr><?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?><th>公司名稱</th><?php } ?>
						<th>帳戶類型</th><th>平台名稱</th><th>帳號</th><th>密碼</th><th>帳戶取得方法</th><th>已簽約</th>
						<th>可交易項目</th><th>歐羅每手按金</th><th>金每手按金</th><th>最少手數</th><th>最多手數</th><th>結算貨幣</th><th>備註</th><th>操作</th>
					</tr>
					<?php
					if(isset($_GET["id"]) && !empty($_GET["id"])){
						$accounts_sql = "SELECT * FROM crm_accounts WHERE cid = " . $_GET["id"] . " AND deleted = 0";
						$page_sql = "SELECT COUNT(*) count FROM crm_accounts WHERE cid = " . $_GET["id"] . " AND deleted = 0";
					} else {
						$accounts_sql = "SELECT c.id, c.name, a.* FROM crm_customers c, crm_accounts a WHERE c.id = a.cid AND a.deleted = 0";
						$page_sql = "SELECT COUNT(*) count FROM crm_customers c, crm_accounts a WHERE c.id = a.cid AND a.deleted = 0";
					}
					$page = isset($_GET['apage'])?$_GET['apage']:1;
					if($presult = mysqli_query($con, $page_sql)){
						$prow = mysqli_fetch_assoc($presult);
						$count = $prow["count"];
						mysqli_free_result($presult);
						if($count){
							$getpageinfo = page($page, $count, "apage");
							$accounts_sql .= $getpageinfo['sqllimit'];
							if($result = mysqli_query($con, $accounts_sql)){
								while($row = mysqli_fetch_assoc($result)){
									switch ($row["trade_item"]) {
										case "eur": $trade_item = "歐羅"; break;
										case "gold": $trade_item = "金"; break;
										case "both": $trade_item = "歐羅/金"; break;
									}
					?>
					<tr><?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?><td><a href="accounts.php?id=<?=$row['cid']?>"><?=$row["name"]?></a></td><?php } ?>
						<td><?=$row["type"]?></td>
						<td><?=$row["platform"]?>平台</td>
						<td><?=$row["ac"]?$row["ac"]:'-'?></td>
						<td><?=$row["pw"]?$row["pw"]:'-'?></td>
						<td><?=$row["link"]?$row["link"]:'-'?></td>
						<td><?=$row["contract"]?'是':'否'?></td>
						<td><?=$trade_item?></td>
						<td><?=$row["eur_dps"]?$row["eur_dps"]:'-'?></td>
						<td><?=$row["gold_dps"]?$row["gold_dps"]:'-'?></td>
						<td><?=$row["min"]?$row["min"]:'-'?></td>
						<td><?=$row["max"]?$row["max"]:'-'?></td>
						<td><?=$row["currency"]?$row["currency"]:'-'?></td>
						<td><?=$row["remarks"]?$row["remarks"]:'-'?></td>
						<td><input type="button" value="編輯" onclick="location.href='editaccount.php?id=<?php echo $row["id"];?>'" />
							<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>" 
								onsubmit="return confirm('確認刪除帳戶 <?=$row["ac"]?> ?');">
								<input type="hidden" name="aid" value="<?=$row["id"]?>">
								<input type="submit" name="submit" value="刪除">
								<input type="hidden" name="action" value="del_acc">
							</form>
						</td>
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

			<div>
				<p class="section-header expandable" id="new-acc">新增帳戶</p>
				<div class="new-form" id="new-acc-form">
					<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>">
						<?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?>
						公司名稱: <select name="cid">
						<?php
							$customers_sql = "SELECT id, name FROM crm_customers";
							if($result = mysqli_query($con, $customers_sql)){
								while($row = mysqli_fetch_assoc($result)){
						?>
							<option value="<?=$row['id']?>"><?=$row["name"]?></option>
						<?php	
								}
								mysqli_free_result($result);
							}
						?>
						</select><br>
						<?php }	?>
						帳戶類型: <input type="radio" name="type" value="Demo" checked>Demo <input type="radio" name="type" value="Real">Real<br>
						平台名稱: <input type="radio" name="platform" value="JAVA" checked>JAVA平台 <input type="radio" name="platform" value="WEB">WEB平台 <input type="radio" name="platform" value="MT4">MT4平台<br>
						帳號: <input type="text" name="ac"><br>
						密碼: <input type="text" name="pw"><br>
						帳戶取得方法: <input type="text" name="link"><br>
						已簽約: <input type="radio" name="contract" value="1" checked>是 <input type="radio" name="contract" value="0">否<br>
						可交易項目: <input type="checkbox" name="trade_item[]" value="eur" checked>歐羅 <input type="checkbox" name="trade_item[]" value="gold">金<br>					
						<div id="eur-dps">歐羅每手按金: <input type="text" name="eur_dps"></div>
						<div id="gold-dps">金每手按金: <input type="text" name="gold_dps"></div>
						最少手數: <input type="text" name="min"><br>
						最多手數: <input type="text" name="max"><br>
						結算貨幣: <input type="text" name="currency"><br>			
						備註: <textarea rows="4" cols="25" name="remarks"></textarea><br>			
						<input type="submit" name="submit" value="提交"><br>
						<input type="hidden" name="action" value="new_acc">
					</form>
				</div>
			</div><br>


			<div>
				<p class="section-header">現有跟進<?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?> (所有客戶)<?php } ?></p>
				<table>
					<tr><?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?><th>公司名稱</th><?php } ?>
						<th>帳戶</th><th>聯絡日期/時間</th><th>內容</th><th>對口人聯絡方式</th><th>下次跟進時間</th><th>附件</th><th>操盤員</th>
						<th>歐羅差價</th><th>金差價</th><th>是否要每次調教手數</th><th>是否有等候批示</th><th>可否LOCK倉</th><th>按金</th><th>可否溝貨</th><th>CUT倉%</th>
						<th>歐羅評分</th><th>金評分</th><th>備註</th><th>操作</th>
					</tr>
					<?php
					if(isset($_GET["id"]) && !empty($_GET["id"])){
						$accounts_sql = "SELECT a.platform, a.type, a.ac, t.* FROM crm_accounts a, crm_transactions t WHERE a.cid = " . $_GET["id"] . " AND a.id = t.aid AND t.deleted = 0";
						$page_sql = "SELECT COUNT(*) count FROM crm_accounts a, crm_transactions t WHERE a.cid = " . $_GET["id"] . " AND a.id = t.aid AND t.deleted = 0";
					} else {
						$accounts_sql = "SELECT c.id, c.name, a.cid, a.platform, a.type, a.ac, t.* FROM crm_customers c, crm_accounts a, crm_transactions t WHERE c.id = a.cid AND a.id = t.aid AND t.deleted = 0";
						$page_sql = "SELECT COUNT(*) count FROM crm_customers c, crm_accounts a, crm_transactions t WHERE c.id = a.cid AND a.id = t.aid AND t.deleted = 0";
					}
					$page = isset($_GET['tpage'])?$_GET['tpage']:1;
					if($presult = mysqli_query($con, $page_sql)){
						$prow = mysqli_fetch_assoc($presult);
						$count = $prow["count"];
						mysqli_free_result($presult);
						if($count){
							$getpageinfo = page($page, $count, "tpage");
							$accounts_sql .= $getpageinfo['sqllimit'];
							if($result = mysqli_query($con, $accounts_sql)){
								while($row = mysqli_fetch_assoc($result)){
									switch ($row["approval"]) {
										case "always": $approval = "經常有"; break;
										case "often": $approval = "間中有"; break;
										case "no": $approval = "無"; break;
									}
									$ac = $row["platform"] . "/" . $row["type"] . "/" . $row["ac"];
									
									$t_time = date('Y-m-d H:i', strtotime($row["t_time"]));									
									$t_timet = date('Y', strtotime($row["t_time"]));
									if($t_timet == "1970"){$t_time="-";}
									
									$follow = date('Y-m-d H:i', strtotime($row["follow"]));
									$followt = date('Y', strtotime($row["follow"]));
									if($followt == "1970"){$follow="-";}
								
					?>
					<tr><?php if(!isset($_GET["id"]) || empty($_GET["id"])){ ?><td><a href="accounts.php?id=<?=$row['cid']?>"><?=$row["name"]?></a></td><?php } ?>
						<td><?=$ac?></td>
						<td><?=$t_time?></td>
						<td><?=$row["content"]?$row["content"]:'-'?></td>
						<td><?=$row["contact"]?$row["contact"]:'-'?></td>
						<td><?=$follow?></td>
						<td><?=$row["attachment"]?'有':'沒有'?></td>
						<td><?=$row["agent"]?$row["agent"]:'-'?></td>
						<td><?=$row["eur_diff"]?$row["eur_diff"]:'-'?></td>
						<td><?=$row["gold_diff"]?$row["gold_diff"]:"-"?></td>
						<td><?=$row["tune"]?'是':'否'?></td>
						<td><?=$approval?></td>
						<td><?=$row["lockable"]?'可':'否'?></td>
						<td><?=$row["deposit"]?$row["deposit"]:'-'?></td>
						<td><?=$row["dilute"]?'可':'否'?></td>
						<td><?=$row["cut_p"]?$row["cut_p"]:'-'?>%</td>
						<td><?=$row["eur_rate"]?$row["eur_rate"] . '/10':'-'?></td>
						<td><?=$row["gold_rate"]?$row["gold_rate"] . '/10':'-'?></td>
						<td><?=$row["remarks"]?$row["remarks"]:'-'?></td>
						<td><input type="button" value="編輯" onclick="location.href='edittran.php?id=<?php echo $row["id"];?>'" />
							<form method="post" action="<?=htmlentities($_SERVER['PHP_SELF'])?><?php if(isset($_GET["id"]) && !empty($_GET["id"])){ ?>?id=<?=$_GET['id']?><?php } ?>" 
								onsubmit="return confirm('確認刪除 <?=$ac?> 在 <?=$t_time?> 的跟進?');">
								<input type="hidden" name="tid" value="<?=$row["id"]?>">
								<input type="submit" name="submit" value="刪除">
								<input type="hidden" name="action" value="del_trans">
							</form>
						</td>
					</tr>		
					<?php
								}
							}
							mysqli_free_result($result);
						}
					}
					?>
				</table>
			</div>
			<?php
			if(isset($count) && $count){echo $getpageinfo['pagecode'];}
			?>

			<div>
				<p class="section-header expandable" id="new-trans">新增跟進</p>
				<div class="new-form" id="new-trans-form">
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
						<input type="hidden" name="action" value="new_trans">
					</form>
				</div>
			</div>
		</div>
	</div><br><br>
</body>
</html>
<?php
include 'DB/DB_DISCONNECT.php';
?>