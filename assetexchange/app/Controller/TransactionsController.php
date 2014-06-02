<?php
App::import('Controller','Assets');
App::uses('Sanitize', 'Utility');

class TransactionsController extends AppController {
	var $name = 'Transactions';
	public $helpers = array('Html', 'Form', 'Session');
	public $AssetCtl;
	
	public function index() {
        
	}

	public function beforeFilter(){
		$this->AssetCtl = new AssetsController();
		$this->AssetCtl->constructClasses();

	}
	
	public function history($keyword = null){	
		if($keyword) $this->request->data['Search']['Search'] = $keyword;

		$this->request->data = Sanitize::clean($this->request->data);
		if(!empty($this->request->data)){						
			$asset_symbols = preg_split('/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/', $this->request->data['Search']['Search']);
			if($asset_symbols[0] != null)$assets = $this->AssetCtl->findBySymbols($asset_symbols);
			if(isset($assets)&&count($assets) == 1){
				$search_asset_id_condition = array('asset_id' => $assets[0]['Asset']['id']); 
			}else if(isset($assets)&&count($assets) > 1){
				$search_asset_id_conditions = array();
				foreach ($assets as $asset) {
					$search_asset_id_conditions[] = array('asset_id ' => $asset['Asset']['id']);
				}
				$search_asset_id_condition = array('OR' => $search_asset_id_conditions);
			}
				
			date_default_timezone_set('Asia/Hong_Kong');
			$begintime = $this->request->data['Search']['close_time_begin'];
			$close_time_begin = date('Y-m-d',mktime(0,0,0,$begintime['month'],$begintime['day'],$begintime['year']));
			$endtime = $this->request->data['Search']['close_time_end'];
			$close_time_end = date('Y-m-d',mktime(0,0,0,$endtime['month'],$endtime['day']+1,$endtime['year']));
			
			if(isset($search_asset_id_condition)){
				$search_condition = array(
					$search_asset_id_condition,
					'close_time >= ' => $close_time_begin,
					'close_time < ' => $close_time_end,
					'or' => array('sell_user_id' => $this->Session->read('Auth.User')['username'], 
							'buy_user_id' => $this->Session->read('Auth.User')['username'])
				);
			}else{
				$search_condition = array(
					'close_time >= ' => $close_time_begin,
					'close_time < ' => $close_time_end,
					'or' => array('sell_user_id' => $this->Session->read('Auth.User')['username'], 
							'buy_user_id' => $this->Session->read('Auth.User')['username'])
				);
			}
			$transactions = $this->Transaction->find('all', array(
					'conditions' => $search_condition,
					'order' => 'close_time desc',
					'recursive' => 0
			));
				
			if (!$transactions) {
				$this->Session->setFlash('沒有相關結果');
				return ;
			}

			$this->set('transactions',$transactions);
			$this->set('keyword',$this->request->data['Search']['Search']);
   	
  		}
	}
	//添加提款、取款交易记录			
	public function add($user_id, $amount, $comment, $type) {
		date_default_timezone_set('Asia/Hong_Kong');
        $CURRENT_TMIE = date('Y-m-d H:i:s');
        $transaction =array(
			'type' => $type,
			'buy_user_id' => $user_id,
			'close_price' => $amount,
        	'close_time' => $CURRENT_TMIE,
        	'comment' => $comment,
			'created' => $CURRENT_TMIE,
			'created_by' => $this->Session->read('Auth.User')['username'],
        	'modified' => $CURRENT_TMIE,
        	'modified_by' => $this->Session->read('Auth.User')['username']
		);        
		$this->Transaction->create();
		$this->Transaction->save($transaction);
        
	}
	
	//添加分派交易记录
	public function addAssignTransaction($user_id, $asset_id, $volume, $amount) {
		date_default_timezone_set('Asia/Hong_Kong');
        $CURRENT_TMIE = date('Y-m-d H:i:s');
        $transaction =array(
			'type' => 'B',
			'buy_user_id' => $user_id,
        	'asset_id' => $asset_id,
        	'volume' => $volume,
			'close_price' => $amount,
        	'sell_price' => $amount,
        	'close_time' => $CURRENT_TMIE,
			'created' => $CURRENT_TMIE,
			'created_by' => $this->Session->read('Auth.User')['username'],
        	'modified' => $CURRENT_TMIE,
        	'modified_by' => $this->Session->read('Auth.User')['username']
		);
		$this->Transaction->create();
		if($this->Transaction->save($transaction)){
			return true;
		}else {
			return false;
		}
        
	}
	
