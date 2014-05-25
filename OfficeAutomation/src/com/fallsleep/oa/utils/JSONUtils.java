package com.fallsleep.oa.utils;

import org.apache.struts2.ServletActionContext;

import com.sdicons.json.mapper.JSONMapper;
import com.sdicons.json.mapper.MapperException;

public class JSONUtils {
	public static void toJSON(Object object){
		try {
			String string = JSONMapper.toJSON(object).render(false);
			ServletActionContext.getResponse().setCharacterEncoding("UTF-8");
			ServletActionContext.getResponse().getWriter().print(string);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
