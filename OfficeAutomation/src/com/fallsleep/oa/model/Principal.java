package com.fallsleep.oa.model;

import java.util.List;

public interface Principal {
	public int getPrincipalId();
	public String getPrincipalType();
	public List<Principal> getParentPrincipal();
}
