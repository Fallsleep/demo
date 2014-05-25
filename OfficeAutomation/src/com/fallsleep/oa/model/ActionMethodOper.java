package com.fallsleep.oa.model;

import org.apache.commons.lang3.ArrayUtils;

public class ActionMethodOper {
	/**
	 * 操作唯一标识，如：ADD,UPDATE,DEL,READ
	 */
	private String operSn;
	/**
	 * 操作存储在aclState中的索引位置，必须大于0，小于或等于31
	 * 同一资源中不同操作索引值是唯一的，不能重复
	 */
	private int operIndex;
	/**
	 * 方法名，同一种操作可能对应多个方法
	 * 比如：add|addInput,updateInput|update
	 */
	private String methodName;
	/**
	 * 操作的名称
	 * 如：添、删、改、查询等
	 */
	private String operName;
	
	public void addMethodName(String methodName){
		if(this.methodName == null){
			this.methodName = methodName;
		}
		else{
			String[] methodNames = this.methodName.split("\\|");
			if(!ArrayUtils.contains(methodNames, methodName)){
				this.methodName += "|" + methodName;
			}
		}
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
