<?php
class Worker extends AppModel {
	var $name = 'Worker';
	var $hasMany = array('AvailDistrict', 'EduBackground', 'Schedule');
	var $hasAndBelongsToMany = array('Service' => array('joinTable' => 'additional_services'));
	
    public $validate = array(
        'worker_no' => array(
            'rule' => 'notEmpty'
        ),
        'chi_name' => array(
            'rule' => 'notEmpty'
        ),
        'mobile' => array(
            'rule' => 'notEmpty'
        ),
        'mariage_status' => array(
            'rule' => 'notEmpty'
        ),
        'cantonese' => array(
            'rule' => 'notEmpty'
        ),
        'mandarin' => array(
            'rule' => 'notEmpty'
        ),
        'english' => array(
            'rule' => 'notEmpty'
        ),
        'japanese' => array(
            'rule' => 'notEmpty'
        ),
        'accept_twins' => array(
            'rule' => 'notEmpty'
        ),
        'accept8' => array(
            'rule' => 'notEmpty'
        ),
        'wage8' => array(
            'rule' => 'notEmpty'
        ),
        'accept10' => array(
            'rule' => 'notEmpty'
        ),
        'wage10' => array(
            'rule' => 'notEmpty'
        ),
        'accept12' => array(
            'rule' => 'notEmpty'
        ),
        'wage12' => array(
            'rule' => 'notEmpty'
        ),
        'accept24' => array(
            'rule' => 'notEmpty'
        ),
        'wage24' => array(
            'rule' => 'notEmpty'
        ),
        'year_exp' => array(
            'rule' => 'notEmpty'
        ),
        'status' => array(
            'rule' => 'notEmpty'
        )		
    );
}