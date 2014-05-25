package com.fallsleep.oa.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.ArrayUtils;

import com.opensymphony.xwork2.inject.Container;

public class ActionResource implements SysResource {
	private int id;
	/**
	 * 资源所对应的Action类名（可能有多个，用|线分开(...PartyAction|...CompanyAction)）
	 */
	private String className;
	/**
	 * 资源名称（比如组织机构管理，公文管理）
	 */
	private String name;
	/**
	 * 资源的唯一标识(company,department)
	 */
	private String sn;
	/**
	 * 资源排序号
	 */
	private int orderNumber;
	/**
	 * 资源所包含的操作
	 * key就是ActionMethodOper对象的operSn，该操作的唯一标识，如：ADD,UPDATE,DEL,READ
	 */
	private Map<String, ActionMethodOper> opers;
	/**
	 * 父资源
	 */
	private ActionResource parent;
	/**
	 * 父资源的标识
	 */
	private String parentSn;
	/**
	 * 子资源集合
	 */
	private Set<ActionResource> children = new HashSet<ActionResource>();
	
	public void addActionMethodOper(String methodName, String operName, String operSn, int operIndex){
		if(opers == null){
			opers = new HashMap<String, ActionMethodOper>();
		}
		ActionMethodOper amo = opers.get(operSn);
		if(amo != null){
			amo.addMethodName(methodName);
		}
		else{
			//判断索引值是否已经存在，若存在则抛出异常，因为operIndex不允许重复
			for (ActionMethodOper o : opers.values()) {
				if(o.getOperIndex() == operIndex){
					throw new RuntimeException("针对资源["+ name 	+"]的操作["+ o.getOperName() +"]已经和索引[" 
							+ operIndex + "]绑定，无法把操作["+ operName +"]再次绑定到相同的索引");
				}
			}
			amo = new ActionMethodOper();
			amo.setMethodName(methodName);
			amo.setOperIndex(operIndex);
			amo.setOperName(operName);
			amo.setOperSn(operSn);
			opers.put(operSn, amo);
		}
	}
	
	public void addClassName(String className){
		if(this.className == null){
			this.className = className;
		}
		else{
			String[] classNames = this.className.split("\\|");
			if(!ArrayUtils.contains(classNames, className)){
				this.className += "|" + className;
			}
		}
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getClassName() {
		return className;
	}
	public void setClassName(String className) {
		this.className = className;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getSn() {
		return sn;
	}
	public void setSn(String sn) {
		this.sn = sn;
	}
	public int getOrderNumber() {
		return orderNumber;
	}
	public void setOrderNumber(int orderNumber) {
		this.orderNumber = orderNumber;
	}
	public Map<String, ActionMethodOper> getOpers() {
		return opers;
	}
	public void setOpers(Map<String, ActionMethodOper> opers) {
		this.opers = opers;
	}

	public ActionResource getParent() {
		return parent;
	}

	public void setParent(ActionResource parent) {
		this.parent = parent;
	}

	public String getParentSn() {
		return parentSn;
	}

	public void setParentSn(String parentSn) {
		this.parentSn = parentSn;
	}

	public Set<ActionResource> getChildren() {
		return children;
	}

	public void setChildren(Set<ActionResource> children) {
		this.children = children;
	}

	public void removeActionMethodOper(String operSn) {
		opers.remove(operSn);
	}

	@Override
	public int getResourceId() {
		return id;
	}

	@Override
	public int[] getOperIndexs() {
		if(opers != null){
			Collection<ActionMethodOper> amos = opers.values();
			int[] operIndexs = new int[amos.size()];
			int i = 0;
			for (ActionMethodOper amo : amos) {
				operIndexs[i++] = amo.getOperIndex();
			}
			return operIndexs;
		}
		return null;
	}

	@Override
	public String getResourceType() {
		return "ActionResource";
	}

	@Override
	public List<SysResource> getChildrenResource() {
		if(children != null){
			List<SysResource> res = new ArrayList<SysResource>();
			res.addAll(children);
			return res;
		}
		return null;
	}

	@Override
	public int getOperIndexByOperSn(String operSn) {
		return opers.get(operSn).getOperIndex();
	}

	public String getOperSn(String methodName) {
		if(opers == null){
			return null;
		}
		for (ActionMethodOper oper : opers.values()) {
			if(oper.getMethodName().indexOf(methodName) != -1){
				return oper.getOperSn();
			}
		}
		return null;
	}
}
