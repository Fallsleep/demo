<?php

// app/Model/User.php

class User extends AppModel {
	//var $hasOne = array('Mt4User');
	
	var $hasMany = array('UserAsset', 'Open', 
			'BuyTransaction' => array(
	            'className' => 'Transaction',
	            'foreignKey' => 'buy_user_id'
	        ),'SellTransaction' => array(
	            'className' => 'Transaction',
	            'foreignKey' => 'sell_user_id'
	        ));
	
    public $validate = array(
        'username' => array(
            'required' => array(
                'rule' => array('notEmpty'),
                'message' => 'A username is required'
            )
        ),
        'password' => array(
            'required' => array(
                'rule' => array('notEmpty'),
                'message' => 'A password is required'
            )
        ),
        'role' => array(
            'valid' => array(
                'rule' => array('inList', array('Admin', 'User')),
                'message' => 'Please enter a valid role',
                'allowEmpty' => false
            )
        )
    		/*,
        'balance' => array(
        	'rule' => array('decimal', 3),
        	'message' => 'Please enter a number like 1234.000'
        )*/
    );
}