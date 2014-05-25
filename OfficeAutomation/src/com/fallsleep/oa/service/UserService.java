package com.fallsleep.oa.service;

import java.util.List;

import com.fallsleep.oa.model.User;
import com.fallsleep.oa.vo.PagerVO;

public interface UserService {

	public PagerVO findPersonUsers(String sSearch, String sOrder);

	public void addUser(User user, int[] roleIds);
	
	public void addUser(User user);

	public void delUser(int id);

	public User findUserById(int id);

	public void updateUser(User user, int[] roleIds);
	
	public void updateUser(User user);

	public List findRoleIdsOfUser(int userId);

	public List findPersonWithUsers(String sSearch);

	public User login(String username, String password);

	public void changePassword(String username, String oldPassword, String password,
			String passwordAgain);

	public List findRolesOfUser(int id);

}
