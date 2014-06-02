<?php
class ServicesController extends AppController {
	var $name = 'Services';
	
	public function listAllServices() {
		return $this->Service->find('list', array('fields' => array('id', 'service_name')));
	}
	
	public function countAllServices() {
		return $this->Service->find('count');
	}
}