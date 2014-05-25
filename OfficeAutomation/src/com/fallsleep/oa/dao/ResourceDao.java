package com.fallsleep.oa.dao;

import java.util.List;

import com.fallsleep.oa.model.ActionResource;

public interface ResourceDao extends BaseDao{

	public ActionResource findActionResourceBySn(String sn);

	public List<ActionResource> findAllTopActionResources();
	
	public void update(ActionResource actionResource);

	public List<ActionResource> findAll();

	public ActionResource findActionResourceByClassName(String className);

}
