<?php

App::import('Controller', 'Messages');
App::import('Controller', 'Assets');
App::import('Controller', 'Users');
App::import('Controller', 'Transactions');
App::uses('Sanitize', 'Utility');

class UserAssetsController extends AppController {
	var $name = 'UserAssets';
	public $AssetCtl;
	public $UserCtl;
	public $TransactionCtl;
	public $OpenCtl;
	
	public function beforeFilter(){
		$this->AssetCtl = new AssetsController();
		$this->AssetCtl->constructClasses();
		$this->UserCtl = new UsersController();
		$this->UserCtl->constructClasses();
		$this->TransactionCtl = new TransactionsController();
		$this->TransactionCtl->constructClasses();
		$this->OpenCtl = new OpensController();
        $this->OpenCtl->constructClasses();
	}

	public function getUserAssetVolume($asset_id) {
		$asset = $this->UserAsset->findByUserIdAndAssetId($this->Session->read('Auth.User')['username'], $asset_id)['UserAsset']['volume'];
		
		return !empty($asset)?$asset:0;
	}

	public function getUserAsset($asset_id) {
		$this->UserAsset->recursive = -1;
		$asset = $this->UserAsset->findByUserIdAndAssetId($this->Session->read('Auth.User')['username'], $asset_id);
		
		return isset($asset)?$asset:null;
	}
	
	public function assign($asset_id) {
	    if ( $this->Session->read('Auth.User')['Role'] != 'Admin'){
	    	$this->Session->setFlash('您沒有權限');
	    	return ;
        }
		$asset = $this->AssetCtl->findById($asset_id);
		$users = $this->UserCtl->listAllUsernames();
		sort($users);
		
		$this->set('asset',$asset);
		$this->set('users',$users);
		
		date_default_timezone_set('Asia/Hong_Kong');
        $CURRENT_TMIE = date('Y-m-d H:i:s');

        $this->request->data = Sanitize::clean($this->request->data);
        
		if($this->request->data){			
			$user_key = $this->request->data['Assign']['user'];
			$volume = $this->request->data['Assign']['volume'];
			$price = $this->request->data['Assign']['price'];
			$user = $this->UserCtl->getUser($users[$user_key]);
			$money = $user['User']['balance'] - $this->OpenCtl->getOpenBuyByUserId($users[$user_key]);
			$asset_id = $this->request->data['Assign']['asset_id'];
			if ($volume <= 0) {
				$this->Session->setFlash('股數應為正數');
				return ;
			}
			if($asset['Asset']['available_share'] - $asset['Asset']['sold_share'] < $volume){
				$this->Session->setFlash('已發行股份不足');
				return ;
			}
			if($money < $volume * $price){
				$this->Session->setFlash('可動用資金不足');
				return ;
			}
			
			//CakeLog::debug($asset_id . '|' . $users[$user_key]);
			
			if($userAsset = $this->UserAsset->find('first', array('conditions' => array('asset_id' => $asset_id, 'user_id' => $users[$user_key])))){
				//CakeLog::debug(print_r($userAsset, true));
				$this->UserAsset->id = $userAsset['UserAsset']['id'];
				$this->UserAsset->set(array(
					'user_id' => $users[$user_key],
					'volume' => $userAsset['UserAsset']['volume'] + $volume,
					'average_price' => (($userAsset['UserAsset']['volume'] * $userAsset['UserAsset']['average_price']) + ($price * $volume))/($userAsset['UserAsset']['volume'] + $volume),
		        	'modified' => $CURRENT_TMIE,
		        	'modified_by' => $this->Session->read('Auth.User')['username']
				));
				if($this->UserAsset->save()&&$this->UserCtl->assignChangeBalance($users[$user_key], $volume * $price)
				&&$this->TransactionCtl->addAssignTransaction($users[$user_key], $asset_id, $volume, $price)
				&&$this->AssetCtl->updateSold_share($asset_id, $asset['Asset']['sold_share'] + $volume)){
					$this->Session->setFlash('分配成功');
					$this->redirect(array('controller' => 'Assets', 'action' => 'view', $asset_id));
				}else{
					$this->Session->setFlash('分配失败');
				}
			}else {
				$this->UserAsset->create();
				$this->UserAsset->set(array(
					'user_id' => $users[$user_key],
					'asset_id' => $asset_id,
					'volume' => $volume,
					'average_price' => $price,
					'status' => 'A',
					'created' => $CURRENT_TMIE,
					'created_by' => $this->Session->read('Auth.User')['username'],
		        	'modified' => $CURRENT_TMIE,
		        	'modified_by' => $this->Session->read('Auth.User')['username']
				));
				if($this->UserAsset->save()&&$this->UserCtl->assignChangeBalance($users[$user_key], $volume * $price)
				&&$this->TransactionCtl->addAssignTransaction($users[$user_key], $asset_id, $volume, $price)
				&&$this->AssetCtl->updateSold_share($asset_id, $asset['Asset']['sold_share'] + $volume)){
						$this->Session->setFlash('分配成功');
						$this->redirect(array('controller' => 'Assets', 'action' => 'view', $asset_id));
				}else{
					$this->Session->setFlash('分配失败');
				}
			}
		}
	}
	
