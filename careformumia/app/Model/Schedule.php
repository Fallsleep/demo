<?php
class Schedule extends AppModel {
	var $name = 'Schedule';
	var $belongsTo = 'Worker';
	
    public $validate = array(
        'start_date' => array(
            'rule' => 'notEmpty'
        ),
        'end_date' => array(
            'rule' => 'notEmpty'
        ),
        'status' => array(
            'rule' => 'notEmpty'
        ),
        'remark' => array(
            'rule' => 'notEmpty'
        )
    ); 
}