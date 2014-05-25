package com.fallsleep.oa.web;

import org.apache.struts2.ServletActionContext;

import com.fallsleep.oa.SystemContext;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;

public class PagerInterceptor extends AbstractInterceptor {

	@Override
	public String intercept(ActionInvocation invocation) throws Exception {
		SystemContext.setOffset(getOffset());
		SystemContext.setPagesize(getPagesize());
		
		try {
			return invocation.invoke();
		} finally {
			SystemContext.removeOffset();
			SystemContext.removePagesize();
		}
	}

	private int getOffset(){
		int offset = 0;
		try {
			offset = Integer.parseInt(ServletActionContext.getRequest().getParameter("iDisplayStart"));
		} catch (NumberFormatException e) {
		}
		return offset;
	}
	private int getPagesize(){
		int pagesize = 10;
		try {
			pagesize = Integer.parseInt(ServletActionContext.getRequest().getParameter("iDisplayLength"));
		} catch (NumberFormatException e) {
		}
		return pagesize;
	}
}

