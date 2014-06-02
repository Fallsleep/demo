<?php
	if(isset($assets_result)){
?>
<table>

<tr>
		<th>照片</th>
		<th>編號</th>
		<th>名稱</th>
		<th>類型</th>
		<th>狀態</th>
		<th>地區</th>
		<th>面積</th>
		<th>租價</th>
		<th>開售日期</th>
		<th>截止日期</th>
		<th>單位市價（升跌%）</th>
		<th>操作</th>
		
		
</tr>

 <?php 
 
	    if (empty($assets_result)){
		 	echo('沒有相關檢索結果！');
	    }else{
			foreach ($assets_result as $asset):
			switch($asset['Asset']['type']){
					case "0": $type = "住宅"; break;
					case "1": $type = "工商"; break;
					case "2": $type = "商廈"; break;
					case "3": $type = "店鋪"; break;
					case "4": $type = "車位"; break;
					case "5": $type = "其他"; break;
				}
					
			switch($asset['Asset']['status']){
					case "A": $status = "未售出"; break;
					case "IA": $status = "已售出"; break;
				}
			switch($asset['Asset']['service_fee_type']){
			        case "H": $service_fee_type = "按每次交易收取"; break;
					case "R": $service_fee_type = "按每手交易收取"; break;
					case "U": $service_fee_type = "按交易金額比例"; break;
				}
	
			
			//var_dump($asset);
?> 

<tr>
	   <td>
			<?php
				$path = $asset['AssetImg']['path'];
				if($path!==null){
			?>
			<img src="<?php echo '../' . $path; ?>" alt="" height=48px width=60px/>
			<?php 
				}
			?> 
   		<td><?php echo $this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id'])); ?></td>
   		<td><?php echo $asset['Asset']['name']; ?></td>		
        <td><?php echo $type; ?></td>
        <td><?php echo $status; ?></td>
        <td><?php echo $asset['District']['district_name']; ?></td>
        <td><?php echo $asset['Asset']['size']?$asset['Asset']['size']:"-"; ?></td>        
        <td><?php echo $asset['Asset']['rent']?number_format($asset['Asset']['rent'], 3, '.', ','):"-"; ?></td>       
        <td><?php echo $asset['Asset']['open_date']?$asset['Asset']['open_date']:"-"; ?></td>
        <td><?php echo $asset['Asset']['close_date']?$asset['Asset']['close_date']:"-"; ?></td>
        <td><?=($asset['close_price']!==null)?
						number_format($asset['close_price'], 2, '.', ',').' '.
						(
							'('.((isset($asset['change_per']) && $asset['change_per'] != 0)?('<span class="'.(($asset['change_per']>0)?'rise':'fall').'">'.
								number_format(abs($asset['change_per']), 3).'%</span>'
							):'0.00%').')'
						)
						:'-'?></td>
        <td><?php
							echo '<div class="buy_price">'. (($asset['closest_price']['B'] > 0)?number_format($asset['closest_price']['B'], 2, '.', ','):"---") . '</div>';
							echo $this->Html->link('買賣', array('controller' => 'opens', 'action' => 'trade', $asset['Asset']['id']));
							echo '<div class="sell_price">'. (($asset['closest_price']['S'] > 0)?number_format($asset['closest_price']['S'], 2, '.', ','):"---") . '</div>';
						?></td>
</tr>
<tr></tr>
<?php 
			endforeach; 
	    }
?> 
</table>
<?php
	}
?>


<div class="expand" id="search-asset"><span class="sign">+</span> 檢索物業</div>
	<div class="expandable" id="search-asset-content">
	<?php echo $this->Form->create('Asset', array('url' => array('controller' => 'assets', 'action' => 'search'), 'type' => 'file')); ?>
	<table class = "input">
	<th>地產信息</th>
	<tr><td>	
	<?php echo $this->Form->input('symbol', array('label' => '編號', 'type' => 'text', 'required' => false, 'between' => '</td><td>'));?>
	</td><td>		
	<?php echo $this->Form->input('name', array('label' => '名稱', 'required' => false, 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('type', array('label' => '類型', 'options' => array('unlimited' => '不限','0' => '住宅','1' => '工商' ,'2' => '商廈','3' => '店鋪','4' => '車位', '5' => '其他'), 'required' => false, 'between' => '</td><td>'));?>
	</td><td>		
	<?php echo $this->Form->input('status', array('label' => '狀態', 'options' => array('unlimited' => '不限','A' => '未售出', 'IA' => '已售出'), 'required' => false, 'between' => '</td><td>'));?>
	</td></tr>
	<th>地址信息</th>	
	<tr><td>	
	<?php echo $this->Form->input('district_id', array('label' => '地區', 'options' => array('unlimited' => '不限', $districts), 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('location', array('label' => '位置', 'type' => 'text', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('size', array('label' => '面積', 'type' => 'text', 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('rent', array('label' => '租金', 'type' => 'text', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('has_rent', array('label' => '是否租出', 'options' => array('unlimited' => '不限','0'=>'是','1'=>'否'), 'between' => '</td><td>'));?>
	</td></tr>
	</table>
	<?php echo $this->Form->button('檢索', array('type' => 'submit'));?>
	<?php echo $this->Form->button('重填', array('type' => 'reset'));?>
	<?php echo $this->Form->end();?>
	</div>
