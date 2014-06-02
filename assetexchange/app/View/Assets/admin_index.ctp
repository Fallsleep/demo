<!-- File: /app/View/Assets/index.ctp -->
<!-- 
<table>
<tr>
<td><?php echo $this->Html->link('Assets', array('controller' => 'assets', 'action' => 'admin_index'));	?></td>
<td><?php echo $this->Html->link('Users', array('controller' => 'users', 'action' => 'admin_index')); ?></td>
<td><?php echo 'Reports';?></td>
</tr>
</table> -->
<?php echo $this->element('submenu', array('sub' => 'admin')); ?>
<br><br>
<table>
    <tr>
        <th>編號</th>
        <th>名稱</th>
        <th>類型</th>
        <th>狀態</th>
        <th>地區</th>
        <th>面積</th>
        <th>租價</th>
        <th>是否租出</th>
        <th>購入日期</th>
        <th>開售日期</th>
        <th>截止日期</th>
        <th></th>
    </tr>
 <!-- Here is where we loop through our $assets array, printing out worker info -->
 
 <?php 
	foreach ($assets as $asset):
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
        <td><?php echo $this->Html->link($asset['Asset']['symbol'], array('action' => 'view', $asset['Asset']['id'])); ?></td>
        <td><?php echo $asset['Asset']['name']; ?></td>
        <td><?php echo $type; ?></td>
        <td><?php echo $status; ?></td>
        <td><?php echo $asset['District']['district_name']; ?></td>
        <td><?php echo $asset['Asset']['size']?$asset['Asset']['size']:"-"; ?></td>
        <td><?php echo $asset['Asset']['rent']?number_format($asset['Asset']['rent'], 3, '.', ','):"-"; ?></td>
        <td><?php echo $asset['Asset']['has_rent']?"是":"否"; ?></td>
        <td><?php echo $asset['Asset']['buy_date']?$asset['Asset']['buy_date']:"-"; ?></td>
        <td><?php echo $asset['Asset']['open_date']?$asset['Asset']['open_date']:"-"; ?></td>
        <td><?php echo $asset['Asset']['close_date']?$asset['Asset']['close_date']:"-"; ?></td>
        <td><?php 
			if(isset($asset['Asset']['available_share']) && isset($asset['Asset']['sold_share']) &&
			$asset['Asset']['available_share'] > $asset['Asset']['sold_share'])
				echo $this->Html->link('分配', array('controller' => 'UserAssets', 'action' => 'assign', $asset['Asset']['id']));
		?></td>
</tr>
<?php endforeach; ?> 
</table>

<?php echo $this->element('add_asset'); ?>
