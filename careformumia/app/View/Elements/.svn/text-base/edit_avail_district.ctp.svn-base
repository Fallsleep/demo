<!-- File: /app/View/Elements/edit_avail_district.ctp -->

<?php
$url = explode("/", $_SERVER['REQUEST_URI']);
$url = explode("?",  end($url));
$join_districts = $this->requestAction('AvailDistricts/joinDistricts/' . $url[0]);
?>

<style>
.region {
	display: inline-block;
	margin: 0;
	width: 31%;	
}
form#AvailDistrictViewForm {
	width: 100%;
}
</style>

<div class="tab" id="avail-district">可工作地區</div>
<div class="content" id="avail-district-content">
	<?php
	echo $this->Form->create('AvailDistrict', array('url' => array('controller' => 'avail_districts', 'action' => 'edit', $url[0])));
	$regions = array('NT', 'KL', 'HK');
	foreach ($regions as $region) {
	?>
	<div id="<?=$region?>" class="region">
		<table>
			<caption class="region_title">
			<?php 
			switch ($region) {
				case 'NT': echo '新界'; break;
				case 'KL': echo '九龍'; break;
				case 'HK': echo '香港'; break;
			}
			?>
			</caption>
			<tr><th></th><th>可工作</th><th>須津貼</th></tr>
	<?php
		foreach ($join_districts as $district) {
			if ($district['Districts']['region'] == $region) {
	?>
			<?php
			!empty($district['AvailDistrict']['district_id'])?$checked_district=1:$checked_district=0;
			!empty($district['AvailDistrict']['tran_fee'])?$checked_tran_fee=1:$checked_tran_fee=0;
			?>
			<tr>
				<th><?=$district['Districts']['district_name']?></th>
				<td>
			<?php
			echo $this->Form->input($district['Districts']['id'] . '.district_id', array(
				'checked' => $checked_district, 
				'class' => 'district-item district-id',
				'div' => false,
				'hiddenField' => false, 
				'label' => false,	
				'type' => 'checkbox',
				'value' => $district['Districts']['id']
			));
			?>
				</td>
				<td>
			<?php
			echo $this->Form->input($district['Districts']['id'] . '.tran_fee', array(
				'checked' => $checked_tran_fee, 
				'class' => 'district-item tran-fee',
				'div' => false,
				'hiddenField' => false, 
				'label' => false, 		
				'type' => 'checkbox'
			));
			?>
				</td>
			</tr>
	<?php
			} 
		} 
	?>	
		</table>
	</div>
	
	<?php } ?>
	<br>
	<?php
	echo $this->Form->button('儲存', array('type' => 'submit'));
	echo $this->Form->button('還原', array('type' => 'reset'));
	echo $this->Form->end();
	?>
</div>