<?php
class JobsController extends AppController {
	var $name = 'Jobs';
	
	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	
	public function index() {
        $this->Job->recursive = 0;
        $this->set('jobs', $this->Job->find('all'));
    }

    public function view($id) {
        if (!$id) {
            throw new NotFoundException(__('Invalid post'));
        }
		
        $job = $this->Job->findById($id);
        if (!$job) {
            throw new NotFoundException(__('Invalid post'));
        }
        $this->set('job', $job);
        
        return $job;
    }
	
	public function add() {
		if (!empty($this->request->data) ){
            $this->Job->create();
            if ($this->Job->save($this->request->data)) {
                $this->Session->setFlash('成功新增工作');
                $this->redirect(array('action' => 'index'));
            } else {
                $this->Session->setFlash('未能新增工作');
            }
        }
    }
	
	public function edit($id = null) {
		if (!$id) {
			throw new NotFoundException(__('未輸入工作信息'));
		}

		$job = $this->Job->findById($id);
		if (!$job) {
			throw new NotFoundException(__('該工作信息不存在'));
		}

		if (isset($this->request->data['cancel'])) {
			$this->Session->setFlash('取消編輯基本資料');
			$this->redirect(array('action' => 'view', $id));
		} else {
			if ($this->request->is('job') || $this->request->is('put')) {
				$this->Job->id = $id;
				if ($this->Job->save($this->request->data)) {
					$this->Session->setFlash('成功編輯基本資料');
					$this->redirect(array('action' => 'view', $id));
				} else {
					$this->Session->setFlash('未能編輯基本資料');
				}
			}
		}

		if (!$this->request->data) {
			$this->request->data = $job;
		}
	}
	
	public function listRequestedServicesId($id) {
		return $this->Job->RequestedService->find('list', array('conditions' => array('job_id' => $id), 'fields' => 'service_id'));
	}
	
	public function editRequestedServices($id) {
		$data = array();
		$data['Job']['id'] = $id;
		if (!empty($this->request->data)) {
			$i = 0;
			foreach ($this->request->data['Service'] as $requested_service) {
				$data['Service']['Service'][$i] = $requested_service;
				$i++;
			}
		} else {
			$data['Service']['Service'][0] = array();
		}
	
		if ($this->Job->save($data)) {
			$this->Session->setFlash('成功更新要求服務');
		} else {
			$this->Session->setFlash('未能更新要求服務');
		}
		$this->redirect(array('action' => 'view/' . $id . '?tab=requested-service'));
	}
	
public function search() {
		$conditions = array();
		$districts = $this->requestAction('Districts/index');
		$pic = $this->requestAction('Users/listUsernameByRole/pic');//
		$sales = $this->requestAction('Users/listUsernameByRole/sales');//
		$ds =array();
		$pics = array();//
		$saless = array();//
		foreach ($districts as $id => $district_name) $ds[]=$id;
		foreach ($pic as $id =>$username) $pics[] = $id;//
		foreach ($sales as $id =>$role) $saless[] = $id;//
  		$languages = array("cantonese","mandarin","english","japanese");
		if(!empty($this->request->data)){
			foreach($this->request->data['Search'] as $field => $search_condition ) {				    
				if(!empty($search_condition)){
					
					if($field == 'district_id'){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = $ds;
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
							
					if($field == 'pic'){
							if($search_condition == "unlimited" ){
								//$conditions["$field"] = $pics;
								continue;
							}
							$conditions["$field = "] = $search_condition;
						}
					
					if($field == 'sales'){
							if($search_condition == "unlimited" ){
								//$conditions["$field"] = $saless;
								continue;
							}
							$conditions["$field = "] = $search_condition;
						}
															
					if($field == "birth_method"){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('N', 'P', 'T', 'W');
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					
					if($field == "milk_type"){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('0', '1', '2');
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					
					if($field == "have_servant"){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('0', '1');
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					
					if($field == "have_pet"){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('0', '1');
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}

					if($field == "work_days" ){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('30', '45', '60', '75', '90');//改動
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					
					if($field == "extend"){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = range(0, 14);//改動
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					
					if($field == "work_hours"){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('8', '10', '12', '24');
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					
					if($field == "wage"){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('10000', '10001', '12001', '14001', '16001');
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					
					if($field == "status"){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('P', 'M');
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					
					if(in_array($field, $languages)){
						if($search_condition == "unlimited" ){
							$conditions["$field"] = array('0', '1', '2');
							continue;
						}
						$conditions["$field = "] = $search_condition;
					}
					if($field == "expected_ddate"||$field == "delivery_date"||$field == "work_start"||$field == "work_end"){
						if(empty($search_condition["month"])||empty($search_condition["day"])||empty($search_condition["year"]))
							continue;
						$date_of_birth=mktime(0,0,0,$search_condition["month"],$search_condition["day"],$search_condition["year"]);
						$conditions["$field"] = date("Y-m-d",$date_of_birth);
						continue;
					}
					$conditions["$field LIKE "] = "%$search_condition%";
				}
			}
		}
		if(!empty($conditions)){
			$this->Job->recursive = 0;
			$jobs_result = $this->Job->find('all',array('conditions' => $conditions));
		}
		$this->Session->write('jobs_result',$jobs_result);var_dump($jobs_result);
		$this->redirect(array('action' => 'index','search'));
	}
	
	public function calStartEndDates($id) {
		$job = $this->Job->findById($id);
		$start_end = array();
		$start_end['start_date'] = date('Y-m-d', strtotime($job['Job']['expected_ddate'] . '-' . $job['Job']['extend'] . 'day'));
		$start_end['end_date'] = date('Y-m-d', strtotime($job['Job']['expected_ddate'] . '+' . $job['Job']['work_days'] . 'day+' . $job['Job']['extend'] . 'day'));
		
		return $start_end;
	}
	
	public function matchJobWorker($id) {		
		if ($this->requestAction('Schedules/countLocked/' . $id) < 5) {
			$this->requestAction('Schedules/deleteJobTempLock/' . $id);
			
			$workers = $this->requestAction('Workers/index');
			$job = $this->view($id);
				
			$top_workers = array();
			
			$all_services = $this->Job->Service->find('count');
			$requested_services = $this->Job->RequestedService->find('list', array('conditions' => array('job_id' => $id), 'fields' => 'service_id'));
			
			$languages = array('cantonese', 'mandarin', 'english', 'japanese');
			
			$start_end = $this->calStartEndDates($id);
			$job_start = $start_end['start_date'];
			$job_end = $start_end['end_date'];
			
			foreach ($workers as $worker) {
				if (!$this->requestAction('Schedules/isLocked/' . $id . '/' . $worker['Worker']['id'])) {
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
						
					// Add random score to avoid same marks
					$score += number_format(mt_rand()/mt_getrandmax(), 3);
						
					$top_workers[$worker['Worker']['id']] = $score;
				}
			}
			
			arsort($top_workers);
			$top_workers = $this->requestAction('Schedules/tempLockWorkers', array('pass' => array($id, $top_workers)));
			
			$this->set('top_workers', $top_workers);
		}
	}
}