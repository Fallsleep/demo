package com.fallsleep.oa.service.impl;

import java.lang.reflect.Field;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.fallsleep.oa.dao.PartyDao;
import com.fallsleep.oa.model.Company;
import com.fallsleep.oa.model.Party;
import com.fallsleep.oa.service.PartyService;
import com.fallsleep.oa.vo.PagerVO;
@Service("partyService")
public class PartyServiceImpl implements PartyService {
	@Resource
	private PartyDao partyDao;
	
	@Override
	public void addParty(Party party) {
		partyDao.save(party);
	}

	@Override
	public PagerVO findAllPaging(String partyName) {
		return partyDao.findAllPartyPaging(partyName);
	}

	@Override
	public Company findCurrentCompany() {
		return partyDao.findCompany();
	}

	@Override
	public void saveOrUpdateCompany(Company model) {
		partyDao.saveOrUpdate(model);
	}

	@Override
	public Party findById(int id) {
		return partyDao.findById(Party.class, id);
	}

	@Override
	public void updateParty(Party model) {
		partyDao.update(model);
	}

	@Override
	public void delParty(int id) {
		Party p = findById(id);
		if(p.getChildren().size() > 0){
			throw new RuntimeException("there's child node under this node,can not delete it!");
		}
		partyDao.del(p);
	}

	@Override
	public PagerVO findPersonsByParentId(int parentid, String sSearch, String sOrder) {
		
		return partyDao.findPersonsByParentId(parentid, sSearch, sOrder);
	}

}
