package com.fallsleep.oa.web.action;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.model.Menu;
import com.fallsleep.oa.service.AclService;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.vo.AuthTreeVO;
import com.fallsleep.oa.vo.LoginInfoVO;

@Controller("indexAction")
@Scope("prototype")
public class IndexAction extends BaseAction{
	@Resource
	private AclService aclService;
	
	public void menu(){
		LoginInfoVO user = currentUser();
		List<Menu> menus = aclService.findPermitMenus(user.getId());
		List<AuthTreeVO> vos = new ArrayList<AuthTreeVO>();
		for (Menu menu : menus) {
			vos.add(new AuthTreeVO(menu));
		}
		JSONUtils.toJSON(vos);
	}
	
	public String center(){
		return "center";
	}
	
	public String left(){
		return "left";
	}
	
	public String execute(){
		return "back_index";
	}
}
