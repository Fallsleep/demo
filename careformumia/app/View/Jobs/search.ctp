<!-- File: /app/View/Jobs/search.ctp -->
    <?php $districts = $this->requestAction('Districts/index'); ?>
	<?php
	if(isset($jobs))echo $this->element('search_job_result', array('jobs_result' => $jobs)); 

	echo $this->Form->create('Search', array('url' => array('controller' => 'jobs', 'action' => 'search'))); 
	echo $this->Form->input('customer_id', array('label' => '客戶編號', 'type' => 'text'));
	echo $this->Form->input('mother_chi_name', array('label' => '中文姓名'));
	echo $this->Form->input('mother_eng_name', array('label' => '英文姓名'));
	echo $this->Form->input('mother_mobile', array('label' => '手提電話'));
	echo $this->Form->input('mother_contact', array('label' => '其他電話'));
	echo $this->Form->input('district_id', array('label' => '地區', 'options' => $districts));
	echo $this->Form->input('work_address', array('label' => '地址'));
	echo $this->Form->input('mother_age', array('label' => '年齡'));
	echo $this->Form->input('birth_method', array('label' => '分娩方式', 'options' => array('N' => '自然分娩','P' => '剖腹分娩' ,'T' => '无痛分娩','W' => '水中分娩')));
	echo $this->Form->input('milk_type', array('label' => '哺育方式', 'options' => array('0' => '母乳餵養', '1' => '奶粉餵養', '2' => '母乳與奶粉混合')));
	echo $this->Form->input('hostipal', array('label' => '生產醫院'));
	echo $this->Form->input('expected_ddate', array('label' => '預產日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('delivery_date', array('label' => '生產日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('num_of_child', array('label' => '有幾個小孩？'));
	echo $this->Form->input('have_servant', array('label' => '是否有傭人？', 'options' => array('是', '否')));
	echo $this->Form->input('have_pet', array('label' => '是否有寵物？', 'options' => array('是', '否')));
	echo $this->Form->input('work_days', array('label' => '工作天數', 'options' => range(30, 90, 15)));
	echo $this->Form->input('extend', array('label' => '前後延長天數', 'options' => range(0, 14), 'default' => 7));
	echo $this->Form->input('work_hours', array('label' => '工作時數', 'options' => array('8', '10', '12', '24')));
	echo $this->Form->input('wage', array('label' => '提供月薪', 'options' => array('10000' => '$10000或以下', '10001' => '$10001-12000', '12001' => '$12001-14000', '14001' => '$14001-16000', '16001' => '$16000以上')));
	echo $this->Form->input('year_exp', array('label' => '陪月員年資', 'options' => array('0' => '不拘', '2' => '2年或以上', '5' => '5年或以上', '7' => '7年或以上', '10' => '10年或以上')));
	echo $this->Form->input('age', array('label' => '陪月員年齡', 'options' => array('0' => '不拘', '30' => '30歲或以下', '31' => '31-40歲', '41' => '41-50歲', '51' => '50歲以上')));
	echo $this->Form->input('cantonese', array('label' => '廣東話', 'options' => array('不拘', '一般', '流利')));
	echo $this->Form->input('mandarin', array('label' => '普通話', 'options' => array('不拘', '一般', '流利')));
	echo $this->Form->input('english', array('label' => '英語', 'options' => array('不拘', '一般', '流利')));
	echo $this->Form->input('japanese', array('label' => '日語', 'options' => array('不拘', '一般', '流利')));
	echo $this->Form->input('work_start', array('label' => '開工日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('work_end', array('label' => '結束日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('status', array('label' => '狀況', 'options' => array('P' => '待配對', 'M' => '已配對')));
	echo $this->Form->input('remark', array('label' => '備註'));
	echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s')));
	echo $this->Form->input('created', array('label' => '建立時間', 'selected' => date('Y-m-d H:i:s'), 'timeFormat'=>'24', 'disabled' => false));
	echo $this->Form->hidden('created_by', array('value' => $this->Session->read('Auth.User')['id']));
	echo $this->Form->input('created_by', array('label' => '建立人', 'value' => $this->Session->read('Auth.User')['id'], 'disabled' => false));
	echo $this->Form->button('檢索', array('type' => 'submit'));
	echo $this->Form->button('重填', array('type' => 'reset'));
	echo $this->Form->end();
	?>
</div>
    