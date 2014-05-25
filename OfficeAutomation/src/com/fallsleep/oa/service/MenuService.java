package com.fallsleep.oa.service;

import java.util.List;

import com.fallsleep.oa.model.Menu;

public interface MenuService {

	public List<Menu> findAllTopMenus();

	public void addMenu(Menu menu);

	public Menu findById(int id);

	public void updateMenu(Menu menu);

	public void delMenu(int id);

	public List<Integer> findAllTopMenuIds();

}
