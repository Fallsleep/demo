<!-- File: /app/View/Workers/index.ctp -->

<?php
	if($this->request->params['pass'] == array('search')){
		if($workers_result = $this->Session->read('workers_result')){ 
			echo $this->element('search_worker_result', array('workers_result' => $workers_result)); 
		}
	}
	?>
<?php echo $this->element('search_worker'); ?>
<?php echo $this->element('add_worker'); ?>




