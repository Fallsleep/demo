<?php
class WorkersController extends AppController {
	var $name = 'Workers';
	
	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	
	public function index() {
       	$workers = $this->Worker->find('all');
        $this->set('workers', $workers);
        
        return $workers;
    }

    public function view($id) {
        if (!$id) {
            throw new NotFoundException(__('Invalid post'));
        }
		
        $worker = $this->Worker->findById($id);
        if (!$worker) {
            throw new NotFoundException(__('Invalid post'));
        }
        $this->set('worker', $worker);
        
        return $worker;
    }
	
	public function add() {
		if (!empty($this->request->data) ){
            $this->Worker->create();
    		if (!empty($this->data['Worker']['img'])) {
    			// upload the file to the server
    			$fileOK = $this->uploadFiles('uploads', array($this->data['Worker']['img']));
    			
    			if(array_key_exists('urls', $fileOK)) {
    				$this->request->data['Worker']['img'] = $fileOK['urls'][0];
    			} else {
    				throw new Exception(print_r($fileOK['errors']));
    			}
    		}
    		
            if ($this->Worker->save($this->request->data)) {
                $this->Session->setFlash('成功新增陪月員');
                $this->redirect(array('action' => 'index'));
            } else {
                $this->Session->setFlash('未能新增陪月員');
            }
        }
    }
	
	public function edit($id = null) {
		if (!$id) {
			throw new NotFoundException(__('未輸入陪月員'));
		}

		$worker = $this->Worker->findById($id);
		if (!$worker) {
			throw new NotFoundException(__('該陪月員不存在'));
		}

		if (isset($this->request->data['cancel'])) {
			$this->Session->setFlash('取消編輯基本資料');
			$this->redirect(array('action' => 'view', $id));
		} else {
			if ($this->request->is('worker') || $this->request->is('put')) {
				$this->Worker->id = $id;
				if ($this->Worker->save($this->request->data)) {
					$this->Session->setFlash('成功編輯基本資料');
					$this->redirect(array('action' => 'view', $id));
				} else {
					$this->Session->setFlash('未能編輯基本資料');
				}
			}
		}
		
		if (!$this->request->data) {
			$this->request->data = $worker;
		}
	}
	
	public function listAvailDistricts($id) {
		return $this->Worker->AvailDistrict->find('list', array('conditions' => array('worker_id' => $id), 'fields' => array('district_id', 'tran_fee')));		
	}
	
	public function listAdditionalServicesId($id) {
		return $this->Worker->AdditionalService->find('list', array('conditions' => array('worker_id' => $id), 'fields' => 'service_id'));		
	}
	
	public function editAdditionalServices($id) {
		$data = array();
		$data['Worker']['id'] = $id;
		if (!empty($this->request->data)) {
			$i = 0;
			foreach ($this->request->data['Service'] as $additional_service) {
				$data['Service']['Service'][$i] = $additional_service;
				$i++;
			}
		} else {
			$data['Service']['Service'][0] = array();
		}
		
		if ($this->Worker->save($data)) {
			$this->Session->setFlash('成功更新額外服務');
		} else {
			$this->Session->setFlash('未能更新額外服務');
		}
		$this->redirect(array('action' => 'view/' . $id . '?tab=additional-service'));
	}
	
	public function search() {
  	$conditions = array();
  	$languages = array("cantonese","mandarin","english","japanese");
		if(!empty($this->request->data)){
			foreach($this->request->data['Search'] as $field => $search_condition ) {
				if(!empty($search_condition)){
					if(in_array($field, $languages) && $search_condition == "unlimited" ){
						$conditions["$field"] = array('0', '1', '2');
						continue;
					}
					if($field == "mariage_status" && $search_condition == "unlimited"){
						$conditions["$field"] = array('S', 'M', 'D', 'W');
						continue;
					}
					if($field == "status" && $search_condition == "unlimited"){
						$conditions["$field"] = array('A', 'IA');
						continue;
					}
					if($field == "date_of_birth"){
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
      $this->Worker->recursive = 0;
			$workers_result = $this->Worker->find('all',array('conditions' => $conditions));
		}
		$this->Session->write('workers_result',$workers_result);
  	 	$this->redirect(array('action' => 'index','search'));
   	
  }
}