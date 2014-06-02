<!-- app/View/Users/login.ctp -->

<?php 
echo $this->Session->flash(); 
echo $this->Session->flash('auth'); 
?>

<div class="login-form-header">系統登入</div>
<div class="login-form-content">
	<?php 
	echo $this->Form->create('User');
    echo $this->Form->input('username', array('label' => '用戶名稱', 'value' => false));
    echo $this->Form->input('password', array('label' => '密碼', 'value' => false));
	echo $this->Form->button('登入', array('type' => 'submit'));
	echo $this->Form->end(); 
	?>
</div>
