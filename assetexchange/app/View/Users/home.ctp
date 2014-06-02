<!-- File: /app/View/Users/accounthistory.ctp -->
<?php echo $this->element('submenu', array('sub' => 'ah')); ?>
<br><br>

<div class="form-header">帳戶記錄</div>
<div class="form-content">
<table>   
    <tr>
		<th>帳戶</th>
		<td><?=$hold['userinfo']['id']?></td>
		<th>可動用資金</th>
		<td><?php echo number_format($hold['money'], 3, '.', ','); ?></td>
		<th>投資總額</th>
		<td><?php echo number_format($hold['sum'], 3, '.', ','); ?></td>
		<th>投資市值</th>
		<td><?php echo number_format($hold['total'], 3, '.', ','); ?></td>	
	</tr>	
</table>
<br><br>
<table>   
    <tr>
		<th>商品編號</th><th>商品名稱</th><th>持有股數</th><th>可動用股數</th><th>單位市價</th><th>市值</th>
		<th>平均買入價</th><th>賺/蝕</th><th></th>
	</tr>
<?php 
	foreach ($hold['UserAsset'] as $userasset) {
		if ($userasset['volume'] > 0){
			$asset_id = $userasset['asset_id'];
			$assetinfo = $hold['Assets'][$asset_id];
			$asset = $assetinfo['Asset'];
			$lastclose_price = $assetinfo['lastclose_price'];
?>
	<tr>
		<td><?php echo $this->Html->link($asset['symbol'], array('controller' => 'Assets', 'action' => 'view', $asset_id)); ?></td>
		<td><?=$asset['name']?$asset['name']:"-";?></td>
		<td><?=$userasset['volume']?$userasset['volume']:'-';?></td>
		<td><?=$assetinfo['hold_volume']?$assetinfo['hold_volume']:'-';?></td>
		<td><?=$lastclose_price?number_format($lastclose_price, 3, '.', ','):"-";?></td>
		<td><?=$lastclose_price&&$userasset['volume']?number_format($lastclose_price*$userasset['volume'], 3, '.', ','):"-";?></td>
		<td><?=$assetinfo['average_price']?number_format($assetinfo['average_price'], 3, '.', ','):"-";?></td>
		<td><?=$assetinfo['earning']?number_format($assetinfo['earning'], 3, '.', ',') .
			"(". number_format(($lastclose_price - $assetinfo['average_price'])/$assetinfo['average_price']*100, 3, '.', ',') ."%)":
			"-";
			?>
		</td>
		<td style="text-align:right;">
	    <?php
			if ($asset){
//var_dump($userasset);
				echo '<div class="buy_price">'. (($userasset['closest_price']['B'] > 0)?number_format($userasset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
				echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['id']));
				echo '<div class="sell_price">'. (($userasset['closest_price']['S'] > 0)?number_format($userasset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
			}
		?>
		</td>
	</tr>
<?php 
	}}
?>
</table>
</div>
