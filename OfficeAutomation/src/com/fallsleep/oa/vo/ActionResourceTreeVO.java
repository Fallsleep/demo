package com.fallsleep.oa.vo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.fallsleep.oa.model.ActionResource;
import com.fallsleep.oa.model.Menu;

public class ActionResourceTreeVO {
	private Map data = new HashMap();
	private Map attr = new HashMap();
	private List<ActionResourceTreeVO> children = null;
	
	public ActionResourceTreeVO(ActionResource actionResource) {
		this.data.put("title", actionResource.getName());
		this.attr.put("id", actionResource.getId());
		
		Set<ActionResource> children = actionResource.getChildren();
		if(children != null && children.size() > 0){
			this.children = new ArrayList<ActionResourceTreeVO>();
			for (ActionResource a : children) {
				this.children.add(new ActionResourceTreeVO(a));
			}
		}
	}
	public Map getData() {
		return data;
	}
	public void setData(Map data) {
		this.data = data;
	}
	public Map getAttr() {
		return attr;
	}
	public void setAttr(Map attr) {
		this.attr = attr;
	}
	public List<ActionResourceTreeVO> getChildren() {
		return children;
	}
	public void setChildren(List<ActionResourceTreeVO> children) {
		this.children = children;
	}
		
}
