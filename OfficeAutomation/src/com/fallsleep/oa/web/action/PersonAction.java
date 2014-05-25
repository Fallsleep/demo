package com.fallsleep.oa.web.action;

import java.util.HashMap;
import java.util.Map;

import org.apache.struts2.ServletActionContext;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.model.Person;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.vo.PagerVO;
import com.opensymphony.xwork2.ModelDriven;
@Controller("personAction")
@Scope("prototype")
@Res(name="人员操作",sn="person",orderNumber=50,parentSn="party")
public class PersonAction extends PartyAction implements ModelDriven{
	/**
	 * 搜索框字符串
	 */
	private String sSearch = null;
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
			model = new Person();
		}
		return model;
	}
	/**
	 * 分页查询人员的信息
	 * 根据传来的ID
	 */
	public void list(){
		int parentid = model.getId();
		if(iSortingCols != 0){
			setSOrder();
		}
		PagerVO pagerVO = partyService.findPersonsByParentId(parentid, sSearch, sOrder);
		Map map = new HashMap();
		map.put("aaData", pagerVO.getDatas());
		map.put("iTotalRecords", pagerVO.getTotal());
		map.put("iTotalDisplayRecords", pagerVO.getTotal());
		JSONUtils.toJSON(map);
	}
	
	public void setSOrder(){
		
		String[] columnNames = {"p.id", "p.name", "p.sex", "p.phone"};
		int columnNo;
		sOrder = " order by ";
		for(int i = 0; i < iSortingCols; ++i){
			columnNo = Integer.parseInt(ServletActionContext.getRequest().getParameter("iSortCol_" + i));
			if(columnNo == 1 || columnNo == 2){
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
	
	public void setSSearch(String sSearch) throws Exception {
		this.sSearch = new String(sSearch.getBytes("iso8859_1"), "UTF-8");
	}
	
	public int getISortingCols() {
		return iSortingCols;
	}
	
	public void setISortingCols(int iSortingCols) {
		this.iSortingCols = iSortingCols;
	}
	
	
	public String execute(){
		return "person_list";
	}
}
