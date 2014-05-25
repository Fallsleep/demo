package com.fallsleep.oa.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.fallsleep.oa.dao.RoleDao;
import com.fallsleep.oa.dao.UserDao;
import com.fallsleep.oa.model.Role;
import com.fallsleep.oa.model.User;
import com.fallsleep.oa.model.UserRoles;
import com.fallsleep.oa.service.UserService;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.vo.PagerVO;
@Service("userService")
public class UserServiceImpl implements UserService {
	@Resource
	private UserDao userDao;
	@Resource
	private RoleDao roleDao;
	@Override
	public PagerVO findPersonUsers(String sSearch, String sOrder) {
		return userDao.findPersonUsers(sSearch, sOrder);
	}

	@Override
	public void addUser(User user, int[] roleIds) {
		userDao.save(user);
		//建立用户和角色的关联
		if(roleIds != null){
			for(int roleId : roleIds){
				UserRoles ur = new UserRoles();
				ur.setUser(user);
				ur.setRole(roleDao.findById(Role.class, roleId));
				userDao.save(ur);
			}
		}
	}

	@Override
	public void addUser(User user) {
		userDao.save(user);
	}

	@Override
	public void delUser(int id) {
		userDao.del(findUserById(id));
	}

	public User findUserById(int id) {
		return userDao.findById(User.class, id);
	}

	@Override
	public void updateUser(User user, int[] roleIds) {
		userDao.update(user, roleIds);
	}

	@Override
	public void updateUser(User user) {
		userDao.update(user);
	}

	@Override
	public List findRoleIdsOfUser(int userId) {
		return userDao.findRoleIdsOfUser(userId);
	}

	@Override
	public List findPersonWithUsers(String sSearch) {
		return userDao.findPersonWithUsers(sSearch);
	}

	@Override
	public User login(String username, String password) {
		User user = userDao.findUserByUsername(username);
		if(user == null){
			Map map = new HashMap();
			map.put("error", 1);
			JSONUtils.toJSON(map);
			return null;
		}
		if(!password.equals(user.getPassword())){
			Map map = new HashMap();
			map.put("error", 2);
			JSONUtils.toJSON(map);
			return null;
		}
		return user;
	}

	@Override
	public void changePassword(String username, String oldPassword, String password,
			String passwordAgain) {
		User user = userDao.findUserByUsername(username);
		if(user == null){
			throw new RuntimeException("用户[" + username + "]不存在！");
		}
		if(!oldPassword.equals(user.getPassword())){
			throw new RuntimeException("密码错误！");
		}
		if(password.equals(passwordAgain)){
			throw new RuntimeException("两次密码不一致！");
		}
		user.setPassword(password);
		userDao.update(user);
	}

	@Override
	public List findRolesOfUser(int id) {
		return userDao.findRolesOfUser(id);
	}

}
