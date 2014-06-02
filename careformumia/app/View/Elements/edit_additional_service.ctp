<!-- File: /app/View/Elements/edit_additional_service.ctp -->

<?php
$services = $this->requestAction('Services/listAllServices');
$url = explode("/", $_SERVER['REQUEST_URI']);
$url = explode("?",  end($url));
$additional_services = $this->requestAction('Workers/listAdditionalServicesId/' . $url[0]);
?>

<style>
div.checkbox {
	display: inline-block;
	margin: 0 15px 0 5px;
}
</style>

<div class="tab" id="additional-service">額外服務</div>
<div class="content" id="additional-service-content">
	<?php
	echo $this->Form->create('Service', array('url' => array('controller' => 'workers', 'action' => 'editAdditionalServices', $url[0])));
	
	foreach ($services as $id => $name) {
		in_array($id, $additional_services)?$checked=1:$checked=0;
		echo $this->Form->input('Service.' . $id, array(
					'checked' => $checked,
					'hiddenField' => false, 
					'label' => $name, 
					'type' => 'checkbox',
					'value' => $id
				));
	}
	?>
	<br>
	<?php
	echo $this->Form->button('儲存', array('type' => 'submit'));
	echo $this->Form->button('還原', array('type' => 'reset'));
	echo $this->Form->end();
	?>
</div>