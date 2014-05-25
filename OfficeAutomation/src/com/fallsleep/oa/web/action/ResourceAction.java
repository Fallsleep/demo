package com.fallsleep.oa.web.action;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.annotations.Oper;
import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.model.ActionMethodOper;
import com.fallsleep.oa.model.ActionResource;
import com.fallsleep.oa.service.ResourceService;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.vo.ActionResourceTreeVO;
import com.opensymphony.xwork2.ModelDriven;
@Controller("resourceAction")
@Scope("prototype")
@Res(name="资源操作",sn="resource",orderNumber=100,parentSn="security")
public class ResourceAction extends BaseAction implements ModelDriven{
	@Resource
	private ResourceService resourceService;
	private ActionResource model;
	//操作的属性
	private String operSn;
	private int operIndex;
	private String methodName;
	private String operName;
	@Override
	public Object getModel() {
		if(model == null){
			model = new ActionResource();
		}
		return model;
	}
	/**
	 * 打开资源设置主界面
	 * @return
	 */
	@Oper
	public String execute(){
		return "index";
	}
	/**
	 * 生成资源生成界面上的资源树的数据
	 */
	public void tree(){
		List<ActionResource> resources = resourceService.findAllTopActionResources();
		List<ActionResourceTreeVO> vos = new ArrayList<ActionResourceTreeVO>();
		for (ActionResource actionResource : resources) {
			vos.add(new ActionResourceTreeVO(actionResource));
		}
		JSONUtils.toJSON(vos);
	}
	@Oper
	public String addInput(){
		int parentId = model.getParent().getId();
		if(parentId == 0){
			throw new RuntimeException("unknown parent node,can't create child node!");
		}
		return "add_input";
	}
	@Oper
	public String add(){
		resourceService.addActionResource(model);
		return "add_success";
	}
	@Oper
	public String updateInput(){
		model = resourceService.findById(model.getId());
		return "update_input";
	}
	@Oper
	public String update(){
		resourceService.updateActionResource(model);
		return "update_success";
	}
	@Oper
	public String del(){
		resourceService.delActionResource(model.getId());
		return "del_success";
	}
	
	public String oper_input(){
		
		return "oper_input";
	}
	
	public String addOper(){
		ActionMethodOper oper = new ActionMethodOper();
		oper.setMethodName(methodName);
		oper.setOperIndex(operIndex);
		oper.setOperName(operName);
		oper.setOperSn(operSn);
		resourceService.addActionResourceOper(model.getId(), oper);
		return "add_success";
	}
	
	public void delOper(){
		resourceService.delActionResourceOper(model.getId(), operSn);
	}
	public String getOperSn() {
		return operSn;
	}
	public void setOperSn(String operSn) {
		this.operSn = operSn;
	}
	public int getOperIndex() {
		return operIndex;
	}
	public void setOperIndex(int operIndex) {
		this.operIndex = operIndex;
	}
	public String getMethodName() {
		return methodName;
	}
	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}
	public String getOperName() {
		return operName;
	}
	public void setOperName(String operName) {
		this.operName = operName;
	}
}
