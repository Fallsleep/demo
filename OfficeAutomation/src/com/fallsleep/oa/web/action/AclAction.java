package com.fallsleep.oa.web.action;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.fallsleep.oa.model.ACL;
import com.fallsleep.oa.model.ActionMethodOper;
import com.fallsleep.oa.model.ActionResource;
import com.fallsleep.oa.model.Menu;
import com.fallsleep.oa.model.Role;
import com.fallsleep.oa.service.AclService;
import com.fallsleep.oa.service.MenuService;
import com.fallsleep.oa.service.ResourceService;
import com.fallsleep.oa.service.RoleService;
import com.fallsleep.oa.service.UserService;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.vo.AuthVO;
import com.fallsleep.oa.vo.MenuTreeVO;
import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ModelDriven;
@Controller("aclAction")
@Scope("prototype")
public class AclAction extends BaseAction{
	@Resource
	private RoleService roleService;
	@Resource
	private MenuService menuService;
	@Resource
	private AclService aclService;
	@Resource
	private ResourceService resourceService;
	@Resource
	UserService userService;
	
	private String principalType;
	private int principalId;
	private int topMenuId;
	private List<AuthVO> authvos;
	private String sSearch;
	
	public String getPrincipalType() {
		return principalType;
	}
	
	public void setPrincipalType(String principalType) {
		this.principalType = principalType;
	}
	
	public int getPrincipalId() {
		return principalId;
	}
	
	public void setPrincipalId(int principalId) {
		this.principalId = principalId;
	}
	
	public int getTopMenuId() {
		return topMenuId;
	}
	
	public void setTopMenuId(int topMenuId) {
		this.topMenuId = topMenuId;
	}
	
	public List<AuthVO> getAuthvos() {
		return authvos;
	}
	
	public void setAuthvos(List<AuthVO> authvos) {
		this.authvos = authvos;
	}
	
	
	public String getSSearch() {
		return sSearch;
	}
	
	public void setSSearch(String sSearch) throws Exception {
		this.sSearch = new String(sSearch.getBytes("iso8859_1"), "UTF-8");
	}
	/**
	 * 打开角色授权主界面
	 * @return
	 */
	public String roleAuthIndex(){
		return "role_auth_index";
	}
	/**
	 * 显示角色列表树
	 */
	public void roleAuthIndexTree(){
		//查询所有角色
		List<Role> roles = roleService.findAllRoles();
		//建立角色树VO对象
		List roleTreeVos = new ArrayList();
		//为每个角色创建一个VO对象
		for (Role role : roles) {
			Map roleTreeVO = new HashMap();
			roleTreeVO.put("data", role.getName());
			
			Map attr = new  HashMap();
			attr.put("id", role.getId());
			attr.put("principalType", "Role");
			
			roleTreeVO.put("attr", attr);
			roleTreeVos.add(roleTreeVO);
		}
		JSONUtils.toJSON(roleTreeVos);
	}
	/**
	 * 把所有的授权查询出来并显示到菜单树中
	 */
	public void findMenuAcls(){
		List<AuthVO> acls = aclService.findAclList(principalType, principalId, "Menu");
		JSONUtils.toJSON(acls);
	}
	/**
	 * 把所有的授权查询出来并显示到操作表中
	 */
	public void findActionResourceAcls(){
		List<AuthVO> acls = aclService.findAclList(principalType, principalId, "ActionResource");
		JSONUtils.toJSON(acls);
	}
	/**
	 * 打开用户授权主界面
	 * @return
	 */
	public String userAuthIndex(){
		return "user_auth_index";
	}
	/**
	 * 显示用户列表树
	 */
	public void userAuthIndexTree(){
		List persons = userService.findPersonWithUsers(sSearch);
		Map map = new HashMap();
		map.put("aaData", persons);
		JSONUtils.toJSON(map);
	}
	/**
	 * 打开部门|岗位授权主界面
	 * @return
	 */
	public String partyAuthIndex(){
		return "party_auth_index";
	}
	/**
	 * 显示部门|岗位列表树
	 */
	public void partyAuthIndexTree(){
		
	}
	/**
	 * 转向所有菜单授权
	 */
	public String allMenuResource(){
		List<Integer> topMenuIds = menuService.findAllTopMenuIds();
		ActionContext.getContext().put("menuIds", topMenuIds);
		return "all_menu_resource";
	}
	/**
	 * 在菜单主界面上显示所有菜单的树
	 */
	public void allMenuResourceTree(){
		//根据顶级菜单ID查询出顶级菜单
		Menu topMenu = menuService.findById(topMenuId);
		MenuTreeVO mt = new MenuTreeVO(topMenu);
		JSONUtils.toJSON(mt);
	}
	/**
	 * 给菜单授权
	 */
	public void authMenu(){
		aclService.addOrUpdatePermission(principalId, principalType, "Menu", authvos);
	}
	/**
	 * 操作资源授权主界面
	 * @return
	 */
	public String allActionResource(){
		List<ActionResource> res = resourceService.findAllActionResources();
		ActionContext.getContext().put("ress", res);
		return "all_action_resource";
	}
	
	public void authActionResource(){
		aclService.addOrUpdatePermission(principalId, principalType, "ActionResource", authvos);
	}
}
