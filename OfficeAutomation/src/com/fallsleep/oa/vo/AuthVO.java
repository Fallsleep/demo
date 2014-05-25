package com.fallsleep.oa.vo;

public class AuthVO {
	private int resourceId;
	private int operIndex;
	private boolean permit;//true允许 false拒绝
	private boolean ext;//true继承false不继承
	public int getResourceId() {
		return resourceId;
	}
	public void setResourceId(int resourceId) {
		this.resourceId = resourceId;
	}
	public int getOperIndex() {
		return operIndex;
	}
	public void setOperIndex(int operIndex) {
		this.operIndex = operIndex;
	}
	public boolean isPermit() {
		return permit;
	}
	public void setPermit(boolean permit) {
		this.permit = permit;
	}
	public boolean isExt() {
		return ext;
	}
	public void setExt(boolean ext) {
		this.ext = ext;
	}
}
