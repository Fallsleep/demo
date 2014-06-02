<!-- File: /app/View/Jobs/index.ctp -->

<?php
	if($this->request->params['pass'] == array('search')){
		if($jobs_result = $this->Session->read('jobs_result')){
			echo $this->element('search_job_result', array('jobs_result' => $jobs_result)); 
		}
	}
?>

<?php echo $this->element('search_job'); ?>
<?php echo $this->element('add_job'); ?>
