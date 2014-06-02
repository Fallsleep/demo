<?php

class Message extends AppModel {
	var $name = 'Message';
	var $belongsTo = array('User', 'MessageTemplate');

	public $validate = array(
			'subject' => array(
					'rule' => 'notEmpty'
			),
			'body' => array(
					'rule' => 'notEmpty'
			)
	);
}