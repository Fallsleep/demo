<!-- File: /app/View/Workers/view.ctp -->
<?php
	echo $this->Html->script('/js/bootstrap/bootstrap.min');
	echo $this->Html->script('/js/bic_calendar/bic_calendar');
	echo $this->Html->css('/css/bic_calendar/bic_calendar');
	echo $this->Html->css('/css/bootstrap/bootstrap1');
	//echo $this->Html->css('/css/bootstrap/bootstrap');
	//echo $this->Html->css('/css/bootstrap/bootstrap-responsive.min');
?>
<?php
switch($worker['Worker']['mariage_status']){
	case "S": $marital_status = "單身"; break;
	case "M": $marital_status = "已婚"; break;
	case "D": $marital_status = "離婚"; break;
	case "W": $marital_status = "喪偶"; break;
	default: $marital_status = "-";
}
$languages = array('cantonese','mandarin','english','japanese');
foreach($languages as $language){
	switch($worker['Worker'][$language]){
		case 0: $$language = "不懂"; break;
		case 1: $$language = "普通"; break;
		case 2: $$language = "流利"; break;
		default: $$language = "-";
	}
}
switch($worker['Worker']['status']){
	case "A": $status = "活躍"; break;
	case "IA": $status = "不活躍"; break;
	default: $status = "-";
}
if ($worker['Worker']['created_by']) $created_by = $this->requestAction('Users/getUsername/' . $worker['Worker']['created_by']);
if ($worker['Worker']['modified_by']) $modified_by = $this->requestAction('Users/getUsername/' . $worker['Worker']['modified_by']);
?>
<script>
$(document).ready( function(){

	var mesos = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"];

	var dias = ["日", "一", "二", "三", "四", "五", "六"];

    $('#calendari_lateral1').bic_calendar({
        nombresMes: mesos,
        dias: dias,
        req_ajax: {
        	type: 'post',
        	url: '<?php echo Router::url(array('controller' => 'schedules', 'action' => 'view/'. $worker['Worker']['id'])); ?>'
        }
    });
} );
</script>

