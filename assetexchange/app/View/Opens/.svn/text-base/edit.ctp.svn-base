<!-- File: /app/View/Opens/edit.ctp -->

<?php 
$transactions = $this->requestAction('Transactions/getTransactions/' . $open['Open']['id'] . '/' . $open['Open']['type']);
switch ($open['Open']['type']) {
	case 'B': $type = '買入'; break;
	case 'S': $type = '賣出'; break;
	default: $type = '-';
}
switch ($open['Open']['status']) {
	case 'A': $status = '有待執行'; break;
	default: $status = '-';
}
?>

<style type="text/css"> 
.input { 
	display: inline-block;
	margin-bottom: -20px;
} 
.input input { 
	position: relative;
	top: -10px; 
} 
</style> 

<div class="form-header">更改交易指示</div>
<?php 
$this->request->data = Sanitize::clean($this->request->data);

if ($this->request->is('post') && !empty($this->request->data) && $valid) {
	echo $this->Form->create('Open', array('url' => array('controller' => 'opens', 'action' => 'edit', $open['Open']['id']))); 
	echo $this->Form->hidden('remain_volume', array('value' => $this->request->data['Open']['remain_volume']));
	echo $this->Form->hidden('open_price', array('value' => $this->request->data['Open']['open_price']));
?>

	<table>
		<tr><th colspan="2">核實指示</th></tr>
		<tr><td>指示:</td><td>更改交易指示</td></tr>
		<tr><td>交易類別:</td><td><?=$type?></td></tr>
		<tr><td>商品編號:</td><td><?=$this->Html->link($open['Asset']['symbol'], array('controller' => 'Assets', 'action' => 'view', $open['Asset']['id']))?></td></tr>
		<tr><td>商品名稱:</td><td><?=$open['Asset']['name']?></td></tr>
		<tr><td>每手數量:</td><td><?=$open['Asset']['share_per_lot']?> 股</td></tr>
		<tr><td>價格:</td><td><?=number_format($this->request->data['Open']['open_price'], 3)?></td></tr>
		<tr><td>數量:</td><td><?=$this->request->data['Open']['remain_volume']?> 股</td></tr>
	</table>
	<?php 
		echo $this->Form->hidden('action', array('value' => 'confirm'));
		echo $this->Form->button('確認', array('type' => 'submit'));
		echo $this->Form->end();
	?>

<?php } else { ?>
<div style="margin: 5px 0 -15px;">交易號碼: <?=$open['Open']['id']?></div>	
<div id="leftcolumn">	
	<table>
		<tr><th>交易詳情</th></tr>
		<tr>
			<td colspan="2">
				交易類別: <?=$type?><br>
				商品編號: <?=$this->Html->link($open['Asset']['symbol'], array('controller' => 'Assets', 'action' => 'view', $open['Asset']['id']))?><br>
				商品名稱: <?=$open['Asset']['name']?><br>
				每手數量: <?=$open['Asset']['share_per_lot']?> 股<br>
				商品市價: <?=$this->requestAction(array(
		        		'controller' => 'Assets',
		        		'action' => 'getLastestPrice',
		        		$open['Asset']['id']
		        	))?><br>
				狀況: <?=$status?><br>
			</td>
		</tr>
	</table>
	<table>
		<tr><th colspan="3">成交詳情</th></tr>
		<tr><td><b>成交量(股)</b></td><td><b>成交價</b></td><td><b>備註</b></td></tr>
		<?php 
		$total_volume = 0;
		foreach ($transactions as $transaction) {
			$total_volume += $transaction['Transaction']['volume'];
		?>
		<tr>
			<td><?=$transaction['Transaction']['volume']?></td>
			<td><?=number_format(($open['Open']['type'])=='B'?$transaction['Transaction']['close_price']:$transaction['Transaction']['sell_price'], 3)?></td>
			<td><?=$transaction['Transaction']['comment']?$transaction['Transaction']['comment']:'-'?></td></tr>
		<?php } ?>
	</table>
	<table>
		<tr><td>總成交量:</td><td style="text-align: right;"><?=$total_volume?> 股</td></tr>
	</table>
	<table>
		<tr><td>餘下數量:</td><td><?=$open['Open']['volume']-$open['Open']['fulfil_volume']?> 股</td></tr>
		<tr><td>狀況:</td><td><?=$status?></td></tr>
	</table>
</div>
<div id="rightcolumn">
	<?php echo $this->Form->create('Open', array('url' => array('controller' => 'opens', 'action' => 'edit', $open['Open']['id']))); ?>
	<table>
		<tr><th>原有指示</th><th>新指示</th></tr>
		<tr>
			<td>餘下數量: <?=$open['Open']['volume']-$open['Open']['fulfil_volume']?> 股</td>
			<td>餘下數量: <?php echo $this->Form->input('remain_volume', array('label' => false, 'type' => 'text', 'value' => $open['Open']['volume']-$open['Open']['fulfil_volume'])); ?></td>
		</tr>
		<tr>
			<td>價格: <?=number_format($open['Open']['open_price'], 3)?></td>
			<td>價格: <?php 
				echo $this->Form->input('open_price', array('label' => false, 'type' => 'text', 'value' => number_format($open['Open']['open_price'], 3))); 
				?></td>
		</tr>
		<tr>
			<td><?php echo $this->Html->link('<', 'index')?></td>
			<td style="text-align: right;">
				<?php 
				echo $this->Form->hidden('action', array('value' => 'submit'));
				echo $this->Form->end(array('label' => '去', 'div' => false)); 
				?>
			</td>
		</tr>
	</table>
	<table>
		<tr><th colspan="2">參考資訊</th></tr>
		<tr><td>賣出/買入價</td><td><?=$closest_price['B'] . '/' . $closest_price['S']?></td></tr>
		<tr><td>可動用資金</td><td><?=number_format($user_balance, 3)?></td></tr>
		<tr><td>持有股數</td><td><?=!empty($user_asset)?$volume:'-'?></td></tr>
		<tr><td>可動用股數</td><td><?=!empty($user_asset)?$avail_volume:'-'?></td></tr>
		<tr><td>市值</td><td><?=!empty($user_asset)?$market_cap:'-'?></td></tr>
		<tr><td>平均買入價</td><td><?=!empty($user_asset)?number_format($user_asset['UserAsset']['average_price'], 3):'-'?></td></tr>
		<tr>
			<td>賺/蝕</td>
			<td>
				<?=!empty($user_asset)?number_format(($last-$user_asset['UserAsset']['average_price'])*$user_asset['UserAsset']['volume'], 3):'-'?>
				(<?=!empty($user_asset)?number_format(($last-$user_asset['UserAsset']['average_price'])/$user_asset['UserAsset']['average_price']*100, 3):'-'?>%)
			</td>
		</tr>
	</table>
</div>
<?php } ?>