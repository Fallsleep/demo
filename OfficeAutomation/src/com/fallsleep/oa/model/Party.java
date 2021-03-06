﻿package com.fallsleep.oa.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class Party implements Principal{
	private int id;
	private String name;
	private String description;
	private Party parent;
	private Set<Party> children;
	private String sn;
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public Party getParent() {
		return parent;
	}
	public void setParent(Party parent) {
		this.parent = parent;
	}
	public Set<Party> getChildren() {
		return children;
	}
	public void setChildren(Set<Party> children) {
		this.children = children;
	}
	public String getSn() {
		return sn;
	}
	public void setSn(String sn) {
		this.sn = sn;
	}
	@Override
	public int getPrincipalId() {
		return id;
	}
	@Override
	public String getPrincipalType() {
		return "Party";
	}
	@Override
	public List<Principal> getParentPrincipal() {
		List<Principal> parents = new ArrayList<Principal>();
		if(parent != null){
			parents.add(parent);
		}
		return parents;
	}
}
