package com.fallsleep.oa.web.action;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.annotations.Oper;
import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.model.Menu;
import com.fallsleep.oa.service.MenuService;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.vo.MenuTreeVO;
import com.fallsleep.oa.vo.PartyTreeVO;
import com.opensymphony.xwork2.ModelDriven;
@Controller("menuAction")
@Scope("prototype")
@Res(name="菜单操作",sn="menu",orderNumber=90,parentSn="security")
public class MenuAction extends BaseAction implements ModelDriven{
	@Resource
	protected MenuService menuService;
	protected Menu model;
	@Override
	public Object getModel() {
		if(model == null){
			model = new Menu();
		}
		return model;
	}
	/**
	 * generate the data of the menu tree
	 * in the menu config page
	 */
	public void tree(){
		//查询所有顶级
		List<Menu> menus = menuService.findAllTopMenus();
		List<MenuTreeVO> menuTreeVOs = new ArrayList<MenuTreeVO>();
		for (Menu menu : menus) {
			menuTreeVOs.add(new MenuTreeVO(menu));
		}
		JSONUtils.toJSON(menuTreeVOs);
	}
	/**
	 * open menu config page
	 * @return
	 */
	@Oper
	public String execute(){
		return "index";
	}
	@Oper
	public String addInput(){
		int parentId = model.getParent().getId();
		if(parentId == 0){
			throw new RuntimeException("unknown parent node,can't create child node!");
		}
		return "add_input";
	}
	@Oper
	public String add(){
		menuService.addMenu(model);
		return "add_success";
	}
	@Oper
	public String updateInput(){
		model = menuService.findById(model.getId());
		return "update_input";
	}
	@Oper
	public String update(){
		menuService.updateMenu(model);
		return "update_success";
	}
	@Oper
	public String del(){
		menuService.delMenu(model.getId());
		return "del_success";
	}
}
