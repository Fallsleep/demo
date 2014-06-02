<div class="form-header">帳戶信息</div>
<div class="form-content">
<table>   
    <tr>
		<th>帳戶</th>
		<th>餘額</th>
		<th>投資總額</th>
		<th>賺/蝕</th>
		<th>操作</th>
	</tr>

	<tr>
		<td><?=$hold['userinfo']['id']?></td>
		<td><?=$this->requestAction('Users/doFormatNumber/'.$hold['userinfo']['balance'])?></td>	
		<td><?=$this->requestAction('Users/doFormatNumber/'.$hold['total'])?></td>	
		<td><?=$lastclose_price && $userasset['volume'] && $assetinfo['average_price']?
			$this->requestAction('Users/doFormatNumber/'.($lastclose_price - $assetinfo['average_price']) * $userasset['volume']).
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
</table>
</div>
