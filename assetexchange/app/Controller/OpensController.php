<?php
App::import('Controller', 'Users');
App::import('Controller', 'UserAssets');
App::import('Controller', 'Transactions');
App::uses('Sanitize', 'Utility');

class OpensController extends AppController {
	var $name = 'Opens';
	
	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	//var $uses = array('Transaction', 'Asset');
	
	public $UserCtl;
	public $UserAssetCtl;
	public $TranCtl;
	
	public function beforeFilter(){
		$this->UserCtl = new UsersController();
		$this->UserCtl->constructClasses();
		
		$this->UserAssetCtl = new UserAssetsController();
		$this->UserAssetCtl->constructClasses();
		
		$this->TranCtl = new TransactionsController();
		$this->TranCtl->constructClasses();
	}
			
	public function opensbyuser(){
		return $this->user_opens($this->Session->read('Auth.User')['username']);
	}
	
	public function user_opens($user_id) {
		if ($user != $this->Session->read('Auth.User')['username'] && $this->Session->read('Auth.User')['Role'] != 'Admin'){
			throw new Exception('你沒有存取權限');
		}
		
		$opens = $this->Open->find('all', array('conditions' => array('user_id' => $user_id)));
		$this->set('opens', $opens);
	
		return $opens;
	}
	
	public function asset_opens($asset_id) {
		$opens = $this->Open->find('all', array('conditions' => array('asset_id' => $asset_id,
																	'Open.status' => 'A'),
												'order' => array('Open.type DESC', 'open_price DESC', 'open_time')
		));
		$this->set('opens', $opens);
	
		return $opens;
	}
	
	public function asset_opens_ajax($asset_id) {
		$opens = $this->Open->find('all', array('conditions' => array('asset_id' => $asset_id,
				'Open.status' => 'A'),
				'order' => array('Open.type DESC', 'open_price DESC', 'open_time')
		));
		
		$this->autoRender = false;
		 
		echo json_encode($opens);
	}
	
