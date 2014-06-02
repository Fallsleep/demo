<?php echo $this->element('submenu', array('sub' => 'ah')); ?>
<br><br>



<div class="form-header">交易記錄</div>
<div class="form-content">

<table class = "input">
<tr><?php echo $this->Form->create('Search', array('url' => array('controller' => 'Transactions', 'action' => 'history')));?></tr>
<tr>
<td><?php echo $this->Form->input('Search', array('label' => '商品編號', 'type' => 'text', 'between' => '</td><td>'));?></td>
<td><?php echo $this->Form->input('close_time_begin', array('label' => '成交日期', 'type' => 'date', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'default' => time()-30*24*3600, 'empty' => false, 'between' => '</td><td>'));?></td>
<td><?php echo $this->Form->input('close_time_end', array('label' => '到', 'type' => 'date', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y')+20, 'value' => '', 'empty' => false, 'between' => '</td><td>'));?></td>
<td><?php echo $this->Form->button('檢索', array('type' => 'submit'));?></td>
<td><?php echo $this->Form->end;?></td> 
</tr>

</table>
<table>   
    <tr>
		<th>類型</th>
		<th>成交日期</th>
		<th>商品編號</th>
		<th>商品名稱</th>
		<th>成交量</th>		
		<th>成交價格</th>
		<th>結算金額</th>
		<th>評價</th>
	</tr>
	
	<?php 
	if (isset($transactions)&&!empty($transactions)){			
	foreach ($transactions as $transaction){
	switch($transaction['Transaction']['type']){
			case "B":
			case "S":
				
				if ($transaction['Transaction']['buy_user_id'] == $this->Session->read('Auth.User')['username']){
					$type = "買入"; 
			        $close_price = $transaction['Transaction']['close_price']?$transaction['Transaction']['close_price']:"-";
			        $settlement = $transaction['Transaction']['volume'] * $transaction['Transaction']['close_price'] + $transaction['Transaction']['service_fee'];
				}else{
					$type = "賣出"; 
		   			$close_price = $transaction['Transaction']['sell_price']?$transaction['Transaction']['sell_price']:"-";
		   			$settlement = $transaction['Transaction']['volume'] * $transaction['Transaction']['sell_price'] - $transaction['Transaction']['service_fee'];
	   			}
	   				   	
				break;
			case "D": 
				$type = "存款"; 
				$close_price = '-';
        		$settlement = $transaction['Transaction']['close_price'];
				break;
			case "W": 
				$type = "提款";
				$close_price = '-';
        		$settlement = "(" . $transaction['Transaction']['close_price'] . ")";
				break;
		}
	?>
	
	<tr>
	   <td><?php echo $type; ?></td>
	   <td><?php echo $transaction['Transaction']['close_time']?$transaction['Transaction']['close_time']:"-"; ?></td>
	   <td><?php echo $transaction['Asset']['symbol']?$this->Html->link($transaction['Asset']['symbol'], array('controller' => 'Assets', 'action' => 'view', $transaction['Asset']['id'])):"-"; ?></td>
	   <td><?php echo $transaction['Asset']['name']?$transaction['Asset']['name']:"-"; ?></td>
	   <td><?php echo $transaction['Transaction']['volume']?$transaction['Transaction']['volume']:"-"; ?></td>	   
	   <td><?php echo isset($close_price)?$close_price:"-"?></td>
	   <td><?php echo $settlement;?></td>	
	   <td><?php echo $transaction['Transaction']['comment']?$transaction['Transaction']['comment']:"-"; ?></td>
	</tr>
	
<?php 
		}
	}
?>
</table>
</div>