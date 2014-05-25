package com.fallsleep.oa.dao;

import java.util.List;

import com.fallsleep.oa.model.Menu;

public interface MenuDao extends BaseDao{

	public List<Menu> findAllTopMenus();

	public List<Integer> findAllTopMenuIds();

}
