<!-- File: /app/View/Schedules/add.ctp -->

<?php echo $this->Form->create('EduBackground', array('type' => 'file'));?>
<fieldset>
	<legend>新增證書</legend>
	<?php

	echo $this->Html->div(null, $this->Form->label(null, '陪月員: ' . $workers['Worker']['chi_name']));
	echo $this->Form->input('award_date', array('label' => '證書頒發日期', 'dateFormat' => 'YMD', 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('award_type', array('label' => '證書頪別'));
	echo $this->Form->input('award_title', array('label' => '證書名稱'));
	echo $this->Form->input('remark', array('label' => '備註'));
	echo $this->Form->input('img', array('label' => '上載證書', 'type' => 'file'));
	echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s',time())));
	echo $this->Form->hidden('created_by', array('value' => $workers['Worker']['worker_no']));
	echo $this->Form->hidden('worker_id', array('value' => $workers['Worker']['id']));
	?>
</fieldset>
<?php echo $this->Form->end('新增');?>