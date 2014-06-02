<!-- File: /app/View/Jobs/add.ctp -->

<?php echo $this->Form->create('Job'); ?>
<fieldset>
	<legend>新增工作</legend>
	<?php
	echo $this->Form->input('customer_id', array('label' => '客戶編號', 'type' => 'text'));
	echo $this->Form->input('mother_chi_name', array('label' => '中文姓名'));
	echo $this->Form->input('mother_eng_name', array('label' => '英文姓名'));
	echo $this->Form->input('mother_mobile', array('label' => '手提電話'));
	echo $this->Form->input('mother_contact', array('label' => '其他電話'));
	echo $this->Form->input('work_address', array('label' => '工作地點'));
	echo $this->Form->input('mother_age', array('label' => '媽媽年齡'));
	echo $this->Form->input('birth_method', array('label' => '分娩方式', 'options' => array('N' => '自然分娩','P' => '剖腹分娩' ,'T' => '无痛分娩','W' => '水中分娩')));
	echo $this->Form->input('milk_type', array('label' => '哺育方式', 'options' => array('0' => '母乳餵養', '1' => '奶粉餵養', '2' => '母乳與奶粉混合')));
	echo $this->Form->input('hostipal', array('label' => '生產醫院'));
	echo $this->Form->input('expected_ddate', array('label' => '預產日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('delivery_date', array('label' => '生產日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('num_of_child', array('label' => '有幾個小孩？'));
	echo $this->Form->input('have_servant', array('label' => '是否有傭人？', 'options' => array('是', '否')));
	echo $this->Form->input('have_pet', array('label' => '是否有寵物？', 'options' => array('是', '否')));
	echo $this->Form->input('work_start', array('label' => '開工日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('work_end', array('label' => '結束日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('status', array('label' => '狀況', 'options' => array('A' => '活躍', 'IA' => '不活躍')));
	echo $this->Form->input('remark', array('label' => '備註'));
	echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s',time())));
	echo $this->Form->hidden('created_by', array('value' => '1234567890'));
	?>
</fieldset>
<?php echo $this->Form->end('新增'); ?>