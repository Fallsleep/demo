package com.fallsleep.oa.service;

import java.util.List;

import com.fallsleep.oa.model.Role;
import com.fallsleep.oa.vo.PagerVO;

public interface RoleService {
	/**
	 * 查询所有角色
	 * @return
	 */
	public List<Role> findAllRoles();
	/**
	 * 根据条件查询
	 * @param query
	 * @return
	 */
	public PagerVO findAllRoles(String sSearch, String sOrder);
	/**
	 * 添加角色
	 * @param role
	 */
	public void addRole(Role role);
	/**
	 * 更新角色
	 * @param role
	 */
	public void updateRole(Role role);
	/**
	 * 根据roleId删除
	 * @param roleId
	 */
	public void delRole(int roleId);
	/**
	 * 根据roleId查找
	 * @param roleId
	 * @return
	 */
	public Role findById(int roleId);

}
