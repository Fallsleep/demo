<?php

App::uses('Xml', 'Utility');

class NewsController extends AppController{
	var $name = "News";
	// As the RSS will not currently use a database
	var $uses = array();
	var $feed_url = "http://www.hkej.com/rss/onlinenews.xml";
	var $rss_item = array();

	public $cacheDuration = '+30 mins';
	
	function index(){
		// xml to array conversion
		if (!($this->rss_item = Cache::read('rss.lines'))){
			CakeLog::debug('from web');
			
			$this->rss_item = Xml::toArray(Xml::build($this->feed_url));
			
			Cache::set(array('duration' => $this->cacheDuration));
			Cache::write('rss.lines', $this->rss_item);
		}else{
			CakeLog::debug('from cache');
		}
		
		$this->set('data', $this->rss_item);
		
		$this->set('jsIncludes', array('jquery-ui.min'));
		$this->set('cssIncludes', array('jquery-ui.min'));
	}
	
	function getTopTenNews(){
		// xml to array conversion
		if (!($this->rss_item = Cache::read('rss.lines'))){
			CakeLog::debug('from web');
			
			$this->rss_item = Xml::toArray(Xml::build($this->feed_url));
			
			Cache::set(array('duration' => $this->cacheDuration));
			Cache::write('rss.lines', $this->rss_item);
		}else{
			CakeLog::debug('from cache');
		}
		
		$this->autoRender = false;
    	$this->autoLayout = false;
        $this->header('Content-Type: application/json');
        echo json_encode(array_slice($this->rss_item['rss']['channel']['item'], 0, 10));
	}
}