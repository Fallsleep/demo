<!-- File: /app/View/Schedules/add.ctp -->

<?php 
echo $this->Form->create('Schedule');?>
<fieldset>
	<legend>新增日程</legend>
	<?php
	echo $this->Html->div(null, $this->Form->label(null, '陪月員: ' . $workers['Worker']['chi_name']));
	echo $this->Form->input('start_date', array('label' => '開始時間', 'dateFormat' => 'YMD', 'minYear' => date('Y'), 'maxYear' => date('Y') + 2, 'empty' => true));
	echo $this->Form->input('end_date', array('label' => '完姞時間', 'dateFormat' => 'YMD', 'minYear' => date('Y'), 'maxYear' => date('Y') + 2, 'empty' => true));
	echo $this->Form->input('status', array('label' => '狀況', 'options' => array('B' => '忙碌')));
	echo $this->Form->input('remark', array('label' => '備註'));
	echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s',time())));
	echo $this->Form->hidden('created_by', array('value' => $workers['Worker']['worker_no']));
	echo $this->Form->hidden('worker_id', array('value' => $workers['Worker']['id']));
	?>
</fieldset>
<?php echo $this->Form->end('新增');?>