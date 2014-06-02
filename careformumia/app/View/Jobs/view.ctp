<!-- File: /app/View/Jobs/view.ctp -->

<?php 
switch($job['Job']['birth_method']){
	case "N": $birth_method = "自然分娩"; break;
	case "P": $birth_method = "剖腹分娩"; break;
	case "T": $birth_method = "无痛分娩"; break;
	case "W": $birth_method = "水中分娩"; break;
	default: $birth_method = "-"; 
}
switch($job['Job']['milk_type']){
	case "0": $milk_type = "母乳餵養"; break;
	case "1": $milk_type = "奶粉餵養"; break;
	case "2": $milk_type = "母乳與奶粉混合"; break;
	default: $milk_type = "-";
}
switch($job['Job']['wage']){
	case "10000": $wage = "$10000或以下"; break;
	case "10001": $wage = "$10001-12000"; break;
	case "12001": $wage = "$12001-14000"; break;
	case "14001": $wage = "$14001-16000"; break;
	case "16001": $wage = "$16000以上"; break;
	default: $wage = "-";
}
switch($job['Job']['year_exp']){
	case "0": $year_exp = "不拘"; break;
	case "2": $year_exp = "2年或以上"; break;
	case "5": $year_exp = "5年或以上"; break;
	case "7": $year_exp = "7年或以上"; break;
	case "10": $year_exp = "10年或以上"; break;
	default: $year_exp = "-";
}
switch($job['Job']['age']){
	case "0": $age = "不拘"; break;
	case "30": $age = "30歲或以下"; break;
	case "31": $age = "31-40歲"; break;
	case "41": $age = "41-50歲"; break;
	case "51": $age = "50歲以上"; break;
	default: $age = "-";
}
$languages = array("cantonese","mandarin","english","japanese");
foreach($languages as $language){
	switch($job['Job'][$language]){
		case 0: $$language = "不拘"; break;
		case 1: $$language = "普通"; break;
		case 2: $$language = "流利"; break;
		default: $$language = "-";
	}
}
switch($job['Job']['status']){
	case "P": $status = "待配對"; break;
	case "M": $status = "已配對"; break;
	default: $status = "-";
}
if ($job['Job']['pic']) $pic = $this->requestAction('Users/getUsername/' . $job['Job']['pic']);
if ($job['Job']['sales']) $sales = $this->requestAction('Users/getUsername/' . $job['Job']['sales']);
if ($job['Job']['created_by']) $created_by = $this->requestAction('Users/getUsername/' . $job['Job']['created_by']);
if ($job['Job']['modified_by']) $modified_by = $this->requestAction('Users/getUsername/' . $job['Job']['modified_by']);
?>

<script>
$(document).ready(function() {	
	<?php 
	if (!isset($_GET['tab']) || empty($_GET['tab'])) {
	?>
		$('#job-info').addClass('current');
	<?php 
	} else {
	?>
		$('#<?=$_GET['tab']?>').addClass('current');
	<?php 
	}
	?>
});
</script>
<style>
<?php 
if (!isset($_GET['tab']) || empty($_GET['tab'])) {
?>
	#job-info-content { display: block; }
<?php 
} else {
?>
	#<?=$_GET['tab']?>-content { display: block; }
<?php 
}
?>
</style>