	public function tradeToUserAsset($buyer, $seller, $asset_id, $volume, $buy_price, $sell_price, $caller){
		
		$b_asset = $this->UserAsset->find('first', array('conditions' => array('asset_id' => $asset_id, 'user_id' => $buyer)));
		$s_asset = $this->UserAsset->find('first', array('conditions' => array('asset_id' => $asset_id, 'user_id' => $seller)));
		if (empty($s_asset)){
			throw Exception('Error [1000]');
		}else{
			//$s_asset['UserAsset']['average_price'] = (($s_asset['UserAsset']['average_price'] * $s_asset['UserAsset']['volume']) -
			//		($sell_price * $volume)) / ($s_asset['UserAsset']['volume'] + $volume);
			$s_asset['UserAsset']['volume'] = $s_asset['UserAsset']['volume'] - $volume;
			
			$s_asset['UserAsset']['modified_by'] = $caller;
		}
		
		if (empty($b_asset)){
			$this->UserAsset->create();
				
			$b_asset['UserAsset']['asset_id'] = $asset_id;
			$b_asset['UserAsset']['status'] = 'A';
				
			$b_asset['UserAsset']['average_price'] = $buy_price;
			$b_asset['UserAsset']['volume'] = $volume;
		
			$b_asset['UserAsset']['user_id'] = $buyer;
			
			$b_asset['UserAsset']['created_by'] = $b_asset['UserAsset']['modified_by'] = $caller;
		}else{
			$b_asset['UserAsset']['average_price'] = (($b_asset['UserAsset']['average_price'] * $b_asset['UserAsset']['volume']) +
					($buy_price * $volume)) / ($b_asset['UserAsset']['volume'] + $volume);
			$b_asset['UserAsset']['volume'] = $b_asset['UserAsset']['volume'] + $volume;
				
			$b_asset['UserAsset']['modified_by'] = $caller;
		}
		
		$this->UserAsset->saveMany(array($s_asset, $b_asset));
		
		$msgCtrl = new MessagesController();
		$msgCtrl->constructClasses();
		
		$template = $msgCtrl->getTemplateByName('交易成功');
		$msgCtrl->sendTemplate($buyer, $template, 
				array('subject'=>array('var'=>array('{SYMBOL}'), 'data'=>array($s_asset['Asset']['symbol'])),
					  'body'=>array('var'=>array('{ACTION}', '{TRAN_DATE}','{SYMBOL}','{ASSET_NAME}','{PRICE}','{VOLUME}','{TOTAL}'),
					  				'data'=>array('買入', date("Y-m-d H:i:s"), $s_asset['Asset']['symbol'], 
					  							$s_asset['Asset']['name'], $buy_price, $volume, $buy_price * $volume)
		)));
		
		$msgCtrl->sendTemplate($seller, $template,
				array('subject'=>array('var'=>array('{SYMBOL}'), 'data'=>array($s_asset['Asset']['symbol'])),
						'body'=>array('var'=>array('{ACTION}', '{TRAN_DATE}','{SYMBOL}','{ASSET_NAME}','{PRICE}','{VOLUME}','{TOTAL}'),
								'data'=>array('賣出', date("Y-m-d H:i:s"), $s_asset['Asset']['symbol'],
										$s_asset['Asset']['name'], $sell_price, $volume, $sell_price * $volume)
						)));
	}
}