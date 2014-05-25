package com.fallsleep.oa.web.action;

import javax.annotation.Resource;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.annotations.Oper;
import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.model.Company;
import com.fallsleep.oa.model.Party;
import com.fallsleep.oa.service.PartyService;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.vo.PartyTreeVO;
import com.opensymphony.xwork2.ModelDriven;
@Controller("partyAction")
@Scope("prototype")
@Res(name="组织机构操作",sn="party",orderNumber=10)
public class PartyAction extends BaseAction implements ModelDriven{
	@Resource
	protected PartyService partyService;
	protected Party model;
	@Override
	public Object getModel() {
		return null;
	}
	/**
	 * open the department/position setting page
	 * @return
	 */
	@Oper
	public String execute(){
		return "index";
	}
	/**
	 * generate the data of the organization management tree
	 * in the department/position setting page
	 */
	public void tree(){
		Company company = partyService.findCurrentCompany();
		PartyTreeVO partyTreeVO = new PartyTreeVO(company);
		JSONUtils.toJSON(partyTreeVO);
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
		partyService.addParty(model);
		return "add_success";
	}
	@Oper
	public String updateInput(){
		model = partyService.findById(model.getId());
		return "update_input";
	}
	@Oper
	public String update(){
		partyService.updateParty(model);
		return "update_success";
	}
	@Oper
	public String del(){
		partyService.delParty(model.getId());
		return "del_success";
	}
}
