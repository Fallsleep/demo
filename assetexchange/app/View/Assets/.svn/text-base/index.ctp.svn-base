	<div id='assetwarpper'>
		<div id='leftcolumn'>
			<table class='asset'>
				<tr>
					<th>最高升幅</th>
					<th colspan="3">更新時間（香港）: <?php date_default_timezone_set('Asia/Hong_Kong'); echo date('n月j日  H:i'); ?> </th>
				</tr>
				<tr>
					<td>編號</td>
					<td>商品名稱</td>
					<td>單位市價（升跌%）</td>
					<td>操作</td>
				</tr>
				<?php 
					if($topTen['rise']){
						foreach ($topTen['rise'] as $asset){
							if(isset($asset['Asset'])){
				?>
				<tr>
					<td><?=$this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id']))?></td>
					<td><?=$asset['Asset']['name']?></td>
					<td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
					<td>
					<?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="buy_price">'.  number_format($asset['closest_price']['B'], 2, '.', ',') . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="sell_price">'. number_format($asset['closest_price']['S'], 2, '.', ',') . '</div>';
						?>
					</td>
				</tr>
				<?php 
							}else {
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>			
				<?php 		
							}			
						}
					}else {
						for ($i = 0; $i < 10; $i++){
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>
				<?php 
						}
					}
				?>
			</table>
			<br><br>
			<table class='asset'>
				<tr>
					<th>熱門住宅</th>
					<th colspan="3">更新時間（香港）: <?php  echo date('n月j日  H:i'); ?> </th>
				</tr>
				<tr>
					<td>編號</td>
					<td>商品名稱</td>
					<td>單位市價（升跌%）</td>
					<td>操作</td>
				</tr>
				<?php 
					if($topTen['0']){
						foreach ($topTen['0'] as $asset){
							if(isset($asset['Asset'])){
				?>
				<tr>
					<td><?=$this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id']))?></td>
					<td><?=$asset['Asset']['name']?></td>
					<td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
					<td>
					<?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="buy_price">'.  number_format($asset['closest_price']['B'], 2, '.', ',') . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="sell_price">'. number_format($asset['closest_price']['S'], 2, '.', ',') . '</div>';
						?>
					</td>
				</tr>
				<?php 
							}else {
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>			
				<?php 		
							}			
						}
					}else {
						for ($i = 0; $i < 10; $i++){
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>
				<?php 
						}
					}
				?>
			</table>
			<br><br>			
			<table class='asset'>
				<tr>
					<th>熱門商廈</th>
					<th colspan="3">更新時間（香港）: <?php  echo date('n月j日  H:i'); ?> </th>
				</tr>
				<tr>
					<td>編號</td>
					<td>商品名稱</td>
					<td>單位市價</td>
					<td>操作</td>
				</tr>
				<?php 
					if($topTen['2']){
						foreach ($topTen['2'] as $asset){
							if(isset($asset['Asset'])){
				?>
				<tr>
					<td><?=$this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id']))?></td>
					<td><?=$asset['Asset']['name']?></td>
					<td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
					<td>
					<?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="buy_price">'.  number_format($asset['closest_price']['B'], 2, '.', ',') . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="sell_price">'. number_format($asset['closest_price']['S'], 2, '.', ',') . '</div>';
						?>
					</td>
				</tr>
				<?php 
							}else {
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>			
				<?php 		
							}			
						}
					}else {
						for ($i = 0; $i < 10; $i++){
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>
				<?php 
						}
					}
				?>
			</table>
			<br><br>			
			<table class='asset'>
				<tr>
					<th>熱門車位</th>
				<th colspan="3">更新時間（香港）: <?php  echo date('n月j日  H:i'); ?> </th>
				</tr>
				<tr>
					<td>編號</td>
					<td>商品名稱</td>
					<td>單位市價（升跌%）</td>
					<td>操作</td>
				</tr>
				<?php 
					if($topTen['4']){
						foreach ($topTen['4'] as $asset){
							if(isset($asset['Asset'])){
				?>
				<tr>
					<td><?=$this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id']))?></td>
					<td><?=$asset['Asset']['name']?></td>
					<td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
					<td>
					<?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="buy_price">'.  number_format($asset['closest_price']['B'], 2, '.', ',') . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="sell_price">'. number_format($asset['closest_price']['S'], 2, '.', ',') . '</div>';
						?>
					</td>
				</tr>
				<?php 
							}else {
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>			
				<?php 		
							}			
						}
					}else {
						for ($i = 0; $i < 10; $i++){
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>
				<?php 
						}
					}
				?>
			</table>
		</div>
		<div id='rightcolumn'>
			<table class='asset'>
				<tr>
					<th>最高跌幅</th>
					<th colspan="3">更新時間（香港）: <?php  echo date('n月j日  H:i'); ?> </th>
				</tr>
				<tr>
					<td>編號</td>
					<td>商品名稱</td>
					<td>單位市價（升跌%）</td>
					<td>操作</td>
				</tr>
				<?php 
					if($topTen['fall']){
						foreach ($topTen['fall'] as $asset){
							if(isset($asset['Asset'])){
				?>
				<tr>
					<td><?=$this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id']))?></td>
					<td><?=$asset['Asset']['name']?></td>
					<td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
					<td>
					<?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="buy_price">'.  number_format($asset['closest_price']['B'], 2, '.', ',') . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="sell_price">'. number_format($asset['closest_price']['S'], 2, '.', ',') . '</div>';
						?>
					</td>
				</tr>
				<?php 
							}else {
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>			
				<?php 		
							}			
						}
					}else {
						for ($i = 0; $i < 10; $i++){
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>
				<?php 
						}
					}
				?>
			</table>
			<?php 
				echo $this->Html->link('回到頁頂', '#',array('class' => 'right'));
			?>
			<br><br>
			<table class='asset'>
				<tr>
					<th>熱門工商</th>
					<th colspan="3">更新時間（香港）: <?php  echo date('n月j日  H:i'); ?> </th>
				</tr>
				<tr>
					<td>編號</td>
					<td>商品名稱</td>
					<td>單位市價（升跌%）</td>
					<td>操作</td>
				</tr>
				<?php 
					if($topTen['1']){
						foreach ($topTen['1'] as $asset){
							if(isset($asset['Asset'])){
				?>
				<tr>
					<td><?=$this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id']))?></td>
					<td><?=$asset['Asset']['name']?></td>
					<td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
					<td>
					<?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="buy_price">'.  number_format($asset['closest_price']['B'], 2, '.', ',') . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="sell_price">'. number_format($asset['closest_price']['S'], 2, '.', ',') . '</div>';
						?>
					</td>
				</tr>
				<?php 
							}else {
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>			
				<?php 		
							}			
						}
					}else {
						for ($i = 0; $i < 10; $i++){
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>
				<?php 
						}
					}
				?>
			</table>	
			<?php 
				echo $this->Html->link('回到頁頂', '#',array('class' => 'right'));
			?>
			<br><br>
			<table class='asset'>
				<tr>
					<th>熱門店鋪</th>
					<th colspan="3">更新時間（香港）: <?php  echo date('n月j日  H:i'); ?> </th>
				</tr>
				<tr>
					<td>編號</td>
					<td>商品名稱</td>
					<td>單位市價（升跌%）</td>
					<td>操作</td>
				</tr>
				<?php 
					if($topTen['3']){
						foreach ($topTen['3'] as $asset){
							if(isset($asset['Asset'])){
				?>
				<tr>
					<td><?=$this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id']))?></td>
					<td><?=$asset['Asset']['name']?></td>
					<td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
					<td>
					<?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="buy_price">'.  number_format($asset['closest_price']['B'], 2, '.', ',') . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="sell_price">'. number_format($asset['closest_price']['S'], 2, '.', ',') . '</div>';
						?>
					</td>
				</tr>
				<?php 
							}else {
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>			
				<?php 		
							}			
						}
					}else {
						for ($i = 0; $i < 10; $i++){
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>
				<?php 
						}
					}
				?>
			</table>
			<?php 
				echo $this->Html->link('回到頁頂', '#',array('class' => 'right'));
			?>
			<br><br>
			<table class='asset'>
				<tr>
					<th>熱門其他</th>
					<th colspan="3">更新時間（香港）: <?php  echo date('n月j日  H:i'); ?> </th>
				</tr>
				<tr>
					<td>編號</td>
					<td>商品名稱</td>
					<td>單位市價（升跌%）</td>
					<td>操作</td>
				</tr>
				<?php 
					if($topTen['5']){
						foreach ($topTen['5'] as $asset){
							if(isset($asset['Asset'])){
				?>
				<tr>
					<td><?=$this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id']))?></td>
					<td><?=$asset['Asset']['name']?></td>
					<td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
					<td>
					<?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="buy_price">'.  number_format($asset['closest_price']['B'], 2, '.', ',') . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
							//echo '<div class="sell_price">'. number_format($asset['closest_price']['S'], 2, '.', ',') . '</div>';
						?>
					</td>
				</tr>
				<?php 
							}else {
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>			
				<?php 		
							}			
						}
					}else {
						for ($i = 0; $i < 10; $i++){
				?>
				<tr>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</tr>
				<?php 
						}
					}
				?>
			</table>	
			<?php 
				echo $this->Html->link('回到頁頂', '#',array('class' => 'right'));
			?>
			<br><br>
		</div>
	</div>

