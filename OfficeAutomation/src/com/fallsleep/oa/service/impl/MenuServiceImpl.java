package com.fallsleep.oa.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.fallsleep.oa.dao.MenuDao;
import com.fallsleep.oa.model.Menu;
import com.fallsleep.oa.service.MenuService;
@Service("menuService")
public class MenuServiceImpl implements MenuService{
	@Resource
	MenuDao menuDao;
	@Override
	public List<Menu> findAllTopMenus() {
		return menuDao.findAllTopMenus();
	}

	@Override
	public void addMenu(Menu menu) {
		menuDao.save(menu);
	}

	@Override
	public Menu findById(int id) {
		return menuDao.findById(Menu.class, id);
	}

	@Override
	public void updateMenu(Menu menu) {
		menuDao.update(menu);
	}

	@Override
	public void delMenu(int id) {
		menuDao.del(findById(id));
	}

	@Override
	public List<Integer> findAllTopMenuIds() {
		return menuDao.findAllTopMenuIds();
	}

}
