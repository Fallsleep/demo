package com.fallsleep.oa.web.action;


import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.annotations.Oper;
import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.model.Company;
import com.opensymphony.xwork2.ModelDriven;
@Controller("companyAction")
@Scope("prototype")
@Res(name="公司操作",sn="company",orderNumber=20,parentSn="party")
public class CompanyAction extends PartyAction implements ModelDriven {
	@Override
	public Object getModel() {
		if(model == null){
			model = new Company();
		}
		return model;
	}
	@Oper(name="公司信息维护",sn="saveCompany",index=4)
	public String saveInput(){
		model = partyService.findCurrentCompany();
		return "company_input";
	}
	@Oper(name="公司信息维护",sn="saveCompany",index=4)
	public String save(){
		partyService.saveOrUpdateCompany((Company)model);
		return "save_success";
	}
}
