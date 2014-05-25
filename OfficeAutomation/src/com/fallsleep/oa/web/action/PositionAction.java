package com.fallsleep.oa.web.action;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.model.Position;
import com.opensymphony.xwork2.ModelDriven;
@Controller("positionAction")
@Scope("prototype")
@Res(name="岗位操作",sn="poistion",orderNumber=40,parentSn="party")
public class PositionAction extends PartyAction implements ModelDriven{
	@Override
	public Object getModel() {
		if(model == null){
			model = new Position();
		}
		return model;
	}

}
