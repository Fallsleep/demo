package com.fallsleep.oa.model;

public class ACL {
	private int id;
	private String principalType;
	private int principalId;
	private String resourceType;
	private int resourceId;
	private int aclState;
	private int aclTriState;
	
	public void setPermission(int index, boolean permit, boolean ext){
		if(index < 0 || index > 31){
			throw new RuntimeException("操作索引有误，必须选定0-31之间的值");
		}
		aclTriState = setBit(aclTriState, index, ext);//第index位如果是继承状态，设置为1，否则为0
		aclState = setBit(aclState, index, permit);
	}
	
	public boolean isPermit(int index){
		return getBit(aclState, index);
	}
	
	public boolean isExt(int index){
		return getBit(aclTriState, index);
	}
	private boolean getBit(int i, int index) {
		int temp = 1;
		temp = temp << index;
		temp = i & temp;
		if(temp != 0){
			return true;
		}
		return false;
	}

	public int setBit(int i, int index, boolean value) {
		int temp = 1;
		temp = temp << index;
		if(value){
			i = i | temp;
		}else{
			temp = ~temp;
			i = i & temp;
		}
		return i;
	}
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getPrincipalType() {
		return principalType;
	}
	public void setPrincipalType(String principalType) {
		this.principalType = principalType;
	}
	public int getPrincipalId() {
		return principalId;
	}
	public void setPrincipalId(int principalId) {
		this.principalId = principalId;
	}
	public String getResourceType() {
		return resourceType;
	}
	public void setResourceType(String resourceType) {
		this.resourceType = resourceType;
	}
	public int getResourceId() {
		return resourceId;
	}
	public void setResourceId(int resourceId) {
		this.resourceId = resourceId;
	}
	public int getAclState() {
		return aclState;
	}
	public void setAclState(int aclState) {
		this.aclState = aclState;
	}
	public int getAclTriState() {
		return aclTriState;
	}
	public void setAclTriState(int aclTriState) {
		this.aclTriState = aclTriState;
	}
}
