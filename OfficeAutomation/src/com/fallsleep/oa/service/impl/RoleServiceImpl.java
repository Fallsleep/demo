package com.fallsleep.oa.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.fallsleep.oa.dao.RoleDao;
import com.fallsleep.oa.dao.impl.BaseDaoImpl;
import com.fallsleep.oa.model.Role;
import com.fallsleep.oa.service.RoleService;
import com.fallsleep.oa.vo.PagerVO;
@Service("roleService")
public class RoleServiceImpl extends BaseDaoImpl implements RoleService {
	@Resource
	private RoleDao roleDao; 
	@Override
	public List<Role> findAllRoles() {
		return roleDao.findAll(Role.class);
	}

	@Override
	public PagerVO findAllRoles(String sSearch, String sOrder) {
		return roleDao.findAllRoles(sSearch, sOrder);
	}

	@Override
	public void addRole(Role role) {
		roleDao.save(role);
	}

	@Override
	public void updateRole(Role role) {
		roleDao.update(role);
	}

	@Override
	public void delRole(int roleId) {
		roleDao.del(findById(roleId));
	}

	@Override
	public Role findById(int roleId) {
		return roleDao.findById(Role.class, roleId);
	}

}
