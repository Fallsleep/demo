<!-- File: /app/View/Schedules/edit.ctp -->

<div class="edit-header">編輯日程</div>
<div class="edit-content">
	<?php 
	$created_by = $this->requestAction('Users/getUsername/' . $this->data["Schedule"]['created_by']);
	echo $this->Form->create('Schedule'); 	
	?>
	<div>
		<?php echo $this->Form->label(null, '陪月員: ' . $schedule['Worker']['chi_name']); ?>
	</div>
	<?php
	echo $this->Form->input('start_date', array('label' => '開始時間', 'dateFormat' => 'YMD', 'minYear' => date('Y'), 'maxYear' => date('Y') + 2, 'empty' => true));
	echo $this->Form->input('end_date', array('label' => '完姞時間', 'dateFormat' => 'YMD', 'minYear' => date('Y'), 'maxYear' => date('Y') + 2, 'empty' => true));
	echo $this->Form->input('status', array('label' => '狀況', 'options' => array('B' => '忙碌')));
	echo $this->Form->input('remark', array('label' => '備註'));
	echo $this->Form->input('created', array('label' => '建立時間', 'timeFormat'=>'24', 'disabled' => true));
	echo $this->Form->input('created_by', array('label' => '建立人', 'value' => $created_by, 'type' => 'text', 'disabled' => true));
	echo $this->Form->hidden('modified', array('value' => date('Y-m-d H:i:s')));
	echo $this->Form->input('modified', array('label' => '修改時間', 'selected' => date('Y-m-d H:i:s'), 'timeFormat'=>'24', 'disabled' => true));
	echo $this->Form->hidden('modified_by', array('value' => $this->Session->read('Auth.User')['id']));
	echo $this->Form->input('modified_by', array('label' => '修改人', 'value' => $this->Session->read('Auth.User')['username'], 'type' => 'text', 'disabled' => true));
	echo $this->Form->input('id', array('type' => 'hidden'));
	echo $this->Form->button('保存編輯', array('type' => 'submit', 'name' => 'submit'));
	echo $this->Form->button('取消編輯', array('type' => 'submit', 'name' => 'cancel'));
	echo $this->Form->end(); 
	?>
</div>