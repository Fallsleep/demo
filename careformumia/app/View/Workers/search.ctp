<!-- File: /app/View/Workers/search.ctp -->

	<?php 
	if(isset($workers))echo $this->element('search_result', array('workers_result' => $workers)); 

	echo $this->Form->create('Search', array('url' => array('controller' => 'workers', 'action' => 'search'))); 
	echo $this->Form->input('worker_no', array('label' => '陪月員編號'));
	echo $this->Form->input('chi_name', array('label' => '中文姓名'));
	echo $this->Form->input('eng_first_name', array('label' => '英文名字'));
	echo $this->Form->input('eng_last_name', array('label' => '英文姓氏'));
	echo $this->Form->input('mobile', array('label' => '手提電話'));
	echo $this->Form->input('contact_other', array('label' => '其他電話'));
	echo $this->Form->input('address', array('label' => '地址'));
	echo $this->Form->input('date_of_birth', array('label' => '出生日期', 'dateFormat' => 'YMD', 'minYear' => date('Y')-100, 'maxYear' => date('Y'), 'empty' => true));
	echo $this->Form->input('mariage_status', array('label' => '婚姻狀況', 'options' => array('S' => '單身', 'M' => '已婚', 'D' => '離婚', 'W' => '喪偶')));
	echo $this->Form->input('comments', array('label' => '評語', 'row' => '3'));
	echo $this->Form->input('bank_name', array('label' => '戶口銀行'));
	echo $this->Form->input('bank_account', array('label' => '戶口號碼'));
	echo $this->Form->input('cantonese', array('label' => '廣東話', 'options' => array('不懂', '一般', '流利')));
	echo $this->Form->input('mandarin', array('label' => '普通話', 'options' => array('不懂', '一般', '流利')));
	echo $this->Form->input('english', array('label' => '英語', 'options' => array('不懂', '一般', '流利')));
	echo $this->Form->input('japanese', array('label' => '日語', 'options' => array('不懂', '一般', '流利')));
	echo $this->Form->input('accept_twins', array('label' => '接受雙胞胎?'));
	echo $this->Form->input('accept8', array('label' => '接受8小時?'));
	echo $this->Form->input('wage8', array('label' => '8小時月薪'));
	echo $this->Form->input('accept10', array('label' => '接受10小時?'));
	echo $this->Form->input('wage10', array('label' => '10小時月薪'));
	echo $this->Form->input('accept12', array('label' => '接受12小時?'));
	echo $this->Form->input('wage12', array('label' => '12小時月薪'));
	echo $this->Form->input('accept24', array('label' => '接受24小時?'));
	echo $this->Form->input('wage24', array('label' => '24小時月薪'));
	echo $this->Form->input('year_exp', array('label' => '年資', 'min' => '0'));
	echo $this->Form->input('status', array('label' => '狀況', 'options' => array('A' => '活躍', 'IA' => '不活躍')));
	echo $this->Form->hidden('created', array('value' => date('Y-m-d H:i:s')));
	echo $this->Form->input('created', array('label' => '建立時間', 'selected' => date('Y-m-d H:i:s'), 'timeFormat'=>'24', 'disabled' => false));
	echo $this->Form->hidden('created_by', array('value' => $this->Session->read('Auth.User')['id']));
	echo $this->Form->input('created_by', array('label' => '建立人', 'value' => $this->Session->read('Auth.User')['id'], 'disabled' => false));
	echo $this->Form->button('檢索', array('type' => 'submit'));
	echo $this->Form->button('重填', array('type' => 'reset'));
	echo $this->Form->end();
	
	?>