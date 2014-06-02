<?php
class EduBackgroundsController extends AppController {
	var $name = 'EduBackgrounds';
	
	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	
	public function index() {
		$this->redirect(array('controller' => 'workers', 'action' => 'index'));
    }

    public function add($id = null) {
        if (!$id) {            
			$this->redirect(array('controller' => 'workers', 'action' => 'index'));
        }
        
    	if (!empty($this->data)) {
    		$this->EduBackground->create();
    		if (!empty($this->data['EduBackground']['img']) && !empty($this->data['EduBackground']['img']['name'])){
    			// upload the file to the server
    			$fileOK = $this->uploadFiles('img/uploads', array($this->data['EduBackground']['img']));
    			
    			if(array_key_exists('urls', $fileOK)) {
    				$this->request->data['EduBackground']['img'] = $fileOK['urls'][0];
    			}else{
    				throw new Exception(print_r($fileOK['errors']));
    			}
    		}else{
    			$this->request->data['EduBackground']['img'] = null;
    		}
    		
    		if ($this->EduBackground->save($this->data)) {
                $this->Session->setFlash('成功新增證書');
                $this->redirect(array('controller' => 'workers', 'action' => 'view/' . $id . '?tab=edu-background'));
    		} else {
    			$this->Session->setFlash('未能新增證書');
    		}
    	}

    	$workers = $this->EduBackground->Worker->findById($id);
    	$this->set('workers', $workers);
    	
    	return $workers['Worker'];
    }
 	
	public function edit($id = null) {
		if (!$id) {
			$this->redirect(array('controller' => 'workers', 'action' => 'index'));
		}

		$edu_background = $this->EduBackground->findById($id);
		if (!$edu_background) {
			$this->redirect(array('controller' => 'workers', 'action' => 'index'));
		}
		
		if (isset($this->request->data['cancel'])) {
			$this->Session->setFlash('取消編輯證書');
			$this->redirect(array('controller' => 'workers', 'action' => 'view/' . $edu_background['Worker']['id'] . '?tab=edu-background'));
		} else {
			if ($this->request->is('post') || $this->request->is('put')) {
				$this->EduBackground->id = $id;
				if ($this->EduBackground->save($this->request->data)) {
					$this->Session->setFlash('成功編輯證書');
					$this->redirect(array('controller' => 'workers', 'action' => 'view/' . $edu_background['Worker']['id'] . '?tab=edu-background'));
				} else {
					$this->Session->setFlash('未能編輯證書');
				}
			}
		}
		
		//$workers = $this->Worker->findById(->id);
		$this->set('edu_background', $edu_background);

		if (!$this->request->data) {
			$this->request->data = $edu_background;
		}
	}

}