package com.fallsleep.oa.model;

import java.util.List;

public class Role implements Principal {
	private int id;
	private String name;
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
	@Override
	public int getPrincipalId() {
		return id;
	}
	@Override
	public String getPrincipalType() {
		return "Role";
	}
	@Override
	public List<Principal> getParentPrincipal() {
		return null;
	}
}