	public function trade($asset_id){ 
		$asset = $this->Open->Asset->findById($asset_id);

		$this->request->data = Sanitize::clean($this->request->data);
		
		if ($this->request->is('post') && !empty($this->request->data)) {			
			$valid = true;
			if ($this->request->data['Open']['action']=='submit') {
				if ($this->request->data['Open']['volume']%$asset['Asset']['share_per_lot']!=0) {
					$this->Session->setFlash('股數必須為每手股數之倍數');
					$valid = false;
				}
			} else if ($this->request->data['Open']['action']=='confirm') {
				$user_balance = $this->UserCtl->getUserBalance() - $this->getOpenBuy();
				$user_asset = $this->UserAssetCtl->getUserAssetVolume($asset_id) - $this->getOpenSell($asset_id);
				if ($this->request->data['Open']['type']=='B' && 
					$this->request->data['Open']['volume']*$this->request->data['Open']['open_price'] > $user_balance) {
					$this->Session->setFlash('持有資金不足');
					$valid = false;
				} else if ($this->request->data['Open']['type']=='S' && 
							$this->request->data['Open']['volume'] > $user_asset ) {
					$this->Session->setFlash('持有股份不足');
					$valid = false;
				} else {
					$this->add();
				}
			}
			$this->set('valid', $valid);
		}
		
		$last = !empty($this->TranCtl->findByAssetId($asset['Asset']['id'], 'last')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($asset['Asset']['id'], 'last')[0]['Transaction']['close_price']:$asset['Asset']['start_price'];
		$closest_price = $this->getClosestPrice($asset_id, $last);		
		$user_balance = $this->UserCtl->getUserBalance()-$this->getOpenBuy();
		$user_asset = $this->UserAssetCtl->getUserAsset($asset_id);
		if (!empty($user_asset)) $volume = $user_asset['UserAsset']['volume'];
		if (!empty($user_asset)) $avail_volume = $user_asset['UserAsset']['volume']-$this->getOpenSell($asset_id);
		if (!empty($user_asset)) $market_cap = $this->addNumberScale($user_asset['UserAsset']['volume']*$last, 3);
		
		$this->set('asset', $asset);
		$this->set('closest_price', $closest_price);
		$this->set('user_balance', $user_balance);
		if (!empty($user_asset)) $this->set('user_asset', $user_asset);
		if (!empty($user_asset)) $this->set('volume', $volume);
		if (!empty($user_asset)) $this->set('avail_volume', $avail_volume);
		$this->set('last', $last);
		if (!empty($user_asset)) $this->set('market_cap', $market_cap);
	}
	
	public function add() {		
		$this->request->data = Sanitize::clean($this->request->data);
		
		if ($this->request->is('post') && !empty($this->request->data)) {		
			$this->Open->create();
			
			$this->Open->set(array(
					'open_time' => date("Y-m-d H:i:s"),
					'created_by' => $this->Session->read('Auth.User')['username'],
					'modified_by' => $this->Session->read('Auth.User')['username'],
					'user_id' => $this->Session->read('Auth.User')['username'],
					'created' => date("Y-m-d H:i:s"),
					'modified' => date("Y-m-d H:i:s")
			));
			
			// if ($this->request->data['Open']['close_time'] == 'T') $this->request->data['Open']['close_time'] = date("Y-m-d", strtotime(date("Y-m-d") . " +1 day"));
			
			if ($this->Open->save($this->request->data)) {
				$this->Session->setFlash('成功新增資料');
				//$this->tradematching($this->Open->id);
				$this->redirect(array('controller' => 'users', 'action' => 'home'));
			} else {
				$this->Session->setFlash('未能新增資料');
			}
		}
	}
	
	public function tradematching($id){
		$open = $this->getOpen($id);
		CakeLog::write('debug', print_r($open, true));
		$trade = false;
		
		if ($open != null){
			if ($open['Open']['type'] == 'B'){
				CakeLog::write('debug', $open['Open']['open_price'] . ' - ' . $open['Asset']['spread'] . ' = ' . $open['Open']['open_price'] - $open['Asset']['spread']);
				$sell_ops = $this->Open->find('all', array('conditions' => array('asset_id' => $open['Open']['asset_id'],
																				'Open.type' => 'S', 'Open.status' => 'A', 
																				'open_price <=' => $open['Open']['open_price'] - $open['Asset']['spread'],
																				'not' => array('user_id' => $open['Open']['user_id'])),
															'order' => array('open_price', 'open_time'),
															'recursive' => 0
				));
				
				CakeLog::write('debug', print_r($sell_ops, true));
				
				foreach ($sell_ops as $sell_op){
					$req_volume = $open['Open']['volume'] - $open['Open']['fulfil_volume'];
					$avail_volume = $sell_op['Open']['volume'] - $sell_op['Open']['fulfil_volume'];
					
					CakeLog::write('debug', $req_volume . '|' . $avail_volume);
					if ($req_volume <= $avail_volume){
						$open['Open']['fulfil_volume'] += $req_volume;
						$sell_op['Open']['fulfil_volume'] += $req_volume;
						
						$open['Open']['status'] = 'F';
						if ($sell_op['Open']['fulfil_volume'] == $sell_op['Open']['volume']){
							$sell_op['Open']['status'] = 'F';
							$sell_op['Open']['close_time'] = date("Y-m-d H:i:s");
						}
						
						$this->Open->save($sell_op);
						
						$this->Open->Asset->Transaction->create();
						$this->Open->Asset->Transaction->set(array(
							'type' => 'B', 
							'sell_user_id' => $sell_op['Open']['user_id'],
							'buy_user_id' => $open['Open']['user_id'],
							'sell_open_id' => $sell_op['Open']['id'],
							'buy_open_id' => $open['Open']['id'],
							'asset_id' => $open['Open']['asset_id'],
							'volume' => $req_volume,
							'sell_price' => $sell_op['Open']['open_price'],
							'close_price' => $open['Open']['open_price'],
							'close_time' => date("Y-m-d H:i:s"),
							'service_fee' => '0',
							'created_by' => $open['Open']['user_id'],
							'modified_by' => $open['Open']['user_id'],
							'created' => date("Y-m-d H:i:s"),
							'modified' => date("Y-m-d H:i:s")
						));
						$this->Open->Asset->Transaction->save();
						
						$this->UserCtl->tradeChangeBalance($open['Open']['user_id'], $sell_op['Open']['user_id'], $req_volume * $open['Open']['open_price'], $req_volume * $sell_op['Open']['open_price']);
						
						$this->UserAssetCtl->tradeToUserAsset($open['Open']['user_id'], $sell_op['Open']['user_id'], 
													$open['Open']['asset_id'], $req_volume, $open['Open']['open_price'],  
													$sell_op['Open']['open_price'], $open['Open']['user_id']);
						
						$trade = true;
						
						break;
					}else{
						$open['Open']['fulfil_volume'] += $avail_volume;
						$sell_op['Open']['fulfil_volume'] += $avail_volume;
						
						$sell_op['Open']['status'] = 'F';
						$sell_op['Open']['close_time'] = date("Y-m-d H:i:s");
						
						$this->Open->save($sell_op);
						
						$this->Open->Asset->Transaction->create();
						$this->Open->Asset->Transaction->set(array(
							'type' => 'B',
							'sell_user_id' => $sell_op['Open']['user_id'],
							'buy_user_id' => $open['Open']['user_id'],
							'sell_open_id' => $sell_op['Open']['id'],
							'buy_open_id' => $open['Open']['id'],
							'asset_id' => $open['Open']['asset_id'],
							'volume' => $avail_volume,
							'sell_price' => $sell_op['Open']['open_price'],
							'close_price' => $open['Open']['open_price'],
							'close_time' => date("Y-m-d H:i:s"),
							'service_fee' => '0',
							'created_by' => $open['Open']['user_id'],
							'modified_by' => $open['Open']['user_id'],
							'created' => date("Y-m-d H:i:s"),
							'modified' => date("Y-m-d H:i:s")
						));
						$this->Open->Asset->Transaction->save();
						
						$this->UserCtl->tradeChangeBalance($open['Open']['user_id'], $sell_op['Open']['user_id'], $avail_volume * $open['Open']['open_price'], $avail_volume * $sell_op['Open']['open_price']);
						
						$this->UserAssetCtl->tradeToUserAsset($open['Open']['user_id'], $sell_op['Open']['user_id'],
								$open['Open']['asset_id'], $avail_volume, $open['Open']['open_price'],
								$sell_op['Open']['open_price'], $open['Open']['user_id']);
						
						$trade = true;
					}
				}
			}else{
				$buy_ops = $this->Open->find('all', array('conditions' => array('asset_id' => $open['Open']['asset_id'],
															'Open.type' => 'B', 'Open.status' => 'A',
															'open_price >=' => $open['Open']['open_price'] + $open['Asset']['spread'],
															'not' => array('user_id' => $open['Open']['user_id'])),
															'order' => array('open_price DESC', 'open_time'),
															'recursive' => 0)
				);
				
				foreach ($buy_ops as $buy_op){
					$req_volume = $open['Open']['volume'] - $open['Open']['fulfil_volume'];
					$avail_volume = $buy_op['Open']['volume'] - $buy_op['Open']['fulfil_volume'];
					if ($req_volume <= $avail_volume){
						$open['Open']['fulfil_volume'] += $req_volume;
						$buy_op['Open']['fulfil_volume'] += $req_volume;
				
						$open['Open']['status'] = 'F';
						if ($buy_op['Open']['fulfil_volume'] == $buy_op['Open']['volume']){
							$buy_op['Open']['status'] = 'F';
							$buy_op['Open']['close_time'] = date("Y-m-d H:i:s");
						}
				
						$this->Open->save($buy_op);
				
						$this->Open->Asset->Transaction->create();
						$this->Open->Asset->Transaction->set(array(
							'type' => 'S',
							'sell_user_id' => $open['Open']['user_id'],
							'buy_user_id' => $buy_op['Open']['user_id'],
							'sell_open_id' => $open['Open']['id'],
							'buy_open_id' => $buy_op['Open']['id'],
							'asset_id' => $open['Open']['asset_id'],
							'volume' => $req_volume,
							'sell_price' => $open['Open']['open_price'],
							'close_price' => $buy_op['Open']['open_price'],
							'close_time' => date("Y-m-d H:i:s"),
							'service_fee' => '0',
							'created_by' => $open['Open']['user_id'],
							'modified_by' => $open['Open']['user_id'],
							'created' => date("Y-m-d H:i:s"),
							'modified' => date("Y-m-d H:i:s")
						));
						$this->Open->Asset->Transaction->save();
				
						$this->UserCtl->tradeChangeBalance($buy_op['Open']['user_id'], $open['Open']['user_id'], $req_volume * $buy_op['Open']['open_price'], $req_volume * $open['Open']['open_price']);
						
						$this->UserAssetCtl->tradeToUserAsset($buy_op['Open']['user_id'], $open['Open']['user_id'],
								$open['Open']['asset_id'], $req_volume, $buy_op['Open']['open_price'],
								$open['Open']['open_price'], $open['Open']['user_id']);
						
						$trade = true;
				
						break;
					}else{
						$open['Open']['fulfil_volume'] += $avail_volume;
						$buy_op['Open']['fulfil_volume'] += $avail_volume;
				
						$buy_op['Open']['status'] = 'F';
						$buy_op['Open']['close_time'] = date("Y-m-d H:i:s");
				
						$this->Open->save($buy_op);
				
						$this->Open->Asset->Transaction->create();
						$this->Open->Asset->Transaction->set(array(
							'type' => 'B',
							'sell_user_id' => $open['Open']['user_id'],
							'buy_user_id' => $buy_op['Open']['user_id'],
							'sell_open_id' => $open['Open']['id'],
							'buy_open_id' => $buy_op['Open']['id'],
							'asset_id' => $open['Open']['asset_id'],
							'volume' => $avail_volume,
							'sell_price' => $open['Open']['open_price'],
							'close_price' => $buy_op['Open']['open_price'],
							'close_time' => date("Y-m-d H:i:s"),
							'service_fee' => '0',
							'created_by' => $open['Open']['user_id'],
							'modified_by' => $open['Open']['user_id'],
							'created' => date("Y-m-d H:i:s"),
							'modified' => date("Y-m-d H:i:s")
						));
						$this->Open->Asset->Transaction->save();

						$this->UserCtl->tradeChangeBalance($buy_op['Open']['user_id'], $open['Open']['user_id'], $avail_volume * $buy_op['Open']['open_price'], $avail_volume * $open['Open']['open_price']);
						
						$this->UserAssetCtl->tradeToUserAsset($buy_op['Open']['user_id'], $open['Open']['user_id'],
								$open['Open']['asset_id'], $avail_volume, $buy_op['Open']['open_price'],
								$open['Open']['open_price'], $open['Open']['user_id']);
												
						$trade = true;
					}
				}
			}
		}
		
		if ($trade) {
			$this->Open->save($open);
		}
	}
	
	public function getOpen($id){
		$this->Open->id = $id;
		if ($this->Open->exists()) {
			return $this->Open->findById($id);
		} else {
			return null;
		}
	}
	
	public function getOpenBuy() {
		$opens = $this->Open->find('all', array('conditions' => array('user_id' => $this->Session->read('Auth.User')['username'],
																		'Open.type' => 'B',
																		'Open.status' => 'A'
																		),
												'fields' => array('volume', 'open_price', 'fulfil_volume')
									));		
		$open_buy = 0;
		foreach ($opens as $open) {
			$open_buy += ($open['Open']['volume']-$open['Open']['fulfil_volume'])*$open['Open']['open_price'];
		}
		
		return $open_buy;
	}
	
	public function getOpenBuyByUserId($user_id) {
		$opens = $this->Open->find('all', array('conditions' => array('user_id' => $user_id,
				'Open.type' => 'B',
				'Open.status' => 'A'
		),
				'fields' => array('volume', 'open_price', 'fulfil_volume')
		));
		$open_buy = 0;
		foreach ($opens as $open) {
			$open_buy += ($open['Open']['volume']-$open['Open']['fulfil_volume'])*$open['Open']['open_price'];
		}
	
		return $open_buy;
	}
	
	public function getOpenSell($asset_id) {
		$opens = $this->Open->find('all', array('conditions' => array('user_id' => $this->Session->read('Auth.User')['username'],
																		'asset_id' => $asset_id,
																		'Open.type' => 'S',
																		'Open.status' => 'A'
																),
									'fields' => array('volume', 'fulfil_volume')
									));
		$open_sell = 0;
		foreach ($opens as $open) {
			$open_sell += ($open['Open']['volume']-$open['Open']['fulfil_volume']);
		}
		
		return $open_sell;
	}
	
	public function index() {
		$opens = $this->Open->find('all', array('conditions' => array('Open.user_id' => $this->Session->read('Auth.User')['username'], 'Open.status' => 'A'),
												'order' => array('open_time DESC')));
		$sum = 0;
		foreach ($opens as $open) {
			$sum += $open['Open']['open_price'] * $open['Open']['volume'];
		}
		$this->set('opens', $opens);
		$this->set('money', $this->UserCtl->getUserBalance()- $this->getOpenBuy());
		$this->set('sum', $sum);
	}
	
	public function view($id) {
		$open = $this->Open->findById($id);
		
		if ($open['Open']['user_id']!=$this->Session->read('Auth.User')['username'] || $open['Open']['status']!='A') {
			$this->redirect('index');
		}
		
		$this->set('open', $open);
	}
	
	public function edit($id) {
		$open = $this->Open->findById($id);
		
		if ($open['Open']['user_id']!=$this->Session->read('Auth.User')['username'] || $open['Open']['status']!='A') {
			$this->redirect('index');
		}
		
		if ($this->request->is('post') || $this->request->is('put')) {
			$this->request->data = Sanitize::clean($this->request->data);
			
			$valid = true;
			if ($this->request->data['Open']['action']=='submit') {
				if ($this->request->data['Open']['remain_volume']%$open['Asset']['share_per_lot']!=0) {
					$this->Session->setFlash('股數必須為每手股數之倍數');
					$valid = false;
				}
			} else if ($this->request->data['Open']['action']=='confirm') {
				if ($open['Open']['type']=='B') {
					$user_balance = $this->UserCtl->getUserBalance() - $this->getOpenBuy() + ($open['Open']['volume']-$open['Open']['fulfil_volume'])*$open['Open']['open_price'];
					if ($this->request->data['Open']['remain_volume']*$this->request->data['Open']['open_price'] > $user_balance) {
						$this->Session->setFlash('持有資金不足');
						$valid = false;
						// $this->redirect('edit/' . $id);
					}
				} else if ($open['Open']['type']=='S') {
					$user_asset = $this->UserAssetCtl->getUserAssetVolume($id) - $this->getOpenSell($id) + ($open['Open']['volume']-$open['Open']['fulfil_volume']);
					if ($this->request->data['Open']['remain_volume'] > $user_asset ) {
						$this->Session->setFlash('持有股份不足');
						$valid = false;
						// $this->redirect('edit/' . $id);
					}
				} 
				
				if ($valid) {
					$void_open = $this->Open->find('first', array('conditions' => array('Open.id' => $id), 'fields' => array('id', 'fulfil_volume')));
					
					if ($void_open['Open']['fulfil_volume']==0) {
						$void_open['Open']['status'] = 'C';
					} else {
						$void_open['Open']['status'] = 'F';
						$void_open['Open']['volume'] = $void_open['Open']['fulfil_volume'];
					}
					unset($void_open['Open']['fulfil_volume']);
					
					if ($this->request->data['Open']['remain_volume']!=0) {
						$this->Open->set(array(
							'user_id' => $this->Session->read('Auth.User')['username'],
							'type' => $open['Open']['type'],
							'asset_id' => $open['Asset']['id'],
							'volume' => $this->request->data['Open']['remain_volume'],
							'open_time' => date("Y-m-d H:i:s"),
							'fulfil_volume' => '0',
							'status' => 'A',
							'comment' => $open['Open']['comment'],
							'created' => date("Y-m-d H:i:s"),
							'created_by' => $this->Session->read('Auth.User')['username'],
							'modified' => date("Y-m-d H:i:s"),
							'modified_by' => $this->Session->read('Auth.User')['username']
						));
					}
					
					$oid = 0;
					
					if (($this->request->data['Open']['remain_volume']==0 || $oid = $this->Open->save($this->request->data)) && $this->Open->save($void_open)) {
						$this->Session->setFlash('成功更新指示');
						/*
						CakeLog::debug($this->request->data['Open']['remain_volume'] . ' | ' . $this->Open->id . ' | ' . print_r($oid, true));
						if ($this->request->data['Open']['remain_volume']!=0){
							
							$this->tradematching($oid['Open']['id']);
						}*/
						$this->redirect('index');
					}
				}
			}
			$this->set('valid', $valid);
		}
		
		$last = !empty($this->TranCtl->findByAssetId($open['Asset']['id'], 'last')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($open['Asset']['id'], 'last')[0]['Transaction']['close_price']:$open['Asset']['start_price'];
		$closest_price = $this->getClosestPrice($open['Asset']['id'], $last);
		$user_balance = $this->UserCtl->getUserBalance()-$this->getOpenBuy();
		$user_asset = $this->UserAssetCtl->getUserAsset($open['Asset']['id']);
		if (!empty($user_asset)) $volume = $user_asset['UserAsset']['volume'];
		if (!empty($user_asset)) $avail_volume = $user_asset['UserAsset']['volume']-$this->getOpenSell($asset_id);
		if (!empty($user_asset)) $market_cap = $this->addNumberScale($user_asset['UserAsset']['volume']*$last, 3);
		
		$this->set('closest_price', $closest_price);
		$this->set('user_balance', $user_balance);
		if (!empty($user_asset)) $this->set('user_asset', $user_asset);
		if (!empty($user_asset)) $this->set('volume', $volume);
		if (!empty($user_asset)) $this->set('avail_volume', $avail_volume);
		$this->set('last', $last);
		if (!empty($user_asset)) $this->set('market_cap', $market_cap);
		
		$this->set('open', $open);
	}
	
	public function delete($id) {		
		if ($this->request->is('post')) {
			$open = $this->Open->find('first', array('conditions' => array('Open.id' => $id), 'fields' => array('id', 'fulfil_volume')));
			
			if ($open['Open']['fulfil_volume']==0) {
				$open['Open']['status'] = 'C';
			} else {
				$open['Open']['status'] = 'F';
				$open['Open']['volume'] = $open['Open']['fulfil_volume'];
			}
			unset($open['Open']['fulfil_volume']);
			
			if ($this->Open->save($open)) {
				$this->Session->setFlash('交易 ' . $id . ' 已被刪除');
				$this->redirect('index');
			}
		}
	}
	
	public function getClosestPrice($asset_id, $last) {
		$bp = $this->Open->find('first', array(
											'conditions' => array(
																'asset_id' => $asset_id, 
																//'open_price <= ' => $last, 
																'Open.status' => 'A', 
																'Open.type' => 'B'
															),
											'fields' => array('open_price'),
											'order' => array('open_price DESC')
										));
		$sp = $this->Open->find('first', array(
											'conditions' => array(
																'asset_id' => $asset_id, 
																//'open_price >= ' => $last, 
																'Open.status' => 'A',
																'Open.type' => 'S'
															),
											'fields' => array('open_price'),
											'order' => array('open_price')
										));
		
/*		isset($bp)?$bp=$bp['Open']['open_price']:null;
		isset($sp)?$sp=$sp['Open']['open_price']:null;
		*/
		$bp=!empty($bp)?$bp['Open']['open_price']:null;
		$sp=!empty($sp)?$sp['Open']['open_price']:null;
		
		return array('B' => $bp, 'S' => $sp);
	}
}	

	
	
?>	