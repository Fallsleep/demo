package com.fallsleep.oa.web;

import org.apache.struts2.ServletActionContext;

import com.fallsleep.oa.vo.LoginInfoVO;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;

public class LoginInterceptor extends AbstractInterceptor{

	@Override
	public String intercept(ActionInvocation invocation) throws Exception {
		LoginInfoVO currentUser = (LoginInfoVO) ServletActionContext.getRequest().getSession().getAttribute("login");
		if(currentUser == null){
			/*if(isAjaxRequest()){
				ServletActionContext.getResponse().sendError(408);
				return null;
			}*/
			return "login";
		}
		return invocation.invoke();
	}
	/* main/center/left等页面未放入WEB-INF目录时，未登陆或无权限用户可以直接访问静态页面main/center/left，
	 * 而left通过ajax请求action时会被拦截，虽然返回了index.jsp页面，但是由于ajax方法中对该返回结果无可用回调函数，
	 * 并且ajax是无刷新的，所以整个页面不会刷新，因此定义并使用了isAjaxRequest()方法在未登录时判断是否为ajax请求，
	 * 若为ajax请求则返回408超时错误，并在ajax调用中加入
	 * "error" : function(XMLHttpRequest, textStatus){
	 * 		if(XMLHttpRequest.status == 408){
	 * 			parent.parent.window.location = "index.jsp";
	 * 		}
	 * 	}
	 * 对408错误进行处理，以达到使页面刷新的目的。
	 * 但多数动态页面放入WEB-INF目录后，main/center/left无法直接访问，此问题就不用再考虑了
	private boolean isAjaxRequest() {
	    String header = ServletActionContext.getRequest().getHeader("X-Requested-With");
	    if (header != null && "XMLHttpRequest".equals(header))
	        return true;
	    else
	        return false;
	}*/
}