<div class="tab" id="job-info">基本資料</div>
<div class="content" id="job-info-content">
	<table>
		<tr>
			<th>申請編號:</th>
			<td colspan="6"><?php echo $job['Job']['id']; ?></td>
			<td style="text-align: right;"><?php echo $this->Html->link('編輯', array('action' => 'edit', $job['Job']['id'])); ?></td>
		</tr>
		<tr>
			<th>客戶編號:</th>
			<td><?php echo $job['Job']['customer_id']; ?></td>
			<th>中文姓名:</th>
			<td colspan="2"><?php echo $job['Job']['mother_chi_name']?$job['Job']['mother_chi_name']:'-'; ?></td>
			<th>英文姓名:</th>
			<td colspan="2"><?php echo $job['Job']['mother_eng_name']?$job['Job']['mother_eng_name']:'-'; ?></td>
		</tr>
		<tr>
			<th>手提電話:</th>
			<td colspan="2"><?php echo $job['Job']['mother_mobile']; ?></td>
			<th>其他電話:</th>
			<td colspan="2"><?php echo $job['Job']['mother_contact']?$job['Job']['mother_contact']:'-'; ?></td>
			<th>地區:</th>
			<td><?php echo $job['District']['district_name']; ?></td>
		</tr>
		<tr>
			<th>地址:</th>
			<td colspan="7"><?php echo $job['Job']['work_address']?$job['Job']['work_address']:'-'; ?></td>
		</tr>
		<tr>
			<th>年齡:</th>
			<td><?php echo $job['Job']['mother_age']; ?></td>
			<th>分娩方式:</th>
			<td colspan="2"><?php echo $birth_method; ?></td>
			<th>哺育方式:</th>
			<td colspan="2"><?php echo $milk_type; ?></td>
		</tr>
		<tr>
			<th>生產醫院:</th>
			<td><?php echo $job['Job']['hostipal']?$job['Job']['hostipal']:'-'; ?></td>	
			<th>預產日期:</th>
			<td colspan="2"><?php echo $job['Job']['expected_ddate']?$job['Job']['expected_ddate']:'-'; ?></td>
			<th>生產日期:</th>
			<td colspan="2"><?php echo $job['Job']['delivery_date']?$job['Job']['delivery_date']:'-'; ?></td>		
		</tr>
		<tr>
			<th>有幾個小孩？</th>
			<td><?php echo $job['Job']['num_of_child']; ?></td>
			<th>是否有傭人？</th>
			<td colspan="2"><?php echo $job['Job']['have_servant']?"是":"否"; ?></td>
			<th>是否有寵物？</th>
			<td colspan="2"><?php echo $job['Job']['have_pet']?"是":"否"; ?></td>
		</tr>
		<tr>
			<th>工作天數:</th>
			<td colspan="2"><?php echo $job['Job']['work_days']; ?></td>
			<th>前後延長天數:</th>
			<td colspan="2"><?php echo $job['Job']['extend']; ?></td>
			<th>工作時數:</th>
			<td><?php echo $job['Job']['work_hours']; ?></td>
		</tr>
		<tr>			
			<th>提供月薪:</th>
			<td colspan="2"><?php echo $wage; ?></td>
			<th>陪月員年資:</th>
			<td colspan="2"><?php echo $year_exp; ?></td>
			<th>陪月員年齡:</th>
			<td><?php echo $age; ?></td>
		</tr>
		<tr>
			<th>廣東話:</th>
			<td><?php echo $cantonese; ?></td>
			<th>普通話:</th>
			<td><?php echo $mandarin; ?></td>
			<th>英語:</th>
			<td><?php echo $english; ?></td>
			<th>日語:</th>
			<td><?php echo $japanese; ?></td>
		</tr>
		</tr>
			<th>開工日期:</th>
			<td colspan="2"><?php echo $job['Job']['work_start']=="0000-00-00"?"-":$job['Job']['work_start']; ?></td>
			<th>結束日期:</th>
			<td colspan="2"><?php echo $job['Job']['work_end']=="0000-00-00"?"-":$job['Job']['work_end']; ?></td>
			<th>狀況:</th>
			<td><?php echo $status; ?></td>
		</tr>
		<tr>
			<th>備註:</th>
			<td colspan="7"><?php echo $job['Job']['remark']?$job['Job']['remark']:'-'; ?></td>
		</tr>
		<tr>
			<th>負責人:</th>
			<td colspan="3"><?php echo isset($pic)?$pic:'-'; ?></td>
			<th>營業員:</th>
			<td colspan="3"><?php echo isset($sales)?$sales:'-'; ?></td>
		</tr>
		<tr>
			<th>建立時間:</th>
			<td><?php echo $job['Job']['created']; ?></td>
			<th>建立人:</th>
			<td><?php echo isset($created_by)?$created_by:'-'; ?></td>
			<th>修改時間:</th>
			<td><?php echo $job['Job']['modified']=="0000-00-00 00:00:00"?"-":$job['Job']['modified']; ?></td>
			<th>修改人:</th>
			<td><?php echo isset($modified_by)?$modified_by:'-'; ?></td>
		</tr>
	</table>
</div>

<?php 
echo $this->element('edit_requested_service');
echo $this->Html->link($this->Html->div('tab link', '配對'), 
						array('action' => 'matchJobWorker', $job['Job']['id']),
						array('escape' => false)); 
?>
