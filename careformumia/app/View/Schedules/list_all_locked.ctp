<!-- File: /app/View/Schedules/list_all_locked.ctp -->

<table>
	<?php
	echo $this->Html->tableHeaders(array('陪月員編號', '陪月員姓名', '陪月員電話', '工作編號', '客戶編號', '客戶姓名', '客戶電話', '鎖定時間'));
	foreach ($locked_workers as $worker) {
		$job = $this->requestAction('jobs/view/' . $worker['Schedule']['job_id'])['Job'];
		echo $this->Html->tableCells(array(
										$this->Html->link($worker['Worker']['worker_no'], array('controller' => 'workers', 'action' => 'view', $worker['Worker']['id']), array('target' => '_blank')),
										$worker['Worker']['chi_name'], 
										$worker['Worker']['mobile'], 
										$this->Html->link($worker['Schedule']['job_id'], array('controller' => 'jobs', 'action' => 'view', $worker['Schedule']['job_id']), array('target' => '_blank')),
										$job['customer_id'], 
										$job['mother_chi_name'],
										$job['mother_mobile'],
										$worker['Schedule']['created']
									));
	}
	?>
</table>