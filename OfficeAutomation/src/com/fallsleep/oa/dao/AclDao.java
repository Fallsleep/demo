package com.fallsleep.oa.dao;

import java.util.List;

import com.fallsleep.oa.model.ACL;
import com.fallsleep.oa.model.Principal;
import com.fallsleep.oa.model.SysResource;

public interface AclDao extends BaseDao {
	/**
	 * 删除指定主体及资源类型的所有ACL记录
	 * @param principalId
	 * @param principalType
	 * @param resourceType
	 */
	public void delAcls(int principalId, String principalType, String resourceType);

	public ACL findACL(String principalType, int principalId,
			String resourceType, int resourceId);

	public List<ACL> findAclList(String principalType, int principalId,
			String resourceType);

	public List<SysResource> finAllSysResources(String resourceType);

	public Principal findPrincipalById(String principalType, int principalId);

	public SysResource findSysResourceByResourceSn(String resourceSn);

}
