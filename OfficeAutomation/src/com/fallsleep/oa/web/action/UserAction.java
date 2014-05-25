package com.fallsleep.oa.web.action;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.struts2.ServletActionContext;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import sun.misc.BASE64Decoder;

import com.fallsleep.oa.annotations.Oper;
import com.fallsleep.oa.annotations.Res;
import com.fallsleep.oa.model.Role;
import com.fallsleep.oa.model.User;
import com.fallsleep.oa.service.RoleService;
import com.fallsleep.oa.service.UserService;
import com.fallsleep.oa.utils.JSONUtils;
import com.fallsleep.oa.utils.UUIDUtils;
import com.fallsleep.oa.vo.LoginInfoVO;
import com.fallsleep.oa.vo.PagerVO;
import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ModelDriven;
@Controller("userAction")
@Scope("prototype")
@Res(name="用户操作",sn="user",orderNumber=70,parentSn="security")
public class UserAction extends BaseAction implements ModelDriven{
	private User model;
	private String newPassword;
	private String passwordAgain;
	private String oldPassword;
	private String uploadAvatar;
	@Resource
	private UserService userService;
	@Resource
	private RoleService roleService;
	private int[] roleIds;
	/**
	 * 搜索框字符串
	 */
	private String sSearch = null;
	/**
	 * 排序的列数
	 */
	private int	iSortingCols;
	/**
	 * 生成的排序字符串
	 */
	private String sOrder = null;
	@Override
	public Object getModel() {
		if(model == null){
			model = new User();
		}
		return model;
	}
	/**
	 * 分页查询人员的信息
	 * 根据传来的ID
	 */
	public void list(){
		if(iSortingCols != 0){
			setSOrder();
		}
		PagerVO pagerVO = userService.findPersonUsers(sSearch, sOrder);
		Map map = new HashMap();
		map.put("aaData", pagerVO.getDatas());
		map.put("iTotalRecords", pagerVO.getTotal());
		map.put("iTotalDisplayRecords", pagerVO.getTotal());
		JSONUtils.toJSON(map);
	}
	
	public int[] getRoleIds() {
		return roleIds;
	}
	public void setRoleIds(int[] roleIds) {
		this.roleIds = roleIds;
	}
	public void setSOrder(){		
		String[] columnNames = {"p.id", "p.name", "pt.name", "u.username"};
		int columnNo;
		sOrder = " order by ";
		for(int i = 0; i < iSortingCols; ++i){
			columnNo = Integer.parseInt(ServletActionContext.getRequest().getParameter("iSortCol_" + i));
			if(columnNo != 0){
				sOrder += "convert(" + columnNames[columnNo] + ", gbk)";
			}
			else{
				sOrder += columnNames[columnNo];
			}
			sOrder += " " +	ServletActionContext.getRequest().getParameter("sSortDir_" + i) + ",";
		}
		sOrder = sOrder.substring(0, sOrder.length() - 1);
	}
	
	public String getSSearch() {
		return sSearch;
	}
	
	public void setSSearch(String sSearch) throws Exception {
		this.sSearch = new String(sSearch.getBytes("iso8859_1"), "UTF-8");
	}
	
	public int getISortingCols() {
		return iSortingCols;
	}
	
	public void setISortingCols(int iSortingCols) {
		this.iSortingCols = iSortingCols;
	}
	
	@Oper
	public String execute(){
		return "index";
	}
	@Oper
	public String addInput(){
		List<Role> roles = roleService.findAllRoles();
		ActionContext.getContext().put("roles", roles);
		return "add_input";
	}
	@Oper
	public String add(){
		userService.addUser(model, roleIds);
		return "add_success";//如果想减少传输的数据，可以直接返回index以达到刷新页面的效果
	}
	@Oper
	public String updateInput(){
		model = userService.findUserById(model.getId());
		//查询所有角色
		List<Role> roles = roleService.findAllRoles();
		ActionContext.getContext().put("roles", roles);
		//查询当前用户已经被赋予的角色的ID集合
		List selectedRoles = userService.findRoleIdsOfUser(model.getId());
		ActionContext.getContext().put("selectedRoles", selectedRoles);
		return "update_input";
	}
	//判断roleId是否已是用户角色，如果是返回selected
	public String hasSelected(int roleId, List<Integer> selectedRoles){
		if(selectedRoles == null){
			return "";
		}
		for (Integer i : selectedRoles) {
			if(i.equals(roleId)){
				return "selected";
			}
		}
		return "";
	}
	@Oper
	public String update(){
		userService.updateUser(model, roleIds);
		return "update_success";
	}
	@Oper
	public void del(){
		userService.delUser(model.getId());
	}
	

	public String passwordInput(){
		return "password_input";
	}
	
	public String changePassword(){
		LoginInfoVO currentUser = currentUser();
		userService.changePassword(currentUser.getUsername(), oldPassword, newPassword, passwordAgain);
		return "update_success";
	}
	
	public String avatarInput(){
		return "avatar_input";
	}
	
	public void uploadAvatar(){
		LoginInfoVO currentUser = currentUser();
		model = userService.findUserById(currentUser.getId());
		String fileName = model.getAvatar();
		File file, oldFile = null;
		String realpath = ServletActionContext.getServletContext().getRealPath("");
		if( fileName == null || "".equals(fileName)){
			File folder = new File(realpath + "/upload/" + currentUser.getId());
			if(!folder.isDirectory()){
				folder.mkdirs();
			}
		}else {
			oldFile = new File(realpath + "/" + fileName);
		}
		fileName = UUIDUtils.getUUID() + ".jpg";
		file = new File(realpath + "/upload/" + currentUser.getId() + "/" + fileName);
		try {
			if(!file.exists()){
				file.createNewFile();
			}
			
			sun.misc.BASE64Decoder decoder = new BASE64Decoder();
			byte[] buff = decoder.decodeBuffer(uploadAvatar.substring(uploadAvatar.indexOf(",") + 1));
			for(int i = 0; i < buff.length; ++i){
				if(buff[i] < 0){
					buff[i] += 256;
				}
			}
			FileOutputStream fos = new FileOutputStream(file);
			fos.write(buff);
			fos.close();
			model.setAvatar("/upload/"+currentUser.getId()+"/"+file.getName());
			userService.updateUser(model);
			
			if(oldFile != null){
				oldFile.delete();
			}
		} catch (Exception e) {
			throw new RuntimeException(e.getMessage());
		}
	}
	
	public String userInfoInput(){
		LoginInfoVO currentUser = currentUser();
		model = userService.findUserById(currentUser.getId());
		//查询当前用户已经被赋予的角色的集合
		List roles = userService.findRolesOfUser(model.getId());
		
		ActionContext.getContext().put("roles", roles);
		currentUser.setName(model.getPerson().getName());
		currentUser.setIp(ServletActionContext.getRequest().getRemoteHost());
		currentUser.setAvatar(model.getAvatar());
		
		return "user_info_input";
	}
	
	public String getPasswordAgain() {
		return passwordAgain;
	}
	public void setPasswordAgain(String passwordAgain) {
		this.passwordAgain = passwordAgain;
	}
	public String getOldPassword() {
		return oldPassword;
	}
	public void setOldPassword(String oldPassword) {
		this.oldPassword = oldPassword;
	}
	public String getNewPassword() {
		return newPassword;
	}
	public void setNewPassword(String newPassword) {
		this.newPassword = newPassword;
	}
	public String getUploadAvatar() {
		return uploadAvatar;
	}
	public void setUploadAvatar(String uploadAvatar) {
		this.uploadAvatar = uploadAvatar;
	}
	
}
