<!-- File: /app/View/Opens/trade.ctp -->

<style>
#trade-ref { float: right; width: 29%; }
#trade-form { float: left; width: 70%; }
</style>

<div id="trade-ref">
	<div class="form-header">參考資訊</div>
	<div class="form-content">
		<table>
			<tr><th>可動用資金</th><td><?=number_format($user_balance, 3)?></td></tr>
			<tr><th>持有股數</th><td><?=!empty($user_asset)?$volume:'-'?></td></tr>
			<tr><th>可動用股數</th><td><?=!empty($user_asset)?$avail_volume:'-'?></td></tr>
			<tr><th>市值</th><td><?=!empty($user_asset)?$market_cap:'-'?></td></tr>
			<tr><th>平均買入價</th><td><?=!empty($user_asset)?number_format($user_asset['UserAsset']['average_price'], 3):'-'?></td></tr>
			<tr>
				<th>賺/蝕</th>
				<td>
					<?=!empty($user_asset)?number_format(($last-$user_asset['UserAsset']['average_price'])*$user_asset['UserAsset']['volume'], 3):'-'?>
					(<?=!empty($user_asset)?number_format(($last-$user_asset['UserAsset']['average_price'])/$user_asset['UserAsset']['average_price']*100, 3):'-'?>%)
				</td>
			</tr>
		</table>
	</div>
</div>

<div id="trade-form">
	<div class="form-header">買入賣出</div>
	<div class="form-content">
		<?php 
		echo $this->Form->create('Open', array('url' => array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']))); 
		
		$this->request->data = Sanitize::clean($this->request->data);
		
		if ($this->request->is('post') && !empty($this->request->data) && $valid) {
			echo $this->Form->hidden('asset_id', array('value' => $asset['Asset']['id']));
			echo $this->Form->hidden('type', array('value' => $this->request->data['Open']['type']));
			echo $this->Form->hidden('volume', array('value' => $this->request->data['Open']['volume']));
			echo $this->Form->hidden('open_price', array('value' => $this->request->data['Open']['open_price']));
			echo $this->Form->hidden('comment', array('value' => $this->request->data['Open']['comment']));
			switch ($this->request->data['Open']['type']) {
				case 'B': $type = '買入'; break; 
				case 'S': $type = '賣出'; break;
				default: $type = '-';
			}
		?>
		<table>
			<tr><th colspan="2">核實指示</th></tr>
			<tr><td width="100">指示:</td><td><?=$type?>商品</td></tr>
			<tr><td>商品編號:</td><td><?=$asset['Asset']['symbol']?></td></tr>
			<tr><td>商品名稱:</td><td><?=$asset['Asset']['name']?></td></tr>
			<!--tr><td>每手數量:</td><td><?=$asset['Asset']['share_per_lot']?> 股</td></tr-->
			<tr><td>價格:</td><td><?=number_format($this->request->data['Open']['open_price'], 3)?></td></tr>
			<tr><td>數量:</td><td><?=$this->request->data['Open']['volume']?> 股</td></tr>
			<tr><td>注釋:</td><td><?=$this->request->data['Open']['comment']?$this->request->data['Open']['comment']:'-'?></td></tr>
		</table>
		<?php 
			echo $this->Form->hidden('action', array('value' => 'confirm'));
			echo $this->Form->button('確認', array('type' => 'submit'));
			echo $this->Form->end();
		} else { 
		?>	
		<?php //echo $this->Form->hidden('user_id', array('label' => '客戶編號', 'type' => 'text'));?>
		<table class = "input">
			<tr>
				<td><?php echo $this->Form->input('type', array('legend' => '指示', 'type' => 'radio', 'options' => array('B' =>'買入', 'S' => '賣出'), 'between' => '</td><td>'));?></td>
				<td colspan="2"><?php echo $this->Form->hidden('asset_id', array('value' => $asset['Asset']['id'], 'between' => '</td><td>'));?></td>
			</tr>
			<tr>
				<td><?php echo $this->Form->input('symbol', array('label' => '商品編號', 'type' => 'text', 'disabled' => true, 'value' => $asset['Asset']['symbol'], 'between' => '</td><td>'));?></td>
				<td><?php echo $this->Form->input('asset_name', array('label' => '商品名稱', 'disabled' => true, 'value' => $asset['Asset']['name'], 'between' => '</td><td>'));?></td>
			</tr>
			<tr>
				<td><?php echo $this->Form->input('volume', array('label' => '股數', 'type' => 'text', 'between' => '</td><td>'));?></td>
				<!--td><?php echo $this->Form->input('sharelot', array('label' => '每手股數', 'type' => 'text', 'disabled' => true, 'value' => $asset['Asset']['share_per_lot'], 'between' => '</td><td>'));?></td-->
				<td><?php echo $this->Form->input('cur_price', array('label' => '最新成交價', 'type' => 'text', 'disabled' => true, 'value' => number_format($last, 3), 'between' => '</td><td>'));?></td>
			</tr>
			<tr>
				<td><?php echo $this->Form->input('open_price', array('label' => '價格', 'type' => 'text', 'between' => '</td><td>'));?></td>
				<td><?php echo $this->Form->input('closest_price', array(
																		'label' => '賣出/買入價', 
																		'type' => 'text', 
																		'disabled' => true, 
																		'value' => $closest_price['B'] . '/' . $closest_price['S'], 
																		'between' => '</td><td>'
																	));?></td>
			</tr>
			<tr>
				<td><?php echo $this->Form->input('comment', array('label' => '注釋', 'type' => 'text', 'between' => '</td><td colspan="3">'));?></td>
			</tr>
		</table>
		<?php 
			echo $this->Form->hidden('action', array('value' => 'submit'));
			echo $this->Form->button('提交', array('type' => 'submit'));
			echo $this->Form->button('重填', array('type' => 'reset'));
			echo $this->Form->end();
		}?>
	</div>
</div>