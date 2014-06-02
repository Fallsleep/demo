<div class="form-header">分配股份
<?php //echo '分配股份'.$this->params['pass'][0];?>
</div>
<div class="form-content">

<table class = "input">
<tr><th>編號</th><th>商品名稱</th><th>已發行股份</th><th>賣出股份</th><th>可分配股數</th><th>開盤價格</th></tr>
<tr>
<td><?php echo $asset['Asset']['symbol'];?></td>
<td><?php echo $asset['Asset']['name'];?></td>
<td><?php echo $asset['Asset']['available_share']?$asset['Asset']['available_share']:"-";?></td>
<td><?php echo $asset['Asset']['sold_share']?$asset['Asset']['sold_share']:"-";?></td>
<td><?php echo $asset['Asset']['available_share']&&$asset['Asset']['sold_share']?$asset['Asset']['available_share']-$asset['Asset']['sold_share']:"-";?></td>
<td><?php echo $asset['Asset']['start_price'];?></td>
</tr>
<?php echo $this->Form->create('Assign', array('url' => array('controller' => 'UserAssets', 'action' => 'assign', $this->params['pass'][0])));?>
<tr></tr>
<tr><td colspan="6"><?php echo $this->Form->hidden('asset_id', array('value'=>$asset['Asset']['id']));?></td></tr>
<tr>
<td><?php echo $this->Form->input('user',array('label' => '用户', 'type' => 'select', 'options' => $users, 'between' => '</td><td>'));?></td>
<td colspan="4">
</tr>
<tr>
<td><?php echo $this->Form->input('volume',array('label' => '股數', 'type' => 'number', 'value' => $asset['Asset']['available_share'] - $asset['Asset']['sold_share'], 'between' => '</td><td>'));?></td>
<td colspan="4">
</tr>
<tr>
<td><?php echo $this->Form->input('price',array('label' => '價格', 'type' => 'text', 'value' => $asset['Asset']['start_price'], 'between' => '</td><td>'));?></td>
<td colspan="4">
</tr>
</table>
<?php echo $this->Form->button('分配', array('type' => 'submit'));?>
<?php 
echo $this->Form->button('返回', array('type' => 'button', 'onclick' =>"location.href='".Router::url(array('controller' => 'assets','action' => 'view')).'/'.$asset['Asset']['id']."'"));?>
<?php echo $this->Form->end();?>
</div>