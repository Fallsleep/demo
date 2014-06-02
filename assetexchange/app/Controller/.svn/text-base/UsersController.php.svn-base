<?php

App::import('Controller', 'Transactions');
App::import('Controller', 'Opens');
App::import('Controller', 'Mt4Users');
App::uses('Sanitize', 'Utility');

class UsersController extends AppController {
	var $name = 'Users';
	public $helpers = array('Html', 'Form', 'Session');
	public $TranCtl;
	public $OpenCtl;
	
	public function beforeFilter(){
		$this->TranCtl = new TransactionsController();
        $this->TranCtl->constructClasses();
        $this->OpenCtl = new OpensController();
        $this->OpenCtl->constructClasses();
	}
	
	
	public function login() {
		if ($this->request->is('post')) {
			if ($this->Auth->login()){
				//$this->Session->setFlash('登入成功');
				
				$u = $this->Session->read('Auth.User');
				$o = $this->getUser($u['username']);
				//CakeLog::debug(print_r($o, true));
				if ($o == null){
					$this->User->create();
					$this->User->set(array(
						'id' => $u['username'],
						'group' => 'User',
						'balance' => 0,
						'status' => 'A',
						'created_by' => $u['username'],
						'modified_by' => $u['username']
						//'created' => date("Y-m-d H:i:s"),
						//'modified' => date("Y-m-d H:i:s")
					));
					//CakeLog::debug(print_r($this->validateErrors(), true));
					$this->User->save();
					//CakeLog::debug($this->id . '|' . $this->User->validateErrors);

					//CakeLog::debug(print_r($user, true));
					//CakeLog::debug('bool|' . print_r($bool, true) . '|' . $this->validationErrors);
					
					CakeLog::info('New user added : ' . $u['username'] . ' by ' . $this->request->clientIp());
					$u['Role'] = 'User';
				}else{
					$u['Role'] = $o['User']['group'];
				}
				
				$mt4User = $this->User->query('SELECT * FROM ax_mt4_users as Mt4User where id = ' . $u['username']);
				/*
				$mt4Ctrl = new Mt4UsersController();
				$mt4Ctrl->constructClasses();
				
				$mt4User = $mt4Ctrl->getMt4User($u['username']);
				*/
				$u['name'] = $mt4User[0]['Mt4User']['name'];
				$u['email'] = $mt4User[0]['Mt4User']['email'];
				
				//CakeLog::debug(print_r($mt4User, true));
				
				$this->Session->write('Auth.User', $u);
				$this->redirect($this->Auth->redirect());
			} else {
				$this->Session->setFlash('登入名稱或密碼錯誤');
			}
		}
	
		if ($this->Auth->login()) {
			$this->redirect($this->Auth->redirect());
		}
	}

	public function index(){
		
	}
	
	public function viewajax(){
		$user = $this->User->find('first', array('conditions' => array('id' => $this->Session->read('Auth.User')['username'])));
		$this->autoRender = false;
		 
		echo json_encode($user);
	}
	
	public function view(){
		
	}