<script>
$(document).ready(function() {	
	<?php 
	if (!isset($_GET['tab']) || empty($_GET['tab'])) {
	?>
		$('#worker-info').addClass('current');
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
	#worker-info-content { display: block; }
<?php 
} else {
?>
	#<?=$_GET['tab']?>-content { display: block; }
<?php 
}
?>
</style>

<div class="tab" id="worker-info">基本資料</div>
<div class="content" id="worker-info-content">
	<div id="worker-photo">
		<?php echo $this->Html->image(array_key_exists('img',$worker['Worker'])?$worker['Worker']['img']:'worker-no-photo.jpg', array('alt' => '陪月員照片')); ?>		
	</div>
	<div id="work-info">
		<p>
			狀態: <?=$status?><br>
			接受雙胞胎? <?=$worker['Worker']['accept_twins']?"是":"否"?><br>
			接受8小時? <?=$worker['Worker']['accept8']?"是":"否"?><br>
			<?php if ($worker['Worker']['accept8']) { ?> 8小時月薪: <?=$worker['Worker']['wage8']?><br><?php } ?>
			接受10小時? <?=$worker['Worker']['accept10']?"是":"否"?><br>
			<?php if ($worker['Worker']['accept10']) { ?> 10小時月薪: <?=$worker['Worker']['wage10']?><br><?php } ?>
			接受12小時? <?=$worker['Worker']['accept12']?"是":"否"?><br>
			<?php if ($worker['Worker']['accept12']) { ?> 12小時月薪: <?=$worker['Worker']['wage12']?><br><?php } ?>
			接受24小時? <?=$worker['Worker']['accept24']?"是":"否"?><br>
			<?php if ($worker['Worker']['accept24']) { ?> 24小時月薪: <?=$worker['Worker']['wage24']?><br><?php } ?>
		</p>
	</div>
	<div id="worker-basic-info">
		<p><span id="chi-name"><?=$worker['Worker']['chi_name']?></span> 
			<?php if ($worker['Worker']['eng_first_name'] || $worker['Worker']['eng_last_name']) echo '('; ?><?=$worker['Worker']['eng_first_name']?> <?=$worker['Worker']['eng_last_name']?><?php if ($worker['Worker']['eng_first_name'] || $worker['Worker']['eng_last_name']) echo ')'; ?>
			<?php echo $this->Html->link('編輯', array('controller' => 'workers', 'action' => 'edit', $worker['Worker']['id'])); ?><br>			
			<span id="worker-no">陪月員編號: <?=$worker['Worker']['worker_no']?></span>
		</p>
		<div class="worker-contact" id="worker-mobile">
			<div class="worker-mobile worker-contact-thumb" id="mobile-thumb"></div>
			<div class="worker-mobile"><?=$worker['Worker']['mobile']?></div>
		</div>
		<?php if (!empty($worker['Worker']['contact_other'])) { ?>
			<div class="worker-contact" id="worker-other-contact">
				<div class="worker-other-contact worker-contact-thumb" id="other-contact-thumb"></div>
				<div class="worker-other-contact"><?=$worker['Worker']['contact_other']?></div>
			</div>
		<?php } ?>
		<?php if (!empty($worker['Worker']['address'])) { ?>
			<div id="worker-address">
				<div class="worker-address worker-contact-thumb" id="address-thumb"></div>
				<div class="worker-address"><?=$worker['Worker']['address']?></div>
			</div>
		<?php } ?>
		<?php if (!empty($worker['Worker']['date_of_birth'])) { ?><br><br>出生日期: <?=$worker['Worker']['date_of_birth']?><?php } ?>		
		<?php if (!empty($worker['Worker']['mariage_status'])) { ?><br><br>婚姻狀況: <?=$marital_status?><?php } ?>
	</div>
	<div id="worker-other-info">
		<?php if ($worker['Worker']['comments']) { ?>
			<p class="section-header">評語</p>
			<p><?=$worker['Worker']['comments']?></p>
		<?php } ?>
		<p class="section-header">技能</p>
		<p>
			年資: <?=number_format($worker['Worker']['year_exp'],1)?> 年 
			<div class="lang">語言:</div>
			<div class="lang flag-thumb" id="zh-thumb"></div><div class="lang"><?=$cantonese?></div>
			<div class="lang flag-thumb" id="cn-thumb"></div><div class="lang"><?=$mandarin?></div>
			<div class="lang flag-thumb" id="en-thumb"></div><div class="lang"><?=$english?></div>
			<div class="lang flag-thumb" id="jp-thumb"></div><div class="lang"><?=$japanese?></div>
		</p>
	</div>
	<div id="system-info">
		<p>
			建立時間: <?=$worker['Worker']['created']?> 
			 | 建立人: <?=isset($created_by)?$created_by:'-'?></td>
			 | 修改時間: <?=$worker['Worker']['modified']=="0000-00-00 00:00:00"?'-':$worker['Worker']['modified']?>
			 | 修改人: <?=isset($modified_by)?$modified_by:'-'?>
		<p>
	</div>
</div>

<div class="tab" id="edu-background">證書</div>
<div class="content" id="edu-background-content">
	<table>
	    <tr>
	        <th>證書頒發日期</th>
	        <th>證書類別</th>
	        <th>證書名稱</th>
	        <th>備註</th>
	        <th>相片</th>
	        <!--th>建立日期</th>
	        <th>建立人</th>
	        <th>修改日期</th>
	        <th>修改人</th-->
	        <th></th>        
	    </tr>
		<?php foreach($worker['EduBackground'] as $edu_background){ ?>
		<tr>
	        <td><?php echo $edu_background['award_date']; ?></td>
	        <td><?php echo $edu_background['award_type']; ?></td>
	        <td><?php echo $edu_background['award_title']; ?></td>
	        <td><?php echo $edu_background['remark']; ?></td>
	        <td><?php echo $edu_background['img']?"<a href='/careformumi_crm/".$edu_background['img']."' target='_blank'>link</a>":'-'; ?></td>
	        <!--td><?php echo $edu_background['created']; ?></td>
	        <td><?php echo $edu_background['created_by']; ?></td>
	        <td><?php echo $edu_background['modified']=='0000-00-00 00:00:00'?'-':$edu_background['modified']; ?></td>
	        <td><?php echo $edu_background['modified_by']?$edu_background['modified_by']:'-'; ?></td-->
	        <td>
	            <?php echo $this->Html->link('編輯', array('controller' => 'edu_backgrounds', 'action' => 'edit', $edu_background['id'])); ?>
	        </td>		
		</tr>
		<?php } ?>
	</table>
	<?php echo $this->element('add_edu_background'); ?>
</div>

<div class="tab" id="schedule">日程</div>
<div class="content" id="schedule-content">
	<div id="calendari_lateral1"></div>
	<table>
	    <tr>
	        <th>工作ID</th>
	        <th>開始時間</th>
	        <th>完結時間</th>
	        <th>狀況</th>
	        <th>臨時鎖定時間</th>
	        <th>備註</th>
	        <!--th>建立日期</th>
	        <th>建立人</th>
	        <th>修改日期</th>
	        <th>修改人</th-->
	        <th></th>        
	    </tr>
		<?php 
		foreach($worker['Schedule'] as $schedule){ 
			switch($schedule['status']){
				case "B": $status = "忙碌"; break;
				case "L": $status = "鎖定"; break;
				case "T": $status = "臨時鎖定"; break;
				default: $status = "-";
			}
		?>
		<tr>
	        <td><?php echo $schedule['job_id']?$schedule['job_id']:'-'; ?></td>
	        <td><?php echo $schedule['start_date']; ?></td>
	        <td><?php echo $schedule['end_date']; ?></td>
	        <td><?php echo $status; ?></td>
	        <td><?php echo $schedule['temp_lock_time']=='0000-00-00 00:00:00'?'-':$schedule['temp_lock_time']; ?></td>
	        <td><?php echo $schedule['remark']?$schedule['remark']:'-'; ?></td>
	        <!--td><?php echo $schedule['created']; ?></td>
	        <td><?php echo $schedule['created_by']; ?></td>
	        <td><?php echo $schedule['modified']=='0000-00-00 00:00:00'?'-':$schedule['modified']; ?></td>
	        <td><?php echo $schedule['modified_by']?$schedule['modified_by']:'-'; ?></td-->
	        <td>
	            <?php if ($schedule['status'] != 'L' && $schedule['status'] != 'T') echo $this->Html->link('編輯', array('controller' => 'schedules', 'action' => 'edit', $schedule['id'])); ?>
	        </td>		
		</tr>
		<?php } ?>
	</table>
	<?php echo $this->element('add_schedule'); ?>
</div>

<?php echo $this->element('edit_avail_district'); ?>
<?php echo $this->element('edit_additional_service'); ?>