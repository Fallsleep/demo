<div class="form-header">提款信息</div>
<div class="form-content">

<?php 
	echo $this->Form->create('withdrawal', array('url' => array('controller' => 'Users', 'action' => 'withdrawal', $this->params['pass'][0], $this->params['pass'][1])));
	echo $this->Form->input('withdrawal', array('label' => '提款金額', 'type' => 'text'));
	echo $this->Form->input('comment', array('label' => '評價', 'type' => 'text'));
	echo $this->Form->button('取錢', array('type' => 'submit'));	
	echo $this->Form->button('返回', array('type' => 'button', 'onclick' =>"location.href='../../admin_index'"));
	echo $this->Form->end;
?> 

</div>
