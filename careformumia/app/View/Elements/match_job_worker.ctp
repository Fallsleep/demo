<!-- File: /app/View/Elements/match_job_worker.ctp -->

<?php 
$url = explode("/", $_SERVER['REQUEST_URI']);
$url = explode("?",  end($url));
// $workers = $this->requestAction('Workers/index');
// $job = $this->requestAction('Jobs/view/' . $url[0]);
?>

<style>
form#LockViewForm {
	width: 100%;
}
</style>

<div class="tab" id="match-job-worker">配對</div>
<div class="content" id="match-job-worker-content">
	<?php 
	/*
	$this->requestAction('Schedules/deleteJobTempLock/' . $url[0]); 
	$top_workers = array();
	
	$all_services = $this->requestAction('Services/countAllServices/');
	$requested_services = $this->requestAction('Jobs/listRequestedServicesId/' . $url[0]);
	
	$languages = array('cantonese', 'mandarin', 'english', 'japanese');
	
	$start_end = $this->requestAction('Jobs/calStartEndDates/' . $url[0]);
	$job_start = $start_end['start_date'];
	$job_end = $start_end['end_date'];
	
	foreach ($workers as $worker) {
		if (!$this->requestAction('Schedules/isLocked/' . $url[0] . '/' . $worker['Worker']['id'])) {
			$score = 0;
			
			// Criteria: Age; Score 1@		
			if (isset($worker['Worker']['date_of_birth'])) $worker_age = date_diff(date_create(date('Y-m-d')), date_create($worker['Worker']['date_of_birth']))->y;
			if (isset($worker_age)) {
				if (!$job['Job']['age']) {
					$score++;
				} elseif ($job['Job']['age'] == '30') {
					if ($worker_age <= $job['Job']['age']) $score++;
				} elseif ($job['Job']['age'] == '51') {	
					if ($worker_age >= $job['Job']['age']) $score++;
				} else {
					if (in_array($worker_age, range($job['Job']['age'],  $job['Job']['age']+9))) $score++;
				}
			}
			
			// Criteria: Year of experience; Score 10@		
			if ($job['Job']['year_exp'] == '0') {
				$score+=10;
			} else {
				if ($worker['Worker']['year_exp'] >= $job['Job']['year_exp']) $score+=10;
			}
			
			// Criteria: District, not require transportation fee; Score 100@		
			$worker_avail_districts = $this->requestAction('Workers/listAvailDistricts/' . $worker['Worker']['id']);
			if (array_key_exists($job['Job']['district_id'], $worker_avail_districts)) {
				(!$worker_avail_districts[$job['Job']['district_id']])?$score+=200:$score+=100;
			} 
			
			// Criteria: Wage, Score 1000@; additional services, Score 200@; languages, Score 250@		
			if ($worker['Worker']['accept'.$job['Job']['work_hours']]) $worker_wage = $worker['Worker']['wage'.$job['Job']['work_hours']];
			if (isset($worker_wage)) {		
				if ($job['Job']['wage'] == '10000') {
					if ($worker_wage <= $job['Job']['wage']) $score+=1000;
				} elseif ($job['Job']['wage'] == '16001') {	
					if ($worker_wage >= $job['Job']['wage']) $score+=1000;
				} else {
					if (in_array($worker_wage, range($job['Job']['wage'],  $job['Job']['wage']+1999))) $score+=1000;
				}
			}
			
			$additional_services = $this->requestAction('Workers/listAdditionalServicesId/' . $worker['Worker']['id']);
			if ($all_services-count($requested_services)) $score+=200*($all_services-count($requested_services));
			if (count(array_intersect($requested_services, $additional_services))) $score+=200*count(array_intersect($requested_services, $additional_services));
	
			foreach ($languages as $language) {
				if ($worker['Worker'][$language] >= $job['Job'][$language]) {
					$score+=250;
				}
			}
			
			// Criteria: Schedule, work hours; Score 10000@	
			$overlap = false;
			foreach ($worker['Schedule'] as $schedule) {
				if ((($schedule['start_date'] >= $job_start && $schedule['start_date'] <= $job_end) 
					|| ($schedule['end_date'] >= $job_start && $schedule['end_date'] <= $job_end)) 
					&& (($schedule['temp_lock_time'] == '0000-00-00 00:00:00')
					|| ($schedule['temp_lock_time'] >= date('Y-m-d H:i:s', strtotime('30 minutes ago'))))) {
					$overlap = true;
					break;
				}
			}	 			
			if (!$overlap) $score+=10000;
			
			if ($worker['Worker']['accept' . $job['Job']['work_hours']]) $score+=10000;
			
			// Add randam score to avoid same marks
			$score += number_format(mt_rand()/mt_getrandmax(), 3);
			
			$top_workers[$worker['Worker']['id']] = $score;
		}
	}
	
	arsort($top_workers);	
	$top_workers = array_slice($top_workers, 0, 5, true);
	$this->requestAction('Schedules/tempLockWorkers', array('pass' => array($url[0], $top_workers)));		
	*/
	?>
	
	<h1>已鎖定</h1>
	
	<table>
		<?php
		$locked_workers = $this->requestAction('Schedules/listLocked/' . $url[0]);
		echo $this->Html->tableHeaders(array('陪月員編號','中文姓名','英文名字','英文姓氏','手提電話','其他電話','地址','出生日期','婚姻狀況','評語'));
		foreach ($locked_workers as $worker) {	
			$worker = $this->requestAction('Workers/view/' . $worker);
			switch($worker['Worker']['mariage_status']) {
				case "S": $marital_status = "單身"; break;
				case "M": $marital_status = "已婚"; break;
				case "D": $marital_status = "離婚"; break;
				case "W": $marital_status = "喪偶"; break;
				default: $marital_status = "-";
			}
		?>
		<tr>
			<td><?php echo $this->Html->link($worker['Worker']['worker_no'], array('controller' => 'workers', 'action' => 'view', $worker['Worker']['id'])); ?></td>
	        <td><?php echo $worker['Worker']['chi_name']; ?></td>
	        <td><?php echo $worker['Worker']['eng_first_name']?$worker['Worker']['eng_first_name']:"-"; ?></td>
	        <td><?php echo $worker['Worker']['eng_last_name']?$worker['Worker']['eng_last_name']:"-"; ?></td>
	        <td><?php echo $worker['Worker']['mobile']; ?></td>
	        <td><?php echo $worker['Worker']['contact_other']?$worker['Worker']['contact_other']:"-"; ?></td>
	        <td><?php echo $worker['Worker']['address']?$worker['Worker']['address']:"-"; ?></td>
	        <td><?php echo $worker['Worker']['date_of_birth']?$worker['Worker']['date_of_birth']:"-"; ?></td>
	        <td><?php echo $marital_status; ?></td>
	        <td><?php echo $worker['Worker']['comments']?$worker['Worker']['comments']:"-"; ?></td>
		</tr>
		<?php }	?>
	</table>
	
	<h1>更多陪月員</h1>
	
	<?php echo $this->Form->create('Lock', array('url' => array('controller' => 'schedules', 'action' => 'lockWorkers', $url[0]))); ?>	
	<table>
		<?php
		echo $this->Html->tableHeaders(array('陪月員編號','中文姓名','英文名字','英文姓氏','手提電話','其他電話','地址','出生日期','婚姻狀況','評語','鎖定'));
		foreach ($top_workers as $worker => $score) {	
			$worker = $this->requestAction('Workers/view/' . $worker);
			switch($worker['Worker']['mariage_status']) {
				case "S": $marital_status = "單身"; break;
				case "M": $marital_status = "已婚"; break;
				case "D": $marital_status = "離婚"; break;
				case "W": $marital_status = "喪偶"; break;
				default: $marital_status = "-";
			}
		?>
		<tr>
			<td><?php echo $this->Html->link($worker['Worker']['worker_no'], array('controller' => 'workers', 'action' => 'view', $worker['Worker']['id'])); ?></td>
	        <td><?php echo $worker['Worker']['chi_name']; ?></td>
	        <td><?php echo $worker['Worker']['eng_first_name']?$worker['Worker']['eng_first_name']:"-"; ?></td>
	        <td><?php echo $worker['Worker']['eng_last_name']?$worker['Worker']['eng_last_name']:"-"; ?></td>
	        <td><?php echo $worker['Worker']['mobile']; ?></td>
	        <td><?php echo $worker['Worker']['contact_other']?$worker['Worker']['contact_other']:"-"; ?></td>
	        <td><?php echo $worker['Worker']['address']?$worker['Worker']['address']:"-"; ?></td>
	        <td><?php echo $worker['Worker']['date_of_birth']?$worker['Worker']['date_of_birth']:"-"; ?></td>
	        <td><?php echo $marital_status; ?></td>
	        <td><?php echo $worker['Worker']['comments']?$worker['Worker']['comments']:"-"; ?></td>
	        <td><?php echo $this->Form->checkbox($worker['Worker']['id'], array('value' => $score, 'hiddenField' => false)); echo $score;?></td>
		</tr>
		<?php 
		}	
		?>
	</table>
	<?php 	
	echo $this->Form->button('儲存', array('type' => 'submit'));
	echo $this->Form->button('還原', array('type' => 'reset'));
	echo $this->Form->end();
	?>
</div>