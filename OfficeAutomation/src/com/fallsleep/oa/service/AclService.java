package com.fallsleep.oa.service;

import java.util.List;

import com.fallsleep.oa.model.ACL;
import com.fallsleep.oa.model.Menu;
import com.fallsleep.oa.vo.AuthVO;

public interface AclService {
	/**
	 * 查询或更新ACL列表
	 * @param principalId
	 * @param principalType
	 * @param resourceType
	 * @param authovos
	 */
	public void addOrUpdatePermission(int principalId, String principalType,
			String resourceType, List<AuthVO> acls);

	public List<AuthVO> findAclList(String principalType, int principalId,	String resourceType);

	public List<Menu> findPermitMenus(int userId);

	public boolean hasPermission(int userId, String resourceSn, String operSn);

}
