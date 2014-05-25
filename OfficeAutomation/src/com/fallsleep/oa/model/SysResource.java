package com.fallsleep.oa.model;

import java.util.List;

public interface SysResource {
	public int getResourceId();
	public int[] getOperIndexs();
	public String getResourceType();
	public List<SysResource> getChildrenResource();
	public String getSn();
	public int getOperIndexByOperSn(String operSn);
}
