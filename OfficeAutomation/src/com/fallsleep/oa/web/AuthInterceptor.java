package com.fallsleep.oa.web;

import javax.annotation.Resource;

import org.apache.struts2.ServletActionContext;

import com.fallsleep.oa.model.ActionResource;
import com.fallsleep.oa.service.AclService;
import com.fallsleep.oa.service.ResourceService;
import com.fallsleep.oa.vo.LoginInfoVO;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;

public class AuthInterceptor extends AbstractInterceptor {
	@Resource
	private ResourceService resourceService;
	@Resource
	private AclService aclService;
	@Override
	public String intercept(ActionInvocation invocation) throws Exception {
		// 取到要调用的类名
		String className = invocation.getProxy().getAction().getClass().getName();
		// 根据类名查找ActionResource对象
		ActionResource ar = resourceService.findActionResourceByClassName(className);
		// 如果action不是一种资源，则表示无需权限控制
		if(ar == null){
			return invocation.invoke();
		}
		// 得到调用方法
		String methodName = invocation.getProxy().getMethod();
		// 根据方法名可以得到操作的唯一标识
		String operSn = ar.getOperSn(methodName);
		// 如果没找到操作标识，说明方法没有定义操作，无需权限控制
		if(operSn == null){
			return invocation.invoke();
		}
		// 查找主体
		int userId = ((LoginInfoVO) ServletActionContext.getRequest().getSession().getAttribute("login")).getId();
		// 判断是否允许当前登录用户执行本资源的操作，如果允许
		if(aclService.hasPermission(userId, ar.getSn(), operSn)){
			return invocation.invoke();
		}
		throw new RuntimeException("你无权执行[resourceSn=" + ar.getSn() + ",operSn=" + operSn + "]的操作，请联系管理员！");
	}

}
