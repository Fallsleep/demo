package com.fallsleep.oa.service.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.fallsleep.oa.dao.AclDao;
import com.fallsleep.oa.dao.MenuDao;
import com.fallsleep.oa.dao.UserDao;
import com.fallsleep.oa.model.ACL;
import com.fallsleep.oa.model.ActionMethodOper;
import com.fallsleep.oa.model.Menu;
import com.fallsleep.oa.model.Principal;
import com.fallsleep.oa.model.SysResource;
import com.fallsleep.oa.model.User;
import com.fallsleep.oa.service.AclService;
import com.fallsleep.oa.vo.AuthVO;
@Service("aclService")
public class AclServiceImpl implements AclService {
	@Resource
	private AclDao aclDao;
	@Resource
	private MenuDao menuDao;
	@Resource
	private UserDao	userDao;
	@Override
	public void addOrUpdatePermission(int principalId, String principalType,
			String resourceType, List<AuthVO> acls) {
		//先删除当前主体及资源类型的所有ACL记录
		aclDao.delAcls(principalId, principalType, resourceType);
		//创建ACL对象
		if(acls != null){
			for (AuthVO auth : acls) {
				int resourceId = auth.getResourceId();
				int operIndex = auth.getOperIndex();
				boolean permit = auth.isPermit();
				boolean ext = auth.isExt();
				
				ACL acl = aclDao.findACL(principalType, principalId, resourceType, resourceId);
				if(acl == null){
					acl = new ACL();
					acl.setPrincipalId(principalId);
					acl.setPrincipalType(principalType);
					acl.setResourceId(resourceId);
					acl.setResourceType(resourceType);
					acl.setPermission(operIndex, permit, ext);
					aclDao.save(acl);
				}else{
					acl.setPermission(operIndex, permit, ext);
					aclDao.update(acl);
				}
			}
		}
	}
	@Override
	public List<AuthVO> findAclList(String principalType, int principalId,	String resourceType) {
		List<AuthVO> vos = new ArrayList<AuthVO>();
		
		//查询出指定类型的所有资源
		List<SysResource> resources = aclDao.finAllSysResources(resourceType);
		//针对每个资源
		for (SysResource r : resources) {
			//取出操作索引
			int[] opers = r.getOperIndexs();
			if(opers != null){
				for (int operIndex : opers) {
					AuthVO vo = searchAcl(principalType, principalId, resourceType, r.getResourceId(), operIndex);
					if(vo != null){
						vos.add(vo);
					}
				}
			}
		}
		return vos;
	}
	private AuthVO searchAcl(String principalType, int principalId,
			String resourceType, int resourceId, int operIndex) {
		ACL acl = aclDao.findACL(principalType, principalId, resourceType, resourceId);
		AuthVO vo = null;
		if(acl != null && !acl.isExt(operIndex)){
			vo = new AuthVO();
			vo.setResourceId(resourceId);
			vo.setOperIndex(operIndex);
			vo.setPermit(acl.isPermit(operIndex));
			vo.setExt(acl.isExt(operIndex));
			return vo;
		}
		//如果没有找到授权，则判断父主体是否存在
		Principal principal = aclDao.findPrincipalById(principalType, principalId);
		List<Principal> parents = principal.getParentPrincipal();
		if(parents != null){
			for (Principal p : parents) {
				AuthVO pvo = searchAcl(p.getPrincipalType(), p.getPrincipalId(), resourceType, resourceId, operIndex);
				if(pvo != null){
					vo = new AuthVO();
					vo.setResourceId(resourceId);
					vo.setOperIndex(operIndex);
					vo.setPermit(pvo.isPermit());
					vo.setExt(true);
					//return vo;
				}
			}
		}
		return vo;
	}
	@Override
	public List<Menu> findPermitMenus(int userId) {
		List<Menu> topMenus = menuDao.findAllTopMenus();
		//删除当前用户没有许可的菜单
		removDenyMenus(topMenus, userId);
		return topMenus;
	}
	
	private void removDenyMenus(Collection<Menu> menus, int userId) {
		for (Iterator<Menu> iter = menus.iterator(); iter.hasNext();) {
			Menu menu = iter.next();
			AuthVO vo = searchAcl("User", userId, "Menu", menu.getId(), menu.getOperIndexs()[0]);
			if(vo == null || !vo.isPermit()){
				iter.remove();
			}
			else{
				removDenyMenus(menu.getChildren(), userId);
			}
		}
	}
	@Override
	public boolean hasPermission(int userId, String resourceSn, String operSn) {
		//查找用户
		User user = userDao.findById(User.class, userId);
		//根据资源标识查找资源（包括菜单、action等资源）
		SysResource resource = aclDao.findSysResourceByResourceSn(resourceSn);
		//根据operSn取出资源操作索引
		int operIndex = resource.getOperIndexByOperSn(operSn);
		
		AuthVO vo = searchAcl(user.getPrincipalType(), user.getPrincipalId(),
				resource.getResourceType(), resource.getResourceId(), operIndex);
		if(vo != null && vo.isPermit()){
			return true;
		}
		return false;
	}

}
