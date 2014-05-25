package com.fallsleep.oa.dao.impl;

import org.springframework.stereotype.Repository;

import com.fallsleep.oa.dao.PartyDao;
import com.fallsleep.oa.model.Company;
import com.fallsleep.oa.model.Party;
import com.fallsleep.oa.vo.PagerVO;
@Repository("partyDao")
public class PartyDaoImpl extends BaseDaoImpl implements PartyDao {

	@Override
	public PagerVO findAllPartyPaging(String partyName) {
		String hql = "select p from Party p where p.name like ?";
		return findPaging(hql, "%" + partyName + "%");
	}

	@Override
	public Company findCompany() {
		String hql = "select c from Company c where c.parent is null";
		getSession().enableFilter("no_contain_person");
		return (Company) getSession().createQuery(hql).uniqueResult();
	}

	@Override
	public void saveOrUpdate(Company model) {
		getSession().saveOrUpdate(model);		
	}

	@Override
	public PagerVO findPersonsByParentId(int parentid, String sSearch, String sOrder) {
		String hql = "select p.id, p.name, p.sex, p.phone from Person p where p.parent.id = " + parentid;
		if(parentid == 0){
			hql = "select p.id, p.name, p.sex, p.phone from Person p where 1 = 1";
		}
		if(sSearch != null && !"".equals(sSearch)){
			hql += " and (p.name like ? or p.sex like ? or p.phone like ?)";
			sSearch = "%" + sSearch + "%";
			if(sOrder != null && !"".equals(sOrder)){
				hql += sOrder;
			}
			return findPaging(hql, sSearch, sSearch, sSearch);
		}
		if(sOrder != null && !"".equals(sOrder)){
			hql += sOrder;
		}
		return findPaging(hql);
	}
}
