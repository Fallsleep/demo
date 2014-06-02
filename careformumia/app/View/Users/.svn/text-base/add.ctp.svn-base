<!-- app/View/Users/add.ctp -->

<div class="add-header">Add User</div>
<div class="add-content">
	<?php 
		echo $this->Form->create('User'); 
        echo $this->Form->input('username');
        echo $this->Form->input('password');
        echo $this->Form->input('role', array(
            'options' => array('admin' => 'Admin', 'pic' => 'Person in Charge', 'sales' => 'Sales'),
        ));
        echo $this->Form->button('Submit', array('type' => 'submit'));
        echo $this->Form->end();
	?>
</div>