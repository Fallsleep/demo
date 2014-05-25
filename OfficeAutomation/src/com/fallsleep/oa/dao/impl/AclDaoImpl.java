package com.fallsleep.oa.dao.impl;

import java.util.Iterator;
import java.util.List;

import org.springframework.stereotype.Repository;

import com.fallsleep.oa.dao.AclDao;
import com.fallsleep.oa.model.ACL;
import com.fallsleep.oa.model.Principal;
import com.fallsleep.oa.model.SysResource;
@Repository("aclDao")
public class AclDaoImpl extends BaseDaoImpl implements AclDao {

	@Override
	public void delAcls(int principalId, String principalType, String resourceType) {
		String hql = "select a from ACL a where (a.principalId = ? and a.principalType = ? and resourceType = ?)";
		Iterator acls = getSession().createQuery(hql)
											.setParameter(0, principalId)
											.setParameter(1, principalType)
											.setParameter(2, resourceType)
											.iterate();
		while(acls.hasNext()){
			getSession().delete(acls.next());
		}
	}

	@Override
	public ACL findACL(String principalType, int principalId, String resourceType, int resourceId) {
		String hql = "select a from ACL a where (a.principalId = ? and a.principalType = ? and resourceType = ? and resourceId = ?)";
		return (ACL) getSession().createQuery(hql)
				.setParameter(0, principalId)
				.setParameter(1, principalType)
				.setParameter(2, resourceType)
				.setParameter(3, resourceId)
				.uniqueResult();
	}

	@Override
	public List<ACL> findAclList(String principalType, int principalId,
			String resourceType) {
		String hql = "select a from ACL a where (a.principalId = ? and a.principalType = ? and resourceType = ?)";
		return getSession().createQuery(hql)
				.setParameter(0, principalId)
				.setParameter(1, principalType)
				.setParameter(2, resourceType)
				.list();
	}

	@Override
	public List<SysResource> finAllSysResources(String resourceType) {
		String hql = "from " + resourceType;
		return getSession().createQuery(hql).list();
	}

	@Override
	public Principal findPrincipalById(String principalType, int principalId) {
		String hql = "from " + principalType + " p where p.id = ?";
		return (Principal) getSession().createQuery(hql).setParameter(0, principalId).uniqueResult();
	}

	@Override
	public SysResource findSysResourceByResourceSn(String resourceSn) {
		String hql = "select r from com.fallsleep.oa.model.SysResource r where r.sn = ?";
		return (SysResource) getSession().createQuery(hql).setParameter(0, resourceSn).uniqueResult();
	}

}