	public function home($id = null){
	    if (!$id) {
            //throw new NotFoundException(__('Invalid post'));
            $id = $this->Session->read('Auth.User')['username'];
        }
        
        if ($id != $this->Session->read('Auth.User')['username'] && $this->Session->read('Auth.User')['Role'] != 'Admin'){
        	throw new Exception('您沒有存取權限');
        }
		
        /**
		 * 查询所有User相关数据模型
		 * 包括 User、UserAsset、Open
		 */
        $this->User->recursive=1;
		//$user = $this->User->findById($id, array('contain' => array('UserAsset' => array('Asset'))));
        $user = $this->User->find('first', array(
        		'conditions' => array('id' => $id),
        		'contain' => array('UserAsset' => array('Asset'))));
        if (!$user) {
            throw new NotFoundException(__('Invalid post'));
        }
        
		$hold = array();
		$hold['total'] = 0;
		$hold['sum'] = 0;		
		$hold['userinfo'] = $user['User'];
        $hold['UserAsset'] = $user['UserAsset'];
        $hold['money'] = $hold['userinfo']['balance'];
        		
		foreach ($hold['UserAsset'] as $i => $userasset) {
			if ($userasset['volume'] > 0){
		        $asset_id = $userasset['asset_id'];
		        //$userasset['volume'] -= $this->OpenCtl->getOpenSell($asset_id);
		        $hold['Assets'][$asset_id]['earning'] = 0;
		        $hold['Assets'][$asset_id]['Asset'] = $userasset['Asset'];
		        $transactions = $this->TranCtl->findByAssetId($asset_id, 'last');
		        /*$transactions = $this->requestAction(
		        	array(
		        		'controller' => 'Transactions',
		        		'action' => 'findByAssetId',
		        		$asset_id,
		        		'last'
		        	)
		        );*/
		        if($transactions){
		        	$hold['Assets'][$asset_id]['lastclose_price'] = $transactions[0]['Transaction']['close_price'];		        
			        //$hold['total'] += $hold['Assets'][$asset_id]['lastclose_price'] * $userasset['volume'];			        
			        $hold['Assets'][$asset_id]['earning'] = ($hold['Assets'][$asset_id]['lastclose_price'] - $userasset['average_price']) * $userasset['volume'];
		        }
				else {
					$hold['Assets'][$asset_id]['lastclose_price'] = $hold['Assets'][$asset_id]['Asset']['start_price'];
				}
				$hold['total'] += $hold['Assets'][$asset_id]['lastclose_price'] * $userasset['volume'];
				$hold['Assets'][$asset_id]['average_price'] = $userasset['average_price'];
				$hold['sum'] += $userasset['average_price'] * $userasset['volume'];
				
				$hold['Assets'][$asset_id]['hold_volume'] = $userasset['volume'] - $this->OpenCtl->getOpenSell($asset_id);
				$hold['UserAsset'][$i]['closest_price'] = $this->OpenCtl->getClosestPrice($asset_id, $hold['Assets'][$asset_id]['lastclose_price']);
			}
		}
		$hold['money'] -= $this->OpenCtl->getOpenBuy();
        
		$this->set('hold',$hold);
	}
		
	public function admin_index($keyword = null){
		if ($this->Session->read('Auth.User')['Role'] != 'Admin'){
			throw new Exception('你沒有權限');
		}
		if($keyword)$this->request->data['Search']['Search'] = $keyword;

		$this->request->data = Sanitize::clean($this->request->data);
		
		if(!empty($this->request->data)){
			$conditions = preg_split('/([\s,\.\/\'\";!@#\$%\^\&\*，。！￥…（）])+/', $this->request->data['Search']['Search']);
			if (count($conditions) == 1) {
				if($conditions[0] != ''){
					$search_condition['id LIKE '] = '%'.$conditions[0].'%'; 
				}else {
					$this->Session->setFlash('檢索條件不能為空');
					return ;
				}
			}elseif (count($conditions) > 1){
				$search_conditions =array();
				foreach ($conditions as $condition) {
					if($condition != ''){
						$search_conditions[] = array('id LIKE ' => '%'.$condition.'%');
					}else {
						$this->Session->setFlash('檢索條件不能為空');
						return ;
					} 
				}
				$search_condition =array('OR' => $search_conditions);
			}
			$users = $this->User->find('all', array(
				'conditions' => $search_condition /*array(
					'OR' => $search_condition;
					$search_condition
				)*/
				,'contain' => array('UserAsset' => array('Asset'))
			));
			
			if (!$users) {
				$this->Session->setFlash('沒有相關結果');
				return ;
			}
						
			$result =array();
			foreach ($users as $user) {
				$hold = array();
				$hold['total'] = 0;
				$hold['sum'] = 0;
				$hold['userinfo'] = $user['User'];
				$hold['money'] = $hold['userinfo']['balance'];
		        $hold['earning'] = 0;
		        $temp =array();
						        		
				foreach ($user['UserAsset'] as $userasset) {
			        $asset_id = $userasset['asset_id'];
			        $temp[$asset_id]['Asset'] = $userasset['Asset'];
			        /*$temp[$asset_id]['Asset'] = $this->requestAction(
					   	array(
			        		'controller' => 'Assets',
			        		'action' => 'findById',
			        		$asset_id
			        	)
			        )['Asset'];*/
			        /*$transactions = $this->requestAction(
			        	array(
			        		'controller' => 'Transactions',
			        		'action' => 'findByAssetId',
			        		$asset_id,
			        		'last'
			        	)
			        );*/
			        $transactions = $this->TranCtl->findByAssetId($asset_id, 'last');
			        if($transactions){
			        	$temp[$asset_id]['lastclose_price'] = $transactions[0]['Transaction']['close_price'];		        
			            $hold['total'] += $temp[$asset_id]['lastclose_price'] * $userasset['volume'];
				        $hold['money'] -= $this->OpenCtl->getOpenBuy($asset_id);
			        	$hold['earning'] += ($temp[$asset_id]['lastclose_price'] - $userasset['average_price']) * $userasset['volume'];
			        }
			        $hold['sum'] += $userasset['volume'] * $userasset['average_price'];
				}
				$result[$hold['userinfo']['id']] = $hold;
			}

			$this->set('result',$result);
			$this->set('keyword',$this->request->data['Search']['Search']);
		}		
	}
	
