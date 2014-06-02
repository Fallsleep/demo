
<!-- 
<table>
<tr>
<td><?php echo $this->Html->link('Assets', array('controller' => 'assets', 'action' => 'admin_index'));	?></td>
<td><?php echo $this->Html->link('Users', array('controller' => 'users', 'action' => 'admin_index')); ?></td>
<td><?php echo 'Reports';?></td>
</tr>
</table> -->
<?php echo $this->element('submenu', array('sub' => 'admin')); ?>
<br><br>



<div class="form-header">帳戶信息</div>
<div class="form-content">

<table>
<tr><?php echo $this->Form->create('Search', array('url' => array('controller' => 'Users', 'action' => 'admin_index')));?></tr>
<tr>
<td><?php echo $this->Form->input('Search', array('label' => '', 'type' => 'text'));?></td>
<td><?php echo $this->Form->button('檢索', array('type' => 'submit'));?></td>
<td><?php echo $this->Form->end;?></td> 
</tr>

</table>
<table>   
    <tr>
		<th>帳戶</th>
		<th>可動用資金</th>
		<th>投資總額</th>
		<th>投資市值</th>
		<th>賺/蝕</th>
		<th style="text-align:center;" colspan="2">操作</th>
	</tr>
<?php 
	if (isset($result)){
		foreach ($result as $hold) {
?>
	<tr>
		<td><?=$this->Html->link($hold['userinfo']['id'], array('controller' => 'Users', 'action' => 'home', $hold['userinfo']['id']));?></td>
		<td><?=number_format($hold['money'], 3, '.', ',')?></td>
		<td><?=number_format($hold['sum'], 3, '.', ',')?></td>	
		<td><?=number_format($hold['total'], 3, '.', ',')?></td>	
		<td><?=number_format($hold['earning'], 3, '.', ',');
			?>
		</td>
		<td style="text-align:right;">
<?php 
	if($this->Session->check('Auth.User') && $this->Session->read('Auth.User')['Role'] == 'Admin'){
	    echo $this->Html->link('存款', array('controller' => 'Users', 'action' => 'deposit', $hold['userinfo']['id'], $keyword));
	    echo ' | '; 
	    echo $this->Html->link('提款', array('controller' => 'Users', 'action' => 'withdrawal', $hold['userinfo']['id'], $keyword));
	}
?>		</td>
		<td>
<?php 
	if($this->Session->check('Auth.User') && $this->Session->read('Auth.User')['Role'] == 'Admin'){
	    echo ($hold['userinfo']['status']=='D')?$this->Html->link('啟用', array('controller' => 'Users', 'action' => 'changestatus', $hold['userinfo']['id'],'A', $keyword)):'啟用';
	    echo ' | '; 
	    echo ($hold['userinfo']['status']=='A')?$this->Html->link('禁用', array('controller' => 'Users', 'action' => 'changestatus', $hold['userinfo']['id'],'D', $keyword)):'禁用';
	}
?>
		</td>
	</tr>
<?php 
		}
	}
?>
</table>
</div>
