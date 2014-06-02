<?php
class DistrictsController extends AppController {
	var $name = 'Districts';

	public function index() {
        return $this->District->find('list', array('fields' => array('id', 'district_name')));
	}
}