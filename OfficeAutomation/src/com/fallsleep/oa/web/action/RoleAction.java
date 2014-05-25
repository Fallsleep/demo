package com.fallsleep.oa.web.action;

import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.struts2.ServletActionContext;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.annotations.Oper;
import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.model.Role;
import com.fallsleep.oa.service.RoleService;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.vo.PagerVO;
import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ModelDriven;
@Controller("roleAction")
@Scope("prototype")
@Res(name="角色操作",sn="role",orderNumber=80,parentSn="security")
public class RoleAction extends BaseAction implements ModelDriven{
	private Role model;
	@Resource
	private RoleService roleService;
	/**
	 * 搜索框字符串
	 */
	private String sSearch;
	/**
	 * 排序的列数
	 */
	private int	iSortingCols;
	/**
	 * 生成的排序字符串
	 */
	private String sOrder = null;
	@Override
	public Object getModel() {
		if(model == null){
			model = new Role();
		}
		return model;
	}
	/**
	 * 分页查询人员的信息
	 * 根据传来的ID
	 */
	public void list(){
		if(iSortingCols != 0){
			setSOrder();
		}
		PagerVO pagerVO = roleService.findAllRoles(sSearch, sOrder);
		Map map = new HashMap();
		map.put("aaData", pagerVO.getDatas());
		map.put("iTotalRecords", pagerVO.getTotal());
		map.put("iTotalDisplayRecords", pagerVO.getTotal());
		JSONUtils.toJSON(map);
	}
	
	public void setSOrder(){		
		String[] columnNames = {"r.id", "r.name"};
		int columnNo;
		sOrder = " order by ";
		for(int i = 0; i < iSortingCols; ++i){
			columnNo = Integer.parseInt(ServletActionContext.getRequest().getParameter("iSortCol_" + i));
			if(columnNo != 0){
				sOrder += "convert(" + columnNames[columnNo] + ", gbk)";
			}
			else{
				sOrder += columnNames[columnNo];
			}
			sOrder += " " +	ServletActionContext.getRequest().getParameter("sSortDir_" + i) + ",";
		}
		sOrder = sOrder.substring(0, sOrder.length() - 1);
	}
	
	public String getSSearch() {
		return sSearch;
	}
	
	public void setSSearch(String sSearch) throws UnsupportedEncodingException {
		this.sSearch = new String(sSearch.getBytes("iso8859_1"), "UTF-8");
	}
	
	public int getISortingCols() {
		return iSortingCols;
	}
	
	public void setISortingCols(int iSortingCols) {
		this.iSortingCols = iSortingCols;
	}
	
	@Oper
	public String execute(){
		return "index";
	}
	@Oper
	public String addInput(){
		List<Role> roles = roleService.findAllRoles();
		ActionContext.getContext().put("roles", roles);
		return "add_input";
	}
	@Oper
	public String add(){
		roleService.addRole(model);
		return "index";
	}
	@Oper
	public String updateInput(){
		model = roleService.findById(model.getId());
		return "update_input";
	}
	@Oper
	public String update(){
		roleService.updateRole(model);
		return "index";
	}
	@Oper
	public void del(){
		roleService.delRole(model.getId());
	}
}
