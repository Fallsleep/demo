package com.fallsleep.oa.dao;

import com.fallsleep.oa.model.Company;
import com.fallsleep.oa.model.Party;
import com.fallsleep.oa.vo.PagerVO;

public interface PartyDao extends BaseDao{
	public PagerVO findAllPartyPaging(String partyName);
	public Company findCompany();
	public void saveOrUpdate(Company model);
	public PagerVO findPersonsByParentId(int parentid, String sSearch, String sOrder);
}
