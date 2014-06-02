<!-- File: /app/View/Elements/add_worker.ctp -->

<div class="expand" id="new-worker"><span class="sign">+</span> 新增陪月員</div>
<div class="expandable" id="new-worker-content">
	<?php echo $this->Form->create('Worker', array('url' => array('controller' => 'workers', 'action' => 'add'))); ?> 
<table class = "input">
	<th>個人信息</th>
	<tr><td>
	<?php echo $this->Form->input('worker_no', array('label' => '陪月員編號', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('chi_name', array('label' => '中文姓名', 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('eng_first_name', array('label' => '英文名字', 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('eng_last_name', array('label' => '英文姓氏', 'between' => '</td><td>'));?>
	</td></tr>
	<th>聯繫方式</th>
	<tr><td>		
	<?php echo $this->Form->input('mobile', array('label' => '手提電話', 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('contact_other', array('label' => '其他電話', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('address', array('label' => '地址', 'between' => '</td><td>'));?>
	</td></tr>
	<th>其他信息</th>	
	<tr><td>
	<?php echo $this->Form->input('date_of_birth', array('label' => '出生日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true, 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('mariage_status', array('label' => '婚姻狀況', 'options' => array('S' => '單身', 'M' => '已婚', 'D' => '離婚', 'W' => '喪偶'), 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('bank_name', array('label' => '戶口銀行', 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('bank_account', array('label' => '戶口號碼', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('comments', array('label' => '評語', 'row' => '3', 'between' => '</td><td colspan = "2">'));?>
	</td></tr>	
	<tr><td colspan = "5">
	<table class = "language">
	<th>語言能力</th>
	<tr><td>	
	<?php echo $this->Form->input('cantonese', array('label' => '廣東話', 'options' => array('0' =>'不懂', '1' => '一般', '2' => '流利'), 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('mandarin', array('label' => '普通話', 'options' => array('0' =>'不懂', '1' => '一般', '2' => '流利'), 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('english', array('label' => '英語', 'options' => array('0' =>'不懂', '1' => '一般', '2' => '流利'), 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('japanese', array('label' => '日語', 'options' => array('0' =>'不懂', '1' => '一般', '2' => '流利'), 'between' => '</td><td>'));?>
	</td></tr>
	</table>
	</td></tr>
	<tr><td colspan = "6">
	<table class = "checkbox">
	<th>客戶需求</th>
	<tr><td>	
	<?php echo $this->Form->input('accept_twins', array('label' => '接受雙胞胎?','type' =>'checkbox'));?>
	</td></tr>
	<tr><td>
	<?php echo $this->Form->input('accept8', array('label' => '接受8小時?','type' =>'checkbox'));?>
	</td><td>	
	<?php echo $this->Form->input('wage8', array('label' => '8小時月薪', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('accept10', array('label' => '接受10小時?','type' =>'checkbox'));?>
	</td><td>	
	<?php echo $this->Form->input('wage10', array('label' => '10小時月薪', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('accept12', array('label' => '接受12小時?','type' =>'checkbox'));?>
	</td><td>	
	<?php echo $this->Form->input('wage12', array('label' => '12小時月薪', 'between' => '</td><td>'));?>
	</td></tr>
	<tr><td>	
	<?php echo $this->Form->input('accept24', array('label' => '接受24小時?','type' =>'checkbox'));?>
	</td><td>
	<?php echo $this->Form->input('wage24', array('label' => '24小時月薪', 'between' => '</td><td>'));?>
	</td></tr>
	</table>
	</td></tr>
	<tr><td colspan = "3">
	<table class = "input">
	<tr><td>	
	<?php echo $this->Form->input('year_exp', array('label' => '年資', 'min' => '0', 'between' => '</td><td>'));?>
	</td><td>	
	<?php echo $this->Form->input('status', array('label' => '狀況', 'options' => array('A' => '活躍', 'IA' => '不活躍'), 'between' => '</td><td>'));?>
	</td></tr>
	</table>
	</td></tr>
	<tr><td colspan = "3">
	<table class = "input">
	<tr><td>
	<?php echo $this->Form->input('img', array('label' => '上載相片', 'type' => 'file', 'between' => '</td><td colspan = "3">'));?>
	</td></tr>
	<?php echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s'), 'between' => '</td><td>'));?>
	<tr><td>
	<?php echo $this->Form->input('created', array('label' => '建立時間', 'selected' => date('Y-m-d H:i:s'), 'timeFormat'=>'24', 'disabled' => true, 'between' => '</td><td>'));?>
	</td></tr>
	<?php echo $this->Form->hidden('created_by', array('value' => $this->Session->read('Auth.User')['id'], 'between' => '</td><td>'));?>
	<tr><td>
	<?php echo $this->Form->input('created_by', array('label' => '建立人', 'value' => $this->Session->read('Auth.User')['username'], 'type' => 'text', 'disabled' => true, 'between' => '</td><td>'));?>
	</td></tr>
	</table>
	</td></tr>
	</table>
	<?php echo $this->Form->button('新增', array('type' => 'submit'));?>
	<?php echo $this->Form->button('重填', array('type' => 'reset'));?>
	<?php echo $this->Form->end();?>
	</div>
