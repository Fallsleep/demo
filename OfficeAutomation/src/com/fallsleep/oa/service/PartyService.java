package com.fallsleep.oa.service;

import com.fallsleep.oa.model.Company;
import com.fallsleep.oa.model.Party;
import com.fallsleep.oa.vo.PagerVO;

public interface PartyService {
	public void addParty(Party party);
	public PagerVO findAllPaging(String partyName);
	public Company findCurrentCompany();
	public void saveOrUpdateCompany(Company company);
	public Party findById(int id);
	public void updateParty(Party party);
	public void delParty(int id);
	public PagerVO findPersonsByParentId(int parentid, String sSearch, String sOrder);
}
