<!-- File: /app/View/Elements/add_schedule.ctp -->

<?php 
$url = explode("/", $_SERVER['REQUEST_URI']);
$url = explode("?",  end($url));
$worker = $this->requestAction('Schedules/add/' . $url[0]);
?>

<div class="expand" id="new-schedule"><span class="sign">+</span> 新增日程</div>
<div class="expandable" id="new-schedule-content">
	<?php
	echo $this->Form->create('Schedule', array('url' => array('controller' => 'schedules', 'action' => 'add', $url[0])));
	echo $this->Form->input('start_date', array('label' => '開始時間', 'dateFormat' => 'YMD', 'minYear' => date('Y'), 'maxYear' => date('Y') + 2, 'empty' => true));
	echo $this->Form->input('end_date', array('label' => '完姞時間', 'dateFormat' => 'YMD', 'minYear' => date('Y'), 'maxYear' => date('Y') + 2, 'empty' => true));
	echo $this->Form->input('status', array('label' => '狀況', 'options' => array('B' => '忙碌')));
	echo $this->Form->input('remark', array('label' => '備註'));
	echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s')));
	echo $this->Form->input('created', array('label' => '建立時間', 'selected' => date('Y-m-d H:i:s'), 'timeFormat'=>'24', 'disabled' => true));
	echo $this->Form->hidden('created_by', array('value' => $this->Session->read('Auth.User')['id']));
	echo $this->Form->input('created_by', array('label' => '建立人', 'value' => $this->Session->read('Auth.User')['username'], 'type' => 'text', 'disabled' => true));
	echo $this->Form->hidden('worker_id', array('value' => $worker['id']));
	echo $this->Form->button('新增', array('type' => 'submit'));
	echo $this->Form->button('重新填寫', array('type' => 'reset'));
	echo $this->Form->end();
	?>
</div>