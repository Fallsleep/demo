package com.fallsleep.oa.jsontools;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class Node {
	private Map data = new HashMap();
	private Map attr = new HashMap();
	private Set<Node> children;
	
	public Node(Map data) {
		this.data = data;
	}
	public Node(Map data, int id) {
		this.data = data;
		this.attr.put("id", id);
	}
	public Node(Map data, Map attr) {
		this.data = data;
		this.attr.putAll(attr);
	}
	public void addChildNode(Node child){
		if(children == null){
			children = new HashSet<Node>();
		}
		children.add(child);
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
	public Set<Node> getChildren() {
		return children;
	}
	public void setChildren(Set<Node> children) {
		this.children = children;
	}
}
