package com.fallsleep.oa.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.fallsleep.oa.dao.InitDao;
import com.fallsleep.oa.model.ACL;
import com.fallsleep.oa.model.Person;
import com.fallsleep.oa.model.Principal;
import com.fallsleep.oa.model.Role;
import com.fallsleep.oa.model.SysResource;
import com.fallsleep.oa.model.User;
import com.fallsleep.oa.model.UserRoles;
@Repository("initDao")
public class InitDaoImpl extends BaseDaoImpl implements InitDao {

	@Override
	public void addInitAdmin() {
		//将缓存中数据写入数据库
		getSession().flush();
		//清除hibernate缓存中数据，否则查不到子节点
		getSession().clear();
		//添加超级管理员
		Person admin = new Person();
		admin.setName("超级管理员");
		getSession().save(admin);
		
		User adminUser = new User();
		adminUser.setUsername("admin");
		adminUser.setPassword("admin");
		adminUser.setPerson(admin);
		getSession().save(adminUser);
		
		//创建系统管理员角色
		Role adminRole = new Role();
		adminRole.setName("系统管理员");
		getSession().save(adminRole);
		
		//创建普通员工角色
		Role commonRole = new Role();
		commonRole.setName("普通员工");
		getSession().save(commonRole);
		
		UserRoles ur1 = new UserRoles();
		ur1.setRole(adminRole);
		ur1.setUser(adminUser);
		getSession().save(ur1);
		
		UserRoles ur2 = new UserRoles();
		ur2.setRole(commonRole);
		ur2.setUser(adminUser);
		getSession().save(ur2);
		
		//查询：系统管理相关的菜单，安全相关操作，组织机构
		String hql = "select r from com.fallsleep.oa.model.SysResource r where r.sn in ('system', 'security', 'party')";
		List<SysResource> res = getSession().createQuery(hql).list();
		for (SysResource r : res) {
			saveAllPermitAcl(adminRole, r);//把这些资源的所有操作许可赋予管理员角色
			saveAllPermitAcl(adminUser, r);
		}
		//个人办公和工作流授权给普通员工
		hql = "select r from com.fallsleep.oa.model.SysResource r where r.sn in ('personal', 'workflow')";
		res = getSession().createQuery(hql).list();
		for (SysResource r : res) {
			saveAllPermitAcl(commonRole, r);//把这些资源的所有操作许可赋予普通员工角色
		}
	}

	private void saveAllPermitAcl(Principal principal, SysResource r) {
		ACL acl = new ACL();
		acl.setPrincipalType(principal.getPrincipalType());
		acl.setPrincipalId(principal.getPrincipalId());
		acl.setResourceType(r.getResourceType());
		acl.setResourceId(r.getResourceId());
		acl.setAclState(-1);//111……111 32位1的反码
		acl.setAclTriState(0);//授权不继承
		getSession().save(acl);
		
		List<SysResource> children = r.getChildrenResource();
		if(children != null){
			for (SysResource s : children) {
				saveAllPermitAcl(principal, s);
			}
		}
	}

}