<!-- 
<script>

$(document).ready(function(){
$.ajax({
    url: 'Assets/showAll',
    cache: false,
    type: 'POST',
    dataType: 'json',
    success: function (data) {
        $('#asset_index_view').html(process(data));
    }
});
});

function process(data){
	if ($.isEmptyObject(data)){
		return "<table><tr>沒有資料</tr></table>";
	}

	output = "<table>";
	//console.debug(data[0]);
	for (asset in data) {
		
		var img = false;

		switch(data[asset].Asset.status){
		case 'A': 
			data[asset].Asset.status = '未售出';
			break;
		case'IA':
			data[asset].Asset.status = '已售出';
			break;
	    }
		   
	    switch(data[asset].Asset.type){
		case '0':
			data[asset].Asset.type = '住宅';
			break;
		case '1':
			data[asset].Asset.type = '工商';
			break;
		case '2':
			data[asset].Asset.type = '商廈';
			break;
		case '3':
			data[asset].Asset.type = '店鋪';
			break;
		case '4':
			data[asset].Asset.type = '車位';
			break;
		case '5':
			data[asset].Asset.type = '其他';
			break;
	   }

	    switch(data[asset].Asset.has_rent){
		case false:
			data[asset].Asset.has_rent = '否';
			break;
		case true:
			data[asset].Asset.has_rent = '是';
			break;
	   }
			
		for (i in data[asset].AssetImg){
			if (data[asset].AssetImg[i].is_cover == 1 && !img){
				output += '<tr><td rowspan="6" width="180"><img src="' + data[asset].AssetImg[i].path +'" width="180"></td>';
				img = true;
			}
		}
		if (!img){
			output += '<tr><td rowspan="6" width="180"><img src="img/house.jpg" width="180"></td>';
		}

		
		
		output += '<th>編號:</th><td><a href="Assets/view/' + data[asset].Asset.id + '">' + data[asset].Asset.symbol + '</a></td><th>名稱:</th><td>' + data[asset].Asset.name + '</td></tr>';
		output += '<th>類型:</th><td>' + data[asset].Asset.type + '</td><th>狀態:</th><td>' + data[asset].Asset.status + '</td></tr>';
		output += '<th>地區:</th><td>' + data[asset].District.district_name + '</td><th>地址:</th><td>' + data[asset].Asset.address + '</td></tr>';
		output += '<th>面積:</th><td>' + data[asset].Asset.size + '</td><th>租金:</th><td>' + data[asset].Asset.rent + '</td></tr>';
		output += '<th>是否租出:</th><td>' + data[asset].Asset.has_rent + '</td><th>購入日期:</th><td>' + data[asset].Asset.buy_date + '</td></tr>';
		output += '<th>開售日期:</th><td>' + data[asset].Asset.open_date + '</td><th>截止日期:</th><td>' + data[asset].Asset.close_date + '</td></tr>';
		output += '<td><br><br></td>' + '<td><br><br></td>' + '<td><br><br></td>' + '<td><br><br></td>' + '<td><br><br></td>';
	}
	output += "</table>";
	
	return output;
}
</script>

<div id="asset_index_view">
	
</div>  -->
<?php
//print_r($this->Session->read('Auth.User'));