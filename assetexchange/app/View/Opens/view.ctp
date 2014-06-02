<!-- File: /app/View/Opens/view.ctp -->

<?php 
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

<div class="form-header">交易狀況</div>
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
				數量: <?=$open['Open']['volume']?> 股<br>
				價格: <?=number_format($open['Open']['open_price'], 3)?><br>
				交易日期: <?=date('Y年m月d日', strtotime($open['Open']['open_time']))?><br>
				狀況: <?=$status?><br>
			</td>
		</tr>
		<tr>
			<td><?php echo $this->Html->link('<', 'index')?></td>
			<td style="text-align: right;">
				<?php 
				echo $this->Html->link('更改', 'edit/' . $open['Open']['id']) . ' ';
				echo $this->Form->postlink('刪除', 'delete/' . $open['Open']['id'], array('confirm' => '確認刪除交易 ' . $open['Open']['id'] . ' ?'));
				?>
			</td>
		</tr>
	</table>
</div>
<div id="rightcolumn">
	<table>
		<tr><td>餘下數量:</td><td><?=$open['Open']['volume']-$open['Open']['fulfil_volume']?> 股</td></tr>
		<tr><td>狀況:</td><td><?=$status?></td></tr>
	</table>
</div>