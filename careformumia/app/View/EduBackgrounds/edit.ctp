<!-- File: /app/View/EduBackgrounds/edit.ctp -->

<div class="form-header">編輯證書</div>
<div class="form-content">
	<?php 
	$created_by = $this->requestAction('Users/getUsername/' . $this->data["EduBackground"]['created_by']);
	echo $this->Form->create('EduBackground', array('type' => 'file')); 
	?>
	<div>
		<?php echo $this->Form->label(null, '陪月員: ' . $edu_background['Worker']['chi_name']); ?>
	</div>
	<?php
	echo $this->Form->input('award_date', array('label' => '證書頒發日期', 'dateFormat' => 'YMD', 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('award_type', array('label' => '證書頪別'));
	echo $this->Form->input('award_title', array('label' => '證書名稱'));
	echo $this->Form->input('remark', array('label' => '備註'));
	echo $this->Form->input('img', array('label' => '上載證書', 'type' => 'file'));
	echo $edu_background['EduBackground']['img']?"<a href='/careformumi_crm/".$edu_background['EduBackground']['img']."' target='_blank'>Uploaded file</a>":'-';
	echo $this->Form->input('created', array('label' => '建立時間', 'timeFormat'=>'24', 'disabled' => true));
	echo $this->Form->input('created_by', array('label' => '建立人', 'value' => $created_by, 'type' => 'text', 'disabled' => true));
	echo $this->Form->hidden('modified', array('value' => date('Y-m-d H:i:s')));
	echo $this->Form->input('modified', array('label' => '修改時間', 'selected' => date('Y-m-d H:i:s'), 'timeFormat'=>'24', 'disabled' => true));
	echo $this->Form->hidden('modified_by', array('value' => $this->Session->read('Auth.User')['id']));
	echo $this->Form->input('modified_by', array('label' => '修改人', 'value' => $this->Session->read('Auth.User')['username'], 'type' => 'text', 'disabled' => true));
	echo $this->Form->input('id', array('type' => 'hidden'));
	echo $this->Form->input('worker_id', array('type' => 'hidden'));
	echo $this->Form->button('保存編輯', array('type' => 'submit', 'name' => 'submit'));
	echo $this->Form->button('取消編輯', array('type' => 'submit', 'name' => 'cancel'));
	echo $this->Form->end();
	?>
</div>