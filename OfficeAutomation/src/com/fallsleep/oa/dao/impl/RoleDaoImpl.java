package com.fallsleep.oa.dao.impl;

import org.springframework.stereotype.Repository;

import com.fallsleep.oa.dao.RoleDao;
import com.fallsleep.oa.vo.PagerVO;
@Repository("roleDao")
public class RoleDaoImpl extends BaseDaoImpl implements RoleDao {

	@Override
	public PagerVO findAllRoles(String sSearch, String sOrder) {
		String hql = "select r.id, r.name from Role r";
		if(sSearch != null && !"".equals(sSearch)){
			hql += " where r.name like ?";
			sSearch = "%" + sSearch + "%";
			if(sOrder != null && !"".equals(sOrder)){
				hql += sOrder;
			}
			return findPaging(hql, sSearch);
		}
		if(sOrder != null && !"".equals(sOrder)){
			hql += sOrder;
		}
		return findPaging(hql);
	}

}
