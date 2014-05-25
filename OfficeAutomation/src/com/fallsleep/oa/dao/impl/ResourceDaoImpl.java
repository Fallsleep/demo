package com.fallsleep.oa.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.fallsleep.oa.dao.ResourceDao;
import com.fallsleep.oa.model.ActionResource;
@Repository("resourceDao")
public class ResourceDaoImpl extends BaseDaoImpl implements ResourceDao {

	@Override
	public ActionResource findActionResourceBySn(String sn) {
		String hql = "select ar from ActionResource ar where ar.sn = ?";
		return (ActionResource) getSession().createQuery(hql).setParameter(0, sn).uniqueResult();
	}

	@Override
	public List<ActionResource> findAllTopActionResources() {
		String hql = "select ar from ActionResource ar where ar.parent is null order by ar.orderNumber";
		return (List<ActionResource>) getSession().createQuery(hql).list();
	}

	@Override
	public void update(ActionResource actionResource) {
		ActionResource old = (ActionResource) getSession().load(ActionResource.class, actionResource.getId());
		actionResource.setOpers(old.getOpers());
		//将actionResource与old中不一样的数据复制到old中，并更新，不能用update，因为内存中有两个ID相同的对象
		getSession().merge(actionResource);
	}

	@Override
	public List<ActionResource> findAll() {
		String hql = "select ar from ActionResource ar order by ar.orderNumber";
		return (List<ActionResource>) getSession().createQuery(hql).list();
	}

	@Override
	public ActionResource findActionResourceByClassName(String className) {
		String hql = "select ar from ActionResource ar where ar.className like ?";
		return (ActionResource) getSession().createQuery(hql).setParameter(0, "%"+ className +"%").uniqueResult();
	}

}
