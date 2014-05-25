package com.fallsleep.oa.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.fallsleep.oa.dao.UserDao;
import com.fallsleep.oa.model.Role;
import com.fallsleep.oa.model.User;
import com.fallsleep.oa.model.UserRoles;
import com.fallsleep.oa.vo.PagerVO;
@Repository("userDao")
public class UserDaoImpl extends BaseDaoImpl implements UserDao {

	@Override
	public PagerVO findPersonUsers(String sSearch, String sOrder) {
		String hql = "select p.id, p.name, pt.name, u.username from Person p left join p.parent pt left join p.user u";
		if(sSearch != null && !"".equals(sSearch)){
			hql += " where (p.name like ? or pt.name like ? or u.username like ?)";
			sSearch = "%" + sSearch + "%";
			if(sOrder != null && !"".equals(sOrder)){
				hql += sOrder;
			}
			return findPaging(hql, sSearch, sSearch, sSearch);
		}
		if(sOrder != null && !"".equals(sOrder)){
			hql += sOrder;
		}
		return findPaging(hql);
	}

	@Override
	public List findRoleIdsOfUser(int userId) {
		String hql = "select r.id from UserRoles ur join ur.user u join ur.role r where u.id = ?";
		return getSession().createQuery(hql).setParameter(0, userId).list();
	}

	@Override
	public void update(User user, int[] roleIds) {
		getSession().update(user);
		
		String hql = "select ur from UserRoles ur left join ur.user u where u.id = ?";
		List<UserRoles> urs = getSession().createQuery(hql)
				.setParameter(0, user.getId()).list();
		for (UserRoles ur : urs) {
			getSession().delete(ur);
		}
		//建立用户和角色之间新的关联
		if(roleIds != null){
			for(int roleId : roleIds){
				UserRoles ur = new UserRoles();
				ur.setUser(user);
				ur.setRole(findById(Role.class, roleId));
				getSession().save(ur);
			}
		}
	}

	@Override
	public List findPersonWithUsers(String sSearch) {
		String hql = "select p.id, p.name from Person p join p.user u";
		if(sSearch == null){
			sSearch = "";
		}
		hql += " where (p.name like ?)";
		sSearch = "%" + sSearch + "%";
		return getSession().createQuery(hql).setParameter(0, sSearch).list();
	}

	@Override
	public User findUserByUsername(String username) {
		String hql = "select u from User u where u.username = ?";
		return (User) getSession().createQuery(hql).setParameter(0, username).uniqueResult();
	}

	@Override
	public List findRolesOfUser(int userId) {
		String hql = "select r from UserRoles ur join ur.user u join ur.role r where u.id = ?";
		return getSession().createQuery(hql).setParameter(0, userId).list();
	}

}
