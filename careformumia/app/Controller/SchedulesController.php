<?php
class SchedulesController extends AppController {
	var $name = 'Schedules';
	
	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	
	public function index() {
		$this->redirect(array('controller' => 'workers', 'action' => 'index'));
    }
    
    public function view($worker_id){//, $year, $month){
    	if (!$worker_id) {
    		throw new NotFoundException(__('Invalid post'));
    	}
    	
    	$year = (!array_key_exists('ano',$_POST))?date("Y"):$_POST['ano'];
    	$month = (!array_key_exists('mes',$_POST))?date("m"):$_POST['mes'];
    	
    	$startd = date("Y-m-d h:i:s", mktime(0,0,0,$month,1,$year));
    	$endd = date("Y-m-t h:i:s", mktime(23,59,59,$month,date("t", mktime(0, 0, 0, $month, 1, $year)),$year));
    	
    	$schedules = $this->Schedule->find('all', array('conditions'=>
    			array('and'=>array('Schedule.worker_id' => $worker_id,
			    			array('or' => array('Schedule.status' => 'B','and'=>array('Schedule.status' => 'T', 'temp_lock_time > ' => date('Y-m-d H:i:s', time()-30*60)))),
	    					array('or' => array(array('and' => array('year(start_date)'=>$year,'month(start_date)'=>$month)),
				    							array('and' => array('year(end_date)'=>$year,'month(end_date)'=>$month)),
				    							array('and' => array('start_date < '=>$startd, 'end_date > '=>$endd))))
    			))));
    	
    	$this->autoRender = false;
    	$result = array();
    	foreach($schedules as $sch){
    		$start = (strtotime($sch['Schedule']['start_date']) < strtotime($startd))?1:date("j",strtotime($sch['Schedule']['start_date']));
    		$end = (strtotime($sch['Schedule']['end_date']) > strtotime($endd))?date("t"):date("j",strtotime($sch['Schedule']['end_date']));
    		
    		for ($i = $start; $i<=$end; $i++){
    			$result[] = array("$i/$month/$year", "Busy",'#');
    		}
    	}
    	
     	echo json_encode($result);
    }
    
    public function add($id = null) {
        if (!$id) {            
			$this->redirect(array('controller' => 'workers', 'action' => 'index'));
        }
        
    	if (!empty($this->data)) {
    		$this->Schedule->create();
    		if ($this->Schedule->save($this->data)) {
                $this->Session->setFlash('成功新增日程');
                $this->redirect(array('controller' => 'workers', 'action' => 'view/' . $id . '?tab=schedule'));
    		} else {
    			$this->Session->setFlash('未能新增日程');
    		}
    	}

    	$workers = $this->Schedule->Worker->findById($id);
    	$this->set('workers', $workers);
    	
    	return $workers['Worker'];
    }
 	
	public function edit($id = null) {
		if (!$id) {
			$this->redirect(array('controller' => 'workers', 'action' => 'index'));
		}

		$schedule = $this->Schedule->findById($id);
		if (!$schedule) {
			$this->redirect(array('controller' => 'workers', 'action' => 'index'));
		}

		if (isset($this->request->data['cancel'])) {
			$this->Session->setFlash('取消編輯日程');
			$this->redirect(array('controller' => 'workers', 'action' => 'view/' . $schedule['Worker']['id'] . '?tab=schedule'));
		} else {
			if ($this->request->is('post') || $this->request->is('put')) {
				$this->Schedule->id = $id;
				if ($this->Schedule->save($this->request->data)) {
					$this->Session->setFlash('成功編輯日程');
					$this->redirect(array('controller' => 'workers', 'action' => 'view/' . $schedule['Worker']['id'] . '?tab=schedule'));
				} else {
					$this->Session->setFlash('未能編輯日程');
				}
			}
		}
		
		$workers = $this->Schedule->findById($id);
		$this->set('schedule', $schedule);

		if (!$this->request->data) {
			$this->request->data = $schedule;
		}
	}
	
	public function listAllLocked() {
		$locked_workers =  $this->Schedule->findAllByStatus('L');		
		$this->set('locked_workers', $locked_workers);
	}
	
