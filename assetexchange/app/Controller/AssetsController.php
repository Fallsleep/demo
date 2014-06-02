<?php

App::import('Controller', 'Transactions');
App::import('Controller', 'Opens');
App::import('Controller', 'Districts');
App::import('Controller', 'AssetImgs');
App::uses('Sanitize', 'Utility');

class AssetsController extends AppController {
	var $name = 'Assets';
	
	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	
	public $TranCtl;
	public $OpenCtl;
	public $DistrictCtl;
	public $AssetImgCtl;
	
	public function beforeFilter(){
		$this->TranCtl = new TransactionsController();
		$this->TranCtl->constructClasses();
		$this->OpenCtl = new OpensController();
		$this->OpenCtl->constructClasses();
		$this->DistrictCtl = new DistrictsController();
		$this->DistrictCtl->constructClasses();
		$this->AssetImgCtl = new AssetImgsController();
		$this->AssetImgCtl->constructClasses();
	}
	
	public function admin_index() {
		if ($this->Session->read('Auth.User')['Role'] != 'Admin'){
			throw new Exception('你沒有存取權限');
		}
		
        $this->Asset->recursive = 0;
        $this->set('assets', $this->Asset->find('all'));
        //$this->set('subtitle_for_layout', '<h1>Yusgroup</h1>');
    }

