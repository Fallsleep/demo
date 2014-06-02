<!-- File: /app/View/Elements/add_edu_background.ctp -->

<?php 
$url = explode("/", $_SERVER['REQUEST_URI']);
$url = explode("?",  end($url));
$workers = $this->requestAction('EduBackgrounds/add/' . $url[0]);
?>

<div class="expand" id="new-edu"><span class="sign">+</span> 新增證書</div>
<div class="expandable" id="new-edu-content">
	<?php
	echo $this->Form->create('EduBackground', array('url' => array('controller' => 'edu_backgrounds', 'action' => 'add', $url[0]), 'type' => 'file'));
	echo $this->Form->input('award_date', array('label' => '證書頒發日期', 'dateFormat' => 'YMD', 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('award_type', array('label' => '證書類別'));
	echo $this->Form->input('award_title', array('label' => '證書名稱'));
	echo $this->Form->input('remark', array('label' => '備註'));
	echo $this->Form->input('img', array('label' => '上載證書', 'type' => 'file'));
	//echo $edu_background['img']?"<a href='/careformumi_crm/".$edu_background['img']."' target='_blank'>link</a>":'';
	echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s')));
	echo $this->Form->input('created', array('label' => '建立時間', 'selected' => date('Y-m-d H:i:s'), 'timeFormat'=>'24', 'disabled' => true));
	echo $this->Form->hidden('created_by', array('value' => $this->Session->read('Auth.User')['id']));
	echo $this->Form->input('created_by', array('label' => '建立人', 'value' => $this->Session->read('Auth.User')['username'], 'type' => 'text', 'disabled' => true));
	echo $this->Form->hidden('worker_id', array('value' => $workers['id']));
	echo $this->Form->button('新增', array('type' => 'submit'));
	echo $this->Form->button('重新填寫', array('type' => 'reset'));
	echo $this->Form->end();
	?>
</div>