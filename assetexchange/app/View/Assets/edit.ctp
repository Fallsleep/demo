<!-- File: /app/View/Assets/edit.ctp -->

<?php $districts = $this->requestAction('Districts/index'); ?>
<div class="form-header">編輯資料</div>
<div class="form-content">
	<?php echo $this->Form->create('Asset', array('url' => array('controller' => 'assets', 'action' => 'edit'), 'type' => 'file')); ?>
	<table class = "input">
	<th>地產信息</th>
	<tr><td>	
	<?php echo $this->Form->input('symbol', array('label' => '編號', 'type' => 'text', 'between' => '</td><td>'));?>
	</td><td>		
	<?php echo $this->Form->input('name', array('label' => '名稱', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('type', array('label' => '類型', 'options' => array('0' => '住宅','1' => '工商' ,'2' => '商廈','3' => '店鋪','4' => '車位', '5' => '其他'), 'between' => '</td><td>'));?>
	</td><td>		
	<?php echo $this->Form->input('status', array('label' => '狀態', 'options' => array('A' => '未售出', 'IA' => '已售出'), 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('description', array('label' => '描述', 'between' => '</td><td colspan="3">'));?>
	</td></tr>
	<th>地址信息</th>	
	<tr><td>
	<?php echo $this->Form->input('address', array('label' => '地址', 'between' => '</td><td colspan="3">'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('district_id', array('label' => '地區', 'options' => array($districts), 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('location', array('label' => '位置', 'type' => 'text', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('size', array('label' => '面積', 'type' => 'text', 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('rent', array('label' => '租金', 'type' => 'text', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('has_rent', array('label' => '是否租出', 'options' => array('0'=>'是','1'=>'否'), 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('buy_date', array('label' => '購入日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true, 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('sell_date', array('label' => '售出日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y')+20, 'empty' => true, 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('open_date', array('label' => '開售日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true, 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('close_date', array('label' => '截止日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y')+20, 'empty' => true, 'between' => '</td><td>'));?>
	</td></tr>
	<th>利潤詳情</th>	
	<tr><td>
	<?php echo $this->Form->input('buy_price', array('label' => '買入價格',  'type' => 'text', 'between' => '</td><td>'));?>
    </td></tr>
	<tr><td>
    <?php echo $this->Form->input('available_share', array('label' => '已發行股份',  'type' => 'text', 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('sold_share', array('label' => '賣出股份',  'type' => 'text', 'between' => '</td><td>', 'disabled' => true));?>
	 </td></tr>
	<tr><td>
	<?php echo $this->Form->input('expected_interest', array('label' => '預估每股紅利', 'type' => 'text', 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('share_per_lot', array('label' => '每手股數',  'type' => 'text', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
    <?php echo $this->Form->input('start_price', array('label' => '開盤價格',  'type' => 'text', 'between' => '</td><td>'));?>
	</td><td>
	<?php echo $this->Form->input('spread', array('label' => '差價',  'type' => 'text', 'between' => '</td><td>'));?>
	</td></tr>
	</table>
	
	<table class = "input">
	<th>放盤圖片</th>
	<tr><td>
	<?php echo $this->Form->input('AssetImg. ', array('label' => '上載相片', 'type' => 'file', 'multiple'=>'multiple', 'between' => '</td><td>'));?>	
	</table>


<!--
	<tr><td colspan = "4">	
	<table class = "input">
    <th>其他信息</th>
	<?php echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s'), 'between' => '</td><td>'));?>
	<tr><td>
	<?php echo $this->Form->hidden('login', array('value' => $this->Session->read('Auth.User')['username'], 'between' => '</td><td>'));?>
	<tr></tr>
	</table>
 -->	
 			
	<?php echo $this->Form->button('編輯', array('type' => 'submit'));?>
	<?php echo $this->Form->button('重填', array('type' => 'reset'));?>
	<?php echo $this->Form->end();?>
	</div>