<!-- File: /app/View/Users/accounthistory.ctp -->

<div class="form-header">帳戶記錄</div>
<div class="form-content">
<table>   
    <tr>
		<th>帳戶</th>
		<td colspan="8"><?=$hold['userinfo']['id']?></td>
		<th>餘額</th>
		<td colspan="8"><?=$this->requestAction('Users/doFormatNumber/'.$hold['userinfo']['balance'])?></td>	
		<th>投資總額</th>
		<td colspan="8"><?=$this->requestAction('Users/doFormatNumber/'.$hold['total'])?></td>	
	</tr>	
</table>
<br><br>
<table>   
    <tr>
		<th>商品編號</th><th>商品名稱</th><th>股數</th><th>單位市價</th><th>市值</th>
		<th>平均買入價</th><th>賺/蝕</th><th></th>
	</tr>
<?php 
	foreach ($hold['UserAsset'] as $userasset) {
		$asset_id = $userasset['asset_id'];
		$assetinfo = $hold['Assets'][$asset_id];
		$asset = $assetinfo['Asset'];
		$lastclose_price = $assetinfo['lastclose_price'];
?>
	<tr>
		<td><?php echo $this->Html->link($asset['symbol'], array('controller' => 'Assets', 'action' => 'view', $asset_id)); ?></td>
		<td><?=$asset['name']?$asset['name']:"-";?></td>
		<td><?=$userasset['volume']?$userasset['volume']:'-';?></td>
		<td><?=$lastclose_price?$this->requestAction('Users/doFormatNumber/'.$lastclose_price):"-";?></td>
		<td><?=$lastclose_price&&$userasset['volume']?$this->requestAction('Users/doFormatNumber/'.$lastclose_price*$userasset['volume']):"-";?></td>
		<td><?=$assetinfo['average_price']?$this->requestAction('Users/doFormatNumber/'.$assetinfo['average_price']):"-";?></td>
		<td><?=$assetinfo['earning']?$this->requestAction('Users/doFormatNumber/'.$assetinfo['earning']).
			"(". $this->requestAction('Users/doFormatNumber/'.($lastclose_price - $assetinfo['average_price'])/$assetinfo['average_price']*100) ."%)":
			"-";
			?>
		</td>
		<td style="text-align:right;">
	    <?php
			if ($asset){
				echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['id']));
			}
		?>
		</td>
	</tr>
<?php 
	}
?>
</table>
</div>
