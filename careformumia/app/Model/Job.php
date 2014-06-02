<?php 

class Job extends AppModel {
	var $name = 'Job';
	var $hasOne = array('District' => array('foreignKey' => false, 'conditions' => array('District.id = Job.district_id')));
	var $hasAndBelongsToMany = array('Service' => array('joinTable' => 'requested_services'));
	
    public $validate = array(
    	'customer_id' => array(
    	    'rule' => 'notEmpty'
    	),
        'mother_mobile' => array(
            'rule' => 'notEmpty'
        ),      		
        'district_id' => array(
            'rule' => 'notEmpty'
        ),  		
        'mother_age' => array(
            'rule' => 'notEmpty'
        ),
        'birth_method' => array(
            'rule' => 'notEmpty'
        ),
        'milk_type' => array(
            'rule' => 'notEmpty'
        ),
        'work_days' => array(
            'rule' => 'notEmpty'
        ),
        'extend' => array(
            'rule' => 'notEmpty'
        ),
        'work_hours' => array(
            'rule' => 'notEmpty'
        ),
        'wage' => array(
            'rule' => 'notEmpty'
        ),
        'year_exp' => array(
            'rule' => 'notEmpty'
        ),
        'age' => array(
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
        'num_of_child' => array(
            'rule' => 'notEmpty'
        ),
        'have_servant' => array(
            'rule' => 'notEmpty'
        ),
        'have_pet' => array(
            'rule' => 'notEmpty'
        ),
    	'status' => array(
    		'rule' => 'notEmpty'
    	),
    	'pic' => array(
    		'rule' => 'notEmpty'
    	),
    	'sales' => array(
    		'rule' => 'notEmpty'
    	)
    );
}

?>