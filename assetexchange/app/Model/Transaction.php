<?php

class Transaction extends AppModel {
	var $name = 'Transaction';
	var $belongsTo = array('Asset', 
		'Buyer' => array(
            'className' => 'User',
            'foreignKey' => 'buy_user_id'
        ),
        'Seller' => array(
            'className' => 'User',
            'foreignKey' => 'sell_user_id'
        ));
}