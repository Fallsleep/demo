<!-- File: /app/View/Opens/index.ctp -->
<?php echo $this->element('submenu', array('sub' => 'ah')); ?>
<br><br>

<div class="form-header">交易狀況</div>
<div class="form-content">
	<table>
		<tr><th>可動用資金</th><td><?=isset($money)?number_format($money, 3):"-"?></td><th>交易所需資金</th><td><?=isset($sum)?number_format($sum, 3):"-"?></td></tr>
	</table><br><br>
	<table>	
		<tr><th rowspan="2">交易日期</th><th>交易類別</th><th>編號</th><th rowspan="2">股數</th><th rowspan="2">價格</th><th rowspan="2">狀況</th><th rowspan="2"></th></tr>
		<tr><th>(交易號碼)</th><th>名稱</th></tr>
		<?php 
		foreach ($opens as $open) { 
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
		<tr>
			<td rowspan="2" width="200"><?=date('Y年m月d日 H:i:s', strtotime($open['Open']['open_time']))?></td>
			<td><?=$type?></td>
			<td><?=$this->Html->link($open['Asset']['symbol'], array('controller' => 'Assets', 'action' => 'view', $open['Asset']['id']))?></td>
			<!--td rowspan="2"><?=$open['Open']['volume']-$open['Open']['fulfil_volume']?></td-->
			<td rowspan="2"><?=$open['Open']['volume']?></td>
			<td rowspan="2"><?=number_format($open['Open']['open_price'], 3)?></td>
			<td rowspan="2"><?=$status?></td>
			<td rowspan="2">
				<?php 
				echo $this->Html->link('詳情', 'view/' . $open['Open']['id']) . '<br>';
				echo $this->Html->link('更改', 'edit/' . $open['Open']['id']) . '<br>';
				echo $this->Form->postlink('刪除', 'delete/' . $open['Open']['id'], array('confirm' => '確認刪除交易 ' . $open['Open']['id'] . ' ?'));
				?>
			</td>
		</tr>
		<tr>
			<td><?=$open['Open']['id']?></td>
			<td><?=$open['Asset']['name']?></td>
		</tr>
		<?php } ?>
	</table>
</div>