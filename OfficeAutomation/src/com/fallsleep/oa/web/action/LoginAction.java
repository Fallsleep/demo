package com.fallsleep.oa.web.action;

import java.util.Date;

import javax.annotation.Resource;

import org.apache.struts2.ServletActionContext;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.model.User;
import com.fallsleep.oa.service.UserService;
import com.fallsleep.oa.vo.LoginInfoVO;
import com.opensymphony.xwork2.ActionSupport;

@SuppressWarnings("serial")
@Controller("loginAction")
@Scope("prototype")
public class LoginAction extends ActionSupport{
	private String username;
	private String password;
	@Resource
	private UserService userService;
	
	public String execute(){
		if(username == null){
			return "login";
		}
		User user = userService.login(username, password);
		if(user == null){
			return null;
		}
		LoginInfoVO vo = new LoginInfoVO();
		vo.setId(user.getId());
		vo.setUsername(username);
		vo.setName(user.getPerson().getName());
		vo.setLoginTime(new Date());
		vo.setIp(ServletActionContext.getRequest().getRemoteHost());
		vo.setAvatar(user.getAvatar());
		
		ServletActionContext.getRequest().getSession().setAttribute("login", vo);
		return null;
	}
	
	public String quit(){
		//销毁会话
		ServletActionContext.getRequest().getSession().invalidate();
		return "login";
	}
	
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}

}
