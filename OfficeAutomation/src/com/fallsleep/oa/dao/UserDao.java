package com.fallsleep.oa.dao;

import java.util.List;

import com.fallsleep.oa.model.User;
import com.fallsleep.oa.vo.PagerVO;

public interface UserDao extends BaseDao{

	public PagerVO findPersonUsers(String sSearch, String sOrder);

	public List findRoleIdsOfUser(int userId);

	public void update(User user, int[] roleIds);

	public List findPersonWithUsers(String sSearch);

	public User findUserByUsername(String username);

	public List findRolesOfUser(int id);

}
