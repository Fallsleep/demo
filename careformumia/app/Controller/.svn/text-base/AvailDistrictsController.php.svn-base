<?php
class AvailDistrictsController extends AppController {
	var $name = 'AvailDistricts';

	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	
	public function add($id) {
		if (!empty($this->request->data)) {
			$rows = array();
			$i = 0;
			foreach ($this->request->data['AvailDistrict'] as $avail_district) {
				if (isset($avail_district['district_id'])) {
					$rows[$i]['worker_id'] = $id;
					$rows[$i]['district_id'] = $avail_district['district_id'];
					isset($avail_district['tran_fee']) && $avail_district['tran_fee']?$rows[$i]['tran_fee']=1:$rows[$i]['tran_fee']=0;
					$i++;
				}
			}
			
			$this->AvailDistrict->create();
			if ($this->AvailDistrict->saveMany($rows)) {
				$this->Session->setFlash('成功新增可工作地區');
			} else {
				$this->Session->setFlash('未能新增可工作地區');
			}
		}
	}
	
	public function edit($id) {
		$this->delete($id);
		$this->add($id);
		$this->redirect(array('controller' => 'workers', 'action' => 'view/' . $id . '?tab=avail-district'));
	}
	
	public function delete($id) {
		if ($this->request->is('get')) {
			$this->redirect(array('controller' => 'workers', 'action' => 'view/' . $id));
		}
		
		$this->AvailDistrict->deleteAll(array('worker_id' => $id), false);
	}
	
	public function joinDistricts($id) {
		$join_districts = $this->AvailDistrict->find('all', array(
			'joins' => array(
				array(
					'table' => 'cfm_districts',
					'alias' => 'Districts',
					'type' => 'RIGHT',
					'conditions' => array(
						'Districts.id = AvailDistrict.district_id', 
						'AvailDistrict.worker_id' => $id
					)
				)
			),
			'fields' => array('AvailDistrict.*', 'Districts.*')
		));
				
		return $join_districts;
	}
}