	public function listLocked($job_id) {
		return $this->Schedule->find('list', array(
											'conditions' => array(
												'job_id' => $job_id, 
												'status' => 'L'
											),
											'fields' => 'worker_id', 
											'order' => 'score DESC'
										));
	}
	
	public function countLocked($job_id) {
		return $this->Schedule->find('count', array(
												'conditions' => array(
													'job_id' => $job_id,
													'Schedule.status' => 'L'
												)
											));
	}
	
	public function isLocked($job_id, $worker_id) {
		return $this->Schedule->find('count', array(
												'conditions' => array(
													'job_id' => $job_id,
													'worker_id' => $worker_id,
													'Schedule.status' => 'L'
												)
											));
	}
	
	public function isTempLocked($job_id, $worker_id) {
		$start_end = $this->requestAction('Jobs/calStartEndDates/' . $job_id);
		$job_start = $start_end['start_date'];
		$job_end = $start_end['end_date'];
		
		$worker_schedules = $this->Schedule->find('list', array(
												'conditions' => array(
													'worker_id' => $worker_id,
													'Schedule.status' => 'T',
													'temp_lock_time >=' => date('Y-m-d H:i:s', strtotime('30 minutes ago'))
												), 
												'fields' => array('start_date', 'end_date')
											));
		
		$overlap = false;
		foreach ($worker_schedules as $key => $value) {
			if (($key >= $job_start && $key <= $job_end) || ($value >= $job_start && $value <= $job_end)) {
				$overlap = true; 
				break;
			}
		}
		
		return $overlap;
	}
	
	public function lockWorkers($job_id) {
		$start_end = $this->requestAction('Jobs/calStartEndDates/' . $job_id);
		$rows = array();
		$i = 0;
		if ($this->data) {
			foreach ($this->data['Lock'] as $key => $value) {
				$this->deleteTempLock($job_id, $key);
				
				$rows[$i]['worker_id'] = $key;
				$rows[$i]['job_id'] = $job_id;
				$rows[$i]['start_date'] = $start_end['start_date'];
				$rows[$i]['end_date'] = $start_end['end_date'];
				$rows[$i]['status'] = 'L';
				$rows[$i]['score'] = $value;
				$rows[$i]['created_by'] = $this->Session->read('Auth.User')['id'];
				$i++;
			}
		}
		
		if (!empty($rows)) {
			$this->Schedule->create();
			$this->Schedule->saveMany($rows);
		}
		
		$this->redirect(array('controller' => 'jobs', 'action' => 'matchJobWorker/' . $job_id));
	}	
	
	public function tempLockWorkers($job_id, $workers_score) {
		$start_end = $this->requestAction('Jobs/calStartEndDates/' . $job_id); 
		$rows = array();
		$top_workers = array();
		$i = 0;
		foreach ($workers_score as $key => $value) {
			if (!$this->isTempLocked($job_id, $key)) {
				$rows[$i]['worker_id'] = $key;
				$rows[$i]['job_id'] = $job_id;
				$rows[$i]['start_date'] = $start_end['start_date'];
				$rows[$i]['end_date'] = $start_end['end_date'];
				$rows[$i]['status'] = 'T';
				$rows[$i]['temp_lock_time'] = date('Y-m-d H:i:s');
				$rows[$i]['created_by'] = $this->Session->read('Auth.User')['id'];
				
				$top_workers[$key] = $value;
				$i++;
			}
			if ($i == 5) break;
		}	
		
		if (!empty($rows)) {
			$this->Schedule->create();
			$this->Schedule->saveMany($rows);
		}
		
		return $top_workers;
	}
	
	public function deleteTempLock($job_id, $worker_id) {
		if (!$this->request->is('get')) {
			$this->Schedule->deleteAll(array(
											'job_id' => $job_id,
											'worker_id' => $worker_id,
											'Schedule.status' => 'T',
											'temp_lock_time >=' => date('Y-m-d H:i:s', strtotime('30 minutes ago'))
										));
		}
	}
	
	public function deleteJobTempLock($job_id) {
		$this->Schedule->deleteAll(array(
										'job_id' => $job_id,
										'Schedule.status' => 'T'
									));
	}
}