	public function findByAssetId($asset_id,$type) {
		date_default_timezone_set('Asia/Hong_Kong');
		$CURRENT_DATE = date('Y-m-d');
		$YESTERDAY = date('Y-m-d',time()-24*3600);
		switch ($type){
			case 'last':
		        $transactions = $this->Transaction->find(
		        	'all',
		        	array(
		        		'conditions' => array(
		        			'asset_id' => $asset_id,
			        		'type' => array('B', 'S')
		        		),
		        		'order' => 'close_time DESC', 'limit' => 1,
						'recursive' => -1
		        	)
		        );
		        break;
			case 'today':
				$transactions = $this->Transaction->find(
					'all',
					array(
			        	'conditions' => array(
							'asset_id' => $asset_id,
							'close_time >= ' =>$CURRENT_DATE,
		        			'type' => array('B', 'S')
						),
						'order' => 'close_time DESC',
						'limit' => 1,
						'recursive' => -1
					)
		        );
		        break;
			case 'yesterday':
				$transactions = $this->Transaction->find(
					'all',
					array(
			        	'conditions' => array(
							'asset_id' => $asset_id,
							'close_time < ' =>$CURRENT_DATE,
							// 'close_time >= ' =>$YESTERDAY,
		        			'type' => array('B', 'S')
						),
						'order' => 'close_time DESC',
						'limit' => 1,
						'recursive' => -1
					)
		        );
		        break;
			case 'all':
				$transactions = $this->Transaction->find(
					'all',
					array(
			        	'conditions' => array(
							'asset_id' => $asset_id,
							'close_time >= ' =>$CURRENT_DATE,
		        			'type' => array('B', 'S')			
						),
						'order' => 'close_time DESC',
						'recursive' => -1
					)
		        );
		        break;
			case 'open':
				$transactions = $this->Transaction->find('all',
					array(
			        	'conditions' => array(
							'asset_id' => $asset_id,
							'close_time >= ' => $CURRENT_DATE,
		        			'type' => array('B', 'S')
						),
						'order' => 'close_time',
						'limit' => 1,
						'recursive' => -1
					));
		        break;
		}
        return $transactions;
	}
	
	public function getTransactions($open_id, $type) {
		if ($type == 'B') {
			$transaction = $this->Transaction->find('all', array(
															'conditions' => array('buy_open_id' => $open_id),
															'fields' => array('volume', 'close_price', 'comment')
													));
		} else {
			$transaction = $this->Transaction->find('all', array(
															'conditions' => array('sell_open_id' => $open_id),
															'fields' => array('volume', 'sell_price', 'comment')
													));
		}		
		
		return $transaction;
	}
	
	public function getClosePrice($asset_id, $period, $min_max) {		
		switch ($period) {
			case 'd': 
				$CLOSE_TIME = date('Y-m-d');
				break;
			case '52':
				$CLOSE_TIME = date('Y-m-d', strtotime('-52 week', time()));
				break;
			default: 
				$CLOSE_TIME = '1970-01-01';
		}
		
		$close_price = $this->Transaction->find('first', array(
															'conditions' => array(
																	'asset_id' => $asset_id,
																	'close_time >= ' => $CLOSE_TIME
															),
															'fields' => array($min_max . '(close_price) as close_price')
												));
		
		return $close_price[0]['close_price'];
	}
	
	public function getVolume($asset_id) {
		return $this->Transaction->find('first', array(
													'conditions' => array(
														'asset_id' => $asset_id,
														'close_time >= ' => date('Y-m-d')
													),
													'fields' => array('sum(volume) as volume')
										))[0]['volume'];
	}
	
	public function getTurnover($asset_id) {
		return $this->Transaction->find('first', array(
													'conditions' => array(
														'asset_id' => $asset_id,
														'close_time >= ' => date('Y-m-d')
													),
													'fields' => array('sum(volume*close_price) as turnover')
										))[0]['turnover'];
	}
}