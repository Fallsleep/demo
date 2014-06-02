<?php

App::import('Controller', 'Transactions');
App::import('Controller', 'Assets');
App::import('Controller', 'Opens');
App::import('Controller', 'UserAssets');
App::uses('Sanitize', 'Utility');

class UserFavouritesController extends AppController {
	var $name = 'UserFavourites';
	
	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	
	public $TranCtl;
	public $AssetCtl;
	public $OpenCtl;
	public $UserAssetCtl;
	
	public function beforeFilter() {
		$this->TranCtl = new TransactionsController();
		$this->TranCtl->constructClasses();
		
		$this->AssetCtl = new AssetsController();
		$this->AssetCtl->constructClasses();
		
		$this->OpenCtl = new OpensController();
		$this->OpenCtl->constructClasses();
		
		$this->UserAssetCtl = new UserAssetsController();
		$this->UserAssetCtl->constructClasses();
	}
	
	public function index() {
		$favs = $this->UserFavourite->findAllByUserId($this->Session->read('Auth.User')['username']);
		$i = 0;
		foreach ($favs as $fav) {
			$last = !empty($this->TranCtl->findByAssetId($fav['Asset']['id'], 'last')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($fav['Asset']['id'], 'last')[0]['Transaction']['close_price']:$fav['Asset']['start_price'];
			$prev_close = !empty($this->TranCtl->findByAssetId($fav['Asset']['id'], 'yesterday')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($fav['Asset']['id'], 'yesterday')[0]['Transaction']['close_price']:$fav['Asset']['start_price'];
			$change_per = ($prev_close)?($last-$prev_close)/$prev_close*100:0;
			$day_low = $this->TranCtl->getClosePrice($fav['Asset']['id'], 'd', 'min');
			$day_high = $this->TranCtl->getClosePrice($fav['Asset']['id'], 'd', 'max');
			$user_asset = $this->UserAssetCtl->getUserAsset($fav['Asset']['id']);
			$user_volume = $user_asset['UserAsset']['volume'];
			$avail_volume = $user_asset['UserAsset']['volume']-$this->OpenCtl->getOpenSell($fav['Asset']['id']);
			
			$favs[$i]['last'] = $last;
			$favs[$i]['change'] = $last-$prev_close;
			$favs[$i]['change_per'] = $change_per;
			$favs[$i]['day_low'] = !empty($day_low)?$day_low:$prev_close;
			$favs[$i]['day_high'] = !empty($day_high)?$day_high:$prev_close;
			$favs[$i]['volume'] = number_format($this->TranCtl->getVolume($fav['Asset']['id']));
			$favs[$i]['user_volume'] = !empty($user_asset)?$user_volume:'-';
			$favs[$i]['avail_volume'] = !empty($user_asset)?$avail_volume:'-';
			if (!empty($user_asset)) { $favs[$i]['average_price'] = $user_asset['UserAsset']['average_price']; }
			$favs[$i]['closest_price'] = $this->OpenCtl->getClosestPrice($fav['Asset']['id'], $last);
			$i++;
		}
		
		$this->set('favs', $favs);
	}
	
	public function index_ajax(){
		$this->set('jsIncludes', array('jquery-ui.min'));
		$this->set('cssIncludes', array('jquery-ui.min'));
	}
	
	public function getFavoriteAjax() {
		$favs = $this->UserFavourite->findAllByUserId($this->Session->read('Auth.User')['username']);
		$result = array();
		
		foreach ($favs as $fav) {
			$last = !empty($this->TranCtl->findByAssetId($fav['Asset']['id'], 'last')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($fav['Asset']['id'], 'last')[0]['Transaction']['close_price']:$fav['Asset']['start_price'];
			$prev_close = !empty($this->TranCtl->findByAssetId($fav['Asset']['id'], 'yesterday')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($fav['Asset']['id'], 'yesterday')[0]['Transaction']['close_price']:$fav['Asset']['start_price'];
			$change_per = ($prev_close)?($last-$prev_close)/$prev_close*100:0;
			$day_low = $this->TranCtl->getClosePrice($fav['Asset']['id'], 'd', 'min');
			$day_high = $this->TranCtl->getClosePrice($fav['Asset']['id'], 'd', 'max');
			$user_asset = $this->UserAssetCtl->getUserAsset($fav['Asset']['id']);
			$user_volume = $user_asset['UserAsset']['volume'];
			$avail_volume = $user_asset['UserAsset']['volume']-$this->OpenCtl->getOpenSell($fav['Asset']['id']);

			$result['data'][$fav['UserFavourite']['id']]['asset_id'] = $fav['Asset']['id'];
			$result['data'][$fav['UserFavourite']['id']]['symbol'] = $fav['Asset']['symbol'];
			$result['data'][$fav['UserFavourite']['id']]['last'] = $last;
			$result['data'][$fav['UserFavourite']['id']]['change'] = $last-$prev_close;
			$result['data'][$fav['UserFavourite']['id']]['change_per'] = $change_per;
			$result['data'][$fav['UserFavourite']['id']]['day_low'] = !empty($day_low)?$day_low:$prev_close;
			$result['data'][$fav['UserFavourite']['id']]['day_high'] = !empty($day_high)?$day_high:$prev_close;
			$result['data'][$fav['UserFavourite']['id']]['volume'] = number_format($this->TranCtl->getVolume($fav['Asset']['id']));
			$result['data'][$fav['UserFavourite']['id']]['user_volume'] = !empty($user_asset)?$user_volume:'-';
			$result['data'][$fav['UserFavourite']['id']]['avail_volume'] = !empty($user_asset)?$avail_volume:'-';
			$result['data'][$fav['UserFavourite']['id']]['average_price'] = (!empty($user_asset))?$user_asset['UserAsset']['average_price']:'-';
			$result['data'][$fav['UserFavourite']['id']]['closest_price'] = $this->OpenCtl->getClosestPrice($fav['Asset']['id'], $last);
			
		}
	
		$this->autoRender = false;
    	$this->autoLayout = false;
    	$this->header('Content-Type: application/json');
    	
    	$result['updated'] = date('n月j日  H:i');
    	echo json_encode($result);
	}
	
	public function add() {
		$this->request->data = Sanitize::clean($this->request->data);
		
		if ($this->request->is('post') && !empty($this->request->data)) {
			$asset_id = $this->AssetCtl->getIdBySymbol($this->request->data['UserFavourite']['symbol']);			
			
			// check if this asset exist
			if (empty($asset_id)) {
				$this->Session->setFlash('沒有找到此編號的物業');
				$this->redirect(array('controller' => 'UserFavourites', 'action' => 'index'));
			}
			
			$asset_id = $asset_id[0]['Asset']['id'];
			
			// check if this asset is already on the fav list
			if ($this->UserFavourite->find('count', array('conditions' => array('asset_id' => $asset_id, 'user_id' => $this->Session->read('Auth.User')['username'])))) {
				$this->Session->setFlash('此物業已在您的喜愛列表上');
				$this->redirect(array('controller' => 'UserFavourites', 'action' => 'index'));
			}
			
			$this->UserFavourite->create();	
			$this->UserFavourite->set(array(
										'user_id' => $this->Session->read('Auth.User')['username'], 
										'asset_id' => $asset_id
										));
			
			if ($this->UserFavourite->save($this->request->data)) {
				$this->redirect(array('controller' => 'UserFavourites', 'action' => 'index'));
			}
		}
	}
	
	public function delete($id) {
		if ($this->request->is('post')) {
			if ($this->UserFavourite->delete($id)) {
				$this->redirect(array('controller' => 'UserFavourites', 'action' => 'index'));
			}
		}
	}
}