<?php
class AssetImgsController extends AppController {
	var $name = 'AssetImgs';
	
	public function findCoverByAssetId($asset_id){
		return $this->AssetImg->find('first',array(
			'conditions' => array(
				'asset_id' => $asset_id,
				'is_cover' => true
			),
			'recursive' => -1
		));
	}
}