<?php

class MessagesController extends AppController {
	var $name = 'Messages';

	public $helpers = array('Html', 'Form', 'Session');
	public $components = array('Session');
	
	public function getAllTemplate(){
		return $this->Message->MessageTemplate->find('all');
	}
	
	public function loadTemplate($id){
		return $this->Message->MessageTemplate->findById($id);
	}
	
	//Example:
	//$option['body']['var'] = array('{firstname}','{lastname}','{order_id}','{order_value}', '{ship_date}');
	//$option['body']['data'] = array('yada', 'smeg', '873545', '235.45', date('d/m/Y'));
	public function sendTemplate($user, $msg_tmpl, $option = null){
		//$msg_tmpl = $this->loadTemplate($template);

		if (isset($option['subject'])){
			$subject = str_replace($option['subject']['var'], $option['subject']['data'], $msg_tmpl['MessageTemplate']['subject']);
		}else
			$subject = $msg_tmpl['MessageTemplate']['subject'];
		
		if (isset($option['body'])){
			$body = str_replace($option['body']['var'], $option['body']['data'], $msg_tmpl['MessageTemplate']['body']);
		}else
			$body = $msg_tmpl['MessageTemplate']['body'];
		
		$this->Message->create();
		$this->Message->set(array(
			'user_id' => $user,
			'message_template_id' => $msg_tmpl['MessageTemplate']['id'],
			'subject' => $subject,
			'body' => nl2br($body),
			'type' => $msg_tmpl['MessageTemplate']['type'],
			'status' => 'N',
			'created_by' => $this->Session->read('Auth.User')['username'],
			'modified_by' => $this->Session->read('Auth.User')['username'],
			'created' => date("Y-m-d H:i:s"),
			'modified' => date("Y-m-d H:i:s")
		));
		
		$this->Message->save();
	}
	
	public function index(){
		$msg = $this->Message->find('all', array('conditions'=>array('user_id'=>$this->Session->read('Auth.User')['username']),
												'order' => array('Message.created DESC')
				));
		
		$this->set('msgs', $msg);
		
		$this->set('jsIncludes', array('jquery-ui.min'));
		$this->set('cssIncludes', array('jquery-ui.min'));
	}
	
	public function view($id){
		$msg = $this->Message->findById($id);
		
		if ($msg['Message']['status'] == 'N'){
			//$this->Message->id = $id;
			$this->Message->updateAll(array('Message.status' => '"R"', 'Message.modified_by' => $this->Session->read('Auth.User')['username']),
									array('Message.id' => $id));
		}
		
		$this->layout = 'ajax';
		$this->set('msg', $msg);
	}
	
	public function getTemplateByName($name){
		return $this->Message->MessageTemplate->find('first', array('conditions'=>array('name'=>$name)));
	}
	
	public function getUnreadCount(){
		return $this->Message->find('count', array('conditions'=>array('user_id'=>$this->Session->read('Auth.User')['username'], 'Message.status'=>'N')));
	}
}