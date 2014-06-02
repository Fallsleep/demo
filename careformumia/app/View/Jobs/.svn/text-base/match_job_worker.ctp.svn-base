<!-- File: /app/View/Jobs/match_job_worker.ctp -->

<?php 
$url = explode("/", $_SERVER['REQUEST_URI']);
$url = explode("?",  end($url));
$locked_workers = $this->requestAction('Schedules/listLocked/' . $url[0]);
?>

<script>
$(document).ready(function() {
	$('#LockMatchJobWorkerForm').submit(function() {
		if (!$('input:checkbox:checked').length) {
			alert('請先揀選陪月員');
			return false;
		} else if ($('input:checkbox:checked').length > <?=5-count($locked_workers)?>) {
			alert('請只鎖定 <?=5-count($locked_workers)?> 個或以下陪月員');
			return false;
		}
	});
});
</script>

<style>
#match-job-worker-content { display: block; }
form#LockMatchJobWorkerForm { width: 100%; }
</style>

<?php 
echo $this->Html->link($this->Html->div('tab link', '基本資料'), 
							array('action' => 'view', $url[0]),
							array('escape' => false));
echo $this->Html->link($this->Html->div('tab link', '要求服務'), 
							array('action' => 'view/' . $url[0] . '?tab=requested-service'),
							array('escape' => false));
?>

<div class="tab current" id="match-job-worker">配對</div>
<div class="content" id="match-job-worker-content">
	<?php if (count($locked_workers)) { ?>
		<h1>已鎖定</h1>
		<table>
			<?php
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
				<td><?php echo $this->Html->link($worker['Worker']['worker_no'], array('controller' => 'workers', 'action' => 'view', $worker['Worker']['id']), array('target' => '_blank')); ?></td>
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
	<?php } ?>
	
	<?php if (count($locked_workers) < 5) { ?>
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
				<td><?php echo $this->Html->link($worker['Worker']['worker_no'], array('controller' => 'workers', 'action' => 'view', $worker['Worker']['id']), array('target' => '_blank')); ?></td>
		        <td><?php echo $worker['Worker']['chi_name']; ?></td>
		        <td><?php echo $worker['Worker']['eng_first_name']?$worker['Worker']['eng_first_name']:"-"; ?></td>
		        <td><?php echo $worker['Worker']['eng_last_name']?$worker['Worker']['eng_last_name']:"-"; ?></td>
		        <td><?php echo $worker['Worker']['mobile']; ?></td>
		        <td><?php echo $worker['Worker']['contact_other']?$worker['Worker']['contact_other']:"-"; ?></td>
		        <td><?php echo $worker['Worker']['address']?$worker['Worker']['address']:"-"; ?></td>
		        <td><?php echo $worker['Worker']['date_of_birth']?$worker['Worker']['date_of_birth']:"-"; ?></td>
		        <td><?php echo $marital_status; ?></td>
		        <td><?php echo $worker['Worker']['comments']?$worker['Worker']['comments']:"-"; ?></td>
		        <td><?php echo $this->Form->checkbox($worker['Worker']['id'], array('value' => $score, 'hiddenField' => false)); echo $score; ?></td>
			</tr>
			<?php 
			}	
			?>
		</table>
	<?php 	
		echo $this->Form->button('鎖定', array('type' => 'submit'));
		// echo $this->Form->button('還原', array('type' => 'reset'));
		echo $this->Form->end();
	}
	?>
</div>