	public function getAllAssetsAjax() {
        $this->Asset->recursive = -1;  
        $assets = $this->Asset->find('all');
        $res_asset = array();
        foreach ($assets as $asset) {
    		$last = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'last');
    		if(!empty($last))$last = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'last')[0]['Transaction']['close_price'];
    		$yesterday = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'yesterday');
    		if(!empty($yesterday))$yesterday = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'yesterday')[0]['Transaction']['close_price'];
    		
    		$nominal = !empty($last)?$last:($asset['Asset']['start_price']);
    		$prev_close = !empty($yesterday)?$yesterday:$asset['Asset']['start_price'];
    		$change_per = ($prev_close)?($nominal-$prev_close)/$prev_close*100:0;

   		    $res_asset['data'][] = array(
    			'asset_id' => $asset['Asset']['id'],
    			'symbol' => $asset['Asset']['symbol'],
    			'name' => $asset['Asset']['name'],
    			'close_price' => $nominal,
    			'change_per' => $change_per
    		);
        }    
    	$this->autoRender = false;
    	$this->autoLayout = false;
        $this->header('Content-Type: application/json');
        echo json_encode($res_asset);
    }
    
    public function price_chart_data($id){
    	if (!$id) {
    		throw new NotFoundException(__('Invalid post'));
    	}
    	 
    	$asset = $this->Asset->findById($id);
    	if (!$asset) {
    		throw new NotFoundException(__('Invalid post'));
    	}
    	
    	$trans = $this->Asset->Transaction->find('list', array('conditions' => array('asset_id' => $asset['Asset']['id'], 'Transaction.type' => array('B','S'), 
    																'close_time >= ' => date('Y-m-d', time()- (365*24*60*60))),
    															'order' => 'close_time',
    															'fields' => array('close_time', 'close_price'),
    	));
    	
    	//$tran_list = Set::combine($trans, '{n}.0.close_time', array('{0}', '{n}.Transaction.close_price'));
    	
    	//CakeLog::debug(json_encode($trans));
    	/*
    	$str = "[";
    	foreach($trans as $row){
    		if (strlen($str) > 1)
    			$str .= ',';
    		$str = $str . '[' . $row[0]['close_time']*1000 . ',' . $row['Transaction']['close_price'] . ']';
    	}
    	
    	$str .= "]";
    	*/
    	//CakeLog::debug(json_encode($str));
    	
    	$this->autoRender = false;
    	
    	echo json_encode($trans);
    	//echo json_encode(array('data' => $str));
    }
    /*
    public function genpic($asset){
    	$trans = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'all');
    	
    	$chart = new GoogleChart();
    	
    	$chart->type("LineChart");
    	
    	//Options array holds all options for Chart API
    	$chart->options(array('title' => null, 'width' => 250, 'height' => 250));
    	$chart->columns(array(
    			//Each column key should correspond to a field in your data array
    			'event_date' => array(
    					//Tells the chart what type of data this is
    					'type' => 'string',
    					//The chart label for this column
    					'label' => ''
    			),
    			'price' => array(
    					'type' => 'number',
    					'label' => ''
    			)
    	));
    	
    	//Cakelog::debug(print_r($trans, true));
    	
    	$last = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'yesterday');
    	$chart->addRow(array('event_date' => date('H:i:s', mktime(0,0,0)), 'price' => $last[0]['Transaction']['close_price']));
    	
    	foreach($trans as $row){
    		//$chart->addRow(array('event_date' => $row['Model']['field1'], 'score' => $row['Model']['field2']));
    		$chart->addRow(array('event_date' => date('H:i:s',$row['Transaction']['close_time']), 'price' => $row['Transaction']['close_price']));
    		//CakeLog::debug($row['Transaction']['close_time'] .'|'.$row['Transaction']['close_price'].'|'.$row['Transaction']['asset_id'].'|'.$row['Transaction']['type']);
    	}
    	
    	$last = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'last');
    	$chart->addRow(array('event_date' => date('H:i:s'), 'price' => $last[0]['Transaction']['close_price']));
    	
    	//CakeLog::debug(print_r($chart->__get('row')));
    	//$this->price_chart_data($asset['Asset']['id']);
    	return $chart;
    	//$this->set('chart', $chart);
    	//$this->layout="ajax";
    }*/
       
    public function index(){
    	$all = $this->Asset->find('all',array('recursive' => 0));
    	$rise = 0;
    	$fall = 0;
    	$house = 0;
    	$business = 0;
    	$building = 0;
    	$shop = 0;
    	$carport = 0;
    	$other = 0;
    	foreach ($all as $asset) {
	        //取出今天之前最後一次交易
    		$transaction_yesterday = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'yesterday');
	        //今天之前也有交易則取今天交易，否則沒有升跌幅，什麽也不做
	        if($transaction_yesterday){
	    		//取出今天最後一次交易
	        	$transaction_today = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'today');
		        //今天有交易
		        if ($transaction_today) {
		       		$difference = $transaction_today[0]['Transaction']['close_price'] - $transaction_yesterday[0]['Transaction']['close_price'];
		       		$change_per = $difference/$transaction_yesterday[0]['Transaction']['close_price'] *100;
			        if (0 < $difference) {
			        	$topTen['rise'][$rise] = array(
			        		'difference' => $difference,
			        		'Asset' => $asset['Asset'],
			        		'close_price' => $transaction_today[0]['Transaction']['close_price'],
			        		'change_per' => $change_per
			        	);
			        	$rise++;
			        } else if(0 > $difference) {
			        	$topTen['fall'][$fall] = array(
			        		'difference' => $difference,
			        		'Asset' => $asset['Asset'],
			        		'close_price' => $transaction_today[0]['Transaction']['close_price'],
			        		'change_per' => $change_per
			        	);
			        	$fall++;
			        }
		        }else {
		        	$topTen['rise'][$rise] = array(
		        		'difference' => null,
		        		'Asset' => $asset['Asset'],
		        		'close_price' => $transaction_yesterday[0]['Transaction']['close_price']
		        	);
		        	$rise++;
		        	$topTen['fall'][$fall] = array(
		        		'difference' => null,
		        		'Asset' => $asset['Asset'],
		        		'close_price' => $transaction_yesterday[0]['Transaction']['close_price']
		        	);
		        	$fall++;
		        }
	        }else {	        
	    		//取出今天最後一次交易
	        	$transaction_today = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'today');
		        //今天有交易
		        if ($transaction_today) {
		        	$difference = $transaction_today[0]['Transaction']['close_price'] - $asset['Asset']['start_price'];
		        	$change_per = ($transaction_yesterday[0]['Transaction']['close_price'] > 0)?($difference/$transaction_yesterday[0]['Transaction']['close_price'] *100):0;
	       			$topTen['rise'][$rise] = array(
		        		'difference' => $difference,
		        		'Asset' => $asset['Asset'],
		        		'close_price' => $transaction_today[0]['Transaction']['close_price'],
			        	'change_per' => 0
		        	);
		        	$rise++;
		           	$topTen['fall'][$fall] = array(
		        		'difference' => $difference,
		        		'Asset' => $asset['Asset'],
		        		'close_price' => $transaction_today[0]['Transaction']['close_price'],
			        	'change_per' => 0
		        	);
		        	$fall++;  
		        }else {
		        	$topTen['rise'][$rise] = array(
		        		'difference' => null,
		        		'Asset' => $asset['Asset'],
		        		'close_price' => $asset['Asset']['start_price'] //+ $asset['Asset']['spread']
		        	);
		        	$rise++;
		        	$topTen['fall'][$fall] = array(
		        		'difference' => null,
		        		'Asset' => $asset['Asset'],
		        		'close_price' => $asset['Asset']['start_price'] //+ $asset['Asset']['spread']
		        	);
		        	$fall++;
		        }
	        }
	        $transactions = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'all');
		    if($transactions){
		    	$price = 0;
		    	foreach ($transactions as $transaction) {
		    		$price += $transaction['Transaction']['close_price'] * $transaction['Transaction']['volume'];
		    	}
		        switch ($asset['Asset']['type']){
	    			case '0':
	    				$topTen['0'][$house] = array(
			        		'price' => $price,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $transactions[0]['Transaction']['close_price'],
	    					'change_per' => isset($change_per)?$change_per:0
			        	);
				        $house++;
	    				break;
	    			case '1':
	    				$topTen['1'][$business] = array(
			        		'price' => $price,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $transactions[0]['Transaction']['close_price'],
	    					'change_per' => isset($change_per)?$change_per:0
			        	);
				        $business++;
	    				break;
	    			case '2':
	    				$topTen['2'][$building] = array(
			        		'price' => $price,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $transactions[0]['Transaction']['close_price'],
	    					'change_per' => isset($change_per)?$change_per:0
			        	);
				        $building++;
	    				break;
	    			case '3':
	    				$topTen['3'][$shop] = array(
			        		'price' => $price,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $transactions[0]['Transaction']['close_price'],
	    					'change_per' => isset($change_per)?$change_per:0
			        	);
				        $shop++;
	    				break;
	    			case '4':
	    				$topTen['4'][$carport] = array(
			        		'price' => $price,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $transactions[0]['Transaction']['close_price'],
	    					'change_per' => isset($change_per)?$change_per:0
			        	);
				        $carport++;
	    				break;
	    			case '5':
	    				$topTen['5'][$other] = array(
			        		'price' => $price,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $transactions[0]['Transaction']['close_price'],
	    					'change_per' => isset($change_per)?$change_per:0
			        	);
				        $other++;
	    				break;
		        }
		    }else {
		        switch ($asset['Asset']['type']){
	    			case '0':
	    				$topTen['0'][$house] = array(
			        		'price' => null,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $asset['Asset']['start_price'] //+ $asset['Asset']['spread']
			        	);
				        $house++;
	    				break;
	    			case '1':
	    				$topTen['1'][$business] = array(
			        		'price' => null,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $asset['Asset']['start_price'] //+ $asset['Asset']['spread']
			        	);
				        $business++;
	    				break;
	    			case '2':
	    				$topTen['2'][$building] = array(
			        		'price' => null,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $asset['Asset']['start_price'] //+ $asset['Asset']['spread']
			        	);
				        $building++;
	    				break;
	    			case '3':
	    				$topTen['3'][$shop] = array(
			        		'price' => null,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $asset['Asset']['start_price'] //+ $asset['Asset']['spread']
			        	);
				        $shop++;
	    				break;
	    			case '4':
	    				$topTen['4'][$carport] = array(
			        		'price' => null,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $asset['Asset']['start_price'] //+ $asset['Asset']['spread']
			        	);
				        $carport++;
	    				break;
	    			case '5':
	    				$topTen['5'][$other] = array(
			        		'price' => null,
			        		'Asset' => $asset['Asset'],
    						'close_price' => $asset['Asset']['start_price'] //+ $asset['Asset']['spread']
			        	);
				        $other++;
	    				break;
		        }
		    }
    	}
    	function cmp($a, $b){
    		if ($a['difference'] == null) {
    			return 1;
    		}
    		return $a['difference'] < $b['difference'] ? 1 : -1;
    	}
    	function cmpprice($a, $b){
    		if ($a['price'] == null) {
    			return 1;
    		}
    		return $a['price'] < $b['price'] ? 1 : -1;
    	}
    	if($rise){
	    	usort($topTen['rise'],'cmp');
	    	$topTen['rise'] = array_slice($topTen['rise'], 0, 10, true);
	    	$topTen['rise'] =array_pad($topTen['rise'], 10, array());
	    	$this->loadClosestPrice($topTen['rise']);
    	}else{
    		$topTen['rise'] =null;
    	}
    	if($fall){
	    	usort($topTen['fall'],'cmp');
	    	$topTen['fall'] = array_reverse($topTen['fall']);
    		$topTen['fall'] = array_slice($topTen['fall'], 0, 10, true);
	    	$topTen['fall'] =array_pad($topTen['fall'], 10, array());
	    	$this->loadClosestPrice($topTen['fall']);
    	}else {
    		$topTen['fall'] =null;    		
    	}
    	if($house){
	    	usort($topTen['0'],'cmpprice');
    		$topTen['0'] = array_slice($topTen['0'], 0, 10, true);
	    	$topTen['0'] =array_pad($topTen['0'], 10, array());
	    	$this->loadClosestPrice($topTen['0']);
    	}else {
    		$topTen['0'] =null;    		
    	}
    	if($business){
	    	usort($topTen['1'],'cmpprice');
    		$topTen['1'] = array_slice($topTen['1'], 0, 10, true);
	    	$topTen['1'] =array_pad($topTen['1'], 10, array());
	    	$this->loadClosestPrice($topTen['1']);
    	}else {
    		$topTen['1'] =null;    		
    	}
    	if($building){
	    	usort($topTen['2'],'cmpprice');
    		$topTen['2'] = array_slice($topTen['2'], 0, 10, true);
	    	$topTen['2'] =array_pad($topTen['2'], 10, array());
	    	$this->loadClosestPrice($topTen['2']);
    	}else {
    		$topTen['2'] =null;    		
    	}
    	if($shop){
	    	usort($topTen['3'],'cmpprice');
    		$topTen['3'] = array_slice($topTen['3'], 0, 10, true);
	    	$topTen['3'] =array_pad($topTen['3'], 10, array());
	    	$this->loadClosestPrice($topTen['3']);
    	}else {
    		$topTen['3'] =null;    		
    	}
    	if($carport){
	    	usort($topTen['4'],'cmpprice');
    		$topTen['4'] = array_slice($topTen['4'], 0, 10, true);
	    	$topTen['4'] =array_pad($topTen['4'], 10, array());
	    	$this->loadClosestPrice($topTen['4']);
    	}else {
    		$topTen['4'] =null;    		
    	}
    	if($other){
	    	usort($topTen['5'],'cmpprice');
    		$topTen['5'] = array_slice($topTen['5'], 0, 10, true);
	    	$topTen['5'] =array_pad($topTen['5'], 10, array());
	    	$this->loadClosestPrice($topTen['5']);
    	}else {
    		$topTen['5'] =null;    		
    	}
    	
    	
    	$this->set('topTen', $topTen);
    }
    
    public function getTopTenAjax($type){
    	function cmpdiff($a, $b){
    		//CakeLog::debug($a['asset_id'] . '|' . $a['difference'] . '|' . $b['asset_id'] . '|' . $b['difference']);
    		
    		if ($a['change_per'] == $b['change_per'] && $a['total_volume'] == $b['total_volume'])
    			$ret = 0;
    		else
    			$ret = $a['change_per'] < $b['change_per'] ? 1 : ($a['change_per'] > $b['change_per'] ? -1 : (($a['total_volume'] < $b['total_volume']) ? 1 : -1));
    		
    		//CakeLog::debug($a['asset_id'] . '|' . $a['difference'] . '|' . $b['asset_id'] . '|' . $b['difference'] . '|' . $ret);
    		
    		return $ret;
    	}
    	
    	function cmpvolume($a, $b){
    		if ($a['change_per'] == $b['change_per'] && $a['total_volume'] == $b['total_volume'])
    			$ret = 0;
    		else
    			$ret = $a['total_volume'] < $b['total_volume'] ? 1 : ($a['total_volume'] > $b['total_volume'] ? -1 : (($a['change_per'] < $b['change_per']) ? 1 : -1));
    		
    		return $ret;
    	}
    	
    	if (strlen($type) > 2){
    		$all = $this->Asset->find('all',array('recursive' => 0));
    	}else{
    		$all = $this->Asset->find('all',array('conditions' => array('type' => $type), 'recursive' => 0));
    	}
    	
    	//CakeLog::debug(print_r($all, true));
    	
    	foreach ($all as $asset) {
    		$last = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'last')[0]['Transaction']['close_price'];
    		$yesterday = $this->TranCtl->findByAssetId($asset['Asset']['id'], 'yesterday')[0]['Transaction']['close_price'];
    		
    		$nominal = !empty($last)?$last:($asset['Asset']['start_price']);
    		$prev_close = !empty($yesterday)?$yesterday:$asset['Asset']['start_price'];
    		$change_per = ($prev_close)?($nominal-$prev_close)/$prev_close*100:0;
    		
    		$difference = $nominal - $prev_close;
    		
    		$transactions = $this->Asset->Transaction->find('first', array('conditions' => array('asset_id' =>$asset['Asset']['id'], 'close_time >= ' => date('Y-m-d')),
    															'fields' => array('sum(close_price*volume) AS sum')
    		));
  		
    		$topTen['data'][] = array(
    				//'difference' => $difference,
    				'asset_id' => $asset['Asset']['id'],
    				'symbol' => $asset['Asset']['symbol'],
    				'name' => $asset['Asset']['name'],
    				'close_price' => $nominal,
    				'total_volume' => ($transactions[0]['sum'] == null)?0:$transactions[0]['sum'],
    				'change_per' => $change_per
    		);
    	}
    	
    	if (strlen($type) > 2){
    		usort($topTen['data'],'cmpdiff');
     		
    		if ($type == 'fall'){
    			$topTen['data'] = array_reverse($topTen['data']);
    		}
    	}else{
    		usort($topTen['data'],'cmpvolume');
    	}
    	
    	$topTen['data'] = array_slice($topTen['data'], 0, 10, true);
    	$topTen['data'] = array_pad($topTen['data'], 10, array());
    	$this->loadClosestPrice2($topTen['data']);
    	    	
    	$this->autoRender = false;
    	$this->autoLayout = false;
    	$this->header('Content-Type: application/json');
    	
    	$topTen['updated'] = date('n月j日  H:i');
    	echo json_encode($topTen);
    }
    
    public function index_ajax(){
    	
    }
    
    public function loadClosestPrice(&$array){
    	foreach ($array as $i => $row){
    		//CakeLog::debug(print_r($row[$i], true));
    		$array[$i]['closest_price'] = $this->OpenCtl->getClosestPrice($array[$i]['Asset']['id'], $array[$i]['close_price']);
    /*
    		if($row){
    			$array[$i]['closest_price'] = $this->OpenCtl->getClosestPrice($array[$i]['asset_id'], $array[$i]['close_price']);
    		}*/
    		//CakeLog::debug(print_r($array[$i]['closest_price'], true));
    	}
    }
    
    public function loadClosestPrice2(&$array){
    	foreach ($array as $i => $row){
    		//CakeLog::debug(print_r($row[$i], true));
    		//$array[$i]['closest_price'] = $this->OpenCtl->getClosestPrice($array[$i]['Asset']['id'], $array[$i]['close_price']);
    
    		if($row){
    			$array[$i]['closest_price'] = $this->OpenCtl->getClosestPrice($array[$i]['asset_id'], $array[$i]['close_price']);
    		}
    		//CakeLog::debug(print_r($array[$i]['closest_price'], true));
    	}
    }
    
