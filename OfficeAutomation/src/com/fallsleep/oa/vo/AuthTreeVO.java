package com.fallsleep.oa.vo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.fallsleep.oa.model.Menu;

public class AuthTreeVO {
	private Map data = new HashMap();
	private Map attr = new HashMap();
	private List<AuthTreeVO> children = null;
	
	public AuthTreeVO(Menu menu) {
		this.data.put("title", menu.getName());
		Map linkAttr = new HashMap();
		linkAttr.put("href", menu.getHref());
		this.data.put("attr", linkAttr);
		this.attr.put("id", menu.getId());
		
		Set<Menu> children = menu.getChildren();
		if(children != null && children.size() > 0){
			this.children = new ArrayList<AuthTreeVO>();
			for (Menu m : children) {
				this.children.add(new AuthTreeVO(m));
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
	public List<AuthTreeVO> getChildren() {
		return children;
	}
	public void setChildren(List<AuthTreeVO> children) {
		this.children = children;
	}
		
}
