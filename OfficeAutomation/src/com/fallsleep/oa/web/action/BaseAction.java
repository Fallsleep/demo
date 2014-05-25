package com.fallsleep.oa.web.action;

import javax.annotation.Resource;

import org.apache.struts2.ServletActionContext;

import com.fallsleep.oa.service.AclService;
import com.fallsleep.oa.vo.LoginInfoVO;

public class BaseAction {
	@Resource
	private AclService aclService;
	/**
	 * 从HttpSession中取出当前登录用户的信息
	 * @return
	 */
	protected LoginInfoVO currentUser(){
		return (LoginInfoVO) ServletActionContext.getRequest().getSession().getAttribute("login");
	}
	
	public boolean permit(String resourceSn, String operSn){
		return aclService.hasPermission(currentUser().getId(), resourceSn, operSn);
	}
}
