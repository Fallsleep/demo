<?php
class Asset extends AppModel {
	var $name = 'Asset';
	var $hasOne = array('District' => array('foreignKey' => false, 'conditions' => array('District.id = Asset.district_id')));
	var $hasMany = array('AssetImg', 'UserAsset', 'Open', 'Transaction');

	
    public $validate = array(
    		
        'symbol' => array(
            'rule' => 'notEmpty'
        ),
        'name' => array(
            'rule' => 'notEmpty'
        ),
        'type' => array(
            'rule' => 'notEmpty'
        ),
        'status' => array(
            'rule' => 'notEmpty'
        ),
        'buy_date' => array(
            'rule' => 'notEmpty'
        ),
    		
        'open_date' => array(
            'rule' => 'notEmpty'
        ),
        'close_date' => array(
            'rule' => 'notEmpty'
        ),
    	'buy_price' => array(
    		'rule' => 'notEmpty'
    	),
    	
    	'start_price' => array(
    		'rule' => 'notEmpty'
    	),
    		
        'share_per_lot' => array(
            'rule' => 'notEmpty'
        ),
    	'spread' => array(
    		'rule' => 'notEmpty'
    	)
    );
}