	public function changestatus($id,$status,$keyword) {
	    if ( $this->Session->read('Auth.User')['Role'] != 'Admin'){
	    	$this->Session->setFlash('您沒有權限');
	    	return ;
        }
		if (!$id) {
            throw new NotFoundException(__('Invalid post'));
        }
        $this->User->recursive=-1;
		$user = $this->User->findById($id);
        if (!$user) {
            throw new NotFoundException(__('Invalid post'));
        }
        $this->User->id = $id;
        $this->User->set('status', $status);
        $this->User->set('modified_by', $this->Session->read('Auth.User')['username']);
        if($this->User->save()){
	        switch ($status) {
	        	case 'A':
	        	$this->Session->setFlash($user['User']['id'].'啟用成功');
	        	break;
	        	case 'D':
	        	$this->Session->setFlash($user['User']['id'].'禁用成功');
	        	break;
	        }
        }else {
        	$this->Session->setFlash('操作失敗');
        }
		$this->redirect(str_replace('/'.$keyword, '', $this->referer(null,true)).'/'.$keyword);
   	}
   	
	public function deposit($id,$keyword) {
		if (!$id) {
            throw new NotFoundException(__('Invalid post'));
        }
	    if ( $this->Session->read('Auth.User')['Role'] != 'Admin'){
	    	$this->Session->setFlash('您沒有權限');
	    	return ;
        }
        $this->User->recursive=-1;
		$user = $this->User->findById($id);
        if (!$user) {
            throw new NotFoundException(__('Invalid post'));
        }
        $this->User->id = $id;

        $this->request->data = Sanitize::clean($this->request->data);
        
        if(!empty($this->request->data['deposit'])){
        	if(!is_numeric($this->request->data['deposit']['deposit']) || 0 > $this->request->data['deposit']['deposit'] ){
        		$this->Session->setFlash('Please enter a positive number');
        		return ;
        	}
        	$balance = $this->request->data['deposit']['deposit']+$user['User']['balance'];
	        $balance = sprintf('%.3f', $balance);
	        $this->User->set('balance', $balance);
	        $this->User->set('modified_by', $this->Session->read('Auth.User')['username']);
	        $comment = $this->request->data['deposit']['comment'];
	        if($this->User->save()){
	        	/*$this->requestAction('Transactions/add/'.$user['User']['id'].
	        		'/'.$this->request->data['deposit']['deposit'].'/D');*/
	        	$this->TranCtl->add($user['User']['id'], $this->request->data['deposit']['deposit'], $comment, 'D');
		       	$this->Session->setFlash($user['User']['id'].'成功存入'.number_format($this->request->data['deposit']['deposit'], 3, '.', ',').'港幣');
	        }else {
	        	$this->Session->setFlash('存入失敗');
	        }
			$this->redirect(array('controller' => 'Users', 'action' => 'admin_index',$keyword));
        }
	}
	
