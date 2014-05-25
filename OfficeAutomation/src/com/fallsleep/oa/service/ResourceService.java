package com.fallsleep.oa.service;

import java.util.List;

import com.fallsleep.oa.model.ActionMethodOper;
import com.fallsleep.oa.model.ActionResource;

public interface ResourceService {
	/**
	 * 重建ActionResource对象
	 */
	public void rebuildActionResource();
	/**
	 * 查询顶级ActionResource对象
	 * @return
	 */
	public List<ActionResource> findAllTopActionResources();
	/**
	 * 添加ActionResource对象
	 * @param actionResource
	 */
	public void addActionResource(ActionResource actionResource);
	/**
	 * 根据ID查询
	 * @param id
	 * @return
	 */
	public ActionResource findById(int id);
	/**
	 * 更新ActionResource对象
	 * @param actionResource
	 */
	public void updateActionResource(ActionResource actionResource);
	/**
	 * 删除ActionResource对象
	 * @param id
	 */
	public void delActionResource(int id);
	/**
	 * 给标识为ID参数的ActionResource对象添加操作
	 * @param id
	 * @param oper
	 */
	public void addActionResourceOper(int id, ActionMethodOper oper);
	/**
	 * 删除标识为ID的ActionResource对象的ActionMethodOper操作
	 * @param id
	 * @param operSn
	 */
	public void delActionResourceOper(int id, String operSn);
	/**
	 * 查找所有ActionResource资源
	 * @return
	 */
	public List<ActionResource> findAllActionResources();
	public ActionResource findActionResourceByClassName(String className);
}