/*    public function showAll(){
    	//$this->layout = 'ajax';
    	$all = $this->Asset->find('all');
    	$this->autoRender = false;
    	
    	echo json_encode($all);
    	//$this->set('content', $this->Asset->find('all'));
    }*/
    

    public function view($id) {
        if (!$id) {
            throw new NotFoundException(__('Invalid post'));
        }
		
        $asset = $this->Asset->findById($id);
        if (!$asset) {
            throw new NotFoundException(__('Invalid post'));
        }
        $this->set('asset', $asset);
        
        $this->set('cssIncludes', array('base', 'reset-fonts-grids', 'photostyle'));
        $this->set('jsIncludes', array('jquery.microgallery', 'jquery.flot.min', 'jquery.flot.time.min'));
        
		$nominal = !empty($this->TranCtl->findByAssetId($id, 'last')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($id, 'last')[0]['Transaction']['close_price']:($asset['Asset']['start_price']);
		$prev_close = !empty($this->TranCtl->findByAssetId($id, 'yesterday')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($id, 'yesterday')[0]['Transaction']['close_price']:$asset['Asset']['start_price'];
		$change_per = ($prev_close)?($nominal-$prev_close)/$prev_close*100:0;
		$open = !empty($this->TranCtl->findByAssetId($id, 'open')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($id, 'open')[0]['Transaction']['close_price']:$prev_close;
		$this->set('nominal', $nominal);
		$this->set('change', $nominal-$prev_close);
		$this->set('change_per', $change_per);
		
		$max = $this->TranCtl->getClosePrice($id, 'd', 'max');
		$min = $this->TranCtl->getClosePrice($id, 'd', 'min');
		$this->set('high_day', !empty($max)?$max:$prev_close);
		$this->set('low_day', !empty($min)?$min:$prev_close);
		$this->set('open', $open);
		$this->set('prev_close', $prev_close);
		$this->set('volume', $this->addNumberScale($this->TranCtl->getVolume($id), 0));
		$this->set('turnover', $this->addNumberScale($this->TranCtl->getTurnover($id), 3));
		$max52 = $this->TranCtl->getClosePrice($id, '52', 'max');
		$min52 = $this->TranCtl->getClosePrice($id, '52', 'min');
		$this->set('high_52', !empty($max52)?$max52:$prev_close);
		$this->set('low_52', !empty($min52)?$min52:$prev_close);
		
		//$this->set('chart', $this->genpic($asset));
		//$this->price_chart_data($asset['Asset']['id']);
		
        return $asset;
    }
    
    public function findById($id) {
        if (!$id) {
            throw new NotFoundException(__('Invalid post'));
        }
		$this->recusive = -1;
        $asset = $this->Asset->find('first',array(
        	'conditions' => array('id' => $id),
        	'recursive' => -1
        ));
        if (!$asset) {
            throw new NotFoundException(__('Invalid post'));
        }
        return $asset;
    }
    public function updateSold_share($id, $sold_share) {
        if (!$id) {
            throw new NotFoundException(__('Invalid post'));
        }
        $this->Asset->id = $id;
        if($this->Asset->save(array('sold_share' => $sold_share, 'modified_by' => $this->Session->read('Auth.User')['username']))){
        	return true;
        }else {
        	return false;
        }
    }
    
    public function findBySymbols($symbols)
	{
    	if (!$symbols)
		{
    		throw new NotFoundException(__('Invalid post'));
    	}
		$search_symbol_condition=array();
    
    	if (count($symbols) == 1)
		{
    		if($symbols[0] != '')
			{
    			$search_symbol_condition['symbol LIKE '] = '%'.$symbols[0].'%';
    		}
    	}
		elseif (count($symbols) > 1)
		{
    		foreach ($symbols as $symbol)
			{
    			if($symbol != '')
				{
    				$search_symbol_conditions[] = array('symbol LIKE ' => '%'.$symbol.'%');
    			}
    		}
    		$search_symbol_condition =array('OR' => $search_symbol_conditions);
    	}
    	$assets = $this->Asset->find('all', array(
    			'conditions' => $search_symbol_condition,
    			'recursive' => -1
    	));
    
    	return $assets;
    }
    
    
	
		public function add() {
		if (!empty($this->request->data) ){
            $this->Asset->create();
            if (!empty($this->data['AssetImg']) && !empty($this->data['AssetImg'][0]['tmp_name'])) {
            	// upload the file to the server
            	$fileOK = $this->uploadFiles('uploads', $this->data['AssetImg']);
            	 
            	if(array_key_exists('urls', $fileOK)) {
            		$i = 0;
            		foreach ($fileOK['urls'] as $url){
            			$this->request->data['AssetImg'][$i++] = array('path' => $url, 'is_cover' => ($i > 1)?0:1, 
            					'created_by' => $this->Session->read('Auth.User')['username'],          					
            					'modified_by' => $this->Session->read('Auth.User')['username']);
            		}
            	} else {
            		throw new Exception(print_r($fileOK['errors']));
            	}
            }
            
            $this->Asset->set(array(
            		'sold_share' => 0,
            		'created_by' => $this->Session->read('Auth.User')['username'],
            		'modified_by' => $this->Session->read('Auth.User')['username']
            ));
            
            if ($this->Asset->saveAssociated($this->request->data)) {
                $this->Session->setFlash('成功新增資料');
                $this->redirect(array('action' => 'admin_index'));
            } else {
                $this->Session->setFlash('未能新增資料');
            }
        }
    }
	
	public function edit($id = null) {
		if (!$id) {
			throw new NotFoundException(__('未能輸入資料'));
		}	

		
		
		$asset = $this->Asset->findById($id);
		if (!$asset) {
			throw new NotFoundException(__('該資料不存在'));
		}

		$this->request->data = Sanitize::clean($this->request->data);
		
		if (isset($this->request->data['cancel'])) {
			$this->Session->setFlash('取消編輯資料');
			$this->redirect(array('action' => 'view', $id));
		} else {
			if ($this->request->is('asset') || $this->request->is('put')) {
				$this->Asset->id = $id;
				
				//print_r($this->data['AssetImg']);
				
				if (!empty($this->data['AssetImg']) && !empty($this->data['AssetImg'][0]['tmp_name'])) {
	            	// upload the file to the server
	            	$fileOK = $this->uploadFiles('uploads', $this->data['AssetImg']);
	            	 
	            	//$this->Asset->AssetImg->deleteAll(array('asset_id' => $id));
	            	
	            	if(array_key_exists('urls', $fileOK)) {
	            		$i = 0;
	            		foreach ($fileOK['urls'] as $url){
	            			$this->request->data['AssetImg'][$i++] = array('asset_id' => $id, 'path' => $url, 'is_cover' => ($i > 1)?0:1, 
            					'created_by' => $this->Session->read('Auth.User')['username'],          					
            					'modified_by' => $this->Session->read('Auth.User')['username']);
	            		}
	            		$this->Asset->AssetImg->saveAll($this->request->data['AssetImg']);
	            	} else {
	            		throw new Exception(print_r($fileOK['errors']));
	            	}
	            }
	            
	            //$this->Asset->set(array('AssetImg' => $this->request->data['AssetImg']));
	            
				$this->Asset->set(array(
						'modified_by' => $this->Session->read('Auth.User')['username']
				));
				if ($this->Asset->save($this->request->data)) {
					$this->Session->setFlash('成功編輯資料');
					$this->redirect(array('action' => 'view', $id));
				} else {
					$this->Session->setFlash('未能編輯資料');
				}
			}
		}

		if (!$this->request->data) {
			$this->request->data = $asset;
		}
	}
	
	public function search() {
		$districts = $this->DistrictCtl->index();
		$this->set('districts', $districts);

		$this->request->data = Sanitize::clean($this->request->data);
		
		if(!empty($this->request->data)){			
			$conditions = array();
			$ds =array();
			foreach ($districts as $id => $district_name) $ds[]=$id;
			foreach($this->request->data['Asset'] as $field => $search_condition ) {				    
				if(!empty($search_condition)){
					if($field == 'district_id'){
						if($search_condition == "unlimited" ){
							$conditions[$field] = $ds;
							continue;
						}
						$conditions[$field." = "] = $search_condition;
					}
															
					if($field == "type"){
						if($search_condition == "unlimited" ){
							$conditions[$field] = array('0', '1', '2', '3', '4', '5');
							continue;
						}
						$conditions[$field." = "] = $search_condition;
					}
					
					if($field == "status"){
						if($search_condition == "unlimited" ){
							$conditions[$field] = array('A', 'IA');
							continue;
						}
						$conditions[$field." = "] = $search_condition;
					}
					
					if($field == "has_rent"){
						if($search_condition == "unlimited" ){
							$conditions[$field] = array('0', '1');
							continue;
						}
						$conditions[$field." = "] = $search_condition;
					}
					$conditions[$field." LIKE "] = "%".$search_condition."%";
				}
			}
			if(!empty($conditions)){
				$this->Asset->recursive = 0;
				$assets_result = $this->Asset->find('all',array('conditions' => $conditions));
				if ($assets_result) {
					foreach ($assets_result as &$asset) {
						$assetImg = $this->AssetImgCtl->findCoverByAssetId($asset['Asset']['id']);
						$asset['AssetImg']['path'] = $assetImg?$assetImg['AssetImg']['path']:null;
						$nominal = !empty($this->TranCtl->findByAssetId($asset['Asset']['id'], 'last')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($asset['Asset']['id'], 'last')[0]['Transaction']['close_price']:($asset['Asset']['start_price']);
						$prev_close = !empty($this->TranCtl->findByAssetId($asset['Asset']['id'], 'yesterday')[0]['Transaction']['close_price'])?$this->TranCtl->findByAssetId($asset['Asset']['id'], 'yesterday')[0]['Transaction']['close_price']:$asset['Asset']['start_price'];
						$change_per = ($prev_close)?($nominal-$prev_close)/$prev_close*100:0;
						$asset['close_price'] = $nominal;
						$asset['change_per'] = $change_per;
					};
					$this->loadClosestPrice($assets_result);
				}
				$this->set('assets_result',$assets_result);
			}
		}
	}
	
	
	public function getLastestPrice($id){
		$transactions = $this->TranCtl->findByAssetId($id, 'last');
		
		if ($transactions){
			return $transactions[0]['Transaction']['close_price'];
		}else{
			$asset = $this->Asset->findById($id);
			
			if ($asset){
				return $asset['Asset']['start_price'];
			}	
		}
	}
	/*
	public function getClosestPrice($id){
		$last_price = $this->getLastestPrice($id);
		
		$bp = $this->Asset->Open->find('first', array('conditions' => array('asset_id' => $id, 'open_price >= ' => $last_price, 'status' => 'A'),
													'order' => array('open_price')));
		$sp = $this->Asset->Open->find('first', array('conditions' => array('asset_id' => $id, 'open_price <= ' => $last_price, 'status' => 'A'),
													'order' => array('open_price DESC')));
		
		return array('B' => $bp, 'S' => $sp);
	}*/
	
	public function getIdBySymbol($symbol) {
		$this->Asset->recursive = -1;
		return $this->Asset->findAllBySymbol($symbol, 'id');
	}
}
?>