	public function withdrawal($id,$keyword) {
		if (!$id) {
            throw new NotFoundException(__('Invalid post'));
        }
	    if ( $this->Session->read('Auth.User')['Role'] != 'Admin'){
	    	$this->Session->setFlash('您沒有權限');
	    	return ;
        }
        $this->User->recursive=-1;
		$user = $this->User->findById($id);
        if (!$user) {
            throw new NotFoundException(__('Invalid post'));
        }
        $this->User->id = $id;

        $this->request->data = Sanitize::clean($this->request->data);
        
        if(!empty($this->request->data['withdrawal'])){
        	if(!is_numeric($this->request->data['withdrawal']['withdrawal']) || 0 > $this->request->data['withdrawal']['withdrawal']){
        		$this->Session->setFlash('Please enter a positive number');
        		return ;
        	}
        	$money = $this->Session->read('result')[$id]['money'];
	        if ($money < $this->request->data['withdrawal']['withdrawal']){
	        	$this->Session->setFlash('您提取的金額已超出可動用資金');
	        	return ;
	        }
	        $balance = $user['User']['balance'] - $this->request->data['withdrawal']['withdrawal'];
	        $balance = sprintf('%.3f', $balance);
	        $this->User->set('balance', $balance);
	        $this->User->set('modified_by', $this->Session->read('Auth.User')['username']);
	        $comment = $this->request->data['withdrawal']['comment'];
	        if($this->User->save()){
	        	/*$this->requestAction('Transactions/add/'.$user['User']['id'].
	        		'/'.$this->request->data['withdrawal']['withdrawal'].'/W');*/
	        	$this->TranCtl->add($user['User']['id'], $this->request->data['withdrawal']['withdrawal'], $comment, 'W');
		       	$this->Session->setFlash($user['User']['id'].'成功取出'.number_format($this->request->data['withdrawal']['withdrawal'], 3, '.', ',').'港幣');	        
	        }else {
	        	$this->Session->setFlash('取出失敗');
	        }
			$this->redirect(array('controller' => 'Users', 'action' => 'admin_index', $keyword));
        }
	}
	
	public function logout() {
		$this->Session->setFlash('請重新登入或關閉視窗');
		$this->redirect($this->Auth->logout());
	}
	
	public function getUser($id){
		$this->User->id = $id;
		if ($this->User->exists()) {
			return $this->User->findById($id);
		} else {
			return null;
		}
	}
	
	public function listUsernameByRole($role) {
		return $this->User->find('list', array('conditions' => array('role' => $role), 'fields' => 'id'));
	}
	
	public function listAllUsernames() {
		return $this->User->find('list', array('fields' => 'id'));
	}
	
	public function getUsername(){
		return $this->Session->read('Auth.User')['username'];
	}
	
	public function getUserBalance() {
		return $this->User->findById($this->Session->read('Auth.User')['username'])['User']['balance'];
	}
	
	public function tradeChangeBalance($buyer, $seller, $b_amount, $s_amount){
		$buy = $this->getUser($buyer);
		$sell = $this->getUser($seller);
		
		if (empty($buy) || empty($sell)){
			throw Exception('Error [1000]');
		}else{
			$buy['User']['balance'] -= $b_amount;
			$sell['User']['balance'] += $s_amount;
		}
		
		$this->User->saveMany(array($buy, $sell));
		
	}
	
	
	public function assignChangeBalance($buyer,$b_amount){
		$buy = $this->getUser($buyer);
		
		if (empty($buy)){
			return false;
		}else{
			$buy['User']['balance'] -= $b_amount;
			$buy['User']['modified_by'] = $this->Session->read('Auth.User')['username'];
			$buy['User']['modified'] = date('Y-m-d H:i:s');
		}
		
		if($this->User->save($buy)){
			return true;
		}else {
			return false;
		}
		
	}
}



	