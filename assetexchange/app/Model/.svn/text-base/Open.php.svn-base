<?php

class Open extends AppModel {
	var $name = 'Open';
	var $belongsTo = array('Asset', 'User');
	
	public $validate = array(	
		'type' => array(
			'rule' => 'notEmpty'
		),	
		'volume' => array(
			'rule' => 'notEmpty'
		),	
		'open_price' => array(
			'rule' => 'notEmpty'
		)
	);
}