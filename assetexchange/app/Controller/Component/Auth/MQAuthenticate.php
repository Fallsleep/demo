<?php

App::uses('BaseAuthenticate', 'Controller/Component/Auth');

//define('T_HOST','113.28.223.116'); // MetaTrader Server Address
define('T_HOST','113.28.236.146');   // test server
define('T_PORT',443);                  // MetaTrader Server Port
define('T_TIMEOUT',5);                 // MetaTrader Server Connection Timeout, in sec

class MQAuthenticate extends BaseAuthenticate{
	public function authenticate(CakeRequest $request, CakeResponse $response){
		if (empty($request->data['User']['username']) || empty($request->data['User']['password']))
			return false;
		//CakeLog::debug(print_r($request->data['User'], true));
		
		$res = $this->MQ_Login($request->data['User']['username'], $request->data['User']['password']);
		if ($res){
			return array('username' => $request->data['User']['username'], 'res' => $res);
		}
		
		return false;
	}
		
	function MQ_Query($query)
	{
		$ret = '';
	
		$ptr=@fsockopen(T_HOST,T_PORT,$errno,$errstr,T_TIMEOUT);
		if($ptr)
		{
			//--- If having connected, request and collect the result
			if(fputs($ptr,"W$query\r\nQUIT\r\n")!=FALSE)
			while(!feof($ptr))
			{
				if(($line=fgets($ptr,128))=="end\r\n") break;
				$ret .= $line;
			}
			fclose($ptr);
		}
	
		return $ret;
	}
	
	function MQ_Login($login,$password)
	{
		$login = substr($login,0,14);
		$password = substr($password,0,16);
		//---
		$res = $this->MQ_Query('WAPUSER-'.$login.'|'.$password,'',0);
		//---
		//CakeLog::debug(print_r($res, true));
		if($res=='!!!CAN\'T CONNECT!!!')
		{
			return false;
		}
		//---
		if(strpos($res,'Invalid')!==false || strpos($res,'Disabled')!==false)
		{
			return false;
		}
		else
		{
			return array($res);
		}